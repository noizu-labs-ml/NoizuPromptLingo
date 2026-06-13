---
id: US-137
title: Regression suite from rejected freeballs
issue_type: story
slug: regression-suite-from-rejected-freeballs
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: review-and-promotion
components:
  - backend
  - frontend
labels:
  - wave-3
  - review
  - regression
  - freeball
assignee: null
reporter: null
epic: post-mvp-review
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
  - derek-support-engineer
secondary_personas: [] 
related_stories:
  - US-089
  - US-109
dependencies:
  - US-089
blocks: []
duplicates: []
schema_refs:
  - datasets
  - runs
  - scripts
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Regression suite from rejected freeballs

## Story

As a **QA Lead**,
I want **freeball nodes rejected as "regression" (US-089) to automatically feed into a regression suite the runner checks on every future run**
so that **bugs we flagged once become permanent tripwires without manual script edits**.

## Acceptance Criteria

- [ ] Rejection as regression tagged on the freeball promotes the captured input to a regression dataset for that script
- [ ] Future runs of the script append regression-dataset steps after the graph traversal (always-on)
- [ ] Regression-dataset failures are always counted as FAIL on the run verdict (never WARN/PASS)
- [ ] Dashboard shows regression-suite failure rate per script over time
- [ ] Admins can remove items from the regression suite with justification

## Notes

- Uses dataset-run infrastructure (US-105) as the substrate

## Out of Scope

- Auto-regression across all scripts (Wave 3+; per-script scope is the default)
