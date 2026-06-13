---
id: US-081
title: "Score History and Trend Chart Over Time"
slug: "score-history-trend-chart"
personas: [P-002, P-003, P-008]
epic: "Quality Scoring Engine"
priority: "could-have"
complexity: "M"
tags: [scoring, history, chart, analytics, transparency]
---

# US-081: Score History and Trend Chart Over Time

## User Story

**As a** Research Journalist (P-003),
**I want to** see how a site's quality score has changed over time,
**So that** I can assess whether a source is improving, declining, or stable before citing it in my work.

## Acceptance Criteria

- [ ] Given I am viewing a site detail page, when I scroll to the scoring section, then I see a line chart showing the composite score over the past 12 months (or since listing, whichever is shorter)
- [ ] Given the score history chart is displayed, when I hover over a data point, then a tooltip shows the score value and date of that recalculation
- [ ] Given a site has fewer than 3 historical data points, when the chart would be displayed, then a "not enough history yet" message is shown instead of an incomplete chart
- [ ] Given the chart is rendered, when I view it on a screen reader, then a data table alternative is available as an accessible fallback

## Notes

Score history is particularly valuable for P-008 (Community Curator) who tracks site quality longitudinally. Store score snapshots on every recalculation event (see US-078) to power this chart. The data table fallback connects to US-096 (screen reader support).
