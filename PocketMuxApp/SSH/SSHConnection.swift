import Foundation
import Citadel
import NIOSSH

/// One SSH connection to a remote host, backed by Citadel (SwiftNIO SSH).
///
/// Phase 2 Slice 3 wires the real Citadel connection, host-key callback flow,
/// and remote command execution.
///
/// Known limitations as of Slice 3:
/// - Host key fingerprint display: NIOSSH does not expose a public API for
///   computing the standard OpenSSH SHA-256 wire-format fingerprint. The
///   fingerprint shown to the user is the key's string description. This is
///   a stable unique identifier but is not the same format as `ssh-keygen -lf`.
///   Fix when NIOSSH exposes key serialization or a fingerprint helper.
/// - Public key authentication: SecKey → NIOSSHPrivateKey bridge is not yet
///   implemented. Password authentication is fully wired.
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
    /// The `onHostKey` callback receives a key description string and must
    /// return `true` to accept or `false` to reject. If rejected, the
    /// connection is torn down and `ConnectionError.hostKeyRejected` is thrown.
    func connect(onHostKey: @escaping (String) async -> Bool) async throws {
        let authMethod: SSHAuthenticationMethod
        switch profile.authMethod {
        case .password:
            guard let password = profile.loadPassword() else {
                throw ConnectionError.authFailed
            }
            authMethod = .passwordBased(username: profile.username, password: password)
        case .publicKey:
            // TODO: bridge SecKey / key-tag to NIOSSHPrivateKey — deferred to a later slice.
            throw ConnectionError.notYetImplemented
        }

        // Capture the callback for use in the validator closure.
        // SSHHostKeyValidator calls this synchronously during the handshake.
        let validator = SSHHostKeyValidator { key in
            let description = SSHConnection.keyDescription(for: key)
            let trusted = await onHostKey(description)
            if !trusted {
                throw ConnectionError.hostKeyRejected
            }
        }

        client = try await SSHClient.connect(
            host: profile.hostname,
            port: Int(profile.port),
            authenticationMethod: authMethod,
            hostKeyValidator: validator,
            reconnect: .never
        )
    }

    // MARK: - Commands

    /// Execute a remote shell command and return stdout as UTF-8 text.
    ///
    /// Stderr is not captured. Use the shell wrapper `cmd 2>&1` if stderr is needed.
    func exec(_ command: String) async throws -> String {
        guard let client else { throw ConnectionError.notConnected }
        var buffer = try await client.executeCommand(command)
        return buffer.readString(length: buffer.readableBytes) ?? ""
    }

    // MARK: - Disconnect

    func disconnect() async {
        try? await client?.close()
        client = nil
    }

    var isConnected: Bool { client != nil }

    // MARK: - Key description

    /// Returns a human-readable string identifying the host key.
    ///
    /// LIMITATION: NIOSSH does not expose a public API for computing the
    /// standard `SHA256:<base64>` OpenSSH fingerprint from `NIOSSHPublicKey`.
    /// The string returned is the key's `description`, which is stable for the
    /// same key but differs from the output of `ssh-keygen -lf`.
    ///
    /// Replace with a proper wire-format SHA-256 fingerprint once NIOSSH
    /// exposes key serialization or Citadel provides a fingerprint helper.
    private static func keyDescription(for key: NIOSSHPublicKey) -> String {
        String(describing: key)
    }
}
