---
id: US-068
title: Stream scores in real time alongside the step stream
issue_type: story
slug: stream-scores-realtime
status: draft
priority: P1
story_points: 5
estimated_scope: M
category: run-execution
components:
  - backend
  - frontend
labels:
  - wave-2
  - runs
  - streaming
  - scoring
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - sofia-product-manager
secondary_personas: []
related_stories:
  - US-016
  - US-020
dependencies:
  - US-016
  - US-020
blocks: []
duplicates: []
schema_refs:
  - runs
  - scores
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Stream scores in real time alongside the step stream

## Story

As a **Senior ML Engineer**,
I want to **see each expectation's score appear live as soon as the judge returns**
so that **I don't have to wait for the whole run to finish to realize that every step is failing the same expectation**.

## Acceptance Criteria

- [ ] Score rows for a step are streamed to the UI via the same WebSocket/SSE channel as step updates
- [ ] Each score event includes: `run_step_id`, expectation label, verdict, score, rationale preview
- [ ] Step row updates incrementally as scores arrive (scoring may lag the step itself)
- [ ] Reconnecting mid-run replays pending scores from `scored_at` cursor

## Notes

- Scoring can be parallel-per-expectation — no serialization required
- Run-aggregate verdict update-on-the-fly is intentionally *not* part of this story; wait for US-019 fires at terminal only

## Out of Scope

- Progressive aggregate verdict during streaming (Wave 3 — care needed re: premature conclusions)
- Scoring retry notifications (Wave 3)
