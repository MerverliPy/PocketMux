import Foundation
import SwiftUI

/// Owns the active SSH connection and drives the top-level connection state machine.
/// Published state controls which root view is shown.
@MainActor
final class SSHConnectionManager: ObservableObject {

    enum State: Equatable {
        case disconnected
        case verifyingHost(fingerprint: String)
        case connected
        case reconnecting

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.disconnected, .disconnected),
                 (.connected, .connected),
                 (.reconnecting, .reconnecting):
                return true
            case (.verifyingHost(let a), .verifyingHost(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    /// Pending host key approval that the UI must resolve.
    struct PendingHostKey {
        let fingerprint: String
        let approve: () -> Void
        let reject: () -> Void
    }

    @Published var state: State = .disconnected
    @Published var pendingHostKey: PendingHostKey?

    private var connection: SSHConnection?
    private(set) var profile: HostProfile?

    // MARK: - Public API

    func connect(to profile: HostProfile) async {
        self.profile = profile
        let conn = SSHConnection(profile: profile)
        connection = conn

        do {
            try await conn.connect { [weak self] fingerprint in
                guard let self else { return false }
                return await self.requestApproval(fingerprint: fingerprint)
            }
            state = .connected
        } catch SSHConnection.ConnectionError.hostKeyRejected {
            reset()
        } catch {
            reset()
        }
    }

    func disconnect() async {
        await connection?.disconnect()
        reset()
    }

    func reconnect() async {
        guard let profile else { return }
        state = .reconnecting
        await connect(to: profile)
    }

    /// Execute a command on the active connection.
    func exec(_ command: String) async throws -> String {
        guard let connection else { throw SSHConnection.ConnectionError.notConnected }
        return try await connection.exec(command)
    }

    // MARK: - Private

    private func reset() {
        connection = nil
        pendingHostKey = nil
        state = .disconnected
    }

    /// Suspends until the user approves or rejects the host key in the UI.
    private func requestApproval(fingerprint: String) async -> Bool {
        await withCheckedContinuation { continuation in
            let pending = PendingHostKey(
                fingerprint: fingerprint,
                approve: { continuation.resume(returning: true) },
                reject: { continuation.resume(returning: false) }
            )
            self.state = .verifyingHost(fingerprint: fingerprint)
            self.pendingHostKey = pending
        }
    }
}
