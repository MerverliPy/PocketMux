# ADR-002 — Session Model

## Status
Accepted

## Context
PocketMux exposes multiple persistent remote sessions as top tabs. The session model must answer:
- What creates a session and what terminates one
- How sessions survive app backgrounding and SSH interruption
- Where tmux ends and dmux begins
- What the app does when the SSH connection drops and when it returns

Without a clear model, reconnect behavior and tab state become ambiguous during implementation.

## Decision

### Session definition
A **session** is a named tmux session on the remote host. It exists on the host independently of the SSH connection. The app maps one tab to one tmux session.

### Lifecycle
```
connect SSH
  → list tmux sessions on host
  → attach to existing session by name (or create new)
  → render terminal output in tab

app backgrounded
  → SSH connection may drop (iOS kills idle sockets)
  → tmux session continues on host uninterrupted

app foregrounded
  → reconnect SSH
  → reattach to same tmux session by stored name
  → resume rendering
```

### Session naming
Sessions are identified by name, not by SSH channel or ephemeral ID. The name is stable across reconnects. The app persists session names locally (e.g., in UserDefaults) so reattach is deterministic on return.

### Multiple sessions
Multiple sessions per host are each a separate top tab. Sessions are independent tmux sessions on the same host — not tmux windows or panes within one session. v1 does not surface windows or panes as distinct UI elements.

### Reconnect behavior
On SSH reconnect, the app reattaches to the stored session name. If the session no longer exists (host reboot, manual kill), the app prompts the user to create a new session with the same name. The user is not silently dropped into a blank state.

### tmux / dmux boundary
- **tmux** is the required reliability substrate. Session create, list, attach, and reattach all use standard tmux commands. No dmux dependency is required for these operations.
- **dmux** provides optional workspace metadata: task name, worktree path, status label. This metadata enriches the tab display when available. Its absence does not affect session survival or tab switching.
- The app must never block on dmux availability. If dmux is not installed on the host, all core session operations continue unchanged.

### Explicit non-scope (v1)
- tmux windows within a session are not separate tabs.
- tmux panes are not surfaced as distinct UI elements.
- Local shell processes are not sessions.

## Rationale
- Naming sessions rather than tracking by channel ID makes reattach simple and host-reboot-safe.
- Separating sessions (tabs) from windows/panes avoids desktop-style pane management, which is excluded from v1.
- Keeping dmux strictly additive means the session model is implementable on any plain-tmux host without a setup dependency.
- Explicit reconnect handling prevents silent data-loss perception — the user always knows where their session stands.

## Consequences
- The app must persist session names across launches.
- Session listing must use `tmux list-sessions` as the canonical source of truth, not local state.
- Tab state is partially reconstructed from the remote host on each reconnect, not maintained purely client-side.
- dmux metadata polling is optional and must degrade silently when unavailable.
- Multi-window and split-pane UI is deferred to Phase 2+.
