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

## Completed Phase 1 work
- docs/product/spec.md (Slice 1)
- docs/architecture/adr-001-product-scope.md (Slice 1)
- docs/architecture/adr-002-session-model.md (Slice 2)
- docs/architecture/adr-003-security-model.md (Slice 2)
- docs/architecture/ux-map.md (Slice 3)

## Phase 1 status
COMPLETE. All Phase 1 deliverables are done.
Awaiting explicit user approval and PHASE_STATE.json advancement before Phase 2.
