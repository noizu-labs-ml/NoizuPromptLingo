---
id: US-084
title: "Reject MCP Calls Using a Revoked API Key"
slug: "mcp-call-with-revoked-api-key"
personas: [P-002, P-006]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "S"
tags: [auth, api-key, mcp, security]
---

# US-084: Reject MCP Calls Using a Revoked API Key

## User Story

**As** the Platform Administrator (P-006),
**I want to** have any MCP call authenticated with a revoked API key rejected immediately,
**So that** key revocation is actually effective the moment I act on it, not just cosmetic in the admin console.

## Acceptance Criteria

- [ ] Given an API key was revoked via the admin console, when an MCP call authenticated with that key arrives, then the server rejects it with a distinct `key_revoked` error code rather than `token_expired` or a generic 401.
- [ ] Given a revoked key is used, when the rejection occurs, then a security-relevant audit log entry is written with the key's identifier (never the raw secret), the calling actor if known, and a timestamp.
- [ ] Given the Autonomous Coding Agent (P-002) is using a revoked key, when it receives `key_revoked`, then it does not automatically retry with the same key, and the error is surfaced to the harness operator.
- [ ] Given a key is revoked, when revocation propagates through caching layers, then it takes effect across all API nodes within a defined bound (e.g., cache TTL of 60 seconds or less), not at next deploy.

## Notes

Pairs with US-083 — both are auth-rejection paths but carry different codes and telemetry since revocation is security-sensitive while expiry is routine. Revocation propagation bound should align with existing key-cache invalidation design.
