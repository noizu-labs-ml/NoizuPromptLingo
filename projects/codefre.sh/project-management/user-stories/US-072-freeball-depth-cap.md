---
id: US-072
title: Enforce a freeball depth cap / budget
issue_type: story
slug: freeball-depth-cap
status: draft
priority: P1
story_points: 3
estimated_scope: S
category: freeball-protocol
components:
  - backend
labels:
  - wave-2
  - freeball
  - governance
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas: []
related_stories:
  - US-022
  - US-067
dependencies:
  - US-022
blocks: []
duplicates: []
schema_refs:
  - freeball_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Enforce a freeball depth cap / budget

## Story

As a **Senior ML Engineer**,
I want to **cap how many consecutive freeball steps a run can take before it's forcibly terminated**
so that **an agent that keeps going off-script doesn't let the runner improvise indefinitely and rack up cost**.

## Acceptance Criteria

- [ ] `run_config.freeball_max_depth` (default: 5) caps consecutive freeball steps
- [ ] `run_config.freeball_max_total` (default: 20) caps total freeball steps per run (non-consecutive)
- [ ] Hitting a cap terminates the run with `status='failed'` and `error.type='freeball_cap_exceeded'`
- [ ] Cap reached is visible in the run detail with a clear explanation
- [ ] Caps can be disabled per-run by setting to `null` (for research workflows — Nia, Yuki)

## Notes

- Protects against freeball infinite loops where agent and runner conspire to ping-pong

## Out of Scope

- Cost-per-freeball-step caps (folded into US-067 run-level cost cap)
- Adaptive depth that expands as confidence grows (Wave 3)
