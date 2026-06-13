---
id: US-042
title: Add a terminal node to mark the end of a conversation path
issue_type: story
slug: add-terminal-node
status: in-progress
priority: P1
story_points: 2
estimated_scope: XS
category: script-authoring
components:
  - backend
  - frontend
labels:
  - wave-2
  - authoring
  - graph-editor
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - alex-oss-maintainer
related_stories:
  - US-002
  - US-041
  - US-043
dependencies:
  - US-002
blocks: []
duplicates: []
schema_refs:
  - script_edges
  - script_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Add a terminal node to mark the end of a conversation path

## Story

As a **Senior ML Engineer**,
I want to **add terminal nodes that end a conversation path deterministically**
so that **my graph has explicit exit states and the runner doesn't keep sampling when the path should have closed**.

## Acceptance Criteria

- [ ] "Add Terminal Node" action creates a `kind='terminal'` node
- [ ] Terminal nodes may not attach a prompt (no agent turn follows)
- [ ] Terminal nodes have outgoing edges disabled (sink only)
- [ ] When the runner traverses to a terminal node, the run completes successfully
- [ ] A script may have many terminal nodes (branches may end in different terminals)

## Notes

- Absence of terminals is not a publish-time error; runs simply complete when no authored edge matches and the freeball policy decides next

## Out of Scope

- Terminal-specific verdict overrides (e.g. "terminating here means FAIL") — Wave 3
- Terminal labels as user-visible "exit reasons" — Wave 3
