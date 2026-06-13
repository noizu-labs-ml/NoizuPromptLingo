---
id: US-059
title: "View Score Trends Over Time"
slug: "score-trends-over-time"
personas: [P-001, P-002]
epic: "Analytics Dashboard"
priority: "must-have"
complexity: "M"
tags: [analytics, score, trends, chart, dashboard]
---

# US-059: View Score Trends Over Time

## User Story

**As a** indie lifestyle blogger (P-001),
**I want to** see how my overall AI score has changed over time,
**So that** I can understand whether my improvements are working and track my growth trajectory.

## Acceptance Criteria

- [ ] Given I navigate to /dashboard/analytics, when the page loads, then I see a line chart of my overall AI score plotted over time with data points for each scoring event
- [ ] Given the score trend chart renders, when I hover over a data point, then a tooltip shows the exact date, overall score, and a mini breakdown of the 6 dimension scores at that point in time
- [ ] Given I have fewer than 2 scoring events, when the chart renders, then I see an empty state explaining that trends appear after my second scoring (see US-066)
- [ ] Given the chart is displayed, when I change the period selector (US-061), then the chart re-renders to show only data within the selected period
- [ ] Given I am a Free tier user, when I view score trends, then I can see trends for up to 30 days of history; Pro users see unlimited history

## Notes

Scoring events occur on: initial submission, re-scoring (manual or scheduled), and competition entry scoring. Chart library should support responsive sizing. See US-061 for period selector, US-060 for radar chart, US-063 for peer benchmarking.
