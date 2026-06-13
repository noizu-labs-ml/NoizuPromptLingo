---
id: US-073
title: Support freeball-within-freeball nesting
issue_type: story
slug: freeball-within-freeball
status: draft
priority: P1
story_points: 5
estimated_scope: M
category: freeball-protocol
components:
  - backend
  - frontend
labels:
  - wave-2
  - freeball
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-022
  - US-072
dependencies:
  - US-022
  - US-072
blocks: []
duplicates: []
schema_refs:
  - freeball_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Support freeball-within-freeball nesting

## Story

As a **Senior ML Engineer**,
I want **freeball to continue operating when a freeball-generated node itself produces a deviating response**
so that **a multi-turn deviation gets captured end-to-end rather than aborting at the first nested off-script turn**.

## Acceptance Criteria

- [ ] When a freeball node's response matches no authored *or* prior freeball edges, the runner generates another freeball node
- [ ] New freeball node's `parent_freeball_node_id` links to the previous freeball step
- [ ] Depth tracking for cap enforcement (US-072) walks the `parent_freeball_node_id` chain
- [ ] Results UI renders nested freeball nodes as a sub-thread with indentation
- [ ] Each nested freeball step has its own confidence; chain surfaces cumulative-confidence

## Notes

- `freeball_nodes.parent_freeball_node_id` already modeled (`data-model.md` §6.4)

## Out of Scope

- Cross-run freeball chain merging (Wave 3)
- Nested promotion (promoting a whole nested chain in one action — see US-090)
