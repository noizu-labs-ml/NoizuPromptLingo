---
id: US-077
title: Side-by-side diff view of two runs
issue_type: story
slug: diff-two-runs
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: results-and-dashboards
components:
  - backend
  - frontend
labels:
  - wave-2
  - dashboards
  - diff
assignee: null
reporter: null
epic: mvp-results
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-015
  - US-066
  - US-070
dependencies:
  - US-015
blocks: []
duplicates: []
schema_refs:
  - expectations
  - run_steps
  - runs
  - scores
  - script_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Side-by-side diff view of two runs

## Story

As a **Senior ML Engineer**,
I want to **pick any two runs of the same script and see their steps, verdicts, and scores side-by-side**
so that **I can prove "this release of the agent did worse on step 4 than the previous release"**.

## Acceptance Criteria

- [ ] Run list supports multi-select; "Compare" action opens the diff view with exactly two runs
- [ ] Diff view shows steps aligned by `(from_node_id, step_index)` where possible; mismatches highlighted
- [ ] Per-step agent_message diffed textually (side-by-side or inline markup)
- [ ] Per-expectation score delta shown (e.g. 0.72 vs. 0.91, Δ +0.19)
- [ ] Overall verdict comparison at the top (PASS → WARN is highlighted amber, FAIL → FAIL flagged red)

## Notes

- Alignment heuristic: prefer `script_version_id` match (same script version = same authored graph). Cross-version compares fall back to best-effort step_index matching.
- Rubric-version differences are surfaced but not conflated with agent-response differences

## Out of Scope

- Three+-way run compare (Wave 3)
- Statistical significance annotations (Wave 3)
