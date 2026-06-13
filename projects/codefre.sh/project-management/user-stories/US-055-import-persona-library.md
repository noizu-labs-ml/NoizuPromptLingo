---
id: US-055
title: Import a persona from a shared starter library
issue_type: story
slug: import-persona-library
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: persona-management
components:
  - backend
  - frontend
labels:
  - wave-2
  - personas
  - library
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - alex-oss-maintainer
  - derek-support-engineer
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-035
dependencies:
  - US-035
blocks: []
duplicates: []
schema_refs:
  - personas
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Import a persona from a shared starter library

## Story

As a **Support Automation Engineer**,
I want to **import a persona from a curated starter library (broken-english, hostile, confused-novice, etc.)**
so that **I start from a well-calibrated baseline instead of defining tone from scratch**.

## Acceptance Criteria

- [ ] "Import Persona" browses a built-in library of starter personas (ships with the app)
- [ ] Each starter persona shows: name, tone tag, description, sample system preamble
- [ ] Import creates a fresh `personas` head + `persona_versions` v1 in the user's org (deep copy)
- [ ] Imported persona is fully editable without affecting the library source
- [ ] Library persona definitions live in a code-shipped YAML manifest (versioned with the app)

## Notes

- Library is in-app curation, not a marketplace (marketplace is post-MVP)
- Default library seeds: broken-english, hostile, confused-novice, adversarial, over-specific, context-switch (matches README tone tags)

## Out of Scope

- User-contributed personas to the library (post-MVP marketplace)
- Diff-to-latest-library when starter personas evolve across app versions (Wave 3)
