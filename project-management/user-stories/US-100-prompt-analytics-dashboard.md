---
id: US-100
title: "Prompt Analytics Dashboard (Views, Forks, Votes Over Time)"
slug: "prompt-analytics-dashboard"
personas: [P-001, P-003, P-006, P-007]
epic: "Advanced Features"
priority: "could-have"
complexity: "L"
tags: [analytics, dashboard, metrics, advanced, prompt-author, data-visualization]
---

# US-100: Prompt Analytics Dashboard (Views, Forks, Votes Over Time)

## User Story

**As a** Prompt Engineer (P-001) or Content Creator (P-006),
**I want to** view time-series analytics for my published prompts,
**So that** I can understand which prompts resonate with the community, when engagement peaks, and how my prompts trend after publishing.

## Acceptance Criteria

- [ ] Given a prompt author navigates to a prompt they own, when they click "View Analytics," then they see a dashboard with line charts for views, unique visitors, upvotes, downvotes, and forks over the past 30 days
- [ ] Given the analytics dashboard is open, when the user adjusts the date range selector (7 days, 30 days, 90 days, all time), then all charts update to reflect the selected period
- [ ] Given the user has multiple prompts, when they view their profile analytics page, then an aggregate view shows total views/votes/forks across all prompts, plus a ranked list of their top-performing prompts
- [ ] Given a prompt receives a sudden spike in views (e.g., featured on the front page), when the author views analytics, then the spike is visible in the chart and annotated with the source event if known (e.g., "Featured in trending")
- [ ] Given analytics data is collected, when a non-author views a public prompt, then they see only aggregate public stats (total votes, total forks) — detailed time-series data is restricted to the author

## Notes

Event collection should be implemented as a lightweight append-only event log to avoid write contention on the prompt record. Time-series aggregation can be pre-computed by a background job at hourly granularity. Views should be deduplicated by IP+user agent within a 24-hour window to prevent trivial inflation. The annotation system for events (trending, featured, etc.) requires integration with the moderation and curation systems.
