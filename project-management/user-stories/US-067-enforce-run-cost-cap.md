---
id: US-067
title: Enforce run-level cost cap (auto-cancel when exceeded)
issue_type: story
slug: enforce-run-cost-cap
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: run-execution
components:
  - backend
labels:
  - wave-2
  - runs
  - governance
  - cost
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas:
  - nia-academic
related_stories:
  - US-015
  - US-064
dependencies:
  - US-015
  - US-064
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

# Enforce run-level cost cap (auto-cancel when exceeded)

## Story

As a **Senior ML Engineer**,
I want to **set a maximum dollar cost for a single run, and have it auto-cancel when the cost is exceeded**
so that **a misconfigured script loop doesn't burn $200 of API calls in twenty minutes**.

## Acceptance Criteria

- [ ] Run trigger form accepts `cost_cap_usd` (optional) in `run_config`
- [ ] After every step, runner sums `(tokens_in + tokens_out) × published rate` and compares to cap
- [ ] Cap exceeded → runner cancels; run transitions to `status='cancelled'` with `error.type='cost_cap_exceeded'`
- [ ] Budget running close to cap (e.g. 80%) surfaces a warning badge on the live run page
- [ ] Default cap configurable per-org; null means no cap

## Notes

- Token rates maintained in app config per (provider, model) tuple; keep up-to-date as providers change pricing
- Cost estimation is post-hoc-per-step; runner doesn't predict next step's cost before it executes

## Out of Scope

- Pre-run cost prediction (Wave 3)
- Per-persona cost caps on a fan-out run (Wave 3)
