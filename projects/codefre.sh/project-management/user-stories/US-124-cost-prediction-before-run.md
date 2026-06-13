---
id: US-124
title: Cost prediction before a run is triggered
issue_type: story
slug: cost-prediction-before-run
status: draft
priority: P2
story_points: 3
estimated_scope: S
category: run-execution
components:
  - backend
  - frontend
labels:
  - wave-3
  - runs
  - cost
assignee: null
reporter: null
epic: mvp-runner
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas: []
related_stories:
  - US-015
  - US-067
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

# Cost prediction before a run is triggered

## Story

As a **Senior ML Engineer**,
I want **the run trigger form to show an estimated USD cost before I confirm**
so that **I catch misconfigured fan-outs and freeball-budget mismatches before eating my API budget**.

## Acceptance Criteria

- [ ] Trigger form recomputes estimate live as user changes agent, personas, or run_config
- [ ] Estimate formula: `script_node_count × avg_tokens_per_step × agent_rate × persona_count × (1 + freeball_budget_ratio)`
- [ ] Historical run data from the same (script, agent) trains a better estimator after 10+ runs
- [ ] Warning shown when estimate exceeds run's `cost_cap_usd` or 2× the org's daily median
- [ ] Estimate logged as `run_config.cost_estimate_usd` for post-hoc comparison

## Notes

- Early estimate accuracy ±50%; improves with historical data; not a firm guarantee

## Out of Scope

- Pre-trigger cost caps at the agent level (US-064 covers runtime enforcement)
