# COMPACT_CONTEXT

## Current phase
Phase 1 — Foundation

## Current objective
Produce the architectural decision documents and product spec that lock PocketMux's remote-first iPhone identity before any implementation code begins.

## Active constraints
- Keep PocketMux explicitly remote-first
- Keep v1 limited to iPhone
- Keep tmux as the default persistence baseline
- dmux is additive differentiation, not required for core session survival
- Do not implement product code yet
- Do not expand scope to local terminal behavior
- Do not leave dmux/tmux boundary ambiguous

## Immediate work
Phase 1 Slice 1 (complete):
- docs/product/spec.md
- docs/architecture/adr-001-product-scope.md

## Remaining Phase 1 work
- docs/architecture/adr-002-session-model.md
- docs/architecture/adr-003-security-model.md
- docs/architecture/ux-map.md
