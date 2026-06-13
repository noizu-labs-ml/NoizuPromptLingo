---
id: US-045
title: Diff two script versions visually
issue_type: story
slug: diff-script-versions
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: script-authoring
components:
  - backend
  - frontend
labels:
  - wave-2
  - authoring
  - diff
  - versioning
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas:
  - sofia-product-manager
related_stories:
  - US-006
  - US-044
  - US-077
dependencies:
  - US-006
blocks: []
duplicates: []
schema_refs:
  - expectations
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

# Diff two script versions visually

## Story

As a **Senior ML Engineer**,
I want to **compare any two versions of the same script and see what changed**
so that **I can justify release decisions and review peer-authored changes before approving**.

## Acceptance Criteria

- [ ] User picks a base version and a target version of the same script
- [ ] Diff shows added / removed / modified nodes, edges, expectations
- [ ] YAML-level diff is also available as a fallback view
- [ ] Graph view highlights changed nodes in green/red/amber
- [ ] Attribute-level diffs shown on hover (e.g. expectation weight 0.7 → 0.9)

## Notes

- Diff computed server-side against `yaml_source` checksums for speed
- Visual graph-diff with node-level color coding is the hero; YAML fallback is safety net

## Out of Scope

- Three-way merge (Wave 3)
- Diff across *different* scripts (use fork then diff — Wave 3)
