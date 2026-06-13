---
id: US-098
title: Query OTel spans by attribute
issue_type: story
slug: otel-span-query-by-attribute
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
  - queries
assignee: null
reporter: null
epic: post-mvp-otel
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-081
  - US-082
  - US-099
  - US-100
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

# Query OTel spans by attribute

## Story

As a **Senior ML Engineer**,
I want to **search OTel spans by attribute key/value (e.g. `llm.tool = "search"`, `llm.model = "gpt-4.1"`)**
so that **I can find every step where the agent used a specific tool or model across all my runs**.

## Acceptance Criteria

- [ ] `/otel/spans` search page with attribute filter builder
- [ ] Backend query uses GIN index on `attributes jsonb_path_ops` (per `data-model.md` §7.1)
- [ ] Supports equality, presence, and numeric-range filters on attribute values
- [ ] Results paginate; each row links to the owning run step
- [ ] Filter state is URL-shareable

## Notes

- Queries scoped to the caller's org via `organization_id` index
- Start simple: no full SQL exposure; build up filter vocabulary over time

## Out of Scope

- Regex filters on attribute values (Wave 3)
- Logical OR / NOT operators (Wave 3 — AND only for now)
- Aggregations (count by attribute value) — Wave 3
