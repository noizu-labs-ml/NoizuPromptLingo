---
id: US-078
title: Trend chart of aggregate scores over time for a script
issue_type: story
slug: trend-chart-scores-over-time
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: results-and-dashboards
components:
  - backend
  - frontend
labels:
  - wave-2
  - dashboards
  - trends
  - analytics
assignee: null
reporter: null
epic: mvp-results
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - marcus-qa-lead
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-021
  - US-025
dependencies:
  - US-021
  - US-025
blocks: []
duplicates: []
schema_refs:
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Trend chart of aggregate scores over time for a script

## Story

As a **QA Lead**,
I want to **see a line chart of a script's aggregate score over time across releases**
so that **I can spot regressions in quarterly review and communicate trends to leadership**.

## Acceptance Criteria

- [ ] Script detail exposes a "Trends" tab with a line chart (score × time)
- [ ] X-axis is time; Y-axis is aggregate score (0-1)
- [ ] Multiple series when multiple agents run the same script; each series is an agent_version (or agent head rolled up)
- [ ] Hover reveals the specific run and verdict
- [ ] Time range selector: 7d / 30d / 90d / all
- [ ] Y-axis band shows threshold zones (pass/warn/fail) for quick visual triage

## Notes

- Backend queries `runs.summary_metrics -> 'aggregate_score'` filtered by script; consider a denormalized `runs.aggregate_score` numeric column for efficient sorting/filtering (schema open question #11 — revisit post-Wave-3 schema pass)

## Out of Scope

- Anomaly detection alerting on regressions (Wave 3)
- Custom metric trending beyond aggregate_score (Wave 3)
