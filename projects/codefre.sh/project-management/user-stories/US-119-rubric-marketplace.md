---
id: US-119
title: Import a rubric from a shared marketplace
issue_type: story
slug: rubric-marketplace
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: rubric-and-scoring
components:
  - backend
  - frontend
labels:
  - wave-3
  - rubrics
  - marketplace
assignee: null
reporter: null
epic: post-mvp-capture
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - nia-academic
secondary_personas:
  - alex-oss-maintainer
related_stories:
  - US-033
  - US-116
dependencies:
  - US-033
blocks: []
duplicates: []
schema_refs:
  - marketplace_rubrics
  - rubric_versions
  - rubrics
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Import a rubric from a shared marketplace

## Story

As an **AI Product Manager**,
I want to **browse community-shared rubrics (e.g. "Anthropic safety rubric v2", "RAG-answer-quality rubric") and import into my org**
so that **I start from vetted judging criteria rather than hand-crafting every rubric from scratch**.

## Acceptance Criteria

- [ ] `/marketplace/rubrics` browse page with filter by domain (safety / RAG / code-gen / etc.) and provenance
- [ ] Rubric detail shows: criteria list, judge model, author, sample scoring on a canned example
- [ ] Import deep-copies the rubric (name + version) into the caller's org
- [ ] Imported rubric retains `imported_from` provenance pointer for attribution

## Notes

- Marketplace publishing is a separate flow (cross-org) — initial version is curator-edited starter pack

## Out of Scope

- User publishing back to marketplace (Wave 3+)
