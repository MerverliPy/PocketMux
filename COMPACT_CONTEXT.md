# COMPACT_CONTEXT

## Current phase
Phase 2 — Core product loop

## Current objective
Implement the one-host connection loop: host profile, SSH connection, session discovery/reattach, top-tab session strip.

## Active constraints
- One host only
- Multiple sessions per host (each = one named tmux session = one tab)
- Session persistence via remote tmux — no local terminal runtime
- Do not introduce multi-host UI
- Do not introduce advanced metadata UI
- SSH library locked: Citadel (SwiftNIO SSH)

## Completed Phase 2 work
- docs/architecture/session-state-machine.md (Slice 1)
- Phase 2 minimum file set identified (Slice 1)
- Phase 2 Slice 2 Swift source files created (Slice 2)
- Xcode project scaffold created (Slice 3)
- Citadel-based SSHConnection implementation added (Slice 3)
- tmux backend error differentiation added (Slice 3)

## Phase 2 Slice 3 status
COMPLETE.

## Files created or changed in Phase 2 Slice 3
- PocketMux.xcodeproj/project.pbxproj (created)
- PocketMux.xcodeproj/project.xcworkspace/contents.xcworkspacedata (created)
- PocketMuxApp/Assets.xcassets/Contents.json (created)
- PocketMuxApp/Assets.xcassets/AppIcon.appiconset/Contents.json (created)
- PocketMuxApp/Assets.xcassets/AccentColor.colorset/Contents.json (created)
- PocketMuxApp/SSH/SSHConnection.swift (updated — Citadel-based connection plumbing)
- PocketMuxApp/Sessions/SessionManager.swift (updated — explicit tmux backend error differentiation)
- PocketMuxApp/Views/SessionListView.swift (updated — UI-level session error surfacing)

## Open items before Slice 4
- Xcode project must be opened on macOS to resolve and fetch Citadel via SPM
  (SPM resolution requires network access and cannot happen in WSL)
- Compile verification is still pending in macOS/Xcode
- SSHHostKeyValidator closure API must be verified against the actual Citadel version resolved by Xcode
- Host key fingerprint display uses `NIOSSHPublicKey.description`, not standard OpenSSH SHA-256 wire format
- Public key authentication path still not implemented (SecKey → NIOSSHPrivateKey bridge)
- TerminalView.swift is an explicit stub — real VT100 renderer deferred
- Keychain entitlements (.entitlements file) not yet created; required for device builds
