---
id: US-060
title: See side-by-side score comparison across rubric versions
issue_type: story
slug: score-comparison-across-rubric-versions
status: draft
priority: P1
story_points: 3
estimated_scope: S
category: rubric-and-scoring
components:
  - frontend
  - backend
labels:
  - wave-2
  - rubrics
  - dashboards
assignee: null
reporter: null
epic: mvp-results
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - nia-academic
secondary_personas: []
related_stories:
  - US-020
  - US-059
dependencies:
  - US-059
blocks: []
duplicates: []
schema_refs:
  - scores
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# See side-by-side score comparison across rubric versions

## Story

As an **AI Product Manager**,
I want to **see a step's scores from two different rubric versions side-by-side**
so that **I can decide whether to adopt the new rubric as the org's default**.

## Acceptance Criteria

- [ ] Run detail exposes a "Rubric versions" chip showing all distinct rubric versions that have scored this run
- [ ] Picking two versions opens a side-by-side score panel per step
- [ ] Each column displays: score, verdict, rationale, judge model
- [ ] Rows highlight where verdicts disagree (green vs. red vs. amber)
- [ ] Aggregate score delta at the run level is surfaced

## Notes

- Leans on the partial-unique constraint in `scores` to ensure one row per `(run_step, expectation, rubric_version)` pair

## Out of Scope

- Three+-way comparison (Wave 3)
- Disagreement analytics across many runs (Wave 3)
