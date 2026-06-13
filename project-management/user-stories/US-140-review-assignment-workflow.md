---
id: US-140
title: Review assignment workflow
issue_type: story
slug: review-assignment-workflow
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
  - workflow
assignee: null
reporter: null
epic: post-mvp-review
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
secondary_personas:
  - sofia-product-manager
related_stories:
  - US-088
  - US-089
dependencies:
  - US-088
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

# Review assignment workflow

## Story

As a **QA Lead**,
I want to **assign review items to specific teammates with a "my queue" view**
so that **large teams divide review work without everyone looking at the same top-of-queue**.

## Acceptance Criteria

- [ ] Queue rows expose "Assign to…" action with member picker
- [ ] Assigned items update `review_queue.assigned_to_user_id`
- [ ] "My queue" page filters to items assigned to the logged-in user
- [ ] Auto-assign rules based on tag or script (simple pattern matching, no complex logic)
- [ ] Unassign action returns item to shared pool

## Notes

- Matches `review_queue.assigned_to_user_id` from `data-model.md` §8.1

## Out of Scope

- Round-robin auto-assignment (Wave 3+)
- Review capacity modeling (Wave 3+)
