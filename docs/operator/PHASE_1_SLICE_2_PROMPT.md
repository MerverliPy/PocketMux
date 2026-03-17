Read these files in order:
1. COMPACT_CONTEXT.md
2. PHASE_HANDOFF.md
3. PROJECT_MEMORY.md
4. PHASE_STATE.json
5. CLAUDE.md
6. docs/plan/IMPLEMENTATION_PHASES.md
7. docs/product/spec.md
8. docs/architecture/adr-001-product-scope.md

Confirm the current allowed phase from PHASE_STATE.json.

Execute Phase 1 only.

Rules:
- create or update only files required by Phase 1
- do not begin Phase 2
- do not create extra architecture docs
- keep decisions explicit, concise, and implementation-relevant
- stop when Slice 2 is complete

For this session, do only Slice 2:
- docs/architecture/adr-002-session-model.md
- docs/architecture/adr-003-security-model.md

Do not create any other files unless required to complete those two ADRs well.

Hard stop rule:
When the requested Slice is complete, stop immediately.
Do not propose or begin Phase 2 implementation.
Do not create Phase 2 files.
Do not reinterpret “next step” as permission to continue.
