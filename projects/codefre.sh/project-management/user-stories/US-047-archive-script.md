---
id: US-047
title: Archive a script
issue_type: story
slug: archive-script
status: in-progress
priority: P1
story_points: 2
estimated_scope: XS
category: script-authoring
components:
  - backend
  - frontend
labels:
  - wave-2
  - authoring
  - lifecycle
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-001
dependencies:
  - US-001
blocks: []
duplicates: []
schema_refs:
  - agents
  - personas
  - prompts
  - rubrics
  - scripts
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Archive a script

## Story

As a **QA Lead**,
I want to **archive scripts that are no longer in use without deleting them**
so that **past runs remain viewable for audit, but inactive scripts don't clutter the editor**.

## Acceptance Criteria

- [ ] "Archive" action on a script sets `archived_at` timestamp
- [ ] Archived scripts hidden from the default editor list
- [ ] Archived scripts still accessible via "Show archived" toggle
- [ ] Runs referencing an archived script's versions remain fully viewable
- [ ] "Unarchive" action restores visibility by clearing `archived_at`

## Notes

- Same archive semantics apply across prompts, rubrics, personas, agents (separate stories not needed unless UX diverges)
- Archive is NOT soft-delete; version tables untouched

## Out of Scope

- Cascading archive (archive a script → archive its prompts?) — no, refs are independent
- Permanent deletion (never — audit requirement)
