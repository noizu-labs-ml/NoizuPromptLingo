---
id: US-033
title: "Daily Vote Limits for New Accounts"
slug: "daily-vote-limits-new-accounts"
personas: [P-004, P-008]
epic: "Voting & Reputation"
priority: "should-have"
complexity: "S"
tags: [voting, rate-limiting, new-users, anti-abuse]
---

# US-033: Daily Vote Limits for New Accounts

## User Story

**As a** community moderator (P-004),
**I want to** enforce daily vote limits for newly registered accounts,
**So that** fresh sockpuppet accounts cannot immediately mass-vote to manipulate rankings.

## Acceptance Criteria

- [ ] Given a user account is fewer than 7 days old or has fewer than 10 karma points, when they attempt to cast more than 20 votes in a 24-hour period, then additional votes are blocked with an explanatory message
- [ ] Given a new user reaches their daily vote limit, when they attempt another vote, then they receive a friendly message explaining the limit and when it resets
- [ ] Given a user's account age exceeds the new-account threshold, when the daily cycle rolls over, then vote limits are automatically elevated to the standard tier without manual intervention
- [ ] Given an admin updates the vote limit configuration, when the new config is saved, then it applies to all subsequent voting sessions within 5 minutes

## Notes

Vote limits should be tiered by account age and karma, not purely binary. Limits and thresholds must be stored in configurable settings rather than hardcoded. The daily reset should align with UTC midnight to simplify debugging.
