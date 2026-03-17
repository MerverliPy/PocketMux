# PocketMux Product Spec

## Summary
PocketMux is an iPhone-native, remote-first SSH workspace for persistent remote sessions.

## V1 definition
- iPhone only
- remote host only
- SSH only
- persistent remote sessions
- tmux-compatible baseline
- dmux-aware metadata where useful

## Primary user
A developer who wants fast session switching and continuity on iPhone while connected to a remote machine.

## Core user jobs
- connect to a remote host quickly
- resume persistent sessions without setup repetition
- switch tasks through top tabs
- recover smoothly from background/foreground transitions

## Non-goals
- local shell execution
- iPad-first UX
- desktop pane management
- plugin marketplace
- speculative AI workflows

## UX model
- top-tab session switching
- host-centric connection model
- session continuity over feature density

## Open questions
- terminal rendering substrate
- SSH library choice
- exact reconnect state restoration rules
