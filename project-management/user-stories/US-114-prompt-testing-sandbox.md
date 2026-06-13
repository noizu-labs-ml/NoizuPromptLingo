---
id: US-114
title: Prompt testing sandbox
issue_type: story
slug: prompt-testing-sandbox
status: in-progress
priority: P2
story_points: 3
estimated_scope: S
category: prompt-management
components:
  - backend
  - frontend
labels:
  - wave-3
  - prompts
  - sandbox
assignee: null
reporter: null
epic: mvp-authoring
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - sofia-product-manager
secondary_personas: []
related_stories:
  - US-010
  - US-048
dependencies:
  - US-010
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

# Prompt testing sandbox

## Story

As a **Senior ML Engineer**,
I want to **test a draft prompt against an agent directly from the prompt editor**
so that **I can iterate on prompt wording without publishing, attaching to a script, and running a full eval**.

## Acceptance Criteria

- [ ] Prompt editor has a "Test" pane with variable-binding inputs, agent picker, and a "Send" button
- [ ] Test fires a single-turn call to the selected agent with the rendered prompt
- [ ] Response displayed inline with latency + tokens
- [ ] Test invocations are out-of-band: no `runs` row created; cost accounted against a "sandbox" budget
- [ ] History of last 5 sandbox invocations visible for compare

## Notes

- Complements `US-058` (rubric preview) with prompt-side iteration

## Out of Scope

- Multi-turn sandbox (Wave 3+ — full script run covers it)
