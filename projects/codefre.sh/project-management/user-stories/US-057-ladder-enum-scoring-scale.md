---
id: US-057
title: Configure a rubric to use a ladder / enum scoring scale
issue_type: story
slug: ladder-enum-scoring-scale
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
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
secondary_personas: []
related_stories:
  - US-033
  - US-056
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

# Configure a rubric to use a ladder / enum scoring scale

## Story

As an **AI Research Engineer**,
I want to **use a discrete rubric scale (e.g. "excellent / adequate / poor / unacceptable")**
so that **my published benchmarks report enum-labeled results that reviewers can interpret without a continuous-score rubric**.

## Acceptance Criteria

- [ ] Rubric `scale` editor supports `type: ladder` with ordered enum values + associated numeric mapping
- [ ] Judge prompt is preformatted to request one of the enum labels
- [ ] Scored result records both the enum label and the derived numeric in `scores.raw_output`
- [ ] Dashboards display enum label prominently; numeric is the aggregation basis

## Notes

- Examples of ladder scales: 3-point (poor/ok/good), 5-point Likert, pass/warn/fail
- Matches academic reporting conventions Nia cares about

## Out of Scope

- Mixing ladder + continuous criteria on the same rubric (Wave 3)
- Custom enum-to-number mappings with non-monotonic values (never; confuses aggregation)
