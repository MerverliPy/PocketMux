# PocketMux Implementation Phases

## Transition rule
Each phase must end with:
1. phase-local work completion
2. compact handoff update
3. explicit stop

The next phase must not begin until the user approves it and `PHASE_STATE.json` is manually advanced.

---

## PHASE 0 — SKELETON REPO

### Objective
Create the minimal repo structure and Claude Code artifact pack required to execute the project cleanly.

### Deliverable
A planning-ready repo with minimal project memory, current context, handoff file, phase gate, and Claude operating instructions.

### Files to create
- CLAUDE.md
- .claude/settings.json
- PROJECT_MEMORY.md
- COMPACT_CONTEXT.md
- PHASE_HANDOFF.md
- PHASE_STATE.json
- docs/plan/IMPLEMENTATION_PHASES.md
- scripts/show-phase.sh
- scripts/advance-phase.sh

### Constraints
- Do not add MCP config yet
- Do not add agents yet
- Do not add skills yet
- Do not add local machine overrides
- Do not create Phase 1 implementation docs unless the user explicitly requested templates

### Acceptance criteria
- Repo exists with the minimal operating files
- Stable memory is separated from current working context
- Phase advancement is manually gated
- Next session can begin Phase 1 safely after explicit approval

---

## PHASE 1 — FOUNDATION

### Objective
Define PocketMux explicitly as a remote iPhone dmux/tmux session client.

### Deliverable
Architecture decision documents for product scope, session model, security model, UX structure, and release pipeline direction.

### Files to create or update
- docs/product/spec.md
- docs/architecture/adr-001-product-scope.md
- docs/architecture/adr-002-session-model.md
- docs/architecture/adr-003-security-model.md
- docs/architecture/ux-map.md
- PROJECT_MEMORY.md
- COMPACT_CONTEXT.md
- PHASE_HANDOFF.md

### Required decisions
- Remote-only scope
- iPhone-only v1
- SSH transport strategy
- tmux compatibility boundaries
- dmux as metadata and differentiation layer
- top-tab interaction rules
- reconnect lifecycle assumptions
- cloud macOS CI direction

### Constraints
- Do not implement product code yet unless required to validate an architectural choice
- Do not expand scope to local terminal behavior
- Do not leave dmux/tmux boundary ambiguous

### Acceptance criteria
- Product scope ADR is complete
- Session model ADR is complete
- Security model ADR is complete
- Product is explicitly defined as a remote-first iPhone session client

### Next handoff
Begin the one-host working loop only after explicit user approval

---

## PHASE 2 — CORE PRODUCT LOOP

### Objective
Implement one-host connection flow with multiple remote sessions exposed as top tabs.

### Deliverable
A working prototype where the user can connect to one host, switch sessions, background the app, return, and continue.

### Files to create or update
- PocketMuxApp/... app source files
- docs/architecture/session-state-machine.md
- docs/testing/core-loop-checklist.md
- COMPACT_CONTEXT.md
- PHASE_HANDOFF.md

### Constraints
- One host only
- Multiple sessions required
- Session persistence must rely on remote persistence model
- Do not introduce multi-host UI yet
- Do not introduce advanced metadata UI yet

### Acceptance criteria
- User can connect to one remote host
- User can open or reattach multiple sessions
- User can switch tabs without losing terminal state
- App background and foreground cycle preserves usable session continuity

---

## PHASE 3 — DIFFERENTIATION LAYER

### Objective
Transform the experience from generic terminal tabs into named mobile work sessions.

### Deliverable
Metadata-aware tabs with naming, labels, quick actions, and lightweight session previews.

### Files to create or update
- PocketMuxApp/... UI and metadata mapping source
- docs/product/metadata-contract.md
- docs/ux/tab-information-density.md
- COMPACT_CONTEXT.md
- PHASE_HANDOFF.md

### Constraints
- Metadata must not overload the screen
- tmux-compatible fallback must continue working without dmux-only features
- Do not reduce core reliability for UI enhancement

### Acceptance criteria
- Tabs read as named tasks, not anonymous shells
- Metadata improves navigation speed
- UI remains legible on iPhone

---

## PHASE 4 — UX REFINEMENT

### Objective
Make the app feel purpose-built for iPhone rather than a compressed terminal emulator.

### Deliverable
Refined gesture model, keyboard flow, tab hierarchy, theme polish, recovery polish, and onboarding.

### Files to create or update
- PocketMuxApp/... UI source
- docs/ux/gesture-model.md
- docs/ux/onboarding-flow.md
- docs/testing/usability-checklist.md
- PHASE_HANDOFF.md

### Constraints
- Do not add hidden or overloaded gestures
- Do not add tablet-specific UX
- Preserve clarity under dense multitasking conditions

### Acceptance criteria
- Product feels faster and clearer on iPhone than generic SSH apps
- Core interactions are reachable and understandable with one hand
- Onboarding explains the remote-session model clearly

---

## PHASE 5 — PRODUCTION READINESS

### Objective
Prepare the app for external beta, App Store submission, and paid positioning.

### Deliverable
A release-ready operational layer covering CI, TestFlight, privacy, monetization, recovery, and positioning.

### Files to create or update
- .github/workflows/* or equivalent CI config
- docs/release/testflight-runbook.md
- docs/policy/privacy-analytics.md
- docs/business/pricing.md
- docs/ops/crash-recovery.md
- PROJECT_MEMORY.md
- PHASE_HANDOFF.md

### Constraints
- Must remain Apple-compliant
- Must avoid privacy stance drift
- Must not ship unclear product messaging

### Acceptance criteria
- External beta can be distributed
- Submission path is defined
- Pricing and positioning are documented
- Reliability and support workflow are documented
