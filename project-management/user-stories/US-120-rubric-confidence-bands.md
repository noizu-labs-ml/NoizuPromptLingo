---
id: US-120
title: Rubric confidence bands on scores
issue_type: story
slug: rubric-confidence-bands
status: in-progress
priority: P2
story_points: 3
estimated_scope: S
category: rubric-and-scoring
components:
  - backend
  - frontend
labels:
  - wave-3
  - rubrics
  - scoring
  - uncertainty
assignee: null
reporter: null
epic: mvp-results
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - nia-academic
  - sofia-product-manager
secondary_personas: []
related_stories:
  - US-033
  - US-020
dependencies:
  - US-033
blocks: []
duplicates: []
schema_refs:
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

# Rubric confidence bands on scores

## Story

As an **AI Research Engineer**,
I want **each score to carry a confidence interval derived from n-shot judge sampling**
so that **my papers report "score 0.82 ± 0.04" rather than a misleading point estimate**.

## Acceptance Criteria

- [ ] Rubric config accepts `n_samples` (default 1, max 10); judge is invoked n times and scores averaged
- [ ] Per-score confidence interval computed (stddev) and persisted in `scores.raw_output.confidence_interval`
- [ ] Results UI shows score ± stddev; aggregate views propagate uncertainty (variance sums)
- [ ] n_samples > 1 scales cost proportionally; warn before triggering runs

## Notes

- Use bootstrap or straight sample variance — no need for Bayesian sophistication in v1

## Out of Scope

- Model-intrinsic confidence (logprobs-based) — Wave 3+; requires adapter-specific extraction
