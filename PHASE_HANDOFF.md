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
- Phase 2 Slice 6: SSH channel + PTY + tmux attach wired; keyboard input bar added

## Phase 2 Slice 6 status
COMPLETE — pending CI green on GitHub Actions.

## Files changed in Phase 2 Slice 6
- PocketMuxApp/SSH/SSHConnection.swift (openShell added)
- PocketMuxApp/SSH/SSHConnectionManager.swift (openShell passthrough added)
- PocketMuxApp/Terminal/TerminalAttachmentCoordinator.swift (real PTY wiring)
- PocketMuxApp/Terminal/TerminalSessionService.swift (onStreamEnded + CancellationError handling)
- PocketMuxApp/Terminal/TerminalContainerView.swift (keyboard input bar)

## Current risks
- SSHHostKeyValidator is still `.acceptAnything()` — not production-safe (ADR-003 violation)
- Public-key authentication still not implemented (throws .notYetImplemented)
- PTY dimensions are fixed 220×50; no dynamic resize — tmux may render incorrectly on smaller screens
- UITextView renderer has no VT100/ANSI parsing; escape sequences render as raw text
- Special key forwarding (Ctrl-C, arrow keys, Tab, Escape) not yet implemented
- The `@available(macOS 15.0, *)` annotation on Citadel's withPTY/TTYOutput only restricts macOS; verified safe for iOS 17 target

## Exact next actions for Phase 2 Slice 7
1. Confirm CI passes for Slice 6 changes
2. Address VT100/ANSI rendering — SwiftTerm is the intended swap target:
   a. Add SwiftTerm as a SwiftPM dependency
   b. Replace UITextView in TerminalRendererView with SwiftTerm.TerminalView (UIViewRepresentable bridge shape already correct)
   c. Wire TerminalAttachmentCoordinator.onOutput bytes directly into SwiftTerm's feed(byteArray:) API
3. Add special key forwarding (Ctrl-C = \x03, arrow keys = ESC sequences, Tab = \x09)
4. Add dynamic PTY resize via TTYStdinWriter.changeSize() on orientation change
5. Replace `.acceptAnything()` with real host-key trust model (ADR-003)
6. Keep scope limited to one-host, iPhone-only, remote tmux

Do not begin Phase 3.
