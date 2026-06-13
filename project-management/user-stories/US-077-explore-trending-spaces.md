---
id: US-077
title: "Explore Trending Spaces"
slug: "explore-trending-spaces"
personas: [P-004, P-006, P-007]
epic: "Explore & Homepage"
priority: "must-have"
complexity: "S"
tags: [discovery, spaces, trending]
---

# US-077: Explore Trending Spaces

## User Story

**As a** Curious Lurker (P-004),
**I want to** see a list of trending spaces sorted by activity and member growth,
**So that** I can discover active communities to join and engage with.

## Acceptance Criteria

- [ ] Given I visit the "Explore Spaces" page, when the page loads, then I see spaces sorted by a "trending score" (combination of new threads, active members, and growth rate)
- [ ] Given I view the trending list, when I examine a space card, then I see: space name, member count, thread count, 24-hour activity indicator, and space description
- [ ] Given a space has no description, when I view its card, then I see a default description "A community about {space topic}"
- [ ] Given I click the "Explore Spaces" CTA from the homepage empty state, when I navigate, then I arrive at the trending spaces page
- [ ] Given there are no trending spaces, when I view the page, then I see an empty state message encouraging early visitors to create spaces

## Notes

Trending algorithm should surface diverse spaces, not just the largest ones. Time window: last 7 days for trending calculation.