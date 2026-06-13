---
id: US-013
title: "User creates a global rate-limit policy"
slug: "user-creates-global-rate-limit-policy"
personas: [P-002, P-003]
epic: "Policy Engine"
priority: "must-have"
complexity: "M"
tags: [policy, rate-limit, global, access-control]
---

# US-013: User Creates a Global Rate-Limit Policy

## User Story

**As a** Platform Engineer (P-002) or Security Engineer (P-003),
**I want to** create a platform-wide rate-limit policy that caps the number of tool invocations per time window,
**So that** I can prevent abuse, protect downstream services from overload, and ensure fair resource allocation across all callers.

## Acceptance Criteria

- [ ] Given the Policy Engine admin console, when the user creates a new policy with scope set to "global" and type set to "rate-limit," then the system presents a form for: max invocations, time window (per second/minute/hour), whether it applies per-caller or per-user, and optional tool pattern filter.
- [ ] Given a completed global rate-limit policy, when the user submits it, then the system validates the policy syntax, stores it as the global scope policy, and propagates it to all Auth Gateway instances within 60 seconds.
- [ ] Given an active global rate-limit of 100 requests per minute per caller, when a caller exceeds 100 invocations within a rolling 60-second window, then the system rejects subsequent requests with HTTP 429 and a `Retry-After` header.
- [ ] Given multiple rate-limit policies at different scopes (e.g., global 100/min and per-tool 10/min), when both apply to a request, then the system enforces the more restrictive limit.
- [ ] Given the policy list view, when the user views the global rate-limit policy, then the system displays current enforcement metrics: total requests blocked in the last 24 hours, top throttled callers, and a utilization heatmap.

## Notes

Global rate-limit policies are the outermost scope level and apply to all callers and users on the platform. They are the first line of defense against abuse and accidental overload. Rate counters should use a sliding window algorithm for accuracy. Related to US-008 (policy evaluation), US-014 (org-level policies).
