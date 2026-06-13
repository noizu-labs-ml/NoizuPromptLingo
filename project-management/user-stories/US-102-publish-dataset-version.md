---
id: US-102
title: Publish a new dataset version
issue_type: story
slug: publish-dataset-version
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
  - versioning
assignee: null
reporter: null
epic: post-mvp-datasets
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - nia-academic
  - marcus-qa-lead
secondary_personas:
  - sofia-product-manager
related_stories:
  - US-101
  - US-103
  - US-105
dependencies:
  - US-101
  - US-103
blocks:
  - US-105
duplicates: []
schema_refs:
  - dataset_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Publish a new dataset version

## Story

As an **AI Research Engineer**,
I want to **publish my dataset as an immutable version with a checksum**
so that **runs pinned to that version remain reproducible even when I evolve the dataset later**.

## Acceptance Criteria

- [ ] "Publish" action creates a `dataset_versions` row with monotonic `version_number`
- [ ] Checksum computed over the normalized JSON of all dataset entries (sorted by entry_key)
- [ ] Re-publish with identical content returns existing version (no-op)
- [ ] Published version is read-only; edits start a new draft (pattern mirrors US-006)
- [ ] `parent_version_id` tracks lineage when forking a dataset

## Notes

- Version immutability is load-bearing for paper citations — reviewers must be able to re-run exact version N

## Out of Scope

- Version deprecation / warnings (Wave 3)
- Version diff UI (Wave 3)
