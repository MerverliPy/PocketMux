import Foundation

/// Owns the terminal attachment lifecycle for one named tmux session.
///
/// Drives TerminalAttachmentCoordinator and publishes state + output for
/// TerminalContainerView to observe.
@MainActor
final class TerminalSessionService: ObservableObject {
    @Published private(set) var state: TerminalSessionState = .idle
    @Published private(set) var outputBuffer: String = ""

    let sessionName: String
    private var coordinator: TerminalAttachmentCoordinator?

    init(sessionName: String) {
        self.sessionName = sessionName
    }

    // MARK: - Lifecycle

    /// Attach to the remote tmux session.
    ///
    /// Allowed from `.idle` or `.failed` states; returns immediately from
    /// `.connecting` or `.attached`.
    func attach(using connectionManager: SSHConnectionManager) async {
        switch state {
        case .idle, .failed:
            break
        case .connecting, .attached:
            return
        }

        coordinator = nil
        state = .connecting

        let coord = TerminalAttachmentCoordinator(sessionName: sessionName)

        coord.onOutput = { [weak self] data in
            guard let text = String(data: data, encoding: .utf8) else { return }
            Task { @MainActor [weak self] in
                self?.outputBuffer.append(text)
            }
        }

        coord.onStreamEnded = { [weak self] error in
            Task { @MainActor [weak self] in
                guard let self, self.coordinator != nil else { return }
                self.coordinator = nil
                if let error {
                    self.state = .failed(error.localizedDescription)
                } else {
                    self.state = .failed("Session ended. Tap Retry to re-attach.")
                }
            }
        }

        coordinator = coord

        do {
            try await coord.attach(using: connectionManager)
            state = .attached
        } catch is CancellationError {
            // Cancelled intentionally (detach/reconnect); don't flash an error.
            coordinator = nil
        } catch {
            coordinator = nil
            state = .failed(error.localizedDescription)
        }
    }

    /// Detach and reset to idle.
    func detach() async {
        await coordinator?.close()
        coordinator = nil
        state = .idle
    }

    /// Forward user input to the remote channel stdin.
    func send(_ data: Data) {
        coordinator?.send(data)
    }
}
