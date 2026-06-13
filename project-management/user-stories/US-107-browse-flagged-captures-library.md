---
id: US-107
title: Browse the flagged captures library
issue_type: story
slug: browse-flagged-captures-library
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: flagged-captures
components:
  - backend
  - frontend
labels:
  - wave-2
  - capture
  - library
assignee: null
reporter: null
epic: post-mvp-capture
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - sofia-product-manager
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-106
  - US-108
  - US-109
dependencies:
  - US-106
blocks:
  - US-108
  - US-109
duplicates: []
schema_refs:
  - flagged_captures
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Browse the flagged captures library

## Story

As a **Support Automation Engineer**,
I want to **browse every flagged capture in my org with filters and search**
so that **during my weekly quality review I can work through newly flagged items and decide what to promote into scripts or datasets**.

## Acceptance Criteria

- [ ] `/captures` page lists flagged items, reverse-chronological by `inserted_at`
- [ ] Filters: tags, reason, flagged_by, date range, promoted status (unpromoted / promoted-to-script / promoted-to-dataset)
- [ ] Row displays: title, tags, reason, flagger, age, truncated input preview
- [ ] Typeahead search over title and notes
- [ ] Click-through to detail: full input, full agent response, linked OTel trace, original run step (if any)
- [ ] Bulk select + "tag all" / "promote all" actions

## Notes

- Library is the curation surface — a team's "interesting-things-we-saw" backlog
- Promoted captures remain visible (not archived on promotion) so curation history stays intact

## Out of Scope

- Per-user notifications on new flags (Wave 3)
- Automated digest emails (Wave 3)
