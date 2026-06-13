---
id: US-060
title: "Dimension Breakdown Radar Chart"
slug: "dimension-radar-chart"
personas: [P-001, P-002, P-003]
epic: "Analytics Dashboard"
priority: "must-have"
complexity: "M"
tags: [analytics, radar-chart, dimensions, ai-score, dashboard]
---

# US-060: Dimension Breakdown Radar Chart

## User Story

**As a** professional tech blogger (P-002),
**I want to** see my 6 AI score dimensions displayed as a radar/spider chart,
**So that** I can immediately identify which dimensions are strong and which need the most improvement.

## Acceptance Criteria

- [ ] Given I am on /dashboard/analytics, when the page loads, then I see a hexagonal radar chart with the 6 dimensions: Originality, Engagement, Consistency, Writing Quality, SEO, and Visual Design
- [ ] Given the radar chart renders, when I hover over a dimension axis, then a tooltip shows the dimension name, current score (0–100), and rank label (e.g., "Top 15%")
- [ ] Given I have multiple scoring events, when I view the radar chart, then I see two overlapping shapes: current scores (solid) and previous period scores (dashed/ghost), visually showing change
- [ ] Given the radar chart renders, when the chart is on mobile, then it scales responsively and all 6 dimension labels remain legible
- [ ] Given I click on a dimension label in the radar chart, when the action fires, then I am anchored to the dimension detail section of the analytics page showing that dimension's trend over time (US-067)

## Notes

The ghost/previous overlay is a key "before/after" UX moment that makes improvement viscerally visible. Use a distinct color per dimension for the detail drilldown (US-067). Radar chart and trend chart (US-059) are the two primary analytics visualizations.
