---
id: US-127
title: Freeball learning mode (promoted paths tune the runner)
issue_type: story
slug: freeball-learning-mode
status: draft
priority: P3
story_points: 8
estimated_scope: L
category: freeball-protocol
components:
  - backend
labels:
  - wave-3
  - freeball
  - ml
  - research
  - stretch
assignee: null
reporter: null
epic: post-mvp-review
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
  - nia-academic
secondary_personas: [] 
related_stories:
  - US-089
  - US-090
  - US-071
dependencies:
  - US-090
blocks: []
duplicates: []
schema_refs:
  - freeball_nodes
  - organizations
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Freeball learning mode (promoted paths tune the runner)

## Story

As an **AI Red Team Researcher**,
I want **the runner prompt to auto-include examples of recently-approved freeball paths as few-shot seeds**
so that **the runner's future improvisations become more consistent with the org's accepted testing style over time**.

## Acceptance Criteria

- [ ] Org setting "Learning mode: enabled / disabled" (default: disabled)
- [ ] When enabled, runner prompt template gets auto-appended with N recent `:approved` freeball examples (most recent first)
- [ ] N configurable (default 3); bypasses if context window would be exceeded
- [ ] Learning sample selection biased toward higher-confidence approvals
- [ ] Disabling reverts immediately for future runs

## Notes

- Research-grade; may destabilize scoring if approved examples aren't representative
- No explicit training of models — in-context learning only

## Out of Scope

- Per-script learning scope (Wave 3+)
- Actual model fine-tuning (never — we're an eval tool, not a training platform)
