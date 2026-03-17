# PocketMux Product Spec

## Product identity
PocketMux is an iPhone-native SSH client for persistent remote development sessions. It is not a local terminal emulator.

## Core job
Let a developer on an iPhone connect to a remote host, open or reattach multiple tmux sessions, switch between them as tabs, background the app, and return to exactly where they left off.

## Target user
A developer who runs real work on a remote machine and needs a first-class iPhone interface for session management, not a compromised desktop experience on a small screen.

## v1 scope

### Must have
- SSH connection to one remote host
- Multiple remote sessions exposed as top tabs
- Session persistence via remote tmux (reattach on return)
- Background/foreground recovery with no session loss
- iOS Keychain storage for SSH credentials and host trust material

### Explicitly excluded from v1
- Local shell execution
- Multiple simultaneous host connections
- iPad layout work
- Desktop-style split-pane management
- Plugin or extension marketplace
- Multi-user collaboration
- Speculative AI features

## Product constraints
- **Platform**: iPhone only
- **Transport**: SSH only
- **Persistence**: remote — app state is recoverable because the remote session survives
- **Reliability baseline**: tmux-compatible session reattach
- **UX model**: top-tab session switching, optimized for one-handed use

## dmux positioning
dmux metadata (task name, worktree, status) is a differentiation layer on top of the tmux session model. The app must remain fully functional on a host running plain tmux with no dmux dependency. dmux features enrich tabs; they do not gate session survival.

## Open questions (deferred to later phases)
- terminal rendering substrate (native vs. library)
- SSH library choice
- exact reconnect state restoration rules

## Naming conventions
| Term | Meaning |
|---|---|
| session | a persistent remote execution context |
| host | a remote machine profile |
| tab | the top-level mobile session selector |
| workspace metadata | task name, worktree, or status label from dmux |
