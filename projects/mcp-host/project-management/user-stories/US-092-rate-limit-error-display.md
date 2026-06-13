---
id: US-092
title: "User sees meaningful error when tool invocation exceeds rate limit"
slug: "rate-limit-error-display"
personas: [P-004, P-001]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "S"
tags: [error-states, rate-limit, error-messages, ux, throttling]
---

# US-092: User Sees Meaningful Error When Tool Invocation Exceeds Rate Limit

## User Story

**As an** AI/ML Engineer (P-004),
**I want to** receive a clear, actionable error message when my tool invocation is rejected due to rate limiting,
**So that** I can understand what limit was hit, when I can retry, and what steps I can take to avoid hitting the limit again.

## Acceptance Criteria

- [ ] Given a tool invocation is rejected by the rate limiter, when the error response is returned to the caller, then it includes HTTP status 429, a human-readable error message ("Rate limit exceeded: 100 requests per minute for this tool"), the limit value, and a Retry-After header with the number of seconds until the limit resets
- [ ] Given a tool invocation is rejected due to a global platform rate limit (not per-tool), when the error is returned, then the message distinguishes between "platform-wide rate limit" and "per-tool rate limit" so the user knows which quota was exhausted
- [ ] Given an AI agent (P-008) receives a 429 response, when it parses the error payload, then the response includes a machine-readable error code ("RATE_LIMIT_EXCEEDED"), the limit scope, and the reset timestamp in ISO 8601 format
- [ ] Given a user is viewing the JustMCP.it dashboard, when they attempt an action that triggers a rate limit, then the UI displays a non-blocking toast notification with the limit details and a countdown until retry is available

## Notes

Rate limit errors are one of the most common friction points in API platforms. The error payload should follow RFC 7807 (Problem Details for HTTP APIs) for consistency. Related to US-090 (admin-managed rate limits) for the configuration side.
