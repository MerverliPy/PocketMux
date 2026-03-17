# ADR-001 — Product Scope

## Status
Accepted

## Context
PocketMux started as a concept for an iPhone SSH client. Without an explicit scope boundary, the product risks drifting toward:
- a generic local+remote terminal (scope creep)
- a desktop-style multi-pane manager on a small screen (UX mismatch)
- a speculative AI workflow tool (premature differentiation)

These failure modes all dilute the core value: reliable, persistent, fast-switching remote sessions on iPhone.

## Decision
PocketMux v1 is an **iPhone-only, remote-first SSH session client**.

Locked inclusions:
- SSH transport only
- One remote host for v1
- Multiple persistent sessions per host, exposed as top tabs
- tmux-compatible session reattach as the reliability baseline
- dmux metadata as an optional differentiation layer
- iOS Keychain for all credential and trust material storage

Locked exclusions:
- Local shell execution of any kind
- iPad or tablet UX
- Desktop-style pane splitting or window management
- Plugin or extension marketplace
- Multi-user collaboration
- Multi-host connection in v1
- Speculative or AI-driven features in v1

## Rationale
- Remote persistence means session state survives app backgrounding without complex client-side state management.
- tmux is ubiquitous and provides a proven reliability substrate; building on it keeps the implementation tractable.
- iPhone-only focus keeps UX decisions unambiguous — every layout choice is made for a single form factor.
- Narrowing to one host for v1 produces a complete, usable loop before adding host management complexity.
- Excluding local execution prevents the product from becoming a generic terminal, which has many incumbents.

## Consequences
- All layout decisions must be validated against iPhone screen real estate, not iPad or desktop.
- Session continuity and reconnect behavior are first-class requirements, not edge cases.
- dmux features must degrade gracefully — plain tmux on the host must always work.
- Multi-host UI is deferred; host management complexity is not incurred until Phase 2+.
- This ADR is a product identity boundary. Any feature that requires local execution violates it.
