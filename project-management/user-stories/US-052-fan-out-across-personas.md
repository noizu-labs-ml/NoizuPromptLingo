---
id: US-052
title: Fan out a run across multiple personas in parallel
issue_type: story
slug: fan-out-across-personas
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: persona-management
components:
  - backend
  - frontend
labels:
  - wave-2
  - personas
  - runs
  - parallelism
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
  - derek-support-engineer
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-036
  - US-015
  - US-054
  - US-084
dependencies:
  - US-036
  - US-015
blocks: []
duplicates: []
schema_refs:
  - run_personas
  - run_steps
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Fan out a run across multiple personas in parallel

## Story

As an **AI Red Team Researcher**,
I want to **trigger a single "run" that fans out across N personas in parallel**
so that **one click produces persona-comparable results in a single cohort rather than requiring N manual triggers**.

## Acceptance Criteria

- [ ] Run trigger form accepts multiple persona selections (multi-select)
- [ ] One parent `runs` row is created; one `run_personas` row per selected persona version
- [ ] The runner spawns N parallel OTP processes (one per persona) under a shared supervisor
- [ ] Parallel step streams appear in a tabbed or columnar view in the run detail
- [ ] Overall run completes when all persona streams terminate; partial failures don't cancel others

## Notes

- `syn` registry pattern: `{{:run, run_id, persona_version_id}, pid}` so individual streams can be controlled
- Aggregate verdict rolls up: any persona stream FAIL → run FAIL; all PASS → run PASS; otherwise WARN

## Out of Scope

- Streaming per-persona verdict to leaderboard dashboard (Wave 3)
- Persona-fan-out across *multiple scripts* in one action (Wave 3 batch runs)
