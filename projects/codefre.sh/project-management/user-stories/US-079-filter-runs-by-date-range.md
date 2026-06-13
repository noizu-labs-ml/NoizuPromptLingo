---
id: US-079
title: Filter the run list by date range
issue_type: story
slug: filter-runs-by-date-range
status: in-progress
priority: P1
story_points: 2
estimated_scope: XS
category: results-and-dashboards
components:
  - backend
  - frontend
labels:
  - wave-2
  - dashboards
  - filters
assignee: null
reporter: null
epic: mvp-results
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas: []
related_stories:
  - US-025
  - US-026
  - US-027
  - US-028
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

# Filter the run list by date range

## Story

As a **QA Lead**,
I want to **filter runs to a specific date range (e.g. "last week", "Q1", custom range)**
so that **I can build release-window reports without scrolling through months of runs**.

## Acceptance Criteria

- [ ] Filter control accepts: quick presets (today / 7d / 30d / 90d) and custom range (start + end date pickers)
- [ ] Filter applies to `runs.inserted_at`
- [ ] Combines with existing filters (script, agent, status, verdict)
- [ ] URL query string persists the range

## Notes

- Date-range queries use the `(organization_id, inserted_at DESC)` index established in `data-model.md` §6.1

## Out of Scope

- Timezone picker for range boundaries (default: user's browser TZ, shown inline)
- Saved date ranges (Wave 3)
