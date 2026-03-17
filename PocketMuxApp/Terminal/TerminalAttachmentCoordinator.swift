import Foundation

/// Bridges TerminalSessionService to a real SSH interactive PTY session.
///
/// Owns the channel lifetime for one tmux session attachment:
///   - attach() starts the PTY session in a background Task and returns once the
///     channel is open and the tmux command has been sent.
///   - send(_:) forwards raw input bytes to channel stdin.
///   - close() cancels the background task and tears down the channel.
///
/// Only this type knows about the SSH transport layer. The service and views
/// remain insulated from Citadel/NIO types.
final class TerminalAttachmentCoordinator {
    let sessionName: String

    /// Called with raw output bytes from the remote channel.
    /// May be invoked from any concurrency context; callers must dispatch
    /// to the appropriate actor for UI updates.
    var onOutput: ((Data) -> Void)?

    /// Called when the PTY session ends after a successful attach (normal or error).
    /// Not called when close() is used to cancel the session intentionally.
    var onStreamEnded: ((Error?) -> Void)?

    private var streamTask: Task<Void, Never>?
    private var inputContinuation: AsyncStream<Data>.Continuation?

    init(sessionName: String) {
        self.sessionName = sessionName
    }

    // MARK: - Transport

    /// Establish the PTY session.
    ///
    /// Returns once the channel is open and `tmux attach-session` has been sent.
    /// Output streaming continues in a background task until the session ends.
    ///
    /// - Throws: SSHConnection.ConnectionError.notConnected if no SSH connection is active.
    ///           CancellationError if close() is called before the channel becomes ready.
    ///           Any Citadel/channel error from PTY setup.
    func attach(using connectionManager: SSHConnectionManager) async throws {
        // Snapshot closures by value before launching background task
        let sessionName = self.sessionName
        let onOutput = self.onOutput
        let onStreamEnded = self.onStreamEnded

        // Input pipe: service calls send(_:) → continuation → channel stdin
        let (inputStream, inputCont) = AsyncStream<Data>.makeStream()
        inputContinuation = inputCont

        // One-shot ready signal: yields .success once PTY is live, .failure on setup error.
        // AsyncStream buffers the single value so the consumer always receives it even if
        // the task signals ready before attach() begins iterating.
        let (readyStream, readyCont) = AsyncStream<Result<Void, Error>>.makeStream()

        streamTask = Task {
            // Always close the ready stream on exit so attach() is never left hanging.
            defer { readyCont.finish() }

            do {
                try await connectionManager.openShell(
                    sessionName: sessionName,
                    inputStream: inputStream,
                    onOutput: { data in onOutput?(data) },
                    onReady: {
                        readyCont.yield(.success(()))
                    }
                )
                // Stream ended normally (tmux detached, session exited, etc.)
                onStreamEnded?(nil)
            } catch {
                guard !Task.isCancelled else { return }
                // Signal failure via whichever channel is still relevant.
                // If ready was already signalled, readyCont is finished and the yield is a no-op.
                readyCont.yield(.failure(error))
                onStreamEnded?(error)
            }
        }

        // Wait for PTY ready signal or setup failure.
        for await result in readyStream {
            try result.get()
            return
        }
        // readyStream drained without a value: task was cancelled before getting ready.
        throw CancellationError()
    }

    /// Write raw bytes to the remote channel stdin (keyboard input).
    func send(_ data: Data) {
        inputContinuation?.yield(data)
    }

    /// Close the remote channel and stop streaming.
    func close() async {
        inputContinuation?.finish()
        streamTask?.cancel()
        streamTask = nil
        inputContinuation = nil
    }
}
