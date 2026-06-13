---
id: US-074
title: Enforce strict mode on a node (reject freeball)
issue_type: story
slug: freeball-strict-mode
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
  - priya-ml-engineer
secondary_personas:
  - derek-support-engineer
related_stories:
  - US-022
  - US-002
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

# Enforce strict mode on a node (reject freeball)

## Story

As a **Senior ML Engineer**,
I want to **mark specific nodes as `strict` to forbid freeball on them**
so that **deviations at policy-critical nodes (e.g. refund-amount confirmation) fail the run instead of being improvised around**.

## Acceptance Criteria

- [ ] Node editor lets the user set `freeball_policy` to `:allow` (default), `:strict`, or `:required`
- [ ] With `:strict`, if the runner finds no authored edge match, the run step fails with `error.type='strict_no_match'`
- [ ] Strict-policy nodes are visually marked in the graph editor (e.g. red border)
- [ ] Publishing validates that at least one `:always`-match or `:required` edge leaves a strict node's children (avoid dead ends)

## Notes

- Matches `script_nodes.freeball_policy` enum from `data-model.md` §5.2
- Derek uses this for policy-gate nodes (refund, escalation-level)

## Out of Scope

- Per-persona strict overrides (Wave 3)
- Soft-strict (warn but continue) — not adding a new enum value
