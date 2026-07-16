---
id: US-043
title: "Mint an MCP JWT from a Raw API Key"
slug: "mint-mcp-jwt-from-api-key"
personas: [P-001, P-002]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [mcp, jwt, api-keys, agent-auth]
---

# US-043: Mint an MCP JWT from a Raw API Key

## User Story

**As the** Autonomous Coding Agent (P-002) configured by a Harness Operator (P-001),
**I want to** exchange the operator's raw MCP API key for a short-lived MCP JWT via `POST /api/mcp/token`,
**So that** I can authenticate ongoing MCP requests without transmitting the long-lived key on every call.

## Acceptance Criteria

- [ ] Given a valid, unrevoked raw MCP API key, when I call `POST /api/mcp/token` with it, then I receive a short-lived MCP JWT usable as a Bearer token in response.
- [ ] Given an invalid or revoked API key, when I call `POST /api/mcp/token`, then the request is rejected with an authentication error and no JWT is issued.
- [ ] Given a successfully issued MCP JWT, when I present it as `Authorization: Bearer <jwt>` on a subsequent MCP request, then the request is authenticated with the key's owning user and org scope.

## Notes

Consumes a key minted per US-041. If the underlying key is later revoked (US-045), new exchanges immediately fail even though already-issued JWTs remain bound by their own short expiry.
