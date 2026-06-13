---
id: US-066
title: Retry a failed run from the failing step
issue_type: story
slug: retry-failed-run
status: draft
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
  - resilience
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-015
  - US-018
dependencies:
  - US-015
blocks: []
duplicates: []
schema_refs:
  - run_steps
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Retry a failed run from the failing step

## Story

As a **Senior ML Engineer**,
I want to **retry a failed run starting from the step that errored**
so that **a transient provider outage doesn't force me to re-pay the full run's token cost**.

## Acceptance Criteria

- [ ] On a failed run detail, a "Retry from step N" action is available (where N is the first errored step)
- [ ] Retry creates a new `runs` row; steps before N are *copied* (not re-executed) into the new run
- [ ] Retry pins the same `script_version_id`, `agent_version_id`, `run_personas`
- [ ] Retry's `run_config.retry_parent_run_id` records lineage
- [ ] Only failures with `error.type IN ('timeout', 'rate_limit', 'network', 'provider_5xx')` are retryable; auth/config errors require re-configuration first

## Notes

- Copy semantics: the new run references past `run_steps.agent_message` without re-calling the agent
- Run-detail diff-view can compare retried run to parent (via `retry_parent_run_id`)

## Out of Scope

- Retry with a different agent version (treat as a new run instead)
- Auto-retry on transient errors (Wave 3 — needs careful interaction with cost caps)
