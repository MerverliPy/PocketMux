# ADR-002 — Session Model

## Status
Draft

## Decision
PocketMux will treat the remote persistent session as the primary execution unit.
Hosts contain sessions.
Tabs represent session selectors.

## Baseline model
- one host profile
- multiple persistent remote sessions
- top-tab switching between sessions
- tmux-compatible reattach path

## dmux boundary
dmux is used for metadata and differentiation where beneficial.
dmux is not required for basic session survival.

## Rationale
This preserves reliability while allowing future metadata enhancement.

## Consequences
The app must maintain clear host/session/tab separation in code and UX.
