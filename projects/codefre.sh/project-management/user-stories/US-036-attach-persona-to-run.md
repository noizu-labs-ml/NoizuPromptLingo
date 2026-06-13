---
id: US-036
title: Attach a persona to a run
issue_type: story
slug: attach-persona-to-run
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: persona-management
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - personas
  - runs
assignee: null
reporter: null
epic: mvp-runner
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
  - derek-support-engineer
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-015
  - US-035
dependencies:
  - US-035
  - US-015
blocks: []
duplicates: []
schema_refs:
  - persona_versions
  - run_personas
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Attach a persona to a run

## Story

As a **Support Automation Engineer**,
I want to **attach one persona to a run**
so that **the runner applies that persona's tone modulation and I can see how my agent behaves under it**.

## Acceptance Criteria

- [ ] Run trigger form (from US-015) accepts an optional persona picker
- [ ] On trigger, `run_personas` row is created pinning `persona_version_id`
- [ ] Runner mutates outgoing prompts per the selected persona's `tone` metadata
- [ ] Run detail shows the attached persona in the header
- [ ] Running with the same script twice — once with and once without a persona — produces two distinct runs (no upsert)

## Notes

- Multi-persona fan-out (many personas in parallel per run) is Wave 2
- Persona's effect on prompt mutation is defined in `docs/arch/freeball-protocol.md` adjacent notes

## Out of Scope

- Multi-persona fan-out (Wave 2)
- Per-step persona switching (Wave 3)
