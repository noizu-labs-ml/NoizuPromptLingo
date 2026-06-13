---
id: US-046
title: "Filter Leaderboard by Time Period"
slug: "filter-leaderboard-by-period"
personas: [P-001, P-002, P-007]
epic: "Leaderboards"
priority: "must-have"
complexity: "M"
tags: [leaderboard, filter, time-period, rankings, all-time, monthly, weekly]
---

# US-046: Filter Leaderboard by Time Period

## User Story

**As a** blogger tracking my performance trends (P-001),
**I want to** filter the leaderboard by time period (All-Time, Monthly, Weekly),
**So that** I can see who the current top performers are and whether my ranking is improving over time.

## Acceptance Criteria

- [ ] Given I am on the Leaderboard page, when I view the period selector, then I see tabs or a segmented control for: All-Time, This Month, and This Week
- [ ] Given I select "This Week," when the leaderboard renders, then rankings are based on the aggregate AI scores from the current 7-day rolling window only
- [ ] Given I select "This Month," when the leaderboard renders, then rankings reflect scores from the current calendar month
- [ ] Given I select "All-Time," when the leaderboard renders, then rankings reflect the cumulative average AI scores across all scoring runs
- [ ] Given I switch between periods, when the new period is selected, then the leaderboard re-renders within 500ms without a full page reload and my highlighted rank row updates to reflect the new period
- [ ] Given my blog appears in the top 25 for one period but not another, when I switch periods, then the leaderboard scrolls or indicates where my blog's row is in the new ranking

## Notes

Period-based rankings incentivize consistent content production — a blog that posts regularly can climb the weekly leaderboard even if its all-time rank is lower. This creates a re-engagement loop. SEO affiliate blogger P-007 will monitor weekly rankings for competitive intelligence. The scoring cadence (how often AI scores are recalculated) must be defined to make period rankings meaningful.
