---
id: US-033
title: Create a simple rubric with LLM-as-judge scoring
issue_type: story
slug: create-simple-rubric
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: rubric-and-scoring
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - rubrics
  - scoring
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - priya-ml-engineer
secondary_personas:
  - nia-academic
related_stories:
  - US-034
  - US-020
dependencies: []
blocks:
  - US-034
  - US-020
duplicates: []
schema_refs:
  - rubric_versions
  - rubrics
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Create a simple rubric with LLM-as-judge scoring

## Story

As an **AI Product Manager**,
I want to **create a rubric with a judge prompt and a single continuous scale**
so that **I can define what "good" means for an expectation without coordinating a custom judge implementation**.

## Acceptance Criteria

- [ ] Rubric head + first draft version creatable via UI
- [ ] User picks an existing published prompt as the `judge_prompt_version`
- [ ] User selects a `judge_model` (e.g. `anthropic:claude-sonnet-4-5`)
- [ ] `scale` defaults to `{"min":0,"max":1,"type":"continuous"}`; overridable
- [ ] Criteria list starts empty (single-expectation rubrics viable)
- [ ] Publish action creates a new `rubric_versions` with checksum + idempotent-republish

## Notes

- Judge model + prompt pinned per `scores` row gives Nia her reproducibility
- Multi-criterion weighted rubrics arrive in Wave 2

## Out of Scope

- Multi-criterion weighted rubrics (Wave 2)
- Ladder / enum scales (Wave 2)
- Inline judge prompt authoring (must use US-009 + US-010 first)
