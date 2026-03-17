import Foundation

/// Discovers and manages remote tmux sessions on the connected host.
///
/// All operations are remote: no local shell, no local tmux.
actor SessionManager {
    private let connectionManager: SSHConnectionManager

    init(connectionManager: SSHConnectionManager) {
        self.connectionManager = connectionManager
    }

    // MARK: - Session discovery

    /// List all tmux sessions currently running on the remote host.
    func listSessions() async throws -> [SessionRecord] {
        let output = try await connectionManager.exec(
            "tmux list-sessions -F '#{session_name}\t#{session_attached}\t#{session_created}' 2>/dev/null || true"
        )
        return parse(output: output)
    }

    // MARK: - Session lifecycle

    /// Ensure a named tmux session exists.
    ///
    /// This slice does not implement interactive terminal attachment yet.
    /// It only guarantees that the session exists remotely so a later slice
    /// can attach a terminal channel to it.
    func ensureSessionExists(sessionName: String) async throws {
        let sanitised = sanitise(sessionName)
        guard !sanitised.isEmpty else { return }

        if !(try await sessionExists(name: sanitised)) {
            _ = try await connectionManager.exec("tmux new-session -d -s \(sanitised)")
        }
    }

    // MARK: - Private

    private func sessionExists(name: String) async throws -> Bool {
        let sessions = try await listSessions()
        return sessions.contains { $0.id == name }
    }

    /// Sanitise a session name to be safe for tmux command interpolation.
    /// Allows alphanumerics, hyphens, underscores, and dots only.
    private func sanitise(_ name: String) -> String {
        name.unicodeScalars
            .filter { CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_.")).contains($0) }
            .reduce(into: "") { $0.append(Character($1)) }
    }

    private func parse(output: String) -> [SessionRecord] {
        output
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { line -> SessionRecord? in
                let parts = line.split(separator: "\t", maxSplits: 3)
                guard parts.count >= 2 else { return nil }
                let name = String(parts[0])
                let isAttached = parts[1] != "0"
                var createdAt: Date?
                if parts.count >= 3, let epoch = TimeInterval(parts[2]) {
                    createdAt = Date(timeIntervalSince1970: epoch)
                }
                return SessionRecord(id: name, isAttached: isAttached, createdAt: createdAt)
            }
    }
}
