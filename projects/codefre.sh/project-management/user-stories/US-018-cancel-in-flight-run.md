---
id: US-018
title: Cancel an in-flight run
issue_type: story
slug: cancel-in-flight-run
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
assignee: null
reporter: null
epic: mvp-runner
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-015
dependencies:
  - US-015
blocks: []
duplicates: []
schema_refs:
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Cancel an in-flight run

## Story

As a **Senior ML Engineer**,
I want to **cancel a run that's still executing**
so that **I can stop wasting API budget the moment I realize something is off**.

## Acceptance Criteria

- [ ] "Cancel" button visible while `status IN ('pending', 'running')`
- [ ] Cancelation signals the runner process via `syn` registry; in-flight API call is not aborted but no new steps are issued
- [ ] Run transitions to `status='cancelled'`; `finished_at` is set
- [ ] Previously-written `run_steps` remain visible and immutable
- [ ] Re-cancelling an already-terminal run is a no-op (idempotent)

## Notes

- Cost cap auto-cancel is Wave 2 (`run_config.cost_cap_usd` enforcement)

## Out of Scope

- Aborting the in-flight upstream API call mid-response (Wave 3)
- Bulk cancel (Wave 3)
