---
id: US-117
title: Persona heatmap visualization
issue_type: story
slug: persona-heatmap-visualization
status: cancelled
priority: P3
story_points: 3
estimated_scope: S
category: persona-management
components:
  - frontend
  - backend
labels:
  - wave-3
  - personas
  - visualization
  - stretch
assignee: null
reporter: null
epic: mvp-results
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - derek-support-engineer
secondary_personas: []
related_stories:
  - US-054
dependencies:
  - US-054
blocks: []
duplicates:
  - US-054
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Persona heatmap visualization

## Story

As an **AI Product Manager**,
I want to **see a heatmap where rows are personas, columns are script nodes, and cells are pass/warn/fail rates**
so that **one glance tells me which persona × node combinations are weakest and need product attention**.

## Acceptance Criteria

- [ ] Heatmap renders per-script on a "Coverage" tab
- [ ] Rows = persona versions used in any run of this script; columns = script nodes
- [ ] Cell color-coded by aggregate verdict (green/amber/red) with tooltip showing (pass, warn, fail) counts
- [ ] Click cell drills into all run_steps at that (persona × node)
- [ ] Time range selector

## Notes

- Query-heavy; consider a materialized view refreshed every 15min for large orgs

## Out of Scope

- Cross-script heatmap (Wave 3+)
- Per-expectation heatmap (Wave 3+)
