---
id: US-040
title: "Trending Prompts Feed"
slug: "trending-prompts-feed"
personas: [P-002, P-006, P-007, P-008]
epic: "Search & Discovery"
priority: "should-have"
complexity: "M"
tags: [trending, feed, discovery, homepage]
---

# US-040: Trending Prompts Feed

## User Story

**As an** AI newcomer visiting the site (P-008),
**I want to** see a dedicated "Trending" feed of prompts gaining rapid vote momentum,
**So that** I can quickly discover what the community is excited about right now.

## Acceptance Criteria

- [ ] Given I navigate to the Trending section, when the page loads, then prompts are ranked by velocity score — the rate of vote gain over the past 6 hours — not raw total score
- [ ] Given a prompt's vote velocity drops out of the top N threshold, when the trending list refreshes, then it is replaced by the next qualifying prompt
- [ ] Given the Trending feed is rendered on the homepage for logged-out visitors, when the page loads, then the top 10 trending prompts are visible without requiring authentication
- [ ] Given I enable trending notifications in my settings, when a prompt I have bookmarked enters the trending list, then I receive an in-app notification

## Notes

Trending velocity is calculated as delta(score) / time_window and refreshed on a configurable interval (default: 15 minutes). The feed should be capped at a configurable maximum (default: 50 items) to prevent runaway lists. Trending data should be persisted for analytics and historical trend visualization.
