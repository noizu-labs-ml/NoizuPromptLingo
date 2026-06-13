---
id: US-083
title: "Handle MCP timeout gracefully"
slug: "handle-mcp-timeout"
personas: [P-001, P-008]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "M"
tags: [error-handling, mcp, timeout, resilience]
---

# US-083: Handle MCP timeout gracefully

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** receive a clear timeout notification when mockup generation exceeds the allowed time,
**So that** I know to retry rather than waiting indefinitely for a hung request.

## Acceptance Criteria

- [ ] Given a mockup generation request is in progress, when it exceeds 60 seconds without a response, then the UI displays a timeout message with a "Retry" button
- [ ] Given a timeout has occurred, when the user clicks "Retry", then a new generation request is initiated with the same parameters
- [ ] Given an MCP timeout occurs in a CI pipeline context, when the agent receives the timeout error, then a structured JSON error response is returned with `error_code: "MCP_TIMEOUT"` and a `retry_after` hint

## Notes

Timeout threshold should be configurable via environment variable (`MCP_TIMEOUT_MS`, default 60000). Long-running jobs should emit progress events via SSE to keep the connection alive before the final timeout. Related to US-087.
