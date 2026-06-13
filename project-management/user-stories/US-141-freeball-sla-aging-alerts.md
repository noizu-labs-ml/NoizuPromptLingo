---
id: US-141
title: Freeball SLA aging alerts
issue_type: story
slug: freeball-sla-aging-alerts
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
  - alerts
  - stretch
assignee: null
reporter: null
epic: post-mvp-review
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
secondary_personas: [] 
related_stories:
  - US-088
  - US-140
dependencies:
  - US-140
blocks: []
duplicates: []
schema_refs:
  - review_queue
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Freeball SLA aging alerts

## Story

As a **QA Lead**,
I want **review queue items older than a configurable SLA to surface aging warnings and optional email alerts**
so that **long-tail backlog doesn't silently rot**.

## Acceptance Criteria

- [ ] Org setting: SLA (days, default 7); items past SLA display an aging badge
- [ ] Optional email alert: "You have N aged items" on Monday mornings
- [ ] Aging items surface first in default queue sort
- [ ] Per-user opt-out for email alerts

## Notes

- Simple threshold; no complex escalation rules

## Out of Scope

- Slack / Teams webhooks (Wave 3+ — integrate with US-144 webhook surface)
