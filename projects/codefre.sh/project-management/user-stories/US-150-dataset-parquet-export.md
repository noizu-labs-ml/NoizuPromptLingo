---
id: US-150
title: Export datasets as Parquet
issue_type: story
slug: dataset-parquet-export
status: in-progress
priority: P2
story_points: 3
estimated_scope: S
category: datasets
components:
  - backend
  - cli
labels:
  - wave-3
  - datasets
  - export
  - parquet
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
  - US-101
  - US-102
  - US-149
dependencies:
  - US-102
blocks: []
duplicates: []
schema_refs:
  - dataset_entries
  - dataset_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Export datasets as Parquet

## Story

As an **AI Research Engineer**,
I want to **export any dataset version as Parquet**
so that **my downstream analysis tooling (pandas / polars / DuckDB) loads the data at native speed instead of parsing JSON**.

## Acceptance Criteria

- [ ] Dataset detail exposes "Download Parquet" action
- [ ] CLI: `codefresh datasets export <slug>@<version> --format=parquet --out=<path>`
- [ ] Parquet schema mirrors `dataset_entries`: entry_key, input (string or json), expected_output (string or json), tags (list<string>), notes
- [ ] Auto-flatten nested JSON inputs into parquet STRUCT type when feasible; fallback to string-serialized JSON

## Notes

- Use `parquet` Erlang/Elixir library, or shell out to a Python helper — implementer's call

## Out of Scope

- Feather / Arrow export (Wave 3+)
- Streaming parquet over HTTP (Wave 3+)
