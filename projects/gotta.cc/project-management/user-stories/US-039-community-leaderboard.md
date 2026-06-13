---
id: US-039
title: "Browse Community Leaderboard of Top Submitters"
slug: "community-leaderboard"
personas: [P-001, P-008]
epic: "Community & Social"
priority: "should-have"
complexity: "M"
tags: [community, leaderboard, gamification, reputation]
---

# US-039: Browse Community Leaderboard of Top Submitters

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** see who the top contributors to the directory are,
**So that** I can find the most prolific and reliable curators to follow.

## Acceptance Criteria

- [ ] Given I navigate to the leaderboard, when it loads, then I see the top 50 submitters ranked by a composite score that weights approved submissions, upvotes received on their finds, and acceptance rate
- [ ] Given the leaderboard is displayed, when I toggle between "All Time," "This Month," and "This Week" views, then the rankings update to reflect the selected time window
- [ ] Given I view a leaderboard entry, when I click a submitter's name or avatar, then I am taken to their submitter profile (US-038)
- [ ] Given I am logged in and appear on the leaderboard, when I view it, then my own entry is highlighted regardless of its position in the list

## Notes

Leaderboard resets the "This Month" and "This Week" tabs on a rolling basis. Rankings feed into the weekly digest (US-043). Following top submitters is covered in US-040.
