---
id: US-113
title: Auto-layout the script graph
issue_type: story
slug: auto-layout-graph
status: cancelled
priority: P3
story_points: 3
estimated_scope: S
category: script-authoring
components:
  - frontend
labels:
  - wave-3
  - authoring
  - graph-editor
  - stretch
assignee: null
reporter: null
epic: mvp-authoring
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-002
  - US-111
dependencies:
  - US-002
blocks: []
duplicates:
  - US-044
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Auto-layout the script graph

## Story

As a **Senior ML Engineer**,
I want **an "Auto-layout" action that rearranges my graph into a readable topology**
so that **I don't spend ten minutes dragging nodes after a bulk operation scrambles the layout**.

## Acceptance Criteria

- [ ] "Auto-layout" button applies hierarchical layout (top-down or left-right selectable)
- [ ] Preserves user-set positions if the user has explicitly locked a node's position
- [ ] Animated transition so users see what changed
- [ ] Undo reverts the layout change
- [ ] Per-user preference for default direction persisted

## Notes

- dagre or elk.js under the hood — no custom layout algorithm needed

## Out of Scope

- Custom layout constraints (Wave 3+)
- Multi-document graph views (Wave 3+)
