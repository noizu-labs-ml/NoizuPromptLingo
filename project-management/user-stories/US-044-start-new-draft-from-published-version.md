---
id: US-044
title: Start a new draft from a published script version
issue_type: story
slug: start-new-draft-from-published-version
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
  - versioning
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - marcus-qa-lead
related_stories:
  - US-006
  - US-045
  - US-090
dependencies:
  - US-006
blocks: []
duplicates: []
schema_refs:
  - expectations
  - persona_versions
  - personas
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

# Start a new draft from a published script version

## Story

As a **Senior ML Engineer**,
I want to **start editing a new draft from an already-published script version**
so that **I can iterate without mutating the version that my prior runs are pinned to**.

## Acceptance Criteria

- [ ] "Edit as new draft" action on a published script_version creates a working draft
- [ ] Draft duplicates the published version's nodes, edges, expectations in-memory (not yet persisted as `script_versions`)
- [ ] Draft tracks `parent_version_id = <published version>` for lineage
- [ ] Publishing the draft (US-006) creates a new `script_versions` row with `version_number = prior + 1`
- [ ] Discarding the draft leaves the published version untouched

## Notes

- Draft storage layer: can be frontend-only or backed by a "working_set" table; either is fine as long as publish-to-version is atomic

## Out of Scope

- Concurrent-draft conflict resolution (Wave 3)
- Auto-save of drafts across sessions (Wave 3)
