---
id: US-022
title: "Fleet Health Score"
slug: "fleet-health-score"
personas: [P-002, P-003]
epic: "Core Dashboard"
priority: "must-have"
complexity: "M"
tags: [dashboard, health-score, fleet, kpi, reporting]
---

# US-022: Fleet Health Score

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** see a single composite Fleet Health Score on the dashboard,
**So that** I can communicate overall IoT operational status to leadership in a single number without needing to interpret raw technical metrics.

## Acceptance Criteria

- [ ] Given I view the dashboard, when the fleet health score is displayed, then it shows a score from 0–100 with a color band (green 80–100, yellow 50–79, red 0–49) and a trend sparkline for the past 7 days.
- [ ] Given I click on the health score, when the detail panel opens, then I see a breakdown of the score's component factors: device connectivity %, open critical anomalies, agent coverage %, and SLA adherence %, each with its individual score and weight.
- [ ] Given the fleet health score drops below 70, when the drop is detected, then I receive a proactive notification via my configured channel with the contributing factors listed.
- [ ] Given I manage multiple device groups, when I view the score breakdown, then I can drill into per-group health sub-scores to identify which segment is dragging down the overall score.
- [ ] Given I want to export the health score for a weekly report, when I click "Export," then a PDF or CSV report is generated showing the score history and breakdown for a selectable date range.

## Notes

The score formula should be documented and transparent to users — P-004 (SRE) will scrutinize the methodology. Weighting of score components should be configurable by Admins in a later story.
