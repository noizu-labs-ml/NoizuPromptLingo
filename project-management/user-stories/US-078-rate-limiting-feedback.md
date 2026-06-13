---
id: US-078
title: "Rate Limiting Feedback"
slug: "rate-limiting-feedback"
personas: [P-001, P-002, P-005]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "M"
tags: [rate-limiting, error-handling, feedback, api, abuse-prevention]
---

# US-078: Rate Limiting Feedback

## User Story

**As a** Prompt Engineer (P-001) or Indie Developer (P-005),
**I want to** receive clear, actionable feedback when I hit a rate limit,
**So that** I understand what action triggered the limit, how long to wait, and what my current usage allowance is.

## Acceptance Criteria

- [ ] Given a user rapidly submitting votes, when they exceed the vote rate limit, then a non-disruptive toast notification appears showing the limit hit and a countdown to when they can vote again
- [ ] Given an API consumer hitting request rate limits, when the limit is exceeded, then the API returns HTTP 429 with a `Retry-After` header and a JSON body containing the limit, current usage, and reset timestamp
- [ ] Given a user submitting prompts too quickly, when the submission rate limit is triggered, then the submit button is disabled with a visible countdown timer and an explanatory message
- [ ] Given any rate limit message, when it is displayed, then it differentiates between temporary throttling (try again soon) and daily limits (reset time shown in user's local timezone)

## Notes

Rate limiting UI feedback must be non-punitive in tone — framing limits as protection for the community rather than penalization. Backend must enforce limits at the API layer regardless of frontend state to prevent bypass. Depends on the authentication and session management systems.
