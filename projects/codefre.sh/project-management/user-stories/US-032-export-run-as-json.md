---
id: US-032
title: Export a single run as JSON
issue_type: story
slug: export-run-as-json
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: results-and-dashboards
components:
  - backend
  - frontend
  - cli
labels:
  - mvp
  - wave-1
  - dashboards
  - exports
  - oss
assignee: null
reporter: null
epic: mvp-cli
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - nia-academic
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-029
  - US-037
dependencies:
  - US-029
blocks: []
duplicates: []
schema_refs:
  - run_personas
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

# Export a single run as JSON

## Story

As an **AI Research Engineer**,
I want to **export a run — including every step, score, and pinned version identifier — as a single JSON file**
so that **I can include it in reproducibility packages with my papers**.

## Acceptance Criteria

- [ ] "Export JSON" action on run detail produces a single file
- [ ] CLI supports `codefresh export-run <run-id> --out=<file>`
- [ ] Export includes: `runs` row, all `run_steps`, all `scores`, all `freeball_nodes` and their expectations, pinned version identifiers (script, agent, persona)
- [ ] Export does NOT include raw auth references or OTel span blobs (referenced by id only)
- [ ] Re-importing to a different CodeFresh instance with matching versioned entities reproduces the run view

## Notes

- Forms the foundation for Nia's reproducibility workflow and reviewer verification

## Out of Scope

- OTel span inclusion in the export (Wave 3 — deep-bundle format)
- CSV export for run data (Wave 2)
- Auto-upload to reproducibility service (never)
