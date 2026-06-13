---
id: US-002
title: Add a user-turn node to a script
issue_type: story
slug: add-user-turn-node
status: in-progress
priority: P0
story_points: 2
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
secondary_personas:
  - nia-academic
related_stories:
  - US-001
  - US-003
  - US-005
dependencies:
  - US-001
blocks:
  - US-003
  - US-004
  - US-005
duplicates: []
schema_refs:
  - script_nodes
  - script_versions
  - scripts
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Add a user-turn node to a script

## Story

As a **Senior ML Engineer**,
I want to **add a user-turn node to my script's graph**
so that **I can describe a specific conversational step the agent under test must handle**.

## Acceptance Criteria

- [ ] User can create a new node from the graph editor with a unique `node_key`
- [ ] Node kind defaults to `user_turn` for the first node added
- [ ] Node appears in the graph at a configurable position
- [ ] First node created in an empty script becomes the script's root
- [ ] Node has placeholder state until a prompt is attached (US-003)
- [ ] `node_key` uniqueness within the script version is enforced

## Notes

- Nodes of kind `system`, `assistant_turn`, `terminal`, and `freeball_anchor` are addressed by later stories in Wave 2
- Editor position (x/y) is stored so the graph layout survives round-trips

## Out of Scope

- Attaching a prompt (US-003)
- Attaching expectations (US-004)
- Connecting nodes via edges (US-005)
