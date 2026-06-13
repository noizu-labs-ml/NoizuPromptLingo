---
id: US-139
title: Promote a freeball expectation to a persona-scoped expectation
issue_type: story
slug: promote-freeball-to-persona-expectation
status: in-progress
priority: P3
story_points: 3
estimated_scope: S
category: review-and-promotion
components:
  - backend
  - frontend
labels:
  - wave-3
  - review
  - personas
  - stretch
assignee: null
reporter: null
epic: post-mvp-review
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-089
  - US-090
  - US-051
dependencies:
  - US-089
  - US-051
blocks: []
duplicates: []
schema_refs:
  - branch_promotions
  - persona_expectations
  - persona_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Promote a freeball expectation to a persona-scoped expectation

## Story

As a **Support Automation Engineer**,
I want to **promote a freeball expectation as a persona-scoped expectation (not a base expectation)**
so that **"when the user is hostile, the agent must de-escalate" becomes a persistent persona rule without affecting runs that use other personas**.

## Acceptance Criteria

- [ ] Alongside US-090 script-promotion path, offer "Promote as persona_expectation" option
- [ ] User picks the target persona version; the promoted expectation attaches via `persona_expectations`
- [ ] Persona head gets a new version reflecting the promotion; existing pinned persona_version_ids in other runs unaffected
- [ ] Branch_promotions record extended with `target_kind` = `script_version | persona_version`

## Notes

- Completes the "deviations observed under specific persona become persona-specific policy" loop

## Out of Scope

- Promoting to a brand-new persona (user must pick existing)
