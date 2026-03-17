# ADR-003 — Security Model

## Status
Draft

## Decision
PocketMux will use iOS-native secure storage and a strict remote trust model for SSH connectivity.

## Baseline controls
- credentials stored in Keychain
- host trust material stored securely
- explicit host identity handling
- no local shell execution
- remote-only execution model

## Rationale
Security must align with a mobile SSH client handling long-lived remote access.

## Consequences
Credential, trust, and reconnect design must be treated as first-class architecture concerns.
