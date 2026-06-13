---
id: US-019
title: "Score History and Trend Chart"
slug: "score-history"
personas: [P-001, P-002, P-003]
epic: "Blog Indexing & Scoring"
priority: "should-have"
complexity: "M"
tags: [scoring, history, trends, chart, analytics]
---

# US-019: Score History and Trend Chart

## User Story

**As a** blogger (P-002),
**I want to** view a chart of my score history over time across all 6 dimensions,
**So that** I can track whether my improvements are having a measurable impact on my scores.

## Acceptance Criteria

- [ ] Given my blog has been scored at least twice, when I visit the Score History tab, then I see a line chart plotting composite score over time with individual dimension scores toggleable via a legend
- [ ] Given I view the score history chart, when I hover over a data point, then a tooltip shows: date, composite score, and all 6 dimension scores for that snapshot
- [ ] Given I want to compare two scoring periods, when I select two data points on the chart, then a comparison panel shows the delta for each dimension with directional arrows (up/down/unchanged)
- [ ] Given I am on the Free tier, when I view score history, then only the 2 most recent score snapshots are visible; older history is shown blurred with a Pro upgrade prompt
- [ ] Given I am on Pro or Team tier, when I view score history, then all historical score snapshots are visible (up to 24 months)

## Notes

Score snapshots must be stored immutably — each re-index produces a new row rather than updating the previous one. Chart should support exporting as PNG/CSV (Pro and Team only). Related: US-015 (scoring), US-018 (re-index adds a snapshot).
