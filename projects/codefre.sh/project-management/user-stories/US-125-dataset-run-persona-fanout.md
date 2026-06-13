---
id: US-125
title: Dataset-run persona fan-out
issue_type: story
slug: dataset-run-persona-fanout
status: in-progress
priority: P3
story_points: 5
estimated_scope: M
category: run-execution
components:
  - backend
  - frontend
labels:
  - wave-3
  - runs
  - datasets
  - personas
  - stretch
assignee: null
reporter: null
epic: post-mvp-datasets
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
  - nia-academic
secondary_personas: []
related_stories:
  - US-105
  - US-052
dependencies:
  - US-105
  - US-052
blocks: []
duplicates: []
schema_refs:
  - run_personas
  - run_steps
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Dataset-run persona fan-out

## Story

As an **AI Red Team Researcher**,
I want **dataset-based eval runs to fan out across multiple personas**
so that **I can measure "does this benchmark behave differently when inputs are framed as hostile vs. confused users" in one cohort**.

## Acceptance Criteria

- [ ] Dataset-run trigger form accepts multiple personas (same UI as US-052)
- [ ] Each dataset entry is executed once per persona; persona tone-modulates the `input`
- [ ] Aggregates break down: accuracy per persona, disagreement across personas per entry
- [ ] Per-entry × persona result grid visualization

## Notes

- Edge case semantics: does "hostile persona applied to MMLU question" make sense? Users make the call; tool doesn't refuse.

## Out of Scope

- Automated persona-suitability warnings for dataset types (Wave 3+)
