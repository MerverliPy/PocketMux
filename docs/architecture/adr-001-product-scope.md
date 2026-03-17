# ADR-001 — Product Scope

## Status
Draft

## Decision
PocketMux v1 is an iPhone-only, remote-first SSH session client for persistent remote development sessions.

## Includes
- SSH host connection
- persistent remote sessions
- tmux-compatible reattach behavior
- top-tab session switching
- remote-first UX

## Excludes
- local shell execution
- iPad-first UI
- desktop pane systems
- collaboration features
- plugin marketplace

## Rationale
Keeping the scope narrow protects the core product identity and reduces implementation drift.

## Consequences
The app must optimize for remote continuity, not generic terminal breadth.
