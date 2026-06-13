---
id: US-062
title: "Leaderboard of Top Contributors"
slug: "leaderboard-top-contributors"
personas: [P-001, P-002, P-006, P-008]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "M"
tags: [leaderboard, gamification, reputation, contributors]
---

# US-062: Leaderboard of Top Contributors

## User Story

**As an** AI newcomer (P-008),
**I want to** browse a leaderboard of top contributors,
**So that** I can identify the most knowledgeable community members and find high-quality prompts to learn from.

## Acceptance Criteria

- [ ] Given the leaderboard page, when I view it, then I see a ranked list of users sorted by a composite reputation score (upvotes received, prompt count, engagement)
- [ ] Given the leaderboard, when I select a time filter (all-time, this month, this week), then the rankings update accordingly
- [ ] Given a leaderboard entry, when I click a user's name, then I am taken to their profile page (US-061)
- [ ] Given a new user has not yet contributed, when they view the leaderboard, then they see a call-to-action to submit their first prompt

## Notes

Reputation scoring algorithm should be transparent and documented to maintain community trust. The leaderboard should be cached and refreshed periodically (e.g., hourly) rather than computed live to avoid performance issues.
