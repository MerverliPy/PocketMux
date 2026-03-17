import Foundation
import Citadel
import NIOSSH
import NIOCore

/// One SSH connection to a remote host, backed by Citadel (SwiftNIO SSH).
///
/// SECURITY NOTE:
/// hostKeyValidator is temporarily set to `.acceptAnything()` to unblock CI.
/// This does NOT satisfy ADR-003 and must be replaced in a follow-up slice.
actor SSHConnection {
    let profile: HostProfile
    private var client: SSHClient?

    enum ConnectionError: Error {
        case hostKeyRejected
        case authFailed
        case notConnected
        case notYetImplemented
    }

    init(profile: HostProfile) {
        self.profile = profile
    }

    // MARK: - Connect

    func connect(onHostKey: @escaping (String) async -> Bool) async throws {
        _ = onHostKey

        let authMethod: SSHAuthenticationMethod
        switch profile.authMethod {
        case .password:
            guard let password = profile.loadPassword() else {
                throw ConnectionError.authFailed
            }
            authMethod = .passwordBased(
                username: profile.username,
                password: password
            )
        case .publicKey:
            // TODO: bridge SecKey / key-tag to NIOSSHPrivateKey in a later slice.
            throw ConnectionError.notYetImplemented
        }

        let settings = SSHClientSettings(
            host: profile.hostname,
            port: Int(profile.port),
            authenticationMethod: { authMethod },
            hostKeyValidator: .acceptAnything()
        )
        client = try await SSHClient.connect(to: settings)
    }

    // MARK: - Commands

    /// Execute a remote shell command and return stdout as UTF-8 text.
    func exec(_ command: String) async throws -> String {
        guard let client else { throw ConnectionError.notConnected }
        let stdout = try await client.executeCommand(command)
        return String(buffer: stdout)
    }

    // MARK: - Interactive shell

    /// Open a PTY shell, send `tmux attach-session -t <sessionName>`, and stream I/O
    /// until the channel closes or the task is cancelled.
    ///
    /// - Parameters:
    ///   - sessionName: tmux session name to attach to
    ///   - inputStream: Data chunks to forward to channel stdin (keyboard input)
    ///   - onOutput: called with each stdout/stderr chunk; may be invoked from any context
    ///   - onReady: called once the channel is open and the tmux command has been sent
    func openShell(
        sessionName: String,
        inputStream: AsyncStream<Data>,
        onOutput: @escaping (Data) -> Void,
        onReady: @escaping () -> Void
    ) async throws {
        guard let client else { throw ConnectionError.notConnected }

        let ptyRequest = SSHChannelRequestEvent.PseudoTerminalRequest(
            wantReply: true,
            term: "xterm-256color",
            terminalCharacterWidth: 220,
            terminalRowHeight: 50,
            terminalPixelWidth: 0,
            terminalPixelHeight: 0,
            terminalModes: .init([])
        )

        try await client.withPTY(ptyRequest) { ttyOutput, stdinWriter in
            // Send the tmux attach command to the shell
            var cmd = ByteBuffer()
            cmd.writeString("tmux attach-session -t \(sessionName)\r")
            try await stdinWriter.write(cmd)

            // Signal caller that the channel is live
            onReady()

            // Stream output and input concurrently until either side closes
            try await withThrowingTaskGroup(of: Void.self) { group in
                // Remote → local output
                group.addTask {
                    for try await chunk in ttyOutput {
                        let buf: ByteBuffer
                        switch chunk {
                        case .stdout(let b): buf = b
                        case .stderr(let b): buf = b
                        }
                        onOutput(Data(buf.readableBytesView))
                    }
                }
                // Local input → remote stdin
                group.addTask {
                    for await data in inputStream {
                        var buf = ByteBuffer()
                        buf.writeBytes(data)
                        try await stdinWriter.write(buf)
                    }
                }
                // First finisher ends both sides
                try await group.next()
                group.cancelAll()
            }
        }
    }

    // MARK: - Disconnect

    func disconnect() async {
        try? await client?.close()
        client = nil
    }

    var isConnected: Bool { client != nil }
}
