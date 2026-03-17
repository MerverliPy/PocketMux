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
- SSH channel + PTY + tmux attach wired (Slice 6)

## Phase 2 Slice 6 status
COMPLETE.

## Files created or changed in Phase 2 Slice 6
- PocketMuxApp/SSH/SSHConnection.swift (updated — openShell added)
- PocketMuxApp/SSH/SSHConnectionManager.swift (updated — openShell passthrough added)
- PocketMuxApp/Terminal/TerminalAttachmentCoordinator.swift (updated — real PTY wiring)
- PocketMuxApp/Terminal/TerminalSessionService.swift (updated — onStreamEnded wiring, CancellationError handling)
- PocketMuxApp/Terminal/TerminalContainerView.swift (updated — keyboard input bar added)

## What was implemented (Slice 6)
- SSHConnection.openShell(): opens PTY via Citadel withPTY, sends `tmux attach-session -t <name>\r`, streams output/input
- SSHConnectionManager.openShell(): thin passthrough, keeps main actor free during streaming
- TerminalAttachmentCoordinator: background Task with AsyncStream<Data> input pipe; ready-signal via AsyncStream<Result<Void,Error>>; onStreamEnded callback notifies service when session ends
- TerminalSessionService: wires onStreamEnded to transition state after session ends; handles CancellationError separately from real errors
- TerminalContainerView: adds minimal keyboard input bar (TextField + send button) in attached state

## Citadel API used (verified from source)
- SSHClient.withPTY(_ request: SSHChannelRequestEvent.PseudoTerminalRequest, perform: (TTYOutput, TTYStdinWriter) async throws -> Void) async throws
- TTYOutput: AsyncSequence where Element = ExecCommandOutput (.stdout(ByteBuffer) | .stderr(ByteBuffer))
- TTYStdinWriter.write(_ buffer: ByteBuffer) async throws
- @available(macOS 15.0, *) on withPTY and TTYOutput — not an iOS restriction; fine for iOS 17 target

## What remains deferred (Slice 6)
- PTY dimensions are fixed (220×50); no dynamic resize on orientation change
- UITextView renderer does not parse VT100/ANSI escape sequences; output may contain control characters
- No special key forwarding (Escape, Ctrl-C, arrow keys, Tab) — text field input only
- SSHHostKeyValidator still `.acceptAnything()` — not production-safe
- Public-key authentication still not implemented

## Architecture state
The terminal transport is complete end-to-end:
  TerminalContainerView → TerminalSessionService → TerminalAttachmentCoordinator → SSHConnectionManager → SSHConnection → Citadel withPTY → tmux attach-session
