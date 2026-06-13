---
id: US-035
title: Create a basic persona with a tone tag
issue_type: story
slug: create-basic-persona
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: persona-management
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - personas
assignee: null
reporter: null
epic: mvp-authoring
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
  - derek-support-engineer
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-036
dependencies: []
blocks:
  - US-036
duplicates: []
schema_refs:
  - persona_versions
  - personas
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Create a basic persona with a tone tag

## Story

As a **Support Automation Engineer**,
I want to **create a persona with a tone tag like "hostile" or "broken-english"**
so that **I can later attach it to runs and verify my agent handles those users correctly**.

## Acceptance Criteria

- [ ] User enters `name`, `slug`, optional `description`
- [ ] User sets `tone` (free-text tag; starter suggestions surfaced: `broken-english`, `hostile`, `confused-novice`, `adversarial`, `over-specific`, `context-switch`)
- [ ] Publish action creates `persona_versions` row with checksum
- [ ] Published personas appear in the persona-picker when configuring runs

## Notes

- Persona-layered expectations (`persona_expectations`) are Wave 2
- Tone tag is indexable for search/filter (Wave 2 "find personas by tone")

## Out of Scope

- System-prompt preamble attached to persona (Wave 2)
- Layered expectations per persona (Wave 2)
