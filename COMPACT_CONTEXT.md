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

## Phase 2 Slice 2 status
COMPLETE.

## Files created in Phase 2 Slice 2
- Package.swift (dependency manifest — Citadel declared)
- PocketMuxApp/PocketMuxApp.swift
- PocketMuxApp/Models/HostProfile.swift
- PocketMuxApp/Models/SessionRecord.swift
- PocketMuxApp/SSH/SSHConnection.swift
- PocketMuxApp/SSH/SSHConnectionManager.swift
- PocketMuxApp/Sessions/SessionManager.swift
- PocketMuxApp/Views/HostSetupView.swift
- PocketMuxApp/Views/HostKeyVerificationView.swift
- PocketMuxApp/Views/SessionListView.swift
- PocketMuxApp/Views/TerminalView.swift (explicit stub)
- PocketMuxApp/Views/ReconnectOverlayView.swift

## Open items before Slice 3
- Xcode project (.xcodeproj) must be created on a Mac (cannot be generated in WSL)
  - SwiftUI lifecycle, iOS 17 deployment target, Citadel via SPM
- SSHConnection.swift has two TODOs:
  1. Host key fingerprint format — use SHA-256 once Citadel/NIOSSH exposes it
  2. Public key auth — SecKey → NIOSSHPrivateKey bridge not yet implemented
- TerminalView.swift is an explicit stub — real VT100 renderer deferred
- docs/testing/core-loop-checklist.md not yet written
