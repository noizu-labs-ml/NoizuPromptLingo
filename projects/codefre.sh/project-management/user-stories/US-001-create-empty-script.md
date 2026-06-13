---
id: US-001
title: Create an empty script with name and description
issue_type: story
slug: create-empty-script
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: script-authoring
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - authoring
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas:
  - nia-academic
related_stories:
  - US-002
  - US-006
  - US-007
dependencies: []
blocks:
  - US-002
  - US-003
  - US-004
  - US-005
  - US-006
  - US-007
duplicates: []
schema_refs:
  - organizations
  - scripts
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Create an empty script with name and description

## Story

As a **Senior ML Engineer**,
I want to **create a new empty script with a name and description**
so that **I can start building a conversation test suite without existing boilerplate getting in the way**.

## Acceptance Criteria

- [ ] Editor UI exposes a "New Script" action
- [ ] `name` is required; `description` is optional
- [ ] Slug auto-derives from `name` (kebab-case), editable before first publish
- [ ] On save, a new script identity is created in the user's active organization
- [ ] A draft working version is created but not yet published
- [ ] User is navigated to the graph editor with the new empty script loaded
- [ ] Duplicate slug within the same organization is rejected with a clear error

## Notes

- This is the entry point for all other authoring work; must work before any other AUTH story lands
- Publish semantics (what makes a version "published" vs. "draft") live in US-006

## Out of Scope

- Adding nodes (US-002)
- Publishing a version (US-006)
- Importing from YAML (US-007)
