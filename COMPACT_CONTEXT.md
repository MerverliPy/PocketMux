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
- SSH library must be selected before SSHConnection.swift is written

## Completed Phase 2 work
- docs/architecture/session-state-machine.md (Slice 1)
- Phase 2 minimum file set identified (Slice 1)

## Phase 2 Slice 1 status
COMPLETE.

## Minimum file set (identified, not yet implemented)
- PocketMuxApp/Models/HostProfile.swift
- PocketMuxApp/Models/SessionRecord.swift
- PocketMuxApp/SSH/SSHConnection.swift
- PocketMuxApp/SSH/SSHConnectionManager.swift
- PocketMuxApp/Sessions/SessionManager.swift
- PocketMuxApp/Views/HostSetupView.swift
- PocketMuxApp/Views/HostKeyVerificationView.swift
- PocketMuxApp/Views/SessionListView.swift
- PocketMuxApp/Views/TerminalView.swift
- PocketMuxApp/Views/ReconnectOverlayView.swift
- PocketMuxApp/PocketMuxApp.swift
- docs/testing/core-loop-checklist.md

## Open decision blocking implementation
SSH library choice — must be locked before SSHConnection.swift is written.
Candidates: SwiftNIO SSH / Citadel (preferred, native Swift); libssh2 (C, widely used).
