import Foundation

/// Represents one persistent remote tmux session.
/// Identity is the tmux session name — stable across reconnects.
struct SessionRecord: Identifiable, Hashable {
    /// tmux session name. Stable identity — used for reattach.
    let id: String
    /// Whether tmux currently reports a client attached.
    var isAttached: Bool
    /// Session creation time, if available from tmux.
    var createdAt: Date?

    /// Name shown in the top-tab strip.
    var displayName: String { id }
}
