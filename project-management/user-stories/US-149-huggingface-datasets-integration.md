---
id: US-149
title: HuggingFace datasets integration
issue_type: story
slug: huggingface-datasets-integration
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: datasets
components:
  - backend
  - frontend
  - cli
labels:
  - wave-3
  - datasets
  - integration
  - huggingface
assignee: null
reporter: null
epic: post-mvp-datasets
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - nia-academic
  - alex-oss-maintainer
secondary_personas: [] 
related_stories:
  - US-104
dependencies:
  - US-104
blocks: []
duplicates: []
schema_refs:
  - dataset_entries
  - dataset_versions
  - datasets
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# HuggingFace datasets integration

## Story

As an **AI Research Engineer**,
I want to **import a HuggingFace dataset directly by ID (e.g. `squad`, `mmlu`, `openai_humaneval`)**
so that **I evaluate against canonical benchmarks without manual download/conversion**.

## Acceptance Criteria

- [ ] `codefresh datasets import-hf <dataset_id> [--split train|validation|test] [--subset <config>]` and UI equivalent
- [ ] Backend fetches via `datasets` library (Python microservice) and materializes entries
- [ ] Column mapping prompts for non-standard datasets (which fields map to `input` / `expected_output`)
- [ ] Supports HF Hub auth token for private datasets
- [ ] Imported dataset tagged `source: huggingface:<id>` for provenance

## Notes

- Python service may be separate from main Elixir backend; communicate via a bounded job queue

## Out of Scope

- HF datasets with complex nested schemas (user maps manually — Wave 3+)
- Pushing back to HF Hub (Wave 3+)
