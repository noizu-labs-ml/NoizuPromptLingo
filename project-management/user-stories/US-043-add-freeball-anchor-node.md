---
id: US-043
title: Add a freeball-anchor node to explicitly invite freeball from a point
issue_type: story
slug: add-freeball-anchor-node
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
  - freeball
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas:
  - nia-academic
related_stories:
  - US-002
  - US-022
  - US-075
dependencies:
  - US-002
  - US-022
blocks: []
duplicates: []
schema_refs:
  - freeball_nodes
  - script_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Add a freeball-anchor node to explicitly invite freeball from a point

## Story

As a **Senior ML Engineer**,
I want to **mark a node as a freeball-anchor to explicitly invite freeball exploration from that point**
so that **I can use the runner's improvisation as a planned probe rather than only as a fallback**.

## Acceptance Criteria

- [ ] "Add Freeball Anchor" action creates a `kind='freeball_anchor'` node
- [ ] Freeball-anchor nodes do not require a prompt; their purpose is to immediately delegate to the runner
- [ ] Arrival at a freeball-anchor triggers freeball generation even when authored edges exist
- [ ] `freeball_policy` on a freeball-anchor node defaults to `:required`
- [ ] Generated freeball nodes link to the freeball-anchor as `parent_script_node_id`

## Notes

- Useful for Yuki's adversarial probing: anchor a "see what the agent does here" point into an otherwise structured script
- Interacts with US-075 (required mode) — this is the node-typed way to achieve the same outcome

## Out of Scope

- Freeball-anchor-specific runner prompts (Wave 3)
- Anchor-scoped budgets separate from global freeball budget (Wave 3)
