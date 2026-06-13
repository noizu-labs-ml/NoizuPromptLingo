---
id: US-017
title: See each step's prompt and agent response in run detail
issue_type: story
slug: see-step-prompt-and-response
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: run-execution
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - runs
  - results
assignee: null
reporter: null
epic: mvp-runner
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - derek-support-engineer
  - yuki-red-teamer
related_stories:
  - US-015
  - US-030
  - US-031
dependencies:
  - US-015
blocks:
  - US-029
  - US-030
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

# See each step's prompt and agent response in run detail

## Story

As a **Senior ML Engineer**,
I want to **see the exact prompt sent and exact response received for every step of a run**
so that **I can understand why the agent produced the verdict it did**.

## Acceptance Criteria

- [ ] Run detail page lists steps in `step_index` order
- [ ] Each step row shows the sent `user_message` and received `agent_message`
- [ ] Per-step latency (ms) and token counts (in/out) are visible
- [ ] Long messages are truncated with a "show all" expander
- [ ] Step shows whether it matched an authored edge, triggered freeball, or errored

## Notes

- Full raw JSON drill-down is US-031
- Persona-per-step display belongs to Wave 2

## Out of Scope

- Copy-to-clipboard per step (Wave 2)
- Side-by-side compare of two steps (Wave 2)
