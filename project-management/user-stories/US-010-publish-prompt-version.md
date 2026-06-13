---
id: US-010
title: Publish a new prompt version
issue_type: story
slug: publish-prompt-version
status: in-progress
priority: P0
story_points: 2
estimated_scope: S
category: prompt-management
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - prompts
  - versioning
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - alex-oss-maintainer
related_stories:
  - US-009
  - US-011
dependencies:
  - US-009
blocks:
  - US-011
duplicates: []
schema_refs:
  - prompt_versions
  - prompts
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Publish a new prompt version

## Story

As a **Senior ML Engineer**,
I want to **publish my prompt body as an immutable version**
so that **script nodes referencing it at the time of a run can always retrieve the exact text that was used**.

## Acceptance Criteria

- [ ] "Publish" action locks in the current draft text as a new `prompt_versions` row
- [ ] `version_number` increments monotonically per prompt
- [ ] Checksum is recorded; re-publishing identical body returns the existing version (no-op)
- [ ] Head's `current_version_id` advances to the new version
- [ ] Prompt detail page shows version history with published timestamps and publisher identity
- [ ] Published versions are read-only

## Notes

- Matches script-version semantics (US-006); applying the same head + version-table pattern

## Out of Scope

- Rollback-to-previous-version UI (Wave 2)
- Version comparison/diff view (Wave 2)
