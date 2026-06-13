---
id: US-050
title: Browse the prompt library and reuse across scripts
issue_type: story
slug: browse-prompt-library
status: in-progress
priority: P1
story_points: 2
estimated_scope: XS
category: prompt-management
components:
  - frontend
  - backend
labels:
  - wave-2
  - prompts
  - reuse
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-003
  - US-009
  - US-011
dependencies:
  - US-009
blocks: []
duplicates: []
schema_refs:
  - prompts
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Browse the prompt library and reuse across scripts

## Story

As a **Senior ML Engineer**,
I want to **search and filter the organization's prompts by name, tag, or recent-usage**
so that **I can reuse a well-tested prompt rather than rewriting one that already exists**.

## Acceptance Criteria

- [ ] `/prompts` page lists published prompts with name, description, usage count (number of script nodes referencing its current version)
- [ ] Filter by tag / label
- [ ] Typeahead search over name and description
- [ ] Click-through reveals the published version's body and referencing scripts
- [ ] "Use this prompt" action returns to the originating node editor with the prompt attached

## Notes

- Usage count is a single-query aggregate over `script_nodes.prompt_version_id`

## Out of Scope

- Cross-org prompt sharing (post-MVP marketplace)
- Prompt recommendation based on node context (Wave 3)
