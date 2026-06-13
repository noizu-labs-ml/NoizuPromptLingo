---
id: US-129
title: Cohort comparison across multiple runs
issue_type: story
slug: cohort-comparison
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: results-and-dashboards
components:
  - backend
  - frontend
labels:
  - wave-3
  - dashboards
  - cohorts
assignee: null
reporter: null
epic: mvp-results
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
  - nia-academic
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-070
  - US-077
dependencies:
  - US-070
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

# Cohort comparison across multiple runs

## Story

As an **AI Red Team Researcher**,
I want to **select N runs (tagged by batch or manually) and see aggregate cross-run metrics — pass-rates, score distributions, verdict deltas**
so that **cohort-level comparisons (e.g. "5 agents × 10 scripts × 3 personas = 150 runs, broken down by agent") require one view rather than 150 tabs**.

## Acceptance Criteria

- [ ] Run list multi-select or batch_id filter creates a "cohort view"
- [ ] Cohort dashboard: per-agent accuracy, per-persona accuracy, score-distribution boxplots, verdict-delta matrix
- [ ] Export cohort summary as CSV for paper tables
- [ ] Shareable URL that encodes cohort membership

## Notes

- Companion to US-077 (diff two runs); this generalizes to N

## Out of Scope

- Statistical-significance flagging on deltas (Wave 3+ — Nia's turf)
