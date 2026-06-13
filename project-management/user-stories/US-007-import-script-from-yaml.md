---
id: US-007
title: Import a script from a YAML file
issue_type: story
slug: import-script-from-yaml
status: in-progress
priority: P0
story_points: 5
estimated_scope: M
category: script-authoring
components:
  - backend
  - frontend
  - cli
labels:
  - mvp
  - wave-1
  - authoring
  - yaml
  - oss
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
  - nia-academic
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-008
  - US-037
dependencies:
  - US-001
  - US-006
blocks:
  - US-037
duplicates: []
schema_refs:
  - prompt_versions
  - prompts
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

# Import a script from a YAML file

## Story

As an **OSS Framework Maintainer**,
I want to **import a script from a YAML file**
so that **I can version my script suite in git and share it with users without a hosted dependency**.

## Acceptance Criteria

- [ ] Editor supports YAML paste or file upload; CLI supports `codefresh import <file>`
- [ ] YAML schema validates: required fields, enum values, graph connectivity
- [ ] Referenced prompts, personas, rubrics, agents are resolved by slug + version in the target org
- [ ] Missing references produce a clear, actionable error (not a stack trace)
- [ ] On success, a new script identity + initial `script_versions` is created
- [ ] Re-importing the same YAML (same checksum) is a no-op — returns existing version

## Notes

- YAML format is canonical; round-trip tested against US-008
- Referenced-entity resolution policy (strict vs. auto-create) is strict for MVP

## Out of Scope

- Auto-creating missing prompts/personas/etc. on import (Wave 2)
- Partial-import recovery from errors (Wave 2)
