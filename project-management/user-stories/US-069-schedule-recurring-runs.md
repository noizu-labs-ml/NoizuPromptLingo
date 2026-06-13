---
id: US-069
title: Schedule recurring runs via cron expression
issue_type: story
slug: schedule-recurring-runs
status: in-progress
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
  - scheduling
  - ci
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas: []
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

# Schedule recurring runs via cron expression

## Story

As a **Senior ML Engineer**,
I want to **schedule a script to run on a cron (e.g. every night at 02:00 UTC) against a pinned agent**
so that **I catch behavioral regressions between releases without anyone remembering to click "run"**.

## Acceptance Criteria

- [ ] Script detail exposes "Schedule" form: cron expression, timezone, enabled toggle, pinned agent_version
- [ ] Scheduler creates runs with `trigger_source='scheduled'` at the specified times
- [ ] Multiple schedules per script allowed (e.g. one nightly, one weekly)
- [ ] Missed runs (downtime) do NOT backfill — next scheduled tick runs normally
- [ ] Schedule list page shows all org schedules with next-fire-time

## Notes

- Backed by a Quantum or Oban-like Elixir job scheduler
- Schedule table is out-of-scope for the Phase-2 schema; add `schedules` table in follow-up

## Out of Scope

- Dynamic scheduling (e.g. "run whenever the prompt changes") — Wave 3
- Rate-limited smart scheduling based on prior failure rate (Wave 3)
