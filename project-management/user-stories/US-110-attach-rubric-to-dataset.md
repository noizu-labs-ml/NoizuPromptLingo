---
id: US-110
title: Attach a rubric to a dataset
issue_type: story
slug: attach-rubric-to-dataset
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
  - rubrics
  - scoring
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
  - priya-ml-engineer
related_stories:
  - US-101
  - US-033
  - US-056
  - US-105
dependencies:
  - US-101
  - US-033
blocks:
  - US-105
duplicates: []
schema_refs:
  - dataset_versions
  - rubric_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Attach a rubric to a dataset

## Story

As an **AI Product Manager**,
I want to **attach a default rubric version to a dataset**
so that **every dataset-eval run (US-105) uses a consistent scoring method unless explicitly overridden at run time**.

## Acceptance Criteria

- [ ] Dataset editor has a "Default Rubric" selector; picks any published rubric version in the org
- [ ] Attachment pins `rubric_version_id` at the dataset_version level (not the head)
- [ ] Run dataset action (US-105) defaults to the attached rubric; user can override
- [ ] Published dataset version's attached rubric is read-only; edits fork a new dataset draft

## Notes

- Keeps the `runs` table simple: no separate "dataset_rubric" join — attachment lives on the dataset_version

## Out of Scope

- Per-entry rubric override (Wave 3)
- Multiple rubrics attached with a "primary / secondary" split (Wave 3)
