---
id: US-088
title: Show the freeball review queue
issue_type: story
slug: review-queue-page
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: review-and-promotion
components:
  - backend
  - frontend
labels:
  - wave-2
  - review
  - freeball
assignee: null
reporter: null
epic: post-mvp-review
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
  - sofia-product-manager
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-022
  - US-089
  - US-090
dependencies:
  - US-022
blocks:
  - US-089
duplicates: []
schema_refs:
  - review_queue
  - freeball_nodes
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Show the freeball review queue

## Story

As a **QA Lead**,
I want **a single page listing every pending freeball node awaiting review across all scripts**
so that **I can triage deviations in one sitting rather than hunting through individual runs**.

## Acceptance Criteria

- [ ] `/review` page lists `review_queue` rows where status = `:pending`
- [ ] Each row shows: parent script + node, freeball prompt preview, confidence, runner model, timestamp, run link
- [ ] Filterable by: script, persona, confidence range, age, runner model
- [ ] Sortable by confidence ascending / descending (low-confidence surfaces first for human attention)
- [ ] Pagination for large queues
- [ ] Badge in global nav shows queue count for the current org

## Notes

- Matches `review_queue` schema from `docs/arch/data-model.md` §8.1

## Out of Scope

- Per-user assignment workflow (Wave 3)
- SLA / aging alerts (Wave 3)
