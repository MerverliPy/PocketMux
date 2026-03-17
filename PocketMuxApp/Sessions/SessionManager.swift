import Foundation

/// Discovers and manages remote tmux sessions on the connected host.
///
/// All operations are remote: no local shell, no local tmux.
actor SessionManager {
    private let connectionManager: SSHConnectionManager

    /// Errors from tmux operations, distinct from SSH-layer errors.
    enum SessionError: Error {
        /// tmux list-sessions exited with a non-zero code that is not the
        /// expected "no server running" exit code (1).
        case tmuxListFailed(exitCode: Int)
        /// tmux new-session failed to create the requested session.
        case tmuxCreateFailed(sessionName: String, exitCode: Int)
    }

    init(connectionManager: SSHConnectionManager) {
        self.connectionManager = connectionManager
    }

    // MARK: - Session discovery

    /// List all tmux sessions currently running on the remote host.
    ///
    /// Distinguishes between three states:
    /// - Exit 0: sessions returned normally.
    /// - Exit 1: no tmux server running — returns empty list (normal initial state).
    /// - Other non-zero: unexpected tmux failure — throws `SessionError.tmuxListFailed`.
    ///
    /// SSH-layer errors propagate as-is from the underlying `exec` call.
    func listSessions() async throws -> [SessionRecord] {
        // Append `; echo "__EXIT__:$?"` so we can read the exit code from stdout.
        // tmux writes session list to stdout and exits 0 on success.
        // tmux exits 1 with no output when the server isn't running (no sessions yet).
        let raw = try await connectionManager.exec(
            "tmux list-sessions -F '#{session_name}\t#{session_attached}\t#{session_created}' 2>/dev/null; echo \"__EXIT__:$?\""
        )

        let lines = raw.components(separatedBy: "\n")
        let exitLine = lines.last(where: { $0.hasPrefix("__EXIT__:") })
        let exitCodeStr = exitLine.flatMap { $0.split(separator: ":").last }.map(String.init) ?? ""
        let exitCode = Int(exitCodeStr.trimmingCharacters(in: .whitespacesAndNewlines)) ?? -1

        switch exitCode {
        case 0:
            let sessionLines = lines
                .filter { !$0.hasPrefix("__EXIT__:") }
                .joined(separator: "\n")
            return parse(output: sessionLines)
        case 1:
            // tmux server not running — zero sessions, not an error.
            return []
        default:
            throw SessionError.tmuxListFailed(exitCode: exitCode)
        }
    }

    // MARK: - Session lifecycle

    /// Ensure a named tmux session exists on the remote host.
    ///
    /// Creates the session in detached mode if it does not already exist.
    /// Throws `SessionError.tmuxCreateFailed` if tmux new-session fails.
    func ensureSessionExists(sessionName: String) async throws {
        let sanitised = sanitise(sessionName)
        guard !sanitised.isEmpty else { return }

        if !(try await sessionExists(name: sanitised)) {
            let raw = try await connectionManager.exec(
                "tmux new-session -d -s \(sanitised) 2>/dev/null; echo \"__EXIT__:$?\""
            )
            let exitCode = extractExitCode(from: raw)
            guard exitCode == 0 else {
                throw SessionError.tmuxCreateFailed(sessionName: sanitised, exitCode: exitCode)
            }
        }
    }

    // MARK: - Private

    private func sessionExists(name: String) async throws -> Bool {
        let sessions = try await listSessions()
        return sessions.contains { $0.id == name }
    }

    /// Sanitise a session name for safe tmux command interpolation.
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

    private func extractExitCode(from output: String) -> Int {
        let lines = output.components(separatedBy: "\n")
        let exitLine = lines.last(where: { $0.hasPrefix("__EXIT__:") })
        let codeStr = exitLine.flatMap { $0.split(separator: ":").last }.map(String.init) ?? ""
        return Int(codeStr.trimmingCharacters(in: .whitespacesAndNewlines)) ?? -1
    }
}
