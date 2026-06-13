---
id: US-080
title: "Rate Limiting with Clear Error Messages"
slug: "rate-limiting-with-error-messages"
personas: [P-001, P-003, P-006]
epic: "API & Integration"
priority: "must-have"
complexity: "M"
tags: [api, rate-limiting, error-handling, developer-experience]
---

# US-080: Rate Limiting with Clear Error Messages

## User Story

**As an** API consumer building integrations (P-001, P-003, P-006),
**I want to** receive clear, machine-readable rate limit feedback on every API response,
**So that** I can implement correct backoff logic and avoid silent failures or unexpected 429 storms.

## Acceptance Criteria

- [ ] Given any successful API response, when I inspect the headers, then `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset` (Unix epoch) are present
- [ ] Given I exceed my rate limit, when the API responds with 429, then the response body includes `error.code`, `error.message`, `retry_after_seconds`, and a link to the rate limit documentation
- [ ] Given a 429 response, when I wait the `retry_after_seconds` duration and retry, then the request succeeds (assuming quota has reset)
- [ ] Given rate limits, when I view my API key settings, then I can see my current tier's limits (requests/minute, requests/day) and my current usage stats
- [ ] Given burst traffic, when requests arrive faster than the per-second limit, then a token bucket or leaky bucket algorithm is used to smooth bursts within the per-minute envelope
- [ ] Given an org plan, when any member key hits the limit, then the org-level quota is decremented (shared pool), not per-user independently

## Notes

Rate limit tiers: free (60/min, 1000/day), pro (300/min, 50k/day), enterprise (custom). The `X-RateLimit-Reset` timestamp must be in UTC. Retry-After header must also be set on 429 responses per RFC 6585.
