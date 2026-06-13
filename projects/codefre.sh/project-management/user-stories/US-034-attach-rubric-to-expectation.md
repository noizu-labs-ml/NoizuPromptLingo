---
id: US-034
title: Attach a rubric to an expectation
issue_type: story
slug: attach-rubric-to-expectation
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: rubric-and-scoring
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - rubrics
  - expectations
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-033
  - US-004
dependencies:
  - US-033
  - US-004
blocks: []
duplicates: []
schema_refs:
  - expectations
  - rubric_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Attach a rubric to an expectation

## Story

As an **AI Product Manager**,
I want to **attach one of my org's rubrics to an expectation**
so that **the runner knows how to score that expectation without me duplicating the judge prompt everywhere**.

## Acceptance Criteria

- [ ] When an expectation's `scoring_method='rubric'`, the config editor requires a rubric selection
- [ ] Rubric picker lists published rubrics in the org
- [ ] Selection pins the rubric's current published version id
- [ ] Validation fails if scoring_method is `rubric` but no rubric is attached

## Notes

- Uses the same "pin version at attach time" semantics as prompt referencing (US-011)

## Out of Scope

- Rubric override at run-time (Wave 2 — `run_config.rubric_overrides`)
- Bulk "update all expectations to latest rubric version" (Wave 2)
