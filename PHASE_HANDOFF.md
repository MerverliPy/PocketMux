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
- Citadel channel/shell API shape has not been compile-verified; transport wiring is blocked on that
- UITextView is the current rendering surface (no VT100 byte parsing); SwiftTerm swap deferred
- SSHHostKeyValidator is still `.acceptAnything()` — not production-safe
- Public-key authentication still not implemented
- macOS/Xcode compile verification of Slice 5 still pending (WSL environment)

## Exact next actions for Phase 2 Slice 6
1. Open PocketMux.xcodeproj on macOS with Xcode 15+ and confirm Slice 5 compiles cleanly
2. Inspect Citadel resolved version for shell channel / exec channel API surface
3. Wire TerminalAttachmentCoordinator.attach() to:
   a. Open SSH shell channel via Citadel
   b. Request PTY with dimensions from the renderer's bounds
   c. Exec `tmux attach-session -t <sessionName>`
   d. Stream stdout/stderr bytes to `onOutput`
4. Wire TerminalSessionService.send(_:) → coordinator → channel stdin
5. Optionally add SwiftTerm as the rendering dependency at this point for VT100 byte parsing
6. Keep scope limited to one-host interactive attach only

Do not begin Phase 3.
