---
id: US-021
title: See aggregate score summary for a run
issue_type: story
slug: aggregate-run-score-summary
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: run-execution
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - runs
  - results
  - aggregation
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - sofia-product-manager
secondary_personas:
  - marcus-qa-lead
related_stories:
  - US-019
  - US-020
  - US-025
dependencies:
  - US-020
blocks: []
duplicates: []
schema_refs:
  - expectations
  - runs
  - scores
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# See aggregate score summary for a run

## Story

As an **AI Product Manager**,
I want to **see pass/warn/fail counts, an overall weighted score, and coverage stats for a run**
so that **I can communicate results to leadership without reading every step**.

## Acceptance Criteria

- [ ] Run detail surfaces: overall weighted score (0.000–1.000), pass count, warn count, fail count
- [ ] Coverage shown: how many authored expectations were evaluated vs. total declared
- [ ] Freeball step count is surfaced separately from authored step count
- [ ] Aggregates are persisted in `runs.summary_metrics` at run completion

## Notes

- Weighted score formula: sum(`score * weight` for positive-direction expectations) / sum(`weight`), with `direction='negative'` failures pulled out separately
- Sofia reviews these in weekly quality review; keep readable without SQL

## Out of Scope

- Per-tag aggregation (Wave 2)
- Per-persona breakdown on this card (Wave 2)
