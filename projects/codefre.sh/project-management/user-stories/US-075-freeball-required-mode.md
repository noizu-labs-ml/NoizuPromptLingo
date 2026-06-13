---
id: US-075
title: Require freeball mode on a node (force freeball)
issue_type: story
slug: freeball-required-mode
status: in-progress
priority: P1
story_points: 2
estimated_scope: XS
category: freeball-protocol
components:
  - backend
  - frontend
labels:
  - wave-2
  - freeball
  - policy
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-022
  - US-043
  - US-074
dependencies:
  - US-022
blocks: []
duplicates: []
schema_refs:
  - script_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Require freeball mode on a node (force freeball)

## Story

As an **AI Red Team Researcher**,
I want to **mark nodes as `required` freeball mode so the runner always improvises from that point, even if an authored match exists**
so that **I can use authored-branch scaffolding around the script but deliberately probe specific points**.

## Acceptance Criteria

- [ ] `freeball_policy = :required` on a node triggers freeball unconditionally when the runner reaches it
- [ ] Any authored edges on a required-mode node are ignored during traversal
- [ ] Required-mode is visually marked in the graph editor (different color from strict mode)
- [ ] Alternative to adding a `freeball_anchor` (US-043) — node-policy approach works on existing node types

## Notes

- Distinction from US-043: `freeball_anchor` nodes are a separate `kind`; this is a policy override on regular node types (`user_turn`, etc.)
- Useful when you want a user-turn to have a prompt *and* mandatory freeball exploration from there

## Out of Scope

- Probability-weighted required-mode (Wave 3 — "50% of the time, force freeball")
