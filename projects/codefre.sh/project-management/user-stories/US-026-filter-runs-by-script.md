---
id: US-026
title: Filter the run list by script
issue_type: story
slug: filter-runs-by-script
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
  - marcus-qa-lead
secondary_personas: []
related_stories:
  - US-025
  - US-027
  - US-028
dependencies:
  - US-025
blocks: []
duplicates: []
schema_refs:
  - runs
  - script_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Filter the run list by script

## Story

As a **QA Lead**,
I want to **filter the run list to one specific script**
so that **I can see the history of runs for the script I'm about to sign off on**.

## Acceptance Criteria

- [ ] Filter control accepts a `script` selector (typeahead over org scripts)
- [ ] Applying the filter narrows the list to runs whose `script_version_id` belongs to the selected script head
- [ ] Filter state is reflected in URL query string (shareable)
- [ ] Clearing the filter returns to the unfiltered list

## Notes

- Filter joins `script_versions.script_id = <selected>`

## Out of Scope

- Filter by specific script version (Wave 2)
- Multi-script filter (Wave 2)
