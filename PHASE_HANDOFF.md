# POCKETMUX — PHASE 2 HANDOFF
## Slice 6A complete / Slice 6B next

---

## CURRENT VERIFIED STATE

Repository state
- `main` is green again
- the failing Slice 6 transport commit was reverted on `main`
- a compile-safe interactive shell boundary was rebuilt on branch `feat/slice6-redo`

Verified green branch
- Branch: `feat/slice6-redo`
- Commit: `a39288b`
- CI run ID: `23225534283`
- Workflow: `PocketMux iOS CI`
- Result: `success`

Meaning
- Slice 6A is complete: the codebase now contains a compile-safe boundary for future interactive shell work without reintroducing the PTY/channel implementation that previously broke the build.

---

## SLICE 6A — COMPLETE

Objective
- Introduce a compile-safe interactive shell boundary without wiring real SSH PTY transport yet.

Outcome
- Completed successfully.

What exists now
- `PocketMuxApp/SSH/SSHConnection.swift`
  - compile-safe interactive shell boundary added
- `PocketMuxApp/SSH/SSHConnectionManager.swift`
  - matching manager passthrough added
- `COMPACT_CONTEXT.md`
  - updated to reflect Slice 6A status
- `PHASE_HANDOFF.md`
  - updated to reflect Slice 6A status

What Slice 6A deliberately does NOT do
- no `withPTY`
- no `PseudoTerminalRequest`
- no `TTYOutput`
- no `TTYStdinWriter`
- no live `tmux attach-session` execution
- no `ByteBuffer`-level PTY/channel streaming
- no dynamic terminal sizing
- no ANSI / VT100 renderer upgrade
- no special key forwarding

Acceptance result
- build passes in GitHub Actions
- `main` remains stable
- feature branch implementation is green before merge
- architecture boundary is ready for later transport fill-in

---

## LOCKED BASELINE AFTER SLICE 6A

Stable baseline commit path
- `main` contains the revert of the broken Slice 6 transport work
- `feat/slice6-redo` contains the compile-safe boundary that passed CI

Merge recommendation
- Merge `feat/slice6-redo` into `main` before any further terminal transport work.

Rule
- Do not implement live PTY/tmux attach directly on `main`.

---

## SLICE 6B — NEXT

Objective
- Implement the real interactive tmux attach transport behind the already-established shell boundary, while keeping CI green at every checkpoint.

Primary goal
- Move from compile-safe shell boundary to real remote interactive terminal transport.

In scope
- inspect the resolved Citadel API actually available in CI / Xcode
- implement the real interactive attach path incrementally
- wire remote shell/channel output into the terminal session service
- wire user input into remote stdin
- keep build passing after each incremental slice

Out of scope
- multi-host support
- Phase 3 work
- public-key auth completion
- production-grade host-key trust model
- advanced terminal UI polish
- iPad / macOS layout changes
- session metadata UI expansion

---

## SLICE 6B IMPLEMENTATION RULES

Hard constraints
- CI must remain green after every step
- do not land a large end-to-end PTY rewrite in one commit
- transport work must be split into small compile-verifiable increments
- if a Citadel API assumption is unverified, inspect first, then code
- no placeholder claims in docs that say transport is complete before CI proves it

Required branch strategy
- create a dedicated branch for Slice 6B
- keep each transport step isolated and reversible
- do not squash exploratory failures into `main`

Required verification rule
1. run GitHub Actions build
2. inspect first real errors if failure occurs
3. fix only the smallest failing assumption
4. rerun CI before proceeding

---

## SLICE 6B RECOMMENDED SUB-SLICES

Slice 6B.1 — API verification only — **COMPLETE (2026-03-17)**
Note: PseudoTerminalRequest init guessed in 6B.1 was partially wrong — see 6B.2 for corrected signature.

Verified facts (source: Citadel 0.12.0 at orlandos-nl/Citadel, confirmed via GitHub source fetch)

