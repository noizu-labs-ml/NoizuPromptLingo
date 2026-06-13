---
id: US-051
title: Attach persona-layered expectations to script nodes
issue_type: story
slug: attach-persona-expectations-to-nodes
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: persona-management
components:
  - backend
  - frontend
labels:
  - wave-2
  - personas
  - expectations
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - yuki-red-teamer
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-035
  - US-004
  - US-052
dependencies:
  - US-035
  - US-004
blocks: []
duplicates: []
schema_refs:
  - persona_expectations
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Attach persona-layered expectations to script nodes

## Story

As a **Support Automation Engineer**,
I want to **layer persona-specific expectations onto nodes (e.g. "must not correct user's grammar when persona is broken-english")**
so that **I can encode persona-aware policies without forking the whole script per persona**.

## Acceptance Criteria

- [ ] From a persona version's detail page, user picks a script node and declares a `persona_expectation`
- [ ] Same fields as a base expectation (label, weight, direction, scoring_method, config, optional rubric/embedding)
- [ ] At run time, the runner evaluates base expectations + all `persona_expectations` for the active persona version
- [ ] Results dashboard shows persona expectations distinctly from base expectations
- [ ] Publishing validates cross-org consistency (persona + script node share `organization_id`)

## Notes

- Implements `persona_expectations` table in `docs/arch/data-model.md` §5.4
- Both FKs are immutable, so the row is effectively immutable; edits produce new persona versions

## Out of Scope

- Persona expectation that *replaces* a base expectation (currently both score; `replaces_expectation_id` overlay is Wave 3 decision)
- Per-persona weight overrides of base expectations (Wave 3)
