---
id: US-121
title: Rubric disagreement analytics across runs
issue_type: story
slug: rubric-disagreement-analytics
status: draft
priority: P3
story_points: 5
estimated_scope: M
category: rubric-and-scoring
components:
  - backend
  - frontend
labels:
  - wave-3
  - rubrics
  - analytics
  - stretch
assignee: null
reporter: null
epic: mvp-results
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - nia-academic
secondary_personas:
  - sofia-product-manager
related_stories:
  - US-059
  - US-060
dependencies:
  - US-060
blocks: []
duplicates: []
schema_refs:
  - expectations
  - rubric_versions
  - run_steps
  - scores
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Rubric disagreement analytics across runs

## Story

As an **AI Research Engineer**,
I want to **see where two rubric versions systematically disagree across hundreds of runs**
so that **I can publish findings on rubric brittleness and calibrate judges better before relying on their scores**.

## Acceptance Criteria

- [ ] Analytics page for a script + two rubric versions: disagreement rate, Cohen's kappa, per-verdict confusion matrix
- [ ] Drill-through from any cell to the underlying run_steps where the disagreement occurred
- [ ] Time-bucketed view: has disagreement drifted over time?
- [ ] CSV export of the full disagreement table for paper appendices

## Notes

- Research-grade feature; Nia is the primary user

## Out of Scope

- Three-way and N-way disagreement matrices (Wave 3+)
