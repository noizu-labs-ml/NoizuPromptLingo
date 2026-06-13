---
id: US-118
title: Per-step persona switching mid-run
issue_type: story
slug: per-step-persona-switching
status: draft
priority: P3
story_points: 5
estimated_scope: M
category: persona-management
components:
  - backend
  - frontend
labels:
  - wave-3
  - personas
  - advanced
  - stretch
assignee: null
reporter: null
epic: mvp-runner
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
secondary_personas:
  - derek-support-engineer
related_stories:
  - US-036
  - US-052
dependencies:
  - US-036
blocks: []
duplicates: []
schema_refs:
  - run_steps
  - script_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Per-step persona switching mid-run

## Story

As an **AI Red Team Researcher**,
I want **the runner to switch active persona at specific script nodes (e.g. "start friendly, become hostile at node 4")**
so that **I can probe how the agent handles abrupt user-mood transitions without authoring two separate scripts**.

## Acceptance Criteria

- [ ] Node editor accepts an optional `switch_persona_to` field
- [ ] Runner honors the switch; `run_steps.persona_version_id` reflects the active persona per step
- [ ] Switch is recorded in `run_steps.metadata` for audit
- [ ] Running under fan-out (US-052), switches apply within each parallel persona stream starting from that stream's initial persona

## Notes

- Edge case: switching to a persona the run wasn't initialized with is rejected at runtime (all potentially-active personas must be declared in `run_personas` up front)

## Out of Scope

- Probabilistic persona switching (Wave 3+)
- Per-edge persona switching (Wave 3+ — node-scoped only for now)
