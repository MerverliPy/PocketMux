Read these files in order:
1. COMPACT_CONTEXT.md
2. PHASE_HANDOFF.md
3. PROJECT_MEMORY.md
4. PHASE_STATE.json
5. CLAUDE.md
6. docs/plan/IMPLEMENTATION_PHASES.md
7. docs/product/spec.md
8. docs/architecture/adr-001-product-scope.md
9. docs/architecture/adr-002-session-model.md
10. docs/architecture/adr-003-security-model.md

Confirm the current allowed phase from PHASE_STATE.json.

Execute Phase 1 only.

Rules:
- complete only the remaining required Phase 1 work
- do not begin Phase 2
- update only the files that genuinely need updating
- keep handoff/context files compact
- stop at Phase 1 completion and ask for permission before continuing

For this session, do only Slice 3:
- create docs/architecture/ux-map.md
- update PROJECT_MEMORY.md only if durable truths were clarified
- update COMPACT_CONTEXT.md for the next phase boundary
- update PHASE_HANDOFF.md with exact next action for Phase 2

At the end:
- summarize what was created
- list touched files
- list unresolved risks
- explicitly state that Phase 1 is complete and permission is required before Phase 2

Hard stop rule:
When the requested Slice is complete, stop immediately.
Do not propose or begin Phase 2 implementation.
Do not create Phase 2 files.
Do not reinterpret “next step” as permission to continue.
