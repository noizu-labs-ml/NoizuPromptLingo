---
id: US-130
title: Custom dashboard builder
issue_type: story
slug: custom-dashboard-builder
status: in-progress
priority: P3
story_points: 8
estimated_scope: L
category: results-and-dashboards
components:
  - frontend
  - backend
labels:
  - wave-3
  - dashboards
  - customization
  - stretch
assignee: null
reporter: null
epic: mvp-results
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - marcus-qa-lead
secondary_personas: []
related_stories:
  - US-078
  - US-129
dependencies:
  - US-078
blocks: []
duplicates: []
schema_refs:
  - dashboard_versions
  - dashboards
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Custom dashboard builder

## Story

As an **AI Product Manager**,
I want to **assemble my own dashboard from a palette of metrics (verdict trends, persona heatmap, cohort accuracy, freeball volume)**
so that **leadership weekly-review slides are one URL, not six screenshots**.

## Acceptance Criteria

- [ ] Dashboard editor: drag-drop widgets from a palette onto a grid
- [ ] Widget types: trend chart, heatmap, cohort table, run list, metric card
- [ ] Widgets configured with filters (script, agent, persona, date range)
- [ ] Saved dashboards are org-scoped; sharable by URL
- [ ] Clone an existing dashboard to a new variant

## Notes

- Dashboard persistence: `dashboards` table (head) + `dashboard_versions` (published snapshots) for consistency with versioning pattern

## Out of Scope

- Embedding external iframes (Wave 3+)
- Scheduled dashboard email digest (Wave 3+)
