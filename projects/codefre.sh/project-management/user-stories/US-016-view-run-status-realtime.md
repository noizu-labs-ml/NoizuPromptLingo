---
id: US-016
title: View run status update in real time
issue_type: story
slug: view-run-status-realtime
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
  - streaming
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
  - sofia-product-manager
related_stories:
  - US-015
  - US-017
  - US-030
dependencies:
  - US-015
blocks: []
duplicates: []
schema_refs:
  - run_steps
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# View run status update in real time

## Story

As a **Senior ML Engineer**,
I want to **watch a run's status and new steps appear in my browser without refreshing**
so that **I can catch problems mid-run and not have to wait for completion to investigate**.

## Acceptance Criteria

- [ ] Run detail page opens a streaming connection (WebSocket or SSE)
- [ ] New `run_steps` appear append-only as they're written by the runner
- [ ] Run `status` transitions (`pending` → `running` → terminal) update live
- [ ] Stream reconnects cleanly on transient disconnect
- [ ] If the user opens the page after completion, it shows the full run without a stream

## Notes

- Backed by `run_steps` ordered by `(run_id, step_index)` — reader pulls new rows from last seen index on reconnect
- Streaming infrastructure likely via Phoenix Channels or bandit SSE

## Out of Scope

- Streaming score updates (US-020 covers scores; streaming those live is Wave 2)
- Multi-run split view (Wave 3)
