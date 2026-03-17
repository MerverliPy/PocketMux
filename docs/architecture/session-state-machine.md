# Session State Machine — PocketMux v1

## Purpose
Defines the states and transitions for a single PocketMux session (one tab). Each tab tracks one named tmux session on the remote host. The SSH connection is shared across all tabs for the same host; session state is per-tab.

---

## Connection states (shared, per host)

```
DISCONNECTED
  │
  ├─[user configures host]──────────────────────────────────→ CONNECTING
  │
  └─[app foregrounded with stored host]────────────────────→ RECONNECTING

CONNECTING
  │
  ├─[host key unknown]─────────────────────────────────────→ AWAITING_KEY_APPROVAL
  ├─[host key matches stored]──────────────────────────────→ AUTHENTICATING
  └─[connection refused / timeout]─────────────────────────→ DISCONNECTED (error shown)

AWAITING_KEY_APPROVAL
  │
  ├─[user approves]────────────────────────────────────────→ AUTHENTICATING
  └─[user rejects]─────────────────────────────────────────→ DISCONNECTED (return to host setup)

AUTHENTICATING
  │
  ├─[auth success]─────────────────────────────────────────→ CONNECTED
  └─[auth failure]─────────────────────────────────────────→ DISCONNECTED (error shown)

CONNECTED
  │
  ├─[host key changed on reconnect]────────────────────────→ KEY_CONFLICT
  └─[SSH socket dropped (background/network)]──────────────→ RECONNECTING

KEY_CONFLICT
  │
  ├─[user trusts new key]──────────────────────────────────→ AUTHENTICATING
  └─[user disconnects]─────────────────────────────────────→ DISCONNECTED

RECONNECTING
  │
  ├─[reconnect success, key matches]───────────────────────→ CONNECTED
  ├─[host key changed]─────────────────────────────────────→ KEY_CONFLICT
  └─[reconnect failed after retries]───────────────────────→ DISCONNECTED (manual retry offered)
```

---

## Session states (per tab, depends on CONNECTED)

```
UNKNOWN
  │
  └─[SSH CONNECTED, enumerate tmux sessions]───────────────→ LISTING

LISTING
  │
  ├─[session name found on host]───────────────────────────→ ATTACHING
  └─[session name not found on host]───────────────────────→ ORPHANED

ATTACHING
  │
  ├─[tmux attach -t <name> success]────────────────────────→ ACTIVE
  └─[attach failed]────────────────────────────────────────→ ORPHANED

ACTIVE
  │
  ├─[SSH connection drops]─────────────────────────────────→ INTERRUPTED
  └─[user closes tab]──────────────────────────────────────→ CLOSED

INTERRUPTED
  │
  └─[SSH CONNECTED restored]───────────────────────────────→ LISTING (reattach attempt)

ORPHANED
  │
  ├─[user creates new session with same name]──────────────→ ATTACHING
  └─[user dismisses tab]───────────────────────────────────→ CLOSED

CLOSED
  (terminal state — tab removed from strip)
```

---

## State ownership

| State machine | Owner | Persistence |
|---|---|---|
| Connection states | `SSHConnectionManager` | in-memory; reconnect on foreground |
| Session states | `SessionManager` | session names persisted in UserDefaults |
| Host profile | `HostProfile` model | iOS Keychain (credentials) + UserDefaults (metadata) |

---

## Key invariants

1. **No silent acceptance.** `AWAITING_KEY_APPROVAL` and `KEY_CONFLICT` require explicit user action before proceeding.
2. **No silent session loss.** `ORPHANED` always surfaces a prompt; the tab is never silently removed.
3. **Reconnect is automatic but visible.** On foreground, `RECONNECTING` state is shown to the user; it is not a hidden background operation.
4. **Session name is the stable identifier.** The app never tracks sessions by SSH channel or ephemeral ID.
5. **tmux is the source of truth.** `LISTING` always calls `tmux list-sessions` on the remote host; local state is a cache only.

---

## tmux command map

| Action | Command |
|---|---|
| List sessions | `tmux list-sessions -F '#{session_name}'` |
| Attach to session | `tmux attach-session -t <name>` |
| Create new session | `tmux new-session -s <name>` |
| Check session exists | `tmux has-session -t <name>` |

---

## Relationship to other documents

| Document | Dependency |
|---|---|
| ADR-002 Session Model | States implement the lifecycle defined there |
| ADR-003 Security Model | `AWAITING_KEY_APPROVAL` and `KEY_CONFLICT` enforce security rules |
| docs/architecture/ux-map.md | Each state maps to a named screen in the UX map |
