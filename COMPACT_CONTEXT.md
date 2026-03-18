# COMPACT_CONTEXT

## Current phase
Phase 2 — Core product loop

## Current objective
Implement the one-host connection loop: host profile, SSH connection, session discovery/reattach, top-tab session strip, real terminal layer.

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
- Keychain entitlements added (Slice 4 — prior CI fix)
- Terminal foundation architecture added (Slice 5)

## Phase 2 Slice 5 status
COMPLETE.

## Phase 2 Slice 6A status
COMPLETE. Interactive shell API boundary introduced in SSHConnection and SSHConnectionManager.
Live tmux/PTY transport remains fully deferred to Slice 6B.

## Files changed in Phase 2 Slice 6A
- PocketMuxApp/SSH/SSHConnection.swift (added openInteractiveShell stub — throws notYetImplemented)
- PocketMuxApp/SSH/SSHConnectionManager.swift (added openInteractiveShell passthrough)

## Files created or changed in Phase 2 Slice 5
- PocketMuxApp/Terminal/TerminalSessionState.swift (new)
- PocketMuxApp/Terminal/TerminalAttachmentCoordinator.swift (new)
- PocketMuxApp/Terminal/TerminalSessionService.swift (new)
- PocketMuxApp/Terminal/TerminalRendererView.swift (new)
- PocketMuxApp/Terminal/TerminalContainerView.swift (new)
- PocketMuxApp/Views/TerminalView.swift (replaced stub with typealias → TerminalContainerView)
- PocketMux.xcodeproj/project.pbxproj (updated — Terminal group + 5 source files registered)

## What was implemented (Slice 5)
- Real terminal-layer boundary with separated rendering / lifecycle / transport layers
- TerminalSessionState enum (idle / connecting / attached / failed)
- TerminalSessionService (@MainActor ObservableObject) owns lifecycle, drives coordinator, publishes state + outputBuffer
- TerminalAttachmentCoordinator owns the transport boundary; attach() is a no-op stub with localized TODOs
- TerminalRendererView — UIViewRepresentable wrapping UITextView; correct bridge shape for SwiftTerm swap
- TerminalContainerView — real SwiftUI container with state-driven rendering and lifecycle hooks
- TerminalView.swift replaced: now a typealias to TerminalContainerView (call site unchanged)

## What remains deferred (Slice 5)
- TerminalAttachmentCoordinator.attach() is still a no-op stub; no live SSH channel data flows yet
- Citadel channel/shell API shape still needs compile-verification before transport wiring
- SwiftTerm dependency not yet added; UITextView is the current rendering surface
- PTY dimension negotiation not yet implemented
- User keyboard input forwarding not yet wired

## No new package dependency added
UITextView used as rendering surface. SwiftTerm is the intended swap target once channel wiring is confirmed.

## Open items for Slice 6B
- Verify Citadel SSHClient API for shell channels (exec channels vs interactive shell channels)
- Wire TerminalAttachmentCoordinator.attach() to call openInteractiveShell, then:
  - Request PTY with renderer-reported dimensions
  - Exec `tmux attach-session -t <sessionName>`
  - Stream stdout/stderr bytes to onOutput callback
- Wire TerminalSessionService.send() → coordinator → channel stdin
- Optionally add SwiftTerm at that point for full VT100 rendering