Citadel version resolved: 0.12.0 (upToNextMajorVersion from 0.6.0)

Confirmed connect API (already green in CI):
- `SSHClientSettings(host:port:authenticationMethod:hostKeyValidator:)` — `authenticationMethod` is a closure `@Sendable @escaping () -> SSHAuthenticationMethod`
- `SSHClient.connect(to: SSHClientSettings) async throws -> SSHClient`

Confirmed interactive shell / PTY API:
```swift
// @available(macOS 15.0, *) — no iOS minimum floor declared; * covers all other platforms
SSHClient.withPTY(
    _ request: SSHChannelRequestEvent.PseudoTerminalRequest,
    environment: [SSHChannelRequestEvent.EnvironmentRequest] = [],
    perform: (_ inbound: TTYOutput, _ outbound: TTYStdinWriter) async throws -> Void
) async throws

SSHClient.withTTY(
    environment: [SSHChannelRequestEvent.EnvironmentRequest] = [],
    perform: (_ inbound: TTYOutput, _ outbound: TTYStdinWriter) async throws -> Void
) async throws
```

Confirmed output/input types:
```swift
TTYOutput: AsyncSequence  // @available(macOS 15.0, *), yields ExecCommandOutput
enum ExecCommandOutput { case stdout(ByteBuffer); case stderr(ByteBuffer) }
TTYStdinWriter.write(_ buffer: ByteBuffer) async throws
TTYStdinWriter.changeSize(cols: Int, rows: Int, pixelWidth: Int, pixelHeight: Int) async throws
```

Key decisions from API review:
- tmux requires PTY allocation → must use `withPTY`, not `withTTY`
- `PTY`/`withTTY` availability: `@available(macOS 15.0, *)` with `*` covers iOS without a floor
  — iOS 17 compile behavior is unconfirmed; CI must verify before relying on it
- The `withPTY` closure owns the session lifetime; detach/cancel happens via task cancellation or closing the `perform` closure normally

Slice 6B.2 — channel open + ready handshake — **COMPLETE (2026-03-17)**

Goal
- Replace `openInteractiveShell()` stub in `SSHConnection` with a real `withPTY` call.

Confirmed actual NIOSSH 0.3.5 `PseudoTerminalRequest` init (differs from documented guess):
```swift
SSHChannelRequestEvent.PseudoTerminalRequest(
    wantReply: true,               // required — not in earlier docs
    term: "xterm-256color",
    terminalCharacterWidth: cols,  // Int, NOT UInt32
    terminalRowHeight: rows,       // Int, NOT UInt32
    terminalPixelWidth: 0,
    terminalPixelHeight: 0,
    terminalModes: .init([:])      // dictionary literal, NOT array
)
```

Delivered
- `SSHConnection.openInteractiveShell(cols:rows:)` — real `withPTY` call, drains inbound
- `SSHConnectionManager.openInteractiveShell(cols:rows:)` — matching passthrough
- `@available(macOS 15.0, *)` does NOT block iOS 17 Simulator build — confirmed

CI result
- run ID: `23228501849`
- result: success
- branch: `feat/slice6b-transport`
- commit: `b9425ba`

Slice 6B.3 — tmux attach command execution — **COMPLETE (2026-03-17)**

Goal
- Send `tmux attach-session -t <sessionName>` after the shell/channel is ready.

Delivered
- `SSHConnection.openInteractiveShell(sessionName:cols:rows:onOutput:)` — writes tmux attach command to remote stdin; forwards inbound `ExecCommandOutput` bytes to `onOutput` closure
- `SSHConnectionManager.openInteractiveShell(sessionName:cols:rows:onOutput:)` — passthrough updated
- `TerminalAttachmentCoordinator.attach(using:)` — starts PTY session on background `Task`; wires `onOutput`; `close()` cancels the task
- `import NIO` added to SSHConnection.swift (required for `ByteBuffer(string:)` and `readableBytesView` — not re-exported by Citadel/NIOSSH)

