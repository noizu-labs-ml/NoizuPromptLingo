---
id: US-100
title: Semantic search over OTel span names and messages
issue_type: story
slug: otel-semantic-span-search
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: otel-ingestion
components:
  - backend
  - frontend
labels:
  - wave-2
  - otel
  - search
  - pgvector
assignee: null
reporter: null
epic: post-mvp-otel
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas:
  - nia-academic
related_stories:
  - US-098
dependencies:
  - US-082
blocks: []
duplicates: []
schema_refs:
  - otel_spans
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Semantic search over OTel span names and messages

## Story

As a **Senior ML Engineer**,
I want to **search OTel spans by semantic similarity (e.g. "database timeout errors")**
so that **I find relevant spans even when the exact attribute wording varies across services or retries**.

## Acceptance Criteria

- [ ] Background embedding worker populates `otel_spans.name_embedding` (vector(1536)) for new spans
- [ ] Query UI accepts a free-text search; embedding computed at query time; pgvector cosine similarity match returns top-K
- [ ] Semantic results sortable by similarity score
- [ ] Combining semantic search with attribute filters (US-098) is supported
- [ ] Embedding backfill for existing spans runs asynchronously; UI shows "indexing" progress

## Notes

- Embedding model lives in org settings (`embedding_model`); default documented (e.g. `openai:text-embedding-3-small` matching the vector(1536) schema choice)
- Cost of embedding generation is non-trivial at high span volume — sampled backfill strategy acceptable

## Out of Scope

- Hybrid BM25 + semantic scoring (Wave 3)
- Embedding of span events + attributes as a concatenated document (Wave 3)
