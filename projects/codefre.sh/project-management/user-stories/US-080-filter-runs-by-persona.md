---
id: US-080
title: Filter the run list by persona
issue_type: story
slug: filter-runs-by-persona
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
  - personas
assignee: null
reporter: null
epic: mvp-results
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-025
  - US-036
  - US-052
dependencies:
  - US-025
  - US-036
blocks: []
duplicates: []
schema_refs:
  - persona_versions
  - personas
  - run_personas
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Filter the run list by persona

## Story

As a **Support Automation Engineer**,
I want to **filter runs to those that included a specific persona (e.g. hostile, broken-english)**
so that **I can quickly review all historical runs that exercised the persona my policy work is focused on**.

## Acceptance Criteria

- [ ] Filter accepts a persona head selector
- [ ] Runs are matched via `run_personas.persona_version_id → persona_versions.persona_id`
- [ ] Works for both single-persona and fan-out (US-052) runs
- [ ] Combines with other filters; URL persists

## Notes

- Query joins `runs` → `run_personas` → `persona_versions` → `personas`

## Out of Scope

- Filter by specific persona version (Wave 3)
- Filter by persona tone tag (Wave 3)
