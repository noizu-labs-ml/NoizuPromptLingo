---
id: US-090
title: Promote a freeball chain to a new script version
issue_type: story
slug: promote-freeball-chain
status: in-progress
priority: P1
story_points: 8
estimated_scope: L
category: review-and-promotion
components:
  - backend
  - frontend
labels:
  - wave-2
  - review
  - freeball
  - versioning
assignee: null
reporter: null
epic: post-mvp-review
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-089
  - US-073
  - US-006
  - US-044
dependencies:
  - US-089
  - US-006
blocks: []
duplicates: []
schema_refs:
  - branch_promotions
  - script_versions
  - script_nodes
  - script_edges
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Promote a freeball chain to a new script version

## Story

As a **QA Lead**,
I want to **promote an approved freeball chain (possibly nested) into a new version of the script that includes the branch as authored nodes**
so that **the deviation is no longer tentative — future runs treat it as a first-class branch and score it against stable expectations**.

## Acceptance Criteria

- [ ] "Promote" action on an approved freeball node (or a chain root) opens a preview of the new script version diff
- [ ] Preview shows: added script_nodes (one per freeball node), added script_edges (branching from the parent authored node), and the runner-generated expectations converted to authored expectations (editable)
- [ ] User can edit labels, weights, and scoring methods on expectations before confirming promotion
- [ ] Confirming creates a new `script_versions` row (via US-006 publish semantics) with `parent_version_id` pointing to the source version
- [ ] `branch_promotions` audit row records: source freeball, source version, target version, node_mapping, edge_additions, user, timestamp
- [ ] Source freeball's `review_status` becomes `:promoted`; unique constraint prevents double promotion

## Notes

- Node prompts are materialized as new `prompt_versions` using the freeball's inline `prompt_text`
- Nested chains (US-073) promote entire subtrees in one action; each freeball_node → one new script_node, preserving `parent_freeball_node_id` as the authored edge shape
- Diff-preview pattern reuses US-045 rendering

## Out of Scope

- Promotion with manual topology rewrites (Wave 3)
- Promote-and-auto-run regression suite (Wave 3)
