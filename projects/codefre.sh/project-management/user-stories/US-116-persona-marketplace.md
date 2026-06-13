---
id: US-116
title: Import a persona from a shared marketplace
issue_type: story
slug: persona-marketplace
status: draft
priority: P2
story_points: 5
estimated_scope: M
category: persona-management
components:
  - backend
  - frontend
labels:
  - wave-3
  - personas
  - marketplace
assignee: null
reporter: null
epic: post-mvp-capture
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - alex-oss-maintainer
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-035
  - US-055
dependencies:
  - US-055
blocks: []
duplicates: []
schema_refs:
  - marketplace_personas
  - persona_versions
  - personas
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Import a persona from a shared marketplace

## Story

As a **Support Automation Engineer**,
I want to **browse community-contributed personas with ratings, descriptions, and sample runs**
so that **my multilingual / adversarial persona coverage starts from collective expertise rather than my own imagination**.

## Acceptance Criteria

- [ ] `/marketplace/personas` lists publicly-shared persona versions across orgs
- [ ] Each entry shows: title, author, downloads, average rating, last updated
- [ ] "Import" action deep-copies into the caller's org (exactly like US-055 library flow)
- [ ] Org admins can opt out of marketplace in settings

## Notes

- First cross-org sharing feature — introduces a `marketplace_personas` publication table and curation review
- Post-MVP feature per README "Adjacent Opportunities"

## Out of Scope

- Paid personas / marketplace monetization (far future)
- Review moderation workflow beyond soft-flag (Wave 3+)
