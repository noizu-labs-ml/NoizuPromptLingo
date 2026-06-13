---
id: US-011
title: Reference a published prompt from a script node
issue_type: story
slug: reference-prompt-from-node
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: prompt-management
components:
  - backend
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
  - US-003
  - US-010
dependencies:
  - US-010
  - US-003
blocks: []
duplicates: []
schema_refs:
  - prompt_versions
  - script_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Reference a published prompt from a script node

## Story

As a **Senior ML Engineer**,
I want **script nodes to pin a specific prompt *version***
so that **re-publishing the prompt after I run my script doesn't silently change the prompt text my past runs used**.

## Acceptance Criteria

- [ ] `script_nodes.prompt_version_id` points to a specific `prompt_versions` row, not the `prompts` head
- [ ] When a user attaches a prompt to a node in the editor, the current `current_version_id` is resolved and pinned
- [ ] User is offered an explicit "update to latest" action if the prompt has a newer version than the one pinned
- [ ] Past runs display the exact prompt body the pinned version had at run time
- [ ] Attempting to pin an un-published prompt is rejected

## Notes

- Makes reproducibility guarantee visible in the UI — Nia and Marcus both depend on this
- "Update to latest" creates a new draft script version rather than mutating the published one

## Out of Scope

- Bulk "update all nodes to latest prompt version" (Wave 2)
- Diff-preview before updating (Wave 2)
