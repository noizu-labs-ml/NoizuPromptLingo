---
id: US-015
title: Trigger a one-off run from the editor
issue_type: story
slug: trigger-one-off-run
status: in-progress
priority: P0
story_points: 5
estimated_scope: M
category: run-execution
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - runs
  - core-loop
assignee: null
reporter: null
epic: mvp-runner
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
  - sofia-product-manager
secondary_personas:
  - derek-support-engineer
related_stories:
  - US-016
  - US-017
  - US-018
  - US-019
dependencies:
  - US-006
  - US-014
blocks:
  - US-016
  - US-017
  - US-018
  - US-022
  - US-025
  - US-036
duplicates: []
schema_refs:
  - agent_versions
  - persona_versions
  - personas
  - run_personas
  - run_steps
  - runs
  - script_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Trigger a one-off run from the editor

## Story

As a **Senior ML Engineer**,
I want to **trigger a one-off run of my published script against a specific agent version from the editor**
so that **I can observe the agent's behavior in under a minute of setup**.

## Acceptance Criteria

- [ ] "Run" action appears on published `script_versions`; disabled for drafts
- [ ] User selects an `agent_version` from a picker (current published version pre-selected)
- [ ] User optionally supplies `run_config` (timeout, cost cap, freeball budget) with sensible defaults
- [ ] On trigger, a new `runs` row is created with `status='pending'`; `trigger_source='manual'`
- [ ] Run immediately transitions to `running` as the runner process picks it up
- [ ] User is redirected to the live run detail page
- [ ] Run pins `script_version_id` and `agent_version_id` immutably

## Notes

- OTP supervisor spawns a per-run process; `syn` registry tracks it
- Persona attachment is covered by US-036; this story runs with no persona

## Out of Scope

- Persona fan-out (US-036, Wave 2 for full multi-persona)
- Scheduled runs (Wave 2)
- Batch runs across multiple agents (Wave 2)
