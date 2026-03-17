# PHASE_HANDOFF

## Completed
- Phase 1 Slice 1: docs/product/spec.md and docs/architecture/adr-001-product-scope.md created
- Phase 1 Slice 2: docs/architecture/adr-002-session-model.md and docs/architecture/adr-003-security-model.md created
- Phase 1 Slice 3: docs/architecture/ux-map.md created
- Phase 2 Slice 1: docs/architecture/session-state-machine.md created; Phase 2 minimum file set identified
- Phase 2 Slice 2: dependency manifest and minimum Swift source files created for the one-host loop
- Phase 2 Slice 3: Xcode project scaffold created; Citadel-based SSHConnection implementation added; tmux backend error differentiation added

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
- PocketMuxApp/Views/SessionListView.swift

## Current risks
- SSHHostKeyValidator closure init is written against an assumed Citadel API shape and must be compile-verified in Xcode
- Host key fingerprint uses `String(describing: NIOSSHPublicKey)`, not standard OpenSSH SHA-256 format
- Public-key authentication is still unimplemented; `.publicKey` currently throws `.notYetImplemented`
- TerminalView is still an explicit stub; no VT100 renderer yet
- No entitlements file yet; Keychain access on device will require one
- macOS/Xcode compile verification is still pending

## Exact next actions for Phase 2 Slice 4
1. Open PocketMux.xcodeproj on macOS with Xcode 15+
2. Let Xcode resolve and fetch Citadel via SPM
3. Build for simulator and fix any compile issues from Citadel/NIOSSH API mismatches
4. Add a `.entitlements` file for Keychain access on device
5. Write docs/testing/core-loop-checklist.md for manual verification
6. Keep scope limited to the one-host core loop

Do not begin Phase 3.
