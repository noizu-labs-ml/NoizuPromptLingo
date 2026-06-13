---
id: US-020
title: See individual step scores
issue_type: story
slug: see-individual-step-scores
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
  - scoring
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - nia-academic
  - sofia-product-manager
related_stories:
  - US-017
  - US-019
  - US-021
dependencies:
  - US-015
  - US-033
  - US-034
blocks:
  - US-019
  - US-021
duplicates: []
schema_refs:
  - expectations
  - rubric_versions
  - scores
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# See individual step scores

## Story

As a **Senior ML Engineer**,
I want to **see every expectation's score for every step of a run**
so that **I can pinpoint exactly which expectation the agent failed to meet**.

## Acceptance Criteria

- [ ] For each step, each expectation's `score`, `verdict`, `scoring_method`, and `rationale` is visible
- [ ] Scores from different rubric versions on the same step (re-scoring) are shown side-by-side with the rubric version labeled
- [ ] Failing expectations are visually highlighted
- [ ] Scoring metadata visible: `judge_model`, `judge_prompt_version_id` (for lm_judge/rubric methods)

## Notes

- The judge provenance data (`judge_model`, `judge_prompt_version_id`) makes Nia's reproducibility work possible
- Scoring display is loaded lazily per-step; don't block step list render

## Out of Scope

- Side-by-side score comparison across runs (US-021 handles run-level; step-level compare is Wave 3)
- Inline re-score UI from the results view (Wave 2)
