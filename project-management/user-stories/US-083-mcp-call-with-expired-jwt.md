---
id: US-083
title: "Reject MCP Calls with an Expired JWT"
slug: "mcp-call-with-expired-jwt"
personas: [P-002]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "S"
tags: [auth, jwt, mcp, error-handling]
---

# US-083: Reject MCP Calls with an Expired JWT

## User Story

**As** the Autonomous Coding Agent (P-002),
**I want to** receive a clear, structured error when my JWT has expired during an MCP call,
**So that** I or my harness operator can detect the expiration and trigger re-authentication instead of retrying blindly or failing silently.

## Acceptance Criteria

- [ ] Given a valid MCP session whose JWT expired moments earlier, when the agent issues any tool call, then the server rejects it with a distinct `token_expired` error code rather than a generic 401 or 500.
- [ ] Given an expired JWT is rejected, when the error response is returned, then it includes the token's expiry timestamp so the caller can distinguish "expired" from "invalid" or "malformed."
- [ ] Given an expired JWT is rejected, when the event is logged server-side, then it is recorded as a routine auth-expiry event, not flagged as a security incident.
- [ ] Given a harness receives `token_expired` and obtains a fresh token, when it retries the original tool call, then the call succeeds without duplicate side effects.

## Notes

Distinguish from US-084 (revoked key) — different failure taxonomy even though both are auth rejections. Related to the tool_guard rollout (US-086), which also depends on JWT validity for identity resolution.
