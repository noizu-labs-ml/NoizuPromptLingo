---
id: US-019
title: Get run-level pass/warn/fail verdict
issue_type: story
slug: run-level-verdict
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: run-execution
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - runs
  - results
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas:
  - derek-support-engineer
related_stories:
  - US-020
  - US-021
  - US-038
dependencies:
  - US-015
  - US-020
blocks:
  - US-038
duplicates: []
schema_refs:
  - runs
  - scores
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Get run-level pass/warn/fail verdict

## Story

As a **QA Lead**,
I want to **see a single pass/warn/fail verdict at the top of every run detail page**
so that **I can make release decisions without reading every step**.

## Acceptance Criteria

- [ ] Run detail displays a large `PASS` / `WARN` / `FAIL` badge once the run completes
- [ ] Verdict rules:
  - [ ] Any expectation's `verdict='fail'` on a `direction='negative'` (must-not) expectation → run is FAIL
  - [ ] Any step with `status='error'` → run is FAIL
  - [ ] Otherwise, run's aggregate score below `run_config.threshold` (default 0.85) → FAIL
  - [ ] Between threshold and `threshold + 0.05` → WARN (freeball-heavy runs default here)
  - [ ] Above → PASS
- [ ] Verdict is persisted in `runs.summary_metrics`

## Notes

- CLI threshold gate (US-038) reads this same verdict
- Marcus uses this for formal release-gate decisions

## Out of Scope

- Per-persona verdicts (Wave 2)
- Per-expectation-tag sub-verdicts (Wave 2)
