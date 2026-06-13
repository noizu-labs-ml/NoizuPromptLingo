---
id: US-028
title: Filter the run list by status
issue_type: story
slug: filter-runs-by-status
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: results-and-dashboards
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - dashboards
  - filters
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-025
  - US-026
  - US-027
dependencies:
  - US-025
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

# Filter the run list by status

## Story

As a **Senior ML Engineer**,
I want to **filter the run list by status**
so that **I can quickly find my currently-running runs or isolate failed runs to investigate**.

## Acceptance Criteria

- [ ] Filter accepts one or more of: `pending`, `running`, `completed`, `failed`, `cancelled`
- [ ] Applying the filter narrows the list accordingly
- [ ] "Verdict" filter (PASS / WARN / FAIL) is a sibling control that applies only to `completed` runs
- [ ] Combines with script and agent filters
- [ ] URL query string persists selection

## Notes

- Enum matches `runs.status` from `data-model.md` §6.1

## Out of Scope

- Filter by persona attached to run (Wave 2)
- Date-range filter (Wave 2)
