---
id: US-111
title: Bulk node operations in the graph editor
issue_type: story
slug: bulk-node-operations
status: cancelled
priority: P2
story_points: 5
estimated_scope: M
category: script-authoring
components:
  - frontend
labels:
  - wave-3
  - authoring
  - graph-editor
  - polish
assignee: null
reporter: null
epic: mvp-authoring
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-002
  - US-005
dependencies:
  - US-002
blocks: []
duplicates:
  - US-043
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Bulk node operations in the graph editor

## Story

As a **Senior ML Engineer**,
I want to **select multiple nodes and apply bulk operations (duplicate subtree, move, delete, tag)**
so that **large-script authoring doesn't turn into one-click-at-a-time tedium**.

## Acceptance Criteria

- [ ] Shift+click and rubber-band selection accumulate multiple nodes
- [ ] Bulk actions: delete, move, duplicate (with edge-preservation for subtree copies), tag
- [ ] Duplicate-subtree preserves local edge topology; auto-renames `node_key` with suffix
- [ ] Undo / redo works across bulk operations
- [ ] Keyboard shortcuts for common bulk ops (Cmd+D duplicate, Delete remove)

## Notes

- Subtree copy is the highest-value bulk op; pure multi-select delete is table-stakes

## Out of Scope

- Cross-script subtree paste (Wave 3 if demand emerges; not now)
