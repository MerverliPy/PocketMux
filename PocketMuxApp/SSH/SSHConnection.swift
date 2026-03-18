import Foundation
import Citadel
import NIOSSH

/// One SSH connection to a remote host, backed by Citadel (SwiftNIO SSH).
///
/// This version fixes the immediate compile error by using Citadel's public
/// SSHClientSettings + SSHClient.connect(to:) API surface.
///
/// SECURITY NOTE:
/// hostKeyValidator is temporarily set to `.acceptAnything()` to unblock CI and
/// validate the rest of the wiring against the real Citadel 0.12.0 API.
/// This does NOT satisfy ADR-003 and must be replaced with a real trust model
/// in a follow-up slice.
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

    /// Open the SSH connection using Citadel.
    ///
    /// Current limitation:
    /// - The `onHostKey` callback is not yet wired into Citadel's public validator API.
    /// - We keep the parameter so the call site does not need to change yet.
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

    // MARK: - Interactive Shell (Slice 6B.2 — real PTY open, no tmux command yet)

    /// Opens a PTY channel via Citadel `withPTY`.
    ///
    /// Slice 6B.2: channel opens and inbound is drained; no tmux attach command yet.
    /// `cols`/`rows` use typical defaults — dynamic resize is wired in a later slice.
    func openInteractiveShell(cols: Int = 80, rows: Int = 24) async throws {
        guard let client else { throw ConnectionError.notConnected }

        let ptyRequest = SSHChannelRequestEvent.PseudoTerminalRequest(
            term: "xterm-256color",
            terminalCharacterWidth: UInt32(cols),
            terminalRowHeight: UInt32(rows),
            terminalPixelWidth: 0,
            terminalPixelHeight: 0,
            terminalModes: .init([])
        )

        try await client.withPTY(ptyRequest) { inbound, _ in
            // Slice 6B.2: drain output to keep the channel alive; tmux command added in 6B.3.
            for try await _ in inbound { }
        }
    }

    // MARK: - Disconnect

    func disconnect() async {
        try? await client?.close()
        client = nil
    }

    var isConnected: Bool { client != nil }
}
