---
id: US-061
title: "Analytics Period Selector"
slug: "period-selector"
personas: [P-001, P-002, P-003]
epic: "Analytics Dashboard"
priority: "must-have"
complexity: "S"
tags: [analytics, period, filter, dashboard, date-range]
---

# US-061: Analytics Period Selector

## User Story

**As a** content marketing manager (P-003),
**I want to** select the time period for my analytics view,
**So that** I can analyze short-term experiments, medium-term campaigns, and long-term growth separately.

## Acceptance Criteria

- [ ] Given I am on /dashboard/analytics, when I view the period selector, then I see preset buttons: 7D, 30D, 90D, and 1Y
- [ ] Given I click a period button, when the selection activates, then all charts and metrics on the analytics page re-render for that time window
- [ ] Given I am a Free tier user and I click "1Y," when the selection applies, then a tooltip explains that full 1Y history is a Pro feature and shows only 30 days; a Pro upgrade CTA is displayed
- [ ] Given I am a Pro user, when I select any period, then all chart data renders without restriction
- [ ] Given I select a period, when the URL updates, then the selected period is reflected in `?period=7d` so the view is bookmarkable

## Notes

The period selector is a global control for the analytics page — it governs the score trend chart (US-059), the radar chart ghost overlay (US-060), the peer benchmark (US-063), and dimension compare chart (US-067). Default period on page load: 30D.
