---
id: US-058
title: Preview a rubric by scoring a sample response
issue_type: story
slug: preview-rubric-sample
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
  - preview
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-033
  - US-056
dependencies:
  - US-033
blocks: []
duplicates: []
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Preview a rubric by scoring a sample response

## Story

As an **AI Product Manager**,
I want to **paste a sample agent response into the rubric editor and see how the judge scores it**
so that **I can calibrate the rubric before attaching it to real expectations — not discover it's miscalibrated after a full run**.

## Acceptance Criteria

- [ ] Rubric editor exposes a "Preview" pane with a sample input + sample response text area
- [ ] "Score now" button invokes the judge with current draft rubric config
- [ ] Results show: overall score, per-criterion scores, judge rationale
- [ ] Preview does not create a `scores` row — out-of-band, not audited
- [ ] Cost of the preview is shown to the user before invocation (estimated tokens)

## Notes

- Encourages iterative rubric design without polluting run history
- Cost estimate is approximate (token count × published rate)

## Out of Scope

- Auto-generating sample inputs from past runs (Wave 3)
- Batch preview across multiple samples (Wave 3)
