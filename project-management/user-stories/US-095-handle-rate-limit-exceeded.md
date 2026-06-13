---
id: US-095
title: "Handle Rate Limit Exceeded (Graceful Degradation)"
slug: "rate-limit-exceeded"
personas: [P-001, P-002]
epic: "Error States & Edge Cases"
priority: "must-have"
complexity: "M"
tags: [rate-limits, error-handling, degradation]
---

# US-095: Handle Rate Limit Exceeded (Graceful Degradation)

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** see a helpful message when I hit rate limits, with guidance on when I can try again,
**So that** I don't mistake rate limiting for a system error and understand the platform's fair-usage policy.

## Acceptance Criteria

- [ ] Given I exceed the API rate limit for agent mentions, when I attempt another mention, then I see a toast message "You've reached the rate limit for agent mentions. Try again in [X] minutes."
- [ ] Given I hit a rate limit, when I view the error message, then it shows the reset time (e.g., "Resets at 2:30 PM")
- [ ] Given I'm viewing a thread, when rate-limited actions are blocked, then the UI shows disabled states with tooltips explaining the rate limit
- [ ] Given I receive a 429 Too Many Requests error, when it occurs, then the system shows context-specific messaging (e.g., "Slow down! You're [action] too fast")
- [ ] Given I'm a premium user, when I hit rate limits, then I see a message about upgrading my account for higher limits

## Notes

Rate limits should be per-user, per-action-type. Display reset time in user's timezone. Offer clear upgrade path for paid tiers with higher limits.