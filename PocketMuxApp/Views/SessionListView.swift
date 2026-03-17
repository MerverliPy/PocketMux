import SwiftUI

/// Root view when connected. Shows the top-tab session strip and the active terminal.
struct SessionListView: View {
    @EnvironmentObject var connectionManager: SSHConnectionManager
    @StateObject private var viewModel = SessionListViewModel()
    @State private var selectedSessionID: String?
    @State private var newSessionName = ""
    @State private var showingNewSession = false
    @State private var showingErrorAlert = false

    var body: some View {
        VStack(spacing: 0) {
            sessionStrip
            Divider()
            terminalArea
        }
        .task { await viewModel.load(using: connectionManager) }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            showingErrorAlert = (newValue != nil)
        }
        .alert("New Session", isPresented: $showingNewSession) {
            TextField("Session name", text: $newSessionName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Create") { createSession() }
            Button("Cancel", role: .cancel) { newSessionName = "" }
        }
        .alert("Session Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown session error.")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Disconnect") {
                    Task { await connectionManager.disconnect() }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var sessionStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.sessions) { session in
                    SessionTab(
                        session: session,
                        isSelected: selectedSessionID == session.id
                    ) {
                        selectedSessionID = session.id
                    }
                }
                Button {
                    showingNewSession = true
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }

    private var terminalArea: some View {
        Group {
            if let id = selectedSessionID {
                TerminalView(sessionName: id)
                    .overlay(alignment: .bottom) {
                        if connectionManager.state == .reconnecting {
                            ReconnectOverlayView()
                                .padding(.bottom, 24)
                        }
                    }
            } else {
                ContentUnavailableView(
                    "No Session Selected",
                    systemImage: "terminal",
                    description: Text("Tap + to open or create a remote session.")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func createSession() {
        let name = newSessionName.trimmingCharacters(in: .whitespaces)
        newSessionName = ""
        guard !name.isEmpty else { return }
        Task {
            await viewModel.createAndSelect(name: name, using: connectionManager)
            if viewModel.sessions.contains(where: { $0.id == name }) {
                selectedSessionID = name
            }
        }
    }
}

// MARK: - Session tab button

private struct SessionTab: View {
    let session: SessionRecord
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(session.displayName)
                .font(.subheadline)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.accentColor : Color(.systemFill),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ViewModel

@MainActor
final class SessionListViewModel: ObservableObject {
    @Published var sessions: [SessionRecord] = []
    @Published var errorMessage: String?

    func load(using manager: SSHConnectionManager) async {
        let sm = SessionManager(connectionManager: manager)
        do {
            sessions = try await sm.listSessions()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load tmux sessions: \(String(describing: error))"
        }
    }

    func createAndSelect(name: String, using manager: SSHConnectionManager) async {
        let sm = SessionManager(connectionManager: manager)
        do {
            try await sm.ensureSessionExists(sessionName: name)
            await load(using: manager)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to create tmux session: \(String(describing: error))"
        }
    }
}
