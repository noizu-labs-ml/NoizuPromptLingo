---
id: US-104
title: Import a dataset from CSV or JSON
issue_type: story
slug: import-dataset-csv-json
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: datasets
components:
  - backend
  - frontend
  - cli
labels:
  - wave-2
  - datasets
  - import
  - oss
assignee: null
reporter: null
epic: post-mvp-datasets
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - nia-academic
  - alex-oss-maintainer
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-101
  - US-103
  - US-105
dependencies:
  - US-101
blocks: []
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

# Import a dataset from CSV or JSON

## Story

As an **AI Research Engineer**,
I want to **import an existing benchmark (MMLU subset, a custom CSV, a JSONL file) into a CodeFresh dataset**
so that **I can evaluate it within the same framework I use for scripts and persona fan-out**.

## Acceptance Criteria

- [ ] Editor + CLI (`codefresh datasets import <file>`) accept CSV / JSON / JSONL
- [ ] User maps columns / fields to `input`, `expected_output`, `tags`, `notes` via a mapping UI (or `--map` flag)
- [ ] Validation: every entry produces a non-empty `input`; clear error on malformed rows
- [ ] Re-import matching an existing dataset returns existing version if checksum identical; else creates a new version
- [ ] CLI exit code 0 on success; non-zero with row numbers of failures

## Notes

- CSV parsing tolerant of quoted newlines, BOM, mixed line endings
- JSONL preferred over JSON (streaming; large datasets handled without loading fully)

## Out of Scope

- Streaming import from URL (Wave 3)
- HuggingFace datasets integration (Wave 3)
- Parquet (Wave 3)
