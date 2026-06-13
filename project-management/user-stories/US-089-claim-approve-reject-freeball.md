---
id: US-089
title: Claim, approve, or reject a freeball node
issue_type: story
slug: claim-approve-reject-freeball
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
  - workflow
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
  - derek-support-engineer
related_stories:
  - US-088
  - US-090
dependencies:
  - US-088
blocks:
  - US-090
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

# Claim, approve, or reject a freeball node

## Story

As a **QA Lead**,
I want to **claim a freeball review item, see full context, then approve or reject it with notes**
so that **the three outcomes of the Freeball Protocol's promotion lifecycle (promote, regression-flag, discard) are explicit actions I take intentionally**.

## Acceptance Criteria

- [ ] "Claim" action on a queue row sets `review_queue.status='claimed'`, `assigned_to_user_id`, `claimed_at`
- [ ] Claimed item shows full context: parent script node, freeball prompt, agent response, confidence, runner's generated expectations
- [ ] Three resolution actions: **Approve** (queue up for promotion via US-090), **Reject as regression** (persist to regression suite tag), **Dismiss** (queue row resolved, no promotion)
- [ ] Resolution notes field required for `Reject` and `Dismiss`; optional for `Approve`
- [ ] Claimed items older than 24h auto-release back to the queue (prevent stuck items)
- [ ] Freeball node `review_status` updates in lockstep: `:approved` / `:rejected`

## Notes

- Regression suite behavior (how flagged regressions feed back into future runs) is a Wave 3 concern; this story only persists the flag
- Auto-release uses a Quantum/Oban scheduled job

## Out of Scope

- Bulk claim / approve (Wave 3)
- Inline editing of runner-generated expectations before approval (Wave 3)
