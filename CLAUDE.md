# PocketMux — Claude Code Operating Guide

## Project identity
PocketMux is an iPhone-native, remote-first SSH session workspace.
It is not a generic local terminal.

## Product definition for v1
PocketMux v1 must remain:
- iPhone only
- remote host only
- SSH only
- persistent remote session client
- tmux-compatible by default
- dmux-aware where useful for metadata and task labeling

## Non-goals for v1
Do not add:
- local shell execution
- iPad-first layout work
- desktop-style pane management
- plugin marketplace
- multi-user collaboration
- speculative AI features

## Architecture direction
- Native iOS app
- SwiftUI-first UI
- UIKit bridge only where terminal rendering requires it
- SSH connection lifecycle managed per host
- Remote persistence required
- tmux is the default reliability substrate
- dmux is additive differentiation, not a hard dependency for core survival

## Repo working rules
1. Keep changes phase-scoped.
2. Prefer the smallest working implementation.
3. Do not introduce speculative abstractions.
4. Keep file creation intentional.
5. Keep project context compact.
6. Update `COMPACT_CONTEXT.md` and `PHASE_HANDOFF.md` only when work meaningfully changes.

## Read order at session start
1. `COMPACT_CONTEXT.md`
2. `PHASE_HANDOFF.md`
3. `PROJECT_MEMORY.md`
4. `PHASE_STATE.json`
5. `CLAUDE.md`
6. `docs/plan/IMPLEMENTATION_PHASES.md` only when phase boundaries or acceptance criteria matter

## Decision rules
- Protect the remote-first product identity.
- Protect iPhone ergonomics over desktop feature parity.
- Protect reconnect and session continuity over feature volume.
- Do not blur dmux and tmux responsibilities.
- Do not create files unless they materially improve execution quality.

## File responsibilities
- `PROJECT_MEMORY.md` stores durable truths and locked decisions.
- `COMPACT_CONTEXT.md` stores current phase, current objective, and active immediate constraints.
- `PHASE_HANDOFF.md` stores exact continuation instructions for the next session.
- `PHASE_STATE.json` stores the manually controlled phase lock.
- `docs/plan/IMPLEMENTATION_PHASES.md` stores the static roadmap and phase acceptance criteria.

## Phase gate
- The current allowed phase is defined by `PHASE_STATE.json`.
- Only create or update files required by the current phase.
- Never begin the next phase unless:
  1. the user explicitly approves it, and
  2. `PHASE_STATE.json` has been manually advanced.
- If the current phase is complete, stop, update context/handoff files if needed, and ask for permission to continue.
- Never edit `PHASE_STATE.json` unless the user explicitly instructs phase advancement.

## Documentation rules
- Keep architecture docs concise and decision-oriented.
- Prefer updating an existing file over creating a near-duplicate.
- Keep meta-documentation smaller than implementation documentation.
