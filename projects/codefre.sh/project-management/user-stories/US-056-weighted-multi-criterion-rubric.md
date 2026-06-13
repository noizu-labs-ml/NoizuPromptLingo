---
id: US-056
title: Define a weighted multi-criterion rubric
issue_type: story
slug: weighted-multi-criterion-rubric
status: in-progress
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
  - scoring
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - nia-academic
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-033
dependencies:
  - US-033
blocks: []
duplicates: []
schema_refs:
  - rubric_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Define a weighted multi-criterion rubric

## Story

As an **AI Product Manager**,
I want to **declare multiple weighted criteria on a single rubric (e.g. relevance 0.4, helpfulness 0.4, safety 0.2)**
so that **the score combines multiple judgments into one defensible number**.

## Acceptance Criteria

- [ ] Rubric editor supports adding ordered criteria, each with: label, description, weight (0.000-1.000)
- [ ] Criteria weights need not sum to 1.0; scorer normalizes at score time
- [ ] Each criterion can optionally override the rubric-level judge model
- [ ] Publishing validates non-empty criteria when scale is `continuous` with multi-criterion mode
- [ ] Generated score is the weighted average across criteria; per-criterion sub-scores persisted in `scores.raw_output`

## Notes

- `rubric_versions.criteria` JSONB already modeled (`data-model.md` §5.5)
- Per-criterion drill-down in results view is a separate story (Wave 3)

## Out of Scope

- Criteria inheritance across rubrics (Wave 3)
- Adaptive criteria weights based on step context (Wave 3)
