---
id: US-060
title: "View Leaderboard for Competitive Labs"
slug: "view-leaderboard-for-competitive-labs"
personas: [P-008, P-001]
epic: "Academy — Labs"
priority: "could-have"
complexity: "M"
tags: [academy, leaderboard, competition, gamification, community]
---

# US-060: View Leaderboard for Competitive Labs

## User Story

**As a** CTF competitor and security student (P-008),
**I want to** see a leaderboard showing top performers on competitive labs,
**So that** I can measure myself against others, find inspiration in high-scoring approaches, and participate in the community competitive culture.

## Acceptance Criteria

- [ ] Given I view a lab that is marked as "competitive," when I scroll to the leaderboard section, then I see the top 25 completions ranked by score (with ties broken by completion time)
- [ ] Given I have completed a competitive lab, when I view its leaderboard, then my own entry is highlighted even if I am outside the top 25, with my rank shown
- [ ] Given the global leaderboard view, when I filter by time period (all time / this month / this week), then rankings recalculate for that window
- [ ] Given a leaderboard entry, when I click a username, then I am taken to that user's public researcher profile
- [ ] Given I completed a lab with hints used or solution viewed, when my score appears on the leaderboard, then those completions are excluded — only clean completions rank

## Notes

Leaderboards should be opt-in at the user level: users who prefer privacy can set their profile to anonymous, appearing as "Researcher_####" on public boards. This prevents discouraging newcomers while preserving competitive culture for those who want it.
