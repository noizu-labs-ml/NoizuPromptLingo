---
id: US-004
title: Add an expectation to a script node
issue_type: story
slug: add-expectation-to-node
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: script-authoring
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - authoring
  - expectations
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - sofia-product-manager
secondary_personas:
  - alex-oss-maintainer
related_stories:
  - US-002
  - US-020
  - US-033
  - US-034
dependencies:
  - US-002
blocks:
  - US-020
  - US-034
duplicates: []
schema_refs:
  - expectations
  - rubric_versions
  - script_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Add an expectation to a script node

## Story

As a **Senior ML Engineer**,
I want to **add a labeled expectation with a weight, direction, and scoring method to a script node**
so that **the runner knows what good-vs-bad behavior looks like at this step**.

## Acceptance Criteria

- [ ] User enters a human-readable `label` (e.g. "asks clarifying questions")
- [ ] `weight` accepts values in 0.000–1.000, defaults to 1.000
- [ ] `direction` picker: `positive` (should) or `negative` (must not)
- [ ] `scoring_method` picker: `lm_judge`, `rubric`, `regex`, `semantic`, `structural`
- [ ] Method-specific config input appears based on selection (e.g. regex pattern, rubric selector)
- [ ] Expectations appear in the node detail pane as a list
- [ ] Validation: `rubric` method requires a rubric reference; `semantic` method requires a reference embedding placeholder

## Notes

- Reference embedding population for semantic method happens async (Wave 2)
- Rubric attachment interplay is refined in US-034

## Out of Scope

- Embedding generation (Wave 2)
- Inline LLM-as-judge prompt authoring (covered via rubrics, US-033)
