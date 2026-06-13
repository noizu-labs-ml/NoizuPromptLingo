---
id: US-086
title: "Rate limiting feedback when user hits API quota"
slug: "rate-limiting-feedback"
personas: [P-001, P-006, P-008]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [rate-limiting, quota, error-handling]
---

# US-086: Rate limiting feedback when user hits API quota

## User Story

**As a** Freelance Consultant (P-006),
**I want to** receive clear feedback when I have hit my API usage quota,
**So that** I know why generation is blocked and when I can try again or how to upgrade.

## Acceptance Criteria

- [ ] Given a user has exhausted their generation quota, when they attempt to generate a mockup, then a rate limit message is shown with the quota limit, current usage, and the reset time
- [ ] Given the rate limit message is shown, when an upgrade plan is available, then a "Upgrade plan" link is displayed alongside the error
- [ ] Given an API client hits the rate limit, when the response is returned, then the HTTP response includes a `429` status with `Retry-After` and `X-RateLimit-Reset` headers

## Notes

Rate limits should be enforced per user account, not per IP, to avoid penalizing shared office networks. Display remaining quota count as a soft warning at 80% usage before the hard limit is reached. Related to US-083, US-084.
