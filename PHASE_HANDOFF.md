# PHASE_HANDOFF

## Completed
- Phase 0: minimal repo artifact pack created and committed
- Phase 1 Slice 1: docs/product/spec.md and docs/architecture/adr-001-product-scope.md created
- Phase 1 Slice 2: docs/architecture/adr-002-session-model.md and docs/architecture/adr-003-security-model.md created
- Phase 1 Slice 3: docs/architecture/ux-map.md created
- Phase 2 Slice 1: docs/architecture/session-state-machine.md created; Phase 2 minimum file set identified

## Phase 2 Slice 1 status
COMPLETE.

## Files touched in Phase 2 Slice 1
- docs/architecture/session-state-machine.md (new)
- COMPACT_CONTEXT.md (updated)
- PHASE_HANDOFF.md (updated)

## Current risks
- SSH library not yet chosen — blocks SSHConnection.swift; Citadel/SwiftNIO SSH vs libssh2 decision needed
- Terminal rendering substrate still deferred — affects TerminalView.swift approach
- No Xcode project scaffold exists yet — required before any Swift compilation

## Exact next action for Phase 2 Slice 2
1. Lock SSH library choice (user decision or research spike)
2. Create Xcode project scaffold: PocketMuxApp target, SwiftUI lifecycle, minimum deployment iOS 17
3. Implement HostProfile model and Keychain storage
4. Implement SSHConnection stub with host key callback
5. Wire HostSetupView → HostKeyVerificationView → SessionListView navigation

Do not begin Phase 3.
