---
id: US-025
title: List recent runs for an organization
issue_type: story
slug: list-recent-runs
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: results-and-dashboards
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - dashboards
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas:
  - derek-support-engineer
related_stories:
  - US-015
  - US-026
  - US-027
  - US-028
  - US-029
dependencies:
  - US-015
  - US-039
blocks:
  - US-026
  - US-027
  - US-028
  - US-029
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

# List recent runs for an organization

## Story

As a **Senior ML Engineer**,
I want to **see a reverse-chronological list of recent runs in my organization**
so that **I can quickly find the run I just triggered or a run from yesterday without navigating through scripts**.

## Acceptance Criteria

- [ ] `/runs` page shows runs ordered by `inserted_at DESC`
- [ ] Each row shows: run ID/short-slug, script name + version, agent name + version, status badge, verdict (if terminal), started_at, duration
- [ ] Pagination: 50 per page, infinite scroll or explicit pager
- [ ] List scoped to the user's active organization
- [ ] Empty state explains how to trigger a run

## Notes

- Uses index on `runs (organization_id, inserted_at DESC)` from `data-model.md` §6.1
- List is the entry point for all filter/open-detail stories

## Out of Scope

- Cross-org list (no such feature — tenant-scoped)
- Saved filter views (Wave 2)
