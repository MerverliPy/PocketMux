# COMPACT_CONTEXT

## Current phase
Phase 2 — Core product loop

## Current slice
Slice 6A complete; Slice 6B next

## Current objective
Keep the one-host PocketMux terminal path stable while moving from a compile-safe interactive shell boundary toward real remote tmux attach transport in small CI-verified increments.

## Verified repository state
- `main` is green again after reverting the broken Slice 6 PTY/channel attempt
- branch `feat/slice6-redo` contains the compile-safe interactive shell boundary
- `feat/slice6-redo` passed GitHub Actions iOS CI
- verified green run:
  - workflow: `PocketMux iOS CI`
  - run ID: `23225534283`
  - commit: `a39288b`

## Active constraints
- one host only
- iPhone-first only
- remote tmux only
- no local terminal runtime
- do not begin Phase 3
- do not expand into multi-host UI
- do not claim PTY/tmux transport is complete before CI proves it
- keep GitHub Actions green after each transport increment

## What is complete through Slice 6A
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
- compile-safe interactive shell boundary exists in:
  - `PocketMuxApp/SSH/SSHConnection.swift`
  - `PocketMuxApp/SSH/SSHConnectionManager.swift`

## What Slice 6A intentionally does not implement
- no `withPTY`
- no `PseudoTerminalRequest`
- no `TTYOutput`
- no `TTYStdinWriter`
- no live `tmux attach-session`
- no `ByteBuffer` streaming implementation
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

## Slice 6B target
Implement real interactive tmux attach transport behind the existing boundary in small steps:
1. ~~verify actual resolved Citadel interactive shell / PTY API~~ **done — Slice 6B.1**
2. add the smallest real transport increment (Slice 6B.2: channel open via `withPTY`)
3. keep CI green
4. stop on red and fix only the smallest failing assumption

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
