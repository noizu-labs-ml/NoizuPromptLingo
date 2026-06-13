---
id: US-054
title: See per-persona results breakdown on a run
issue_type: story
slug: per-persona-results-breakdown
status: draft
priority: P1
story_points: 3
estimated_scope: S
category: persona-management
components:
  - backend
  - frontend
labels:
  - wave-2
  - personas
  - dashboards
assignee: null
reporter: null
epic: mvp-results
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - sofia-product-manager
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-052
  - US-021
dependencies:
  - US-052
blocks: []
duplicates: []
schema_refs:
  - run_steps
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# See per-persona results breakdown on a run

## Story

As a **Support Automation Engineer**,
I want to **see a breakdown of pass/warn/fail counts and aggregate score by persona on a fan-out run**
so that **I can immediately tell which persona the agent is failing most for**.

## Acceptance Criteria

- [ ] On a run that has multiple `run_personas`, a "By Persona" card lists each persona with: verdict, aggregate score, freeball-step count, total steps
- [ ] Clicking a persona filters the step list to that persona's stream
- [ ] Card sorted descending by "failure intensity" (fail count, then warn count)
- [ ] Visual cue (red/amber/green band) on each persona row

## Notes

- Backed by `run_steps.persona_version_id` index
- Complements `US-021` (aggregate summary) by adding the persona dimension

## Out of Scope

- Cross-run persona comparison (Wave 3)
- Persona heatmap visualization (Wave 3)
