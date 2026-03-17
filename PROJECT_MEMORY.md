# PROJECT_MEMORY

## Project goal
Build PocketMux as an iPhone-native, remote-first SSH client for persistent remote development sessions, optimized for fast task switching and session continuity.

## Locked constraints
- Platform: iPhone only for v1
- Product type: remote-first session client
- Transport: SSH
- Persistence: remote persistence required
- Reliability baseline: tmux-compatible session reattach
- Product identity: remote dmux/tmux client, not a generic local terminal
- UX model: top-tab session switching
- Security baseline: iOS Keychain for credentials and trust material

## Durable architecture decisions
- SwiftUI-first app architecture
- UIKit bridge allowed only where terminal rendering requires it
- tmux is the default persistence path
- dmux metadata is a differentiation layer, not a requirement for basic session survival
- One-host-first implementation is the initial usable loop
- Background/foreground recovery is a core product requirement

## Naming rules
- Product name: PocketMux
- Use "session" for remote persistent execution context
- Use "host" for remote machine profile
- Use "tab" for top-level mobile session selector
- Use "workspace metadata" for labels such as task, worktree, or status

## Approved tools
- Native Claude Code capabilities
- Repo-local files and docs
- Cloud macOS CI later in release phase

## Scope exclusions
- Local terminal runtime
- iPad-first UX
- Desktop pane manager features
- Plugin marketplace
- Collaborative multi-user sessions
- Overbuilt agent architecture in early phases

## Phase 1 locked clarifications
- Session model: one tab maps to one named tmux session on the remote host
- Reattach model: reconnect by stored tmux session name; if missing, prompt the user instead of silently dropping state
- tmux/dmux boundary: tmux is the required reliability substrate; dmux is optional metadata enrichment only
- v1 UI scope: tmux windows and panes are not first-class UI elements
- Security model: all credentials and host trust material live in iOS Keychain
- Host verification: first-connect fingerprint approval is required; changed fingerprints must be refused until re-approved
- Auth stance: public key authentication is preferred; password authentication is optional and must never be silently stored
- Local execution: no local shell execution in v1
- UX model: PocketMux is iPhone-only, remote-first, top-tab session switching, and one-handed use is a core product constraint
