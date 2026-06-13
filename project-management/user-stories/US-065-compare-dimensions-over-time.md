---
id: US-065
title: "Compare Dimensions Over Time"
slug: "compare-dimensions-over-time"
personas: [P-002, P-001]
epic: "Analytics Dashboard"
priority: "should-have"
complexity: "M"
tags: [analytics, dimensions, comparison, chart, trend]
---

# US-065: Compare Dimensions Over Time

## User Story

**As a** professional tech blogger (P-002),
**I want to** view multiple AI score dimensions plotted on the same chart over time,
**So that** I can see if improving one dimension is coming at the expense of another and understand the relationships between them.

## Acceptance Criteria

- [ ] Given I am on /dashboard/analytics, when I view the dimension comparison section, then I see a multi-line chart with a separate colored line for each of the 6 dimensions
- [ ] Given the multi-line chart renders, when I click a dimension label in the legend, then that dimension's line toggles on/off so I can isolate specific dimensions
- [ ] Given I hover over any point on the chart, when the tooltip renders, then it shows the date and score for all currently visible dimensions at that point
- [ ] Given I select a period (US-061), when the dimension chart updates, then all lines re-render to show only the selected time window
- [ ] Given fewer than 2 scoring events exist in the selected period, when the chart renders, then each dimension line shows a flat line or a "not enough data" message for that dimension

## Notes

This chart complements the radar chart (US-060) — the radar shows current state, this chart shows trajectory per dimension. Distinct colors per dimension must be consistent across all analytics views. Default state: all 6 dimensions visible. See US-061 for period selector.
