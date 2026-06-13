---
id: US-148
title: Flag digest email
issue_type: story
slug: flag-digest-email
status: in-progress
priority: P3
story_points: 2
estimated_scope: XS
category: flagged-captures
components:
  - backend
labels:
  - wave-3
  - capture
  - notifications
  - stretch
assignee: null
reporter: null
epic: post-mvp-capture
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - sofia-product-manager
secondary_personas: [] 
related_stories:
  - US-107
  - US-147
dependencies:
  - US-107
blocks: []
duplicates: []
schema_refs:
  - flagged_captures
  - memberships
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Flag digest email

## Story

As a **Support Automation Engineer**,
I want **a weekly digest email summarizing new flagged captures, sorted by tag and reason**
so that **my curation practice is habit-driven rather than dependent on me remembering to open the library**.

## Acceptance Criteria

- [ ] User-level opt-in for digest (default: off)
- [ ] Frequency options: daily, weekly, monthly
- [ ] Email includes: counts by reason, top 5 by age, link to library filtered to new items
- [ ] Unsubscribe link per email

## Notes

- Use transactional email provider (SES, Postmark) — not a built-in SMTP

## Out of Scope

- Slack / Teams digest (combine with US-144 webhook surface)
