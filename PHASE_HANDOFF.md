# PHASE_HANDOFF

## Completed
- Phase 1 Slice 1: docs/product/spec.md and docs/architecture/adr-001-product-scope.md created
- Phase 1 Slice 2: docs/architecture/adr-002-session-model.md and docs/architecture/adr-003-security-model.md created
- Phase 1 Slice 3: docs/architecture/ux-map.md created
- Phase 2 Slice 1: docs/architecture/session-state-machine.md created; Phase 2 minimum file set identified
- Phase 2 Slice 2: dependency manifest and minimum Swift source files created for the one-host loop
- Phase 2 Slice 3: Xcode project scaffold created; real Citadel SSH wiring; tmux error surfacing

## Phase 2 Slice 3 status
COMPLETE.

## Files created or changed in Phase 2 Slice 3
- PocketMux.xcodeproj/project.pbxproj
- PocketMux.xcodeproj/project.xcworkspace/contents.xcworkspacedata
- PocketMuxApp/Assets.xcassets/Contents.json
- PocketMuxApp/Assets.xcassets/AppIcon.appiconset/Contents.json
- PocketMuxApp/Assets.xcassets/AccentColor.colorset/Contents.json
- PocketMuxApp/SSH/SSHConnection.swift
- PocketMuxApp/Sessions/SessionManager.swift

## Current risks
- SSHHostKeyValidator closure init: written as `SSHHostKeyValidator { key in ... }` based on
  Citadel source patterns. Must be verified to compile — if the init is not public or the
  signature differs, adjust to use the protocol-conformance path or an intermediate struct.
- Host key fingerprint: uses `String(describing: NIOSSHPublicKey)`. Not the standard OpenSSH
  SHA-256 format. Users familiar with `ssh-keygen -lf` output will see a different string.
  Note in the HostKeyVerificationView UI that the format is non-standard.
- Public-key authentication: still unimplemented. The `.publicKey` auth path throws
  `.notYetImplemented`. Password auth is fully wired.
- TerminalView: still an explicit stub. No VT100 renderer.
- No entitlements file yet. Keychain access on device requires a `.entitlements` file with
  `keychain-access-groups`. The simulator may work without it in development.

## Exact next actions for Phase 2 Slice 4
1. Open PocketMux.xcodeproj on macOS with Xcode 15+
2. Let Xcode resolve and fetch Citadel via SPM (requires network)
3. Build for simulator — fix any compile errors from SSHHostKeyValidator closure signature
   or ByteBuffer API differences
4. Wire HostKeyVerificationView to use the connectionManager.pendingHostKey callbacks
   (the approve/reject continuations are already plumbed in SSHConnectionManager)
5. Wire SessionListView to call SessionManager.listSessions() and display the result
6. Add a .entitlements file for Keychain access on device
7. Write docs/testing/core-loop-checklist.md for manual verification

Do not begin Phase 3.
