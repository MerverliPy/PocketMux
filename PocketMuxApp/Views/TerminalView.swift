import SwiftUI

/// Terminal screen for the selected remote tmux session.
///
/// Backed by TerminalContainerView. This typealias preserves the call-site
/// name used in SessionListView without requiring changes there.
typealias TerminalView = TerminalContainerView
