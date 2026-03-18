# COMPACT_CONTEXT

## Current phase
Phase 2 — Core product loop

## Current slice
Slice 6B.2 complete; Slice 6B.3 next

## Current objective
Keep the one-host PocketMux terminal path stable while moving from a compile-safe interactive shell boundary toward real remote tmux attach transport in small CI-verified increments.

## Verified repository state
- branch `feat/slice6b-transport` contains real `withPTY` channel open (Slice 6B.2)
- `feat/slice6b-transport` passed GitHub Actions iOS CI
- verified green run:
  - workflow: `PocketMux iOS CI`
  - run ID: `23228501849`
  - commit: `b9425ba`
- `@available(macOS 15.0, *)` on `withPTY` does NOT block iOS 17 Simulator build (confirmed)

## Active constraints
- one host only
- iPhone-first only
- remote tmux only
- no local terminal runtime
- do not begin Phase 3
- do not expand into multi-host UI
- do not claim PTY/tmux transport is complete before CI proves it
- keep GitHub Actions green after each transport increment

## What is complete through Slice 6B.2
- product scope and architecture docs established
- Xcode project scaffold exists
- Citadel-based SSH connection path exists
- tmux session discovery / creation path exists
- session list and error surfacing exist
- Keychain entitlements exist
- terminal foundation exists:
  - `TerminalSessionState`
  - `TerminalSessionService`
  - `TerminalAttachmentCoordinator`
  - `TerminalRendererView`
  - `TerminalContainerView`
- real `withPTY` channel open (Slice 6B.2) in:
  - `PocketMuxApp/SSH/SSHConnection.swift` — drains inbound, no tmux command yet
  - `PocketMuxApp/SSH/SSHConnectionManager.swift` — matching passthrough

## Confirmed PseudoTerminalRequest init (actual NIOSSH 0.3.5 signature)
```swift
SSHChannelRequestEvent.PseudoTerminalRequest(
    wantReply: Bool,
    term: String,
    terminalCharacterWidth: Int,   // NOT UInt32
    terminalRowHeight: Int,        // NOT UInt32
    terminalPixelWidth: Int,
    terminalPixelHeight: Int,
    terminalModes: SSHTerminalModes  // init([:]) dictionary, NOT array
)
```

## What Slice 6B.2 intentionally does not implement
- no tmux attach-session command (Slice 6B.3)
- no output wired to TerminalSessionService
- no input forwarding from user
- no dynamic PTY resize
- no ANSI / VT100 parsing
- no special key forwarding

## Verified Citadel API — Slice 6B.1 (confirmed 2026-03-17)

Resolved version: **0.12.0** (via `upToNextMajorVersion` from 0.6.0)

### Confirmed connect API (already working in CI)
```swift
// SSHClientSettings in Sources/Citadel/ClientSession.swift
SSHClientSettings(
    host: String,
    port: Int = 22,
    authenticationMethod: @Sendable @escaping () -> SSHAuthenticationMethod,
    hostKeyValidator: SSHHostKeyValidator
)
SSHClient.connect(to settings: SSHClientSettings) async throws -> SSHClient
```

### Confirmed interactive shell / PTY API
```swift
// On SSHClient — both require @available(macOS 15.0, *); no iOS floor declared
func withPTY(
    _ request: SSHChannelRequestEvent.PseudoTerminalRequest,
    environment: [SSHChannelRequestEvent.EnvironmentRequest] = [],
    perform: (_ inbound: TTYOutput, _ outbound: TTYStdinWriter) async throws -> Void
) async throws

func withTTY(
    environment: [SSHChannelRequestEvent.EnvironmentRequest] = [],
    perform: (_ inbound: TTYOutput, _ outbound: TTYStdinWriter) async throws -> Void
) async throws
```

### Output and input types
```swift
// TTYOutput — @available(macOS 15.0, *) — AsyncSequence<ExecCommandOutput>
enum ExecCommandOutput {
    case stdout(ByteBuffer)
    case stderr(ByteBuffer)
}

// TTYStdinWriter
func write(_ buffer: ByteBuffer) async throws
func changeSize(cols: Int, rows: Int, pixelWidth: Int, pixelHeight: Int) async throws
```

### Notes
- `withPTY` = PTY allocation + shell request (required for tmux attach)
- `withTTY` = raw shell, no PTY
- Both use the same closure shape `(inbound: TTYOutput, outbound: TTYStdinWriter)`
- `@available(macOS 15.0, *)` — `*` covers iOS without a version floor; compile on iOS 17 target needs CI confirmation before relying on this
- tmux requires PTY → use `withPTY`, not `withTTY`

## Slice 6B progress
1. ~~verify actual resolved Citadel interactive shell / PTY API~~ **done — Slice 6B.1**
2. ~~channel open via `withPTY`, drains inbound~~ **done — Slice 6B.2 (CI run 23228501849)**
3. send `tmux attach-session -t <name>` after channel open — **Slice 6B.3, next**
4. wire remote output to TerminalSessionService — Slice 6B.3/4
5. wire user input to remote stdin — Slice 6B.4
6. lifecycle hardening — Slice 6B.5

## Highest-priority files for Slice 6B
- `PocketMuxApp/SSH/SSHConnection.swift`
- `PocketMuxApp/SSH/SSHConnectionManager.swift`
- `PocketMuxApp/Terminal/TerminalAttachmentCoordinator.swift`
- `PocketMuxApp/Terminal/TerminalSessionService.swift`
- `COMPACT_CONTEXT.md`
- `PHASE_HANDOFF.md`

## Current risks
- Citadel interactive APIs may differ from assumed abstractions
- speculative PTY/channel work already broke CI once
- terminal rendering is still not a real VT100 parser
- host-key trust is still not production-safe
- public-key authentication is still incomplete

## Rule for next implementation session
Execute only one small Slice 6B increment at a time, verify CI, then update docs to reflect actual verified state only.
