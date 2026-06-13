---
id: US-095
title: SDK query helpers for runs, steps, and scores
issue_type: story
slug: sdk-query-helpers
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: sdks
components:
  - sdk-python
  - sdk-elixir
  - sdk-typescript
labels:
  - wave-2
  - sdk
  - queries
assignee: null
reporter: null
epic: post-mvp-sdks
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - nia-academic
secondary_personas:
  - alex-oss-maintainer
related_stories:
  - US-091
  - US-092
  - US-093
dependencies:
  - US-091
blocks: []
duplicates: []
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# SDK query helpers for runs, steps, and scores

## Story

As an **AI Research Engineer**,
I want **SDK helpers that iterate paginated results for runs, steps, and scores with optional filters (script, agent, persona, date range, verdict)**
so that **building analysis scripts over thousands of runs is straightforward in Python or Elixir without re-implementing pagination each time**.

## Acceptance Criteria

- [ ] Python: `for run in client.runs.iter(script="...", agent="...", since="2026-01-01"): ...` — auto-paginates transparently
- [ ] Elixir: `Stream`-based — `Codefresh.Runs.stream(client, script: "...", agent: "...", since: ~U[2026-01-01])`
- [ ] TypeScript: Async iterators — `for await (const run of client.runs.iter({ script, agent, since })) { ... }`
- [ ] Filters supported: script, agent, persona, status, verdict, since/until, batch_id, organization_id
- [ ] Similar helpers for `client.run_steps.iter(run_id=...)` and `client.scores.iter(run_id=..., run_step_id=...)`

## Notes

- Pagination under the hood uses cursor-based (opaque next-page token); users never construct page params
- Batch fetching respects server-side rate limits; SDK throttles automatically

## Out of Scope

- Query language (SQL-like DSL) over runs (Wave 3)
- Server-side aggregations exposed through SDK (Wave 3)
