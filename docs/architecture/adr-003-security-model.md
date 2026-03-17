# ADR-003 — Security Model

## Status
Accepted

## Context
PocketMux is a mobile SSH client with long-lived remote access to developer machines. Security decisions made here determine how credentials are stored, how host identity is verified, and what attack surface the app presents. Mistakes in these areas could expose private keys, allow MITM attacks, or leak credentials through logs or app state.

## Decision

### Credential storage
All SSH credentials and host trust material are stored exclusively in the **iOS Keychain**. This includes:
- Private key material (Ed25519 preferred; RSA accepted for compatibility)
- SSH passphrases
- Host public key fingerprints for trust decisions

No credential material is written to UserDefaults, the filesystem, or included in iCloud or iTunes backups. Keychain items must use `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` to prevent cloud sync and ensure device lock protects access.

### Host key verification
On first connection, the app presents the host's public key fingerprint to the user for explicit approval. The approved fingerprint is stored in Keychain. On subsequent connections, the app compares the presented fingerprint against the stored value. If the fingerprint changes, the connection is refused and the user is notified with the conflicting fingerprint displayed. Silent acceptance of a changed host key is not permitted.

### Authentication methods
The app supports:
- Public key authentication (preferred)
- Password authentication (optional, at user discretion)

Password authentication must not be stored unless the user explicitly opts in. If stored, it is held in Keychain with the same access controls as key material.

### No local execution
The app does not execute shell commands locally. All command execution happens on the remote host over SSH. This eliminates a class of local command injection and privilege escalation risks.

### Network transport
All communication uses the SSH protocol. No fallback to plaintext or alternative transport is permitted. The SSH library used must support current cipher suites; deprecated ciphers (RC4, DES, MD5 MACs) must not be negotiated.

### Logging and error handling
- Private key material must never appear in logs, crash reports, or error messages.
- Host fingerprints may be logged for diagnostic purposes but must be treated as sensitive.
- SSH protocol errors must surface a user-facing message without exposing raw server banners that could leak host information.

### App state and backgrounding
- Terminal output in memory is not persisted to disk.
- When the app moves to background, no credential material is written to disk or app state snapshots.
- iOS memory pressure may purge terminal buffer content; this is acceptable — the session survives on the remote host.

### Future considerations (not in v1)
- Certificate-based authentication (SSH CA)
- Biometric re-auth gate before reconnect
- Per-session credential scoping

## Rationale
- iOS Keychain is the platform-appropriate credential store; it provides hardware-backed protection on modern devices.
- Explicit host key verification prevents MITM on first use and alerts users to unexpected host changes.
- No local execution removes the largest attack surface for command injection on the client side.
- Strict logging rules prevent inadvertent credential exposure through crash reporters or debug logs.

## Consequences
- The SSH library integration must expose host key callbacks before connection is established.
- The app cannot silently reconnect to a host whose fingerprint changed — user interaction is required.
- Credential UI must include clear affordances for whether password storage is opt-in.
- The app must test credential Keychain operations as part of integration verification.
- Deprecated SSH cipher support must be audited when the SSH library is selected in Phase 2.
