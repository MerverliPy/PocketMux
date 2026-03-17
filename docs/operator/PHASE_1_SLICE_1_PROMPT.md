Read these files in order:
1. COMPACT_CONTEXT.md
2. PHASE_HANDOFF.md
3. PROJECT_MEMORY.md
4. PHASE_STATE.json
5. CLAUDE.md
6. docs/plan/IMPLEMENTATION_PHASES.md

Confirm the current allowed phase from PHASE_STATE.json.

Execute Phase 1 only.

Rules:
- create or update only files required by Phase 1
- do not begin Phase 2
- do not add implementation code unless required to validate an architectural decision
- do not create duplicate architecture docs
- keep all documents concise and decision-oriented
- if the requested work is complete, stop and hand off cleanly

For this session, do only Slice 1:
- docs/product/spec.md
- docs/architecture/adr-001-product-scope.md

Do not create any additional files beyond what is necessary for those two outputs.

Hard stop rule:
When the requested Slice is complete, stop immediately.
Do not propose or begin Phase 2 implementation.
Do not create Phase 2 files.
Do not reinterpret “next step” as permission to continue.
