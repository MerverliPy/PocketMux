import SwiftUI

/// Real terminal screen container for a named remote tmux session.
///
/// Owns the TerminalSessionService lifecycle, observes attachment state,
/// and hosts the TerminalRendererView. Replaces the former TerminalView stub.
///
/// Call site: `TerminalView(sessionName: id)` — preserved via typealias in TerminalView.swift.
struct TerminalContainerView: View {
    let sessionName: String

    @StateObject private var service: TerminalSessionService
    @EnvironmentObject private var connectionManager: SSHConnectionManager
    @State private var inputText: String = ""

    init(sessionName: String) {
        self.sessionName = sessionName
        _service = StateObject(wrappedValue: TerminalSessionService(sessionName: sessionName))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch service.state {
            case .idle, .connecting:
                connectingIndicator
            case .attached:
                VStack(spacing: 0) {
                    TerminalRendererView(outputBuffer: service.outputBuffer)
                        .ignoresSafeArea(edges: .bottom)
                    inputBar
                }
            case .failed(let message):
                failureView(message: message)
            }
        }
        .task { await service.attach(using: connectionManager) }
        .onDisappear { Task { await service.detach() } }
    }

    // MARK: - Subviews

    private var connectingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.green)
            Text("Attaching to \(sessionName)…")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.green.opacity(0.7))
        }
    }

    /// Minimal keyboard input bar shown while attached.
    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Input", text: $inputText)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.green)
                .tint(.green)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit { submitInput() }
            Button(action: submitInput) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black)
        .overlay(alignment: .top) {
            Divider().overlay(Color.green.opacity(0.3))
        }
    }

    private func submitInput() {
        guard !inputText.isEmpty else { return }
        // Send text + carriage return as expected by the terminal
        let raw = inputText + "\r"
        service.send(Data(raw.utf8))
        inputText = ""
    }

    private func failureView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(.red)
            Text("Failed to attach")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.white)
            Text(message)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.red.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                Task { await service.attach(using: connectionManager) }
            }
            .buttonStyle(.bordered)
            .tint(.green)
        }
    }
}
