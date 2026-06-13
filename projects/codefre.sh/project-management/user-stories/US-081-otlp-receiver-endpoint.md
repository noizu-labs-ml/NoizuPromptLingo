---
id: US-081
title: Stand up an OTLP gRPC receiver endpoint for inbound agent spans
issue_type: story
slug: otlp-receiver-endpoint
status: in-progress
priority: P1
story_points: 8
estimated_scope: L
category: otel-ingestion
components:
  - backend
  - infra
labels:
  - wave-2
  - otel
  - infrastructure
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
  - US-082
  - US-094
  - US-098
dependencies:
  - US-015
blocks:
  - US-082
  - US-094
  - US-098
  - US-099
  - US-100
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

# Stand up an OTLP gRPC receiver endpoint for inbound agent spans

## Story

As a **Senior ML Engineer**,
I want to **point my agent's OTel exporter at a CodeFresh ingestion endpoint so its internal spans land in the run record**
so that **when I investigate a failed step I can see the agent's tool calls, retrievals, and reasoning traces alongside the visible response**.

## Acceptance Criteria

- [ ] Backend exposes OTLP/gRPC on a dedicated port (default 4317) and OTLP/HTTP on 4318
- [ ] Receiver authenticates via API token header (`Authorization: Bearer <token>`) — rejects unauthenticated spans
- [ ] Accepted spans are persisted to `otel_spans` / `otel_logs` partitioned tables
- [ ] `organization_id` is derived from the authenticated token; `run_id` / `run_step_id` left null at ingest (set by correlator, US-082)
- [ ] Receiver handles burst traffic with a bounded queue; backpressure returns OTLP `RESOURCE_EXHAUSTED`
- [ ] Receiver is health-check aware (Kubernetes liveness / readiness probes)

## Notes

- Elixir-native OTLP receivers are thin; may need a Go sidecar or direct OTLP protobuf handling in Phoenix
- Rate limiting and quota enforcement happen at the receiver edge
- Monthly-partitioned `otel_spans` target documented in `docs/arch/data-model.md` §7

## Out of Scope

- OTLP over HTTPS/JSON — phase 1 is gRPC + protobuf
- ClickHouse mirror — schema permits it (§7), but wiring is later
- OTel metrics ingestion — scoped to spans + logs only