CI result
- run ID: `23229029983`
- result: success
- branch: `feat/slice6b-transport`
- commit: `17f0c38`

Slice 6B.4 — input forwarding — **NEXT**

Goal
- Wire user keyboard input into remote stdin.

Deliverables
- service `send(_:)` reaches remote channel
- minimal text input path works

Acceptance
- compile passes
- no actor or lifecycle regressions

Slice 6B.5 — lifecycle hardening

Goal
- Handle detach, cancellation, reconnect, and stream-end transitions cleanly.

Deliverables
- terminal state transitions audited
- disconnect/end-of-stream behavior cleaned up
- docs updated

Acceptance
- CI green
- no leaked session task assumptions
- no false `.attached` state after stream termination

---

## FILES MOST LIKELY TO CHANGE IN SLICE 6B

Primary
- `PocketMuxApp/SSH/SSHConnection.swift`
- `PocketMuxApp/SSH/SSHConnectionManager.swift`
- `PocketMuxApp/Terminal/TerminalAttachmentCoordinator.swift`
- `PocketMuxApp/Terminal/TerminalSessionService.swift`

Secondary
- `PocketMuxApp/Terminal/TerminalContainerView.swift`
- `COMPACT_CONTEXT.md`
- `PHASE_HANDOFF.md`

Optional later
- terminal renderer files, if ANSI/VT100 rendering becomes necessary after transport works

---

## CURRENT KNOWN RISKS

- Citadel interactive APIs may differ from assumed shell/PTY abstractions
- prior full Slice 6 transport attempt already proved that speculative implementation can break CI
- terminal rendering is still not a real VT100 parser
- host-key trust remains non-production-safe
- public-key auth remains incomplete

---

## ACCEPTANCE CRITERIA FOR FULL SLICE 6B

Slice 6B is only complete when all of the following are true:
1. interactive remote shell path is implemented behind the existing boundary
2. tmux attach is actually invoked through that transport
3. remote output reaches the terminal session service
4. local input is forwarded back to the remote session
5. lifecycle transitions are coherent on detach / failure / cancellation
6. GitHub Actions iOS CI passes
7. docs reflect actual verified state, not intended state

---

## DO NOT DO

- do not mark transport complete before CI passes
- do not update docs optimistically
- do not merge experimental PTY work directly into `main`
- do not add SwiftTerm in the same commit as first PTY transport wiring
- do not expand scope into Phase 3

---

## RECOMMENDED NEXT COMMAND SEQUENCE

git checkout main
git pull --rebase origin main
git merge --ff-only feat/slice6-redo
git push origin main

git checkout -b feat/slice6b-transport

---

## COPY/PASTE AGENT PROMPT — SLICE 6B START

POCKETMUX — PHASE 2 / SLICE 6B

Starting point is the green compile-safe shell boundary from Slice 6A.

Locked constraints:
- keep scope to one-host iPhone-only remote tmux
- do not begin Phase 3
- do not add multi-host support
- do not claim transport is complete before CI proves it
- keep GitHub Actions green after each increment

Immediate task:
1. Inspect the currently resolved Citadel API for interactive shell / PTY support.
2. Update COMPACT_CONTEXT.md and PHASE_HANDOFF.md with verified API facts only.
3. Implement the smallest compile-safe real transport increment possible.
4. Do not implement the full PTY/tmux attach path in one jump.
5. After each increment, run CI and stop if red.

Priority files:
- PocketMuxApp/SSH/SSHConnection.swift
- PocketMuxApp/SSH/SSHConnectionManager.swift
- PocketMuxApp/Terminal/TerminalAttachmentCoordinator.swift
- PocketMuxApp/Terminal/TerminalSessionService.swift
- COMPACT_CONTEXT.md
- PHASE_HANDOFF.md

Definition of done for this work session:
- one small transport increment landed
- CI result known
- docs updated to factual current state
- no speculative “complete” claims
