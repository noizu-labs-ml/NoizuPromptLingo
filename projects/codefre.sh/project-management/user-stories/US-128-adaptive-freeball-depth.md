---
id: US-128
title: Adaptive freeball depth based on confidence
issue_type: story
slug: adaptive-freeball-depth
status: draft
priority: P3
story_points: 3
estimated_scope: S
category: freeball-protocol
components:
  - backend
labels:
  - wave-3
  - freeball
  - adaptive
  - stretch
assignee: null
reporter: null
epic: mvp-runner
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-072
  - US-024
dependencies:
  - US-072
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

# Adaptive freeball depth based on confidence

## Story

As a **Senior ML Engineer**,
I want **the freeball depth cap to expand for high-confidence chains and contract for low-confidence ones**
so that **the runner can explore promising deviations deeper without running on fumes when it's uncertain**.

## Acceptance Criteria

- [ ] Run config accepts `freeball_depth_policy`: `fixed` (default, per US-072) or `adaptive`
- [ ] Adaptive mode: cap = base_cap + extension where extension grows with chain average confidence
- [ ] Absolute max cap still enforced (2× base); adaptive cannot blow through cost guardrails
- [ ] Adaptive decisions logged in `freeball_nodes.metadata` for audit

## Notes

- Formulaic, not ML-trained — e.g. `extension = floor(avg_confidence × base_cap)`

## Out of Scope

- Cost-aware adaptation (combine with US-067 in Wave 3+)
