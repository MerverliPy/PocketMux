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
                TerminalRendererView(outputBuffer: service.outputBuffer)
                    .ignoresSafeArea(edges: .bottom)
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
