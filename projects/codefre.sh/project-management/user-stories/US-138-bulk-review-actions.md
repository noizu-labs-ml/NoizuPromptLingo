---
id: US-138
title: Bulk actions on the freeball review queue
issue_type: story
slug: bulk-review-actions
status: in-progress
priority: P2
story_points: 3
estimated_scope: S
category: review-and-promotion
components:
  - backend
  - frontend
labels:
  - wave-3
  - review
  - bulk
assignee: null
reporter: null
epic: post-mvp-review
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
  - sofia-product-manager
secondary_personas: [] 
related_stories:
  - US-088
  - US-089
dependencies:
  - US-089
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

# Bulk actions on the freeball review queue

## Story

As a **QA Lead**,
I want to **multi-select queue rows and approve / dismiss / flag-as-regression in bulk**
so that **Monday's 80-item backlog doesn't cost me 80 individual clicks**.

## Acceptance Criteria

- [ ] Queue rows support multi-select (checkboxes or shift-click)
- [ ] Bulk bar shows: Approve all, Dismiss all, Flag regression, Assign to user
- [ ] Bulk actions require a confirmation dialog with count and preview
- [ ] Bulk Approve respects individual freeball promotion semantics (opens a summary preview before committing)
- [ ] Large selections (>20) show a warning to prevent accidental mass-action

## Notes

- Confirmation text includes a summary of "will create N new script_versions across M scripts"

## Out of Scope

- Saved bulk filter + auto-apply combos (Wave 3+)
