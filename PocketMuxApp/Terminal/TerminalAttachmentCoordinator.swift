import Foundation

/// Bridges an SSH connection to a PTY + tmux attach on the remote host.
///
/// Slice 6B.3: starts the PTY session on a background Task, writes the
/// tmux attach command, and forwards output bytes to `onOutput`.
/// Input forwarding (TTYStdinWriter) is wired in Slice 6B.4.
final class TerminalAttachmentCoordinator {
    let sessionName: String

    /// Called with raw output bytes from the remote channel.
    /// Invoked from an arbitrary concurrency context — callers must dispatch
    /// to the appropriate actor if UI updates are needed.
    var onOutput: ((Data) -> Void)?

    private var sessionTask: Task<Void, Error>?

    init(sessionName: String) {
        self.sessionName = sessionName
    }

    // MARK: - Transport

    /// Starts the PTY + tmux attach session on a background Task and returns immediately.
    ///
    /// Output bytes are forwarded to `onOutput` asynchronously as they arrive.
    func attach(using connectionManager: SSHConnectionManager) async throws {
        sessionTask = Task {
            try await connectionManager.openInteractiveShell(
                sessionName: sessionName,
                onOutput: { [weak self] data in
                    self?.onOutput?(data)
                }
            )
        }
    }

    /// Write user input bytes to the remote channel's stdin.
    func send(_ data: Data) {
        // TODO (Slice 6B.4): Wire to TTYStdinWriter.
        _ = data
    }

    /// Cancel the remote session and release resources.
    func close() async {
        sessionTask?.cancel()
        sessionTask = nil
    }
}
