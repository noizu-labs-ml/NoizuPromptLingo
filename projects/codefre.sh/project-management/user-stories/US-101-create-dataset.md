---
id: US-101
title: Create a dataset of request / expected-output pairs
issue_type: story
slug: create-dataset
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
  - eval
assignee: null
reporter: null
epic: post-mvp-datasets
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - nia-academic
  - sofia-product-manager
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-102
  - US-103
  - US-104
  - US-105
dependencies: []
blocks:
  - US-102
  - US-103
  - US-104
  - US-105
  - US-106
  - US-109
  - US-110
duplicates: []
schema_refs:
  - datasets
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Create a dataset of request / expected-output pairs

## Story

As an **AI Research Engineer**,
I want to **create a dataset — a named collection of (input, expected_output, optional rubric) tuples**
so that **I can evaluate an agent with traditional request→expected-output pairs alongside the graph-based scripts, and cite the dataset in papers**.

## Acceptance Criteria

- [ ] User enters `name` (required), `description` (optional), `type` (`request_response` | `conversation`)
- [ ] Slug auto-derives from name; unique within org
- [ ] Datasets head + first draft version created on save
- [ ] Dataset detail shows entry count, latest-version summary, and history
- [ ] Same head + version-table pattern as scripts / prompts / rubrics for reproducibility

## Notes

- Classical eval workflow: fixed test cases, judge scores each agent response against the expected output
- Complements graph-based scripts — teams can run both against the same agent in one cohort
- New schema entities: `datasets`, `dataset_versions`, `dataset_entries` (to be folded into `docs/arch/data-model.md` during the post-Wave-3 schema-alignment pass)

## Out of Scope

- Publishing the version (US-102)
- Adding entries (US-103)
- Dataset templates (Wave 3)
