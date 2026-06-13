---
id: US-009
title: Create a standalone prompt
issue_type: story
slug: create-standalone-prompt
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: prompt-management
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - prompts
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-010
  - US-011
  - US-003
dependencies: []
blocks:
  - US-010
  - US-011
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

# Create a standalone prompt

## Story

As a **Senior ML Engineer**,
I want to **create a prompt as a first-class versioned entity**
so that **I can reuse it across multiple script nodes and evolve its text without editing every script**.

## Acceptance Criteria

- [ ] User enters `name` (required), `description` (optional)
- [ ] Slug auto-derives from name; unique within org
- [ ] Prompt body is a draft text area until US-010 publishes a version
- [ ] Prompt list page lists all org prompts by name with "draft / published" status
- [ ] Archived prompts are hidden from the default list

## Notes

- Prompts are head entities; the version pattern lives in `docs/arch/data-model.md` §5.1

## Out of Scope

- Publishing the version (US-010)
- Template variable declarations (Wave 2)
- Tool/function definitions (Wave 2)
