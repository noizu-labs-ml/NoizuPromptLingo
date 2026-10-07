---
id: US-302
title: "Complete the vfs/auth handshake and token lifecycle including re-auth and revocation"
slug: "vfs-auth-handshake-token-lifecycle"
personas: [P-002, P-006]
epic: "Virtual File System"
priority: "must-have"
complexity: "M"
tags: [vfs, auth, token-lifecycle, security]
---

# US-302: Complete the vfs/auth handshake and token lifecycle including re-auth and revocation

## User Story

**As a** Platform Administrator (P-006) responsible for the security posture consumed by an Autonomous Coding Agent (P-002),
**I want to** have a well-defined token lifecycle on VFS connections — handshake binding, expiry mid-session, revocation, and re-authentication —
**So that** a long-lived agent connection can never outlive its authorization, and a compromised connection can be cut off immediately.

## Acceptance Criteria

- [ ] Given a valid token, when the client sends `vfs/auth` as the first frame after connecting to `/vfs`, then the verified claims are bound to the connection Ctx and all subsequent operations execute under that principal.
- [ ] Given a connection whose token expires while open, when the client issues any VFS operation after expiry, then the operation is denied and the client is told to re-authenticate.
- [ ] Given a token that is revoked server-side while a connection is open, when any further operation is attempted, then it is denied (or the connection is terminated) within a bounded time.
- [ ] Given a re-authentication attempt on an existing connection, when the client sends a fresh `vfs/auth` handshake with a valid new token, then either the Ctx claims are refreshed or the documented "reconnect required" behavior is returned — no silent continuation under the old claims.
- [ ] Given the legacy Python fleet's session tokens versus the Elixir platform's DualTokenVerifier pipeline, when a client authenticates, then only the documented token kinds are accepted on the `/vfs` transport.

## Notes

The upgrade path already runs the same DualTokenVerifier bearer pipeline as the MCP surface (401 pre-auth); the handshake binds claims to the connection Ctx via `NoizuPromptLingua.MCP.VFS.Principal.context_assigns/0`. Lifecycle states beyond initial bind (expiry, revocation, refresh) are not covered by the current conformance test and need explicit spec-and-test.
