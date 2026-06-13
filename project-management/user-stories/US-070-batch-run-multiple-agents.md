---
id: US-070
title: Trigger a batch run against multiple agents
issue_type: story
slug: batch-run-multiple-agents
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: run-execution
components:
  - backend
  - frontend
labels:
  - wave-2
  - runs
  - parallelism
  - comparison
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
  - nia-academic
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-015
  - US-077
dependencies:
  - US-015
blocks: []
duplicates: []
schema_refs:
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Trigger a batch run against multiple agents

## Story

As an **AI Red Team Researcher**,
I want to **run the same script against N agents (different models or different framework versions) in parallel**
so that **I can compare agent behavior at cohort level without N manual triggers**.

## Acceptance Criteria

- [ ] "Batch Run" action on a published script accepts a multi-select of agent versions
- [ ] One `runs` row is created per (script × agent) pair
- [ ] All runs share a `batch_id` tag in `run_config` so dashboards can group them
- [ ] Batch dashboard shows per-agent verdict in a compact table
- [ ] Batch cost estimate is shown before trigger; user confirms

## Notes

- Each run stays independent at the `runs` table level; the batch grouping is a tag not a parent FK
- Persona fan-out (US-052) combines orthogonally: script × N agents × M personas = N×M runs

## Out of Scope

- Cross-batch comparison (Wave 3)
- Scheduled batch runs (combine with US-069 in Wave 3)
