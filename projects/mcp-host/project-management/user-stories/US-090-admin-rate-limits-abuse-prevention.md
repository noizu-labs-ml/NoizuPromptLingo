---
id: US-090
title: "Platform admin manages global rate limits and abuse prevention rules"
slug: "admin-rate-limits-abuse-prevention"
personas: [P-006, P-003]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "L"
tags: [admin, rate-limits, abuse-prevention, throttling, quotas]
---

# US-090: Platform Admin Manages Global Rate Limits and Abuse Prevention Rules

## User Story

**As an** Enterprise IT Admin (P-006),
**I want to** configure and manage global rate limits and abuse prevention rules from an admin console,
**So that** I can protect the platform from excessive use, prevent denial-of-service scenarios, and ensure fair resource allocation across all tenants.

## Acceptance Criteria

- [ ] Given a platform admin navigates to Admin > Rate Limits, when the page loads, then the current global rate limit rules are displayed with configurable fields for requests per minute, concurrent invocations, and burst allowance, scoped by tier (anonymous, authenticated, verified)
- [ ] Given a platform admin updates a global rate limit rule and saves it, when the save completes, then the new limits take effect within 60 seconds across all gateway nodes without requiring a restart
- [ ] Given a platform admin enables abuse prevention rules (e.g., auto-throttle callers exceeding 200% of their rate limit for 5 minutes, auto-flag servers with error rates above 50%), when a rule triggers, then the affected caller or server enters a throttled/flagged state with a recorded reason
- [ ] Given a platform admin views the abuse prevention log, when they filter by triggered rule type and time range, then they see each triggered event with the caller identity, affected server, rule that fired, and the automatic action taken

## Notes

Rate limits are enforced at the Auth Gateway layer before requests reach the Policy Engine. Global limits serve as a backstop -- per-server and per-tool rate limits (configured in manifests) take precedence when they are stricter. For self-hosted deployments, these are organization-scoped. Related to US-092 (user-facing rate limit errors) and US-077 (resource caps).
