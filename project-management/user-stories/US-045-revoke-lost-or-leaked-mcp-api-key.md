---
id: US-045
title: "Revoke a Lost or Leaked MCP API Key"
slug: "revoke-lost-or-leaked-mcp-api-key"
personas: [P-001]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [mcp, api-keys, revocation, security]
---

# US-045: Revoke a Lost or Leaked MCP API Key

## User Story

**As the** Harness Operator (P-001),
**I want to** immediately revoke an MCP API key I believe was lost or leaked,
**So that** no further requests can be authenticated with it while I mint a replacement.

## Acceptance Criteria

- [ ] Given a listed API key on `/app/mcp-keys`, when I select "revoke" and confirm, then the key's status changes to "revoked" immediately.
- [ ] Given a key was just revoked, when any client attempts to exchange that key's raw value for an MCP JWT via `POST /api/mcp/token`, then the exchange is rejected with an authentication error.
- [ ] Given a key is revoked, when I view my key list afterward, then the key remains visible with a "revoked" status and timestamp rather than disappearing, so I retain an audit trail.

## Notes

Complements minting in US-041 and JWT exchange in US-043 — revocation closes off the exchange path but does not retroactively invalidate a JWT already issued and still within its own short expiry.
