---
id: US-023
title: See freeball-generated prompt in run detail
issue_type: story
slug: see-freeball-prompt
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: freeball-protocol
components:
  - frontend
labels:
  - mvp
  - wave-1
  - freeball
  - results
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-017
  - US-022
  - US-024
dependencies:
  - US-022
blocks: []
duplicates: []
schema_refs:
  - freeball_nodes
  - run_steps
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# See freeball-generated prompt in run detail

## Story

As a **Senior ML Engineer**,
I want to **see which prompt the freeball engine improvised**
so that **I can evaluate whether that improvisation was reasonable or itself the source of a misleading score**.

## Acceptance Criteria

- [ ] Freeball steps are visually distinct in the step list (e.g. orange tint)
- [ ] The freeball prompt text is shown inline alongside the agent response
- [ ] The parent authored node (`parent_script_node_id`) is linked so the user can see where the deviation originated
- [ ] `runner_model` used for generation is displayed

## Notes

- Keeps the freeball path first-class in the results view rather than hiding it in a drawer

## Out of Scope

- Promote/reject actions inline (Wave 2, REV category)
- Editing the freeball prompt post-hoc (not supported — freeball prompts are immutable)
