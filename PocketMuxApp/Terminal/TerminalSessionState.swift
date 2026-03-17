/// Terminal attachment lifecycle states.
///
/// Drives TerminalContainerView rendering and TerminalSessionService transitions.
enum TerminalSessionState: Equatable {
    /// No attach attempt has started.
    case idle
    /// Opening SSH channel + PTY + tmux attach in progress.
    case connecting
    /// Channel is open; output data flows to the renderer.
    case attached
    /// Attach failed; message describes the reason.
    case failed(String)
}
