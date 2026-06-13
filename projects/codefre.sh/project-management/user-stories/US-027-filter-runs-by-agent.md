---
id: US-027
title: Filter the run list by agent
issue_type: story
slug: filter-runs-by-agent
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
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-025
  - US-026
  - US-028
dependencies:
  - US-025
blocks: []
duplicates: []
schema_refs:
  - agent_versions
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Filter the run list by agent

## Story

As an **AI Red Team Researcher**,
I want to **filter runs by the agent they were executed against**
so that **I can compare behavior across model versions of the same agent head**.

## Acceptance Criteria

- [ ] Filter control accepts an `agent` selector
- [ ] Runs whose `agent_version_id` belongs to the selected agent head are shown
- [ ] Filter combines additively with script filter (US-026) and status filter (US-028)
- [ ] URL query string persists filter selection

## Notes

- Cohort comparison workflows in Wave 3 build on this filter

## Out of Scope

- Filter by specific agent version (Wave 2)
- Multi-agent OR filter (Wave 2)
