---
id: US-003
title: Attach a prompt to a script node
issue_type: story
slug: attach-prompt-to-node
status: in-progress
priority: P0
story_points: 2
estimated_scope: S
category: script-authoring
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - authoring
  - graph-editor
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
  - US-002
  - US-009
  - US-011
dependencies:
  - US-002
  - US-011
blocks:
  - US-006
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

# Attach a prompt to a script node

## Story

As a **Senior ML Engineer**,
I want to **attach a published prompt to one of my script nodes**
so that **the runner has something concrete to send to the agent at that step**.

## Acceptance Criteria

- [ ] From the node detail pane, user can pick any published prompt in the organization
- [ ] Selected prompt version is displayed inline with body preview
- [ ] Changing the prompt on a draft node updates the reference without creating a new script version
- [ ] Attempting to attach a non-published prompt surfaces an error
- [ ] Node's attached prompt renders in the graph editor preview

## Notes

- Prompt versioning is independent of script versioning — see US-011 for the reference semantics

## Out of Scope

- Creating the prompt itself (US-009)
- Inline prompt editing from the node pane (Wave 2)
- Template variable binding at the node level (Wave 2)
