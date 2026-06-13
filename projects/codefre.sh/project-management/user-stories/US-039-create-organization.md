---
id: US-039
title: Create an organization
issue_type: story
slug: create-organization
status: in-progress
priority: P0
story_points: 2
estimated_scope: S
category: tenancy-and-admin
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - tenancy
assignee: null
reporter: null
epic: mvp-tenancy
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-040
dependencies: []
blocks:
  - US-040
  - US-025
duplicates: []
schema_refs:
  - memberships
  - organizations
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Create an organization

## Story

As a **QA Lead**,
I want to **create a new organization**
so that **my team can collaborate in an isolated tenant boundary distinct from any personal workspace**.

## Acceptance Criteria

- [ ] Authenticated user can create an org via a form: `name` (required), `slug` (auto-derived, editable, globally unique)
- [ ] Creating user becomes `:owner` via an automatic `memberships` row
- [ ] User's active org switches to the newly created one
- [ ] Empty org state renders helpful "create your first script" CTA
- [ ] Slug collisions are rejected with a clear error

## Notes

- Global unique slug (not per-user) because org slugs appear in URLs
- First-user signup flow auto-creates a personal org (Wave 2)

## Out of Scope

- Signup / first-user UX (Wave 2, ORG category continues)
- Org billing setup (out of MVP entirely)
- Org deletion (Wave 3)
