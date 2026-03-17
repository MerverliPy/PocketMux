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
