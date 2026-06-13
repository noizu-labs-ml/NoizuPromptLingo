---
id: US-059
title: Re-score a past run with a newer rubric version
issue_type: story
slug: rescore-past-run
status: draft
priority: P1
story_points: 5
estimated_scope: M
category: rubric-and-scoring
components:
  - backend
  - frontend
labels:
  - wave-2
  - rubrics
  - reproducibility
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - nia-academic
  - sofia-product-manager
secondary_personas:
  - marcus-qa-lead
related_stories:
  - US-033
  - US-020
  - US-060
dependencies:
  - US-033
  - US-020
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

# Re-score a past run with a newer rubric version

## Story

As an **AI Research Engineer**,
I want to **re-score a completed run using a newer rubric version**
so that **I can compare scores under a refined judge without losing the original scores or re-running the agent itself**.

## Acceptance Criteria

- [ ] On a terminal run, "Re-score with rubric version…" action offered
- [ ] User picks a rubric version (must be newer or different from what originally scored)
- [ ] Re-scoring runs the judge across every `run_step × expectation` where that rubric applies
- [ ] New `scores` rows are inserted pinning the new `rubric_version_id` — original rows remain visible
- [ ] UI shows original-vs-rescored side-by-side (feeds into US-060)
- [ ] Re-score cost estimate shown before execution; user confirms

## Notes

- Validates the partial-unique constraint on `(run_step_id, expectation_id, rubric_version_id)` from `data-model.md` §6.6
- Crucial for Nia's reproducibility workflow and paper revisions

## Out of Scope

- Bulk re-score across many runs in one action (Wave 3)
- Re-score with a different judge model but same rubric version (resolves via US-033 open question #8)
