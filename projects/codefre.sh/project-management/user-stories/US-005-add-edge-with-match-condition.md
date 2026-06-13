---
id: US-005
title: Add a directed edge between two nodes with a match condition
issue_type: story
slug: add-edge-with-match-condition
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: script-authoring
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - authoring
  - graph-editor
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-002
  - US-022
dependencies:
  - US-002
blocks:
  - US-006
  - US-022
duplicates: []
schema_refs:
  - script_edges
  - script_nodes
  - script_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Add a directed edge between two nodes with a match condition

## Story

As a **Senior ML Engineer**,
I want to **connect two nodes with a directed edge carrying a match condition**
so that **the runner knows when to follow this branch based on the agent's response**.

## Acceptance Criteria

- [ ] User selects a source node and a target node in the graph editor
- [ ] Edge requires a `match_method`: `regex`, `semantic`, `lm_judge`, `structural`, `always`, `freeball`
- [ ] Method-specific `match_config` input appears
- [ ] Optional `label` and `priority` (lower wins)
- [ ] Self-loops are rejected unless `match_method` is `always`
- [ ] Edge renders in the graph with direction and label visible

## Notes

- `freeball` match method is the fall-through signal — see US-022
- Multiple edges from the same source are resolved by priority

## Out of Scope

- Semantic match embedding generation (Wave 2)
- Inline lm_judge prompt authoring (Wave 2)
- Edge bulk operations (Wave 2)
