---
id: US-041
title: Add a system-prompt node to a script
issue_type: story
slug: add-system-prompt-node
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
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
  - US-042
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

# Add a system-prompt node to a script

## Story

As a **Senior ML Engineer**,
I want to **add a system-prompt node at the head of my script graph**
so that **I can prime the agent with instructions before the first user turn**.

## Acceptance Criteria

- [ ] "Add System Node" action available in the graph editor
- [ ] System nodes use `kind='system'` and reject incoming edges except from other system nodes
- [ ] A script may have 0..1 leading system nodes; multiple are rejected with a clear error
- [ ] Attached prompt body is passed to the adapter's system role, not injected as a user turn
- [ ] System nodes are highlighted distinctly in the graph editor

## Notes

- Runner maps system nodes to the adapter-specific system-message channel (OpenAI `system` role, Anthropic `system` parameter)

## Out of Scope

- Multi-turn system conversation (not a standard pattern)
- Inline system prompt editing without a referenced `prompt_version_id` (use US-011's reference mechanism)
