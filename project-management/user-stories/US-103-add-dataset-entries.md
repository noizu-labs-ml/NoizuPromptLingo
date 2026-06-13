---
id: US-103
title: Add entries to a dataset manually
issue_type: story
slug: add-dataset-entries
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: datasets
components:
  - backend
  - frontend
labels:
  - wave-2
  - datasets
assignee: null
reporter: null
epic: post-mvp-datasets
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - sofia-product-manager
  - nia-academic
secondary_personas:
  - derek-support-engineer
related_stories:
  - US-101
  - US-104
  - US-106
dependencies:
  - US-101
blocks:
  - US-102
duplicates: []
schema_refs:
  - dataset_entries
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Add entries to a dataset manually

## Story

As an **AI Product Manager**,
I want to **add individual (input, expected_output) entries to a dataset via a web form**
so that **I can quickly add test cases I discover in production or manual QA sessions without writing a CSV**.

## Acceptance Criteria

- [ ] Dataset detail page exposes an "Add Entry" form
- [ ] Form fields: `entry_key` (auto-generated if blank), `input` (text or structured JSON), `expected_output` (text), `tags` (list), `notes` (optional)
- [ ] Validation: `input` required, `expected_output` required for `request_response` type
- [ ] Added entries live in the current draft version until publish (US-102)
- [ ] Draft entries editable; published entries read-only

## Notes

- `dataset_entries` table: (id, dataset_version_id, entry_key, input jsonb, expected_output jsonb, tags text[], notes text, inserted_at)
- `entry_key` uniqueness scoped to `(dataset_version_id, entry_key)` supports re-import idempotency

## Out of Scope

- Rich-text / markdown in expected_output (Wave 3)
- Per-entry rubric overrides (Wave 3 — US-110 covers dataset-level attach)
