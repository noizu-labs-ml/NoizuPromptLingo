---
id: US-093
title: "View Trending Techniques on Homepage"
slug: "trending-techniques-homepage"
personas: [P-001, P-002, P-004, P-005, P-006, P-008]
epic: "Search & Discovery"
priority: "should-have"
complexity: "M"
tags: [homepage, discovery, trending, catalog, engagement]
---

# US-093: View Trending Techniques on Homepage

## User Story

**As a** visitor or logged-in user arriving at the site (P-001, P-002, P-004, P-005, P-006, P-008),
**I want to** see which techniques are currently trending based on community activity and scan data,
**So that** I immediately understand the current threat landscape without needing to know what to search for.

## Acceptance Criteria

- [ ] Given the homepage, when I load it (logged in or anonymous), then a "Trending This Week" section shows the top 6 techniques ranked by a composite signal (views + bookmarks + scan detections in the last 7 days)
- [ ] Given a trending technique card, when I view it, then it shows the technique name, category, severity badge, a 1-sentence summary, trending rank position, and the percentage change in activity vs. the prior week
- [ ] Given a technique that is newly added this week, when it trends, then it is labeled "NEW" in addition to its trend position
- [ ] Given the trending list, when it refreshes, then it updates every 6 hours (stale-while-revalidate pattern acceptable)
- [ ] Given I click a trending technique card, when the detail page loads, then I see a "Trending" banner at the top of the page with the trend context
- [ ] Given an admin, when they identify a trending technique based on harmful community interest rather than legitimate research, then they can suppress it from the trending list with an audit log entry

## Notes

Trending algorithm should weight scan detections more heavily than page views to favor security-signal relevance over click-bait. Anonymous users see the same trending list as logged-in users (no personalization at this level). Suppression by admins covers PR/ethics edge cases.
