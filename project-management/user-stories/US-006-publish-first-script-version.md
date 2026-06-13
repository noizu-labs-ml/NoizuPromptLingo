---
id: US-006
title: Publish the first version of a script
issue_type: story
slug: publish-first-script-version
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
  - versioning
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas:
  - nia-academic
related_stories:
  - US-001
  - US-007
  - US-015
dependencies:
  - US-001
  - US-003
  - US-005
blocks:
  - US-007
  - US-015
duplicates: []
schema_refs:
  - script_edges
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

# Publish the first version of a script

## Story

As a **Senior ML Engineer**,
I want to **publish my script as an immutable version**
so that **I can run it against agents and later compare runs from the same pinned version**.

## Acceptance Criteria

- [ ] "Publish" action appears in the editor when the script has at least one node
- [ ] Publishing validates: root node set, at least one expectation, all edges reference existing nodes
- [ ] On publish, a new `script_versions` row is created with monotonic `version_number`
- [ ] Canonical YAML snapshot + checksum are recorded
- [ ] Head's `current_version_id` advances to the new version
- [ ] Re-publish with identical canonical content returns the existing version (no duplicate)
- [ ] Published versions are read-only in the editor; edits start a new draft

## Notes

- Implements the head + version-table copy-on-write pattern from `docs/arch/data-model.md` §5.2
- Deferred FK `script_versions.root_node_id` resolved in the publish transaction

## Out of Scope

- Draft/pre-publish workflow refinements (Wave 2)
- Publish audit notifications (Wave 2)
- Version diff view (Wave 2)
