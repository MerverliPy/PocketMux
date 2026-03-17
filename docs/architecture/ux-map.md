# UX Map — PocketMux v1

## Purpose
This document locks the iPhone interaction model before implementation begins. It defines screens, flows, and interaction rules. It does not specify visual design.

---

## Principles

1. **Remote-first clarity** — every screen reflects remote state, not local assumption.
2. **One-handed reachability** — primary actions sit in thumb reach on iPhone.
3. **Session continuity over freshness** — the app always tries to return the user to where they left off, never silently resets.
4. **Explicit over automatic** — reconnect, trust decisions, and session creation are confirmed by the user, not silent.

---

## Screen inventory

### 1. Host Setup Screen
**When shown**: first launch, or when no host is configured.

**Purpose**: collect host address, port, username, and authentication method.

**Inputs**:
- Hostname or IP
- Port (default 22)
- Username
- Auth method: public key (preferred) or password (optional)
- Private key selector (if public key auth)

**Outcome**: host profile saved; SSH credential written to iOS Keychain; proceeds to Host Key Verification.

**Constraints**:
- No local execution path.
- No multi-host management in v1. One host only.
- Password storage is opt-in, not default.

---

### 2. Host Key Verification Screen
**When shown**: first connection to a host.

**Purpose**: present the host's public key fingerprint for explicit user approval.

**Inputs**:
- Display fingerprint (SHA-256, human-readable)
- Trust / Reject

**Outcome**: approved fingerprint stored in Keychain; proceeds to Session List. If rejected, returns to Host Setup Screen.

**Constraints**:
- Silent acceptance is not permitted.
- Changed fingerprint on return triggers Fingerprint Conflict Screen, not silent acceptance.

---

### 3. Session List Screen (main shell)
**When shown**: after successful SSH connection with host key trusted.

**Purpose**: show all active remote tmux sessions as named tabs; let the user open, reattach, or create sessions.

**Layout**:
- Top tab bar: one tab per remote tmux session, identified by session name.
- Active tab: renders terminal output.
- Tab bar actions: add new session (+ button), long-press tab for rename/close.
- dmux metadata (task name, worktree, status) displayed in tab label when available; plain session name when not.

**Reachability**:
- Tab bar at top (reachable via swipe or tap; primary tab switching action).
- Primary action (new session) accessible without scrolling.

**Empty state**: no sessions on host — prompt to create the first session.

**Constraints**:
- Sessions are independent tmux sessions, not windows or panes.
- Tab count is not artificially limited, but no pagination UI is required in v1.
- dmux metadata enriches the label only; its absence does not change tab behavior.

---

### 4. Terminal View (inline, inside active tab)
**When shown**: when a session tab is selected.

**Purpose**: render remote terminal output; accept keyboard input; send it to the remote session over SSH.

**Layout**:
- Full-width terminal canvas.
- iOS system keyboard or hardware keyboard.
- Thin status strip (session name, connection indicator) above the terminal canvas.
- Tab bar remains accessible above the status strip.

**Keyboard behavior**:
- System keyboard appears when terminal is tapped.
- Keyboard toolbar row for common keys not on iOS keyboard: Escape, Tab, Ctrl, arrow keys.
- Hardware keyboard supported natively.

**Constraints**:
- Terminal rendering substrate is deferred to Phase 2 (pending SSH library selection).
- No tmux window or pane splitting UI in v1.
- Terminal buffer is in-memory only; not persisted to disk.

---

### 5. Reconnect Screen
**When shown**: app foregrounded after SSH connection dropped (iOS backgrounded socket).

**Purpose**: inform the user the connection was interrupted; offer immediate reconnect.

**Layout**:
- Inline overlay on the affected tab: "Session interrupted — Reconnecting…" with spinner.
- Auto-reconnect attempt runs immediately on foreground.
- If reconnect succeeds: overlay dismissed, terminal resumes.
- If reconnect fails: "Could not reconnect to [host]. Retry / Edit host."

**Session reattach**:
- On successful SSH reconnect, app reattaches to the stored session name using `tmux attach -t <name>`.
- If session no longer exists: Orphaned Session Prompt.

**Constraints**:
- Reconnect is automatic but visible. No silent failures.
- Multiple tabs each attempt reattach to their stored session name independently.

---

### 6. Orphaned Session Prompt
**When shown**: after reconnect, when a stored session name no longer exists on the host.

**Purpose**: inform the user the session was lost; offer recovery.

**Options**:
- Create new session with the same name.
- Dismiss tab.

**Constraints**:
- User is not silently dropped into a blank terminal.
- The tab is not automatically removed; user chooses.

---

### 7. Fingerprint Conflict Screen
**When shown**: SSH connection presents a fingerprint that differs from the stored trusted value.

**Purpose**: alert the user to a potential host identity change; require explicit action.

**Layout**:
- Clear warning: "Host key has changed."
- Show stored fingerprint and new fingerprint side by side.
- Options: Trust new key (replaces stored) / Disconnect.

**Constraints**:
- Connection is refused until user resolves the conflict.
- Silent acceptance of a changed key is not permitted.

---

## Navigation flows

### First launch
```
Host Setup → Host Key Verification → Session List (empty) → Create first session → Terminal View
```

### Return after backgrounding
```
App foreground → Reconnect attempt (auto)
  → success → Terminal View (reattached)
  → session missing → Orphaned Session Prompt
  → host unreachable → Reconnect Screen (manual retry)
```

### Session switching
```
Terminal View → tap tab → Terminal View (different session)
Terminal View → tap + → new session name input → Terminal View (new session)
```

### Host key conflict
```
App foreground → SSH connect → fingerprint mismatch → Fingerprint Conflict Screen
  → trust new → Session List
  → disconnect → Host Setup Screen
```

---

## Interaction rules

| Rule | Rationale |
|---|---|
| Tab bar is always visible when connected | Session switching is a primary action; it must not require navigation |
| New session requires name input | Session names are stable identifiers; anonymous sessions create reattach ambiguity |
| Reconnect is automatic on foreground | Users expect to return to where they were; manual retry is a fallback only |
| Password storage is opt-in | Default is key-based auth; storing passwords requires explicit user decision |
| Changed host key always prompts | Silent trust of a changed key is a security failure, not a UX convenience |

---

## Deferred to Phase 2+

- Terminal rendering substrate selection
- Exact keyboard toolbar key layout (validated during implementation)
- tmux window or pane navigation
- Host management (add, edit, delete multiple hosts)
- Biometric re-auth before reconnect
- dmux metadata display design detail
- Onboarding walkthrough
- Gesture model beyond tap

---

## Relationship to other decisions

| Document | Dependency |
|---|---|
| ADR-001 Product Scope | UX is iPhone-only; no iPad layout variants |
| ADR-002 Session Model | Tabs map 1:1 to tmux sessions; reconnect follows session-by-name reattach |
| ADR-003 Security Model | Host key verification and credential opt-in are enforced in UX flows |
| docs/product/spec.md | Top-tab session switching and one-handed use are direct product constraints |
