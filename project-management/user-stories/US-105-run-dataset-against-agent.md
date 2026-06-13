---
id: US-105
title: Run a dataset against an agent (model-based eval)
issue_type: story
slug: run-dataset-against-agent
status: in-progress
priority: P1
story_points: 8
estimated_scope: L
category: datasets
components:
  - backend
  - frontend
labels:
  - wave-2
  - datasets
  - runs
  - eval
assignee: null
reporter: null
epic: post-mvp-datasets
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - nia-academic
  - priya-ml-engineer
secondary_personas:
  - sofia-product-manager
related_stories:
  - US-101
  - US-102
  - US-110
  - US-015
dependencies:
  - US-102
  - US-014
  - US-110
blocks: []
duplicates: []
schema_refs:
  - runs
  - run_steps
  - scores
  - datasets
  - dataset_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Run a dataset against an agent (model-based eval)

## Story

As an **AI Research Engineer**,
I want to **run every entry in a dataset version through an agent and score the agent's response against the expected_output using a rubric**
so that **I can report benchmark-style results for papers (accuracy, mean score, per-tag breakdowns) alongside my graph-based behavioral tests**.

## Acceptance Criteria

- [ ] "Run Dataset" action on a published dataset version; picks an agent version + rubric version
- [ ] Creates a `runs` row with `trigger_source='manual'` and `run_config.dataset_version_id = <pinned>`
- [ ] One `run_steps` row per dataset entry; `from_node_id` / `to_node_id` remain null (datasets have no graph); `user_message = input`, `agent_message = agent response`
- [ ] Each step scores against the pinned rubric comparing `agent_message` to `expected_output`
- [ ] Aggregate verdict: accuracy (% PASS), mean score, per-tag breakdown
- [ ] Fan-out across multiple agents supported (combines with US-070)

## Notes

- Unifies classical dataset eval with CodeFresh's run/score/verdict model by reusing `runs` / `run_steps` / `scores` tables — no separate "dataset run" table
- Graph-based scripts and datasets are interchangeable run *inputs*; output schema is the same

## Out of Scope

- Few-shot / in-context-learning prompt injection from dataset (Wave 3)
- Dataset-run persona fan-out (Wave 3 — scope check: does "persona + dataset" make sense?)
