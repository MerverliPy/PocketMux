import Foundation

/// Bridges an SSH connection to a PTY + tmux attach on the remote host.
///
/// Transport wiring is deferred to the next slice once the Citadel shell/channel
/// API shape is verified against the resolved package version.
///
/// Wiring target (Slice 6):
///   1. Open an SSH channel via Citadel (SSHClient shell or exec channel)
///   2. Request a PTY on the channel with correct terminal dimensions
///   3. Exec `tmux attach-session -t <sessionName>` on the channel
///   4. Stream channel stdout/stderr bytes to `onOutput`
///   5. Forward `send(_:)` bytes to channel stdin
final class TerminalAttachmentCoordinator {
    let sessionName: String

    /// Called with raw output bytes from the remote channel.
    /// Invoked from an arbitrary concurrency context — callers must dispatch
    /// to the appropriate actor if UI updates are needed.
    var onOutput: ((Data) -> Void)?

    init(sessionName: String) {
        self.sessionName = sessionName
    }

    // MARK: - Transport

    /// Establish the SSH channel, request a PTY, and attach to the tmux session.
    ///
    /// Currently a no-op stub. The coordinator succeeds immediately so the
    /// terminal layer architecture is exercise-able end-to-end before the
    /// transport is wired.
    func attach(using connectionManager: SSHConnectionManager) async throws {
        // TODO (Slice 6): Use SSHConnectionManager to open a shell channel,
        // negotiate PTY dimensions matching the terminal renderer bounds,
        // and exec `tmux attach-session -t \(sessionName)`.
        // Requires compile-verification of Citadel channel/shell API shape.
    }

    /// Write user input bytes to the remote channel's stdin.
    func send(_ data: Data) {
        // TODO (Slice 6): Write data to the open SSH channel stdin.
        _ = data
    }

    /// Close the remote channel cleanly.
    func close() async {
        // TODO (Slice 6): Close the SSH channel and release resources.
    }
}
