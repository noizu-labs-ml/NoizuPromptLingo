---
id: US-133
title: ClickHouse mirror for OTel spans and logs
issue_type: story
slug: clickhouse-mirror-for-otel
status: in-progress
priority: P3
story_points: 13
estimated_scope: XL
category: otel-ingestion
components:
  - backend
  - infra
labels:
  - wave-3
  - otel
  - clickhouse
  - infrastructure
  - stretch
assignee: null
reporter: null
epic: post-mvp-otel
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas: [] 
related_stories:
  - US-081
  - US-131
dependencies:
  - US-081
blocks: []
duplicates: []
schema_refs:
  - otel_spans
  - otel_logs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# ClickHouse mirror for OTel spans and logs

## Story

As a **Senior ML Engineer**,
I want **OTel spans and logs mirrored to a ClickHouse cluster for high-volume querying**
so that **query latency stays fast as my org grows to millions of spans per day without degrading Postgres for the rest of the app**.

## Acceptance Criteria

- [ ] Background pipe consumes new `otel_spans` / `otel_logs` and inserts into ClickHouse with matching columns
- [ ] Column schema mirrors the Postgres schema's run-linking columns (stable per `data-model.md` §7 design)
- [ ] Query routing: attribute-filter queries (US-098) go to ClickHouse; run-step join queries still go to Postgres until full mirror
- [ ] Pipeline lag < 60s under nominal load
- [ ] Feature-flagged per org (opt-in during rollout)

## Notes

- Schema was designed to permit this; now we build the pipeline
- Consider using OTLP → ClickHouse directly (bypass Postgres for spans) as a future simplification

## Out of Scope

- Postgres deprecation for OTel tables (Wave 3+ — after mirror stabilizes)
- Cross-DB joins (impractical; keep concerns separate)
