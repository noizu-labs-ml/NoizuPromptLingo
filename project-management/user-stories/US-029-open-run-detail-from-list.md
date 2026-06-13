---
id: US-029
title: Open run detail from the list
issue_type: story
slug: open-run-detail-from-list
status: in-progress
priority: P0
story_points: 2
estimated_scope: XS
category: results-and-dashboards
components:
  - frontend
labels:
  - mvp
  - wave-1
  - dashboards
  - navigation
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-017
  - US-025
  - US-030
  - US-031
  - US-032
dependencies:
  - US-025
  - US-017
blocks:
  - US-030
  - US-031
  - US-032
duplicates: []
schema_refs:
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Open run detail from the list

## Story

As a **Senior ML Engineer**,
I want to **click any row in the run list to open that run's full detail**
so that **the navigation from "I see an interesting run" to "I'm reading its steps" takes one action**.

## Acceptance Criteria

- [ ] Each run list row is clickable and navigates to `/runs/{id}`
- [ ] Deep-link to `/runs/{id}` works without first visiting the list
- [ ] Back button returns to the list with filters preserved
- [ ] Detail page URL is shareable (copy-link produces working URL for other org members)

## Notes

- Tenancy: detail page 404s gracefully for runs outside the caller's org

## Out of Scope

- Right-click "open in new tab" handling (default browser behavior is sufficient)
- Detail-page breadcrumb navigation (Wave 2)
