import Foundation
import Citadel

/// One SSH connection to a remote host.
///
/// Phase 2 Slice 2 deliberately keeps this as a scaffold-level stub.
/// Citadel is the locked SSH library for later implementation, but the real
/// connection wiring, host-key handling, and interactive channel/session
/// attachment are deferred to the next slice.
actor SSHConnection {
    let profile: HostProfile
    private var connected = false

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

    /// Open the SSH connection.
    ///
    /// This is a scaffold stub for Slice 2:
    /// - validates that the selected auth path has enough local data to proceed
    /// - requests explicit host-key approval through the callback
    /// - marks the connection as established in-memory
    ///
    /// Real Citadel wiring is deferred to the next slice.
    func connect(onHostKey: @escaping (String) async -> Bool) async throws {
        switch profile.authMethod {
        case .password:
            guard profile.loadPassword() != nil else {
                throw ConnectionError.authFailed
            }
        case .publicKey(let tag):
            _ = tag
            // TODO: implement SecKey / key-tag lookup and Citadel auth bridge.
            throw ConnectionError.authFailed
        }

        // TODO: replace placeholder with real host fingerprint from Citadel.
        let placeholderFingerprint = "\(profile.hostname) [fingerprint TODO]"
        let trusted = await onHostKey(placeholderFingerprint)
        guard trusted else {
            throw ConnectionError.hostKeyRejected
        }

        connected = true
    }

    // MARK: - Commands

    /// Execute a shell command and return stdout as UTF-8 text.
    ///
    /// Real remote execution is deferred until the Citadel connection/channel
    /// plumbing is implemented.
    func exec(_ command: String) async throws -> String {
        guard connected else { throw ConnectionError.notConnected }
        _ = command
        // TODO: replace with real remote execution over the active SSH session.
        return ""
    }

    // MARK: - Disconnect

    func disconnect() async {
        connected = false
    }

    var isConnected: Bool { connected }
}
