---
id: US-044
title: "Refresh an Expiring Guardian JWT Pair"
slug: "refresh-expiring-guardian-jwt-pair"
personas: [P-001]
epic: "Onboarding & Auth"
priority: "should-have"
complexity: "S"
tags: [jwt, session-refresh, oidc]
---

# US-044: Refresh an Expiring Guardian JWT Pair

## User Story

**As the** Harness Operator (P-001),
**I want to** have my Guardian JWT access/refresh pair renew automatically before it expires,
**So that** my session stays active without forcing me back through SSO login in the middle of a task.

## Acceptance Criteria

- [ ] Given I hold a valid, unexpired refresh token, when the access token nears or reaches expiry and a refresh request is made, then a new access/refresh pair is issued and the old access token is invalidated.
- [ ] Given my refresh token has itself expired or been revoked, when a refresh is attempted, then the request fails and I am redirected to re-authenticate via `/auth/oidc`.
- [ ] Given a refresh succeeds, when the new pair is issued, then in-flight requests made with the old access token within its remaining valid window are not abruptly broken mid-session.

## Notes

Extends the session established during first-time login in US-040; keeps human (not agent/MCP) sessions alive across a working day.
