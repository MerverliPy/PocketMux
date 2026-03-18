# PHASE_HANDOFF

## Completed
- Phase 1 Slice 1: docs/product/spec.md and docs/architecture/adr-001-product-scope.md created
- Phase 1 Slice 2: docs/architecture/adr-002-session-model.md and docs/architecture/adr-003-security-model.md created
- Phase 1 Slice 3: docs/architecture/ux-map.md created
- Phase 2 Slice 1: docs/architecture/session-state-machine.md created; Phase 2 minimum file set identified
- Phase 2 Slice 2: dependency manifest and minimum Swift source files created for the one-host loop
- Phase 2 Slice 3: Xcode project scaffold created; Citadel-based SSHConnection implementation added; tmux backend error differentiation added
- Phase 2 Slice 4: Keychain entitlements added; CI iOS simulator build fixed
- Phase 2 Slice 5: Terminal foundation architecture introduced; fake placeholder replaced

## Phase 2 Slice 5 status
COMPLETE.

## Phase 2 Slice 6A status
COMPLETE.

## Files changed in Phase 2 Slice 6A
- PocketMuxApp/SSH/SSHConnection.swift — added `openInteractiveShell() async throws` stub (throws `.notYetImplemented`)
- PocketMuxApp/SSH/SSHConnectionManager.swift — added `openInteractiveShell()` passthrough

## Files created or changed in Phase 2 Slice 5
- PocketMuxApp/Terminal/TerminalSessionState.swift (new)
- PocketMuxApp/Terminal/TerminalAttachmentCoordinator.swift (new)
- PocketMuxApp/Terminal/TerminalSessionService.swift (new)
- PocketMuxApp/Terminal/TerminalRendererView.swift (new)
- PocketMuxApp/Terminal/TerminalContainerView.swift (new)
- PocketMuxApp/Views/TerminalView.swift (stub removed; now typealias → TerminalContainerView)
- PocketMux.xcodeproj/project.pbxproj (Terminal group + 5 files registered)

## Current risks
- TerminalAttachmentCoordinator.attach() is a no-op stub; state transitions to .attached immediately with no live data
- SSHConnection.openInteractiveShell() throws notYetImplemented — no channel is opened yet
- Citadel shell channel API shape has not been compile-verified on macOS/Xcode
- UITextView is the current rendering surface (no VT100 byte parsing); SwiftTerm swap deferred
- SSHHostKeyValidator is still `.acceptAnything()` — not production-safe
- Public-key authentication still not implemented

## Exact next actions for Phase 2 Slice 6B
1. Open PocketMux.xcodeproj on macOS with Xcode 15+ and confirm Slice 6A compiles cleanly
2. Inspect Citadel resolved version for the shell / exec channel API (SSHClient.openShell or executeCommand variants)
3. Implement SSHConnection.openInteractiveShell() to:
   a. Open a real Citadel shell channel
   b. Return or store a channel handle for streaming
4. Wire TerminalAttachmentCoordinator.attach() to call openInteractiveShell, then:
   a. Request PTY with renderer-reported dimensions
   b. Exec `tmux attach-session -t <sessionName>`
   c. Stream stdout/stderr bytes to onOutput callback
5. Wire TerminalSessionService.send(_:) → coordinator → channel stdin
6. Optionally add SwiftTerm for VT100 rendering once streaming is confirmed

Do not begin Phase 3.
