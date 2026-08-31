---
id: US-100
title: "Dashboard stays responsive as corpus grows"
slug: dashboard-responsive-as-corpus-grows
personas: [P-005]
epic: "Performance & Scale"
priority: could-have
complexity: medium
tags: [performance, dashboard, scale]
---

# US-100: Dashboard Stays Responsive As Corpus Grows

## User Story

**As an** engineering lead auditing team AI usage
**I want to** have the Dashboard stat row and Browse project counts stay fast as the indexed corpus grows
**So that** my weekly oversight scan doesn't turn into a waiting game as team usage accumulates

## Acceptance Criteria

- **Given** Daniel's indexed corpus grows into the tens of thousands of conversations
  **When** he opens the Dashboard
  **Then** stat-row numbers (totals, recent activity) render without visible lag (e.g. under ~500ms)

- **Given** Daniel views Browse grouped by project
  **When** project counts are computed at that scale
  **Then** counts display without a noticeable stall or spinner beyond initial page load

- **Given** the corpus is actively being indexed while Daniel views the dashboard
  **When** new conversations are added
  **Then** stat counts update without requiring a full page reload or freezing the UI

## Notes
could-have — dashboard responsiveness at extreme scale is a nice-to-have polish item, deferred behind the higher-priority search-path performance work in US-097, since Daniel's weekly scan tolerates a bit more latency than an active search query would.
