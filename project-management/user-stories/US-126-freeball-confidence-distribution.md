---
id: US-126
title: Freeball confidence distribution histograms
issue_type: story
slug: freeball-confidence-distribution
status: draft
priority: P3
story_points: 3
estimated_scope: S
category: freeball-protocol
components:
  - backend
  - frontend
labels:
  - wave-3
  - freeball
  - analytics
  - stretch
assignee: null
reporter: null
epic: mvp-results
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-024
  - US-076
dependencies:
  - US-024
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

# Freeball confidence distribution histograms

## Story

As a **Senior ML Engineer**,
I want to **see a histogram of runner confidence across all freeball nodes in a run or org**
so that **I know whether my runner is consistently confident or systematically uncertain — either signal is actionable**.

## Acceptance Criteria

- [ ] Histogram view on run detail (run-scope) and org dashboard (cross-run)
- [ ] Buckets: 0.0-0.1, 0.1-0.2, ..., 0.9-1.0 (10 buckets)
- [ ] Split by runner model for orgs with multiple runner configs
- [ ] Drill-through to the underlying freeball_nodes

## Notes

- Low-confidence-heavy distributions suggest swapping runner model; high-confidence-heavy may indicate runner is overfitting

## Out of Scope

- Automated runner-tuning feedback loop (Wave 3+ research)
