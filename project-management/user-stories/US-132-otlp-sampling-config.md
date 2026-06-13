---
id: US-132
title: OTLP ingest sampling configuration
issue_type: story
slug: otlp-sampling-config
status: in-progress
priority: P2
story_points: 3
estimated_scope: S
category: otel-ingestion
components:
  - backend
  - frontend
labels:
  - wave-3
  - otel
  - sampling
assignee: null
reporter: null
epic: post-mvp-otel
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - marcus-qa-lead
related_stories:
  - US-081
  - US-094
dependencies:
  - US-081
blocks: []
duplicates: []
schema_refs:
  - otel_sampling_policies
  - otel_spans
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# OTLP ingest sampling configuration

## Story

As a **Senior ML Engineer**,
I want to **configure head-based and tail-based sampling rates for inbound OTel spans**
so that **high-volume production traffic doesn't overwhelm the storage tier while still capturing interesting traces**.

## Acceptance Criteria

- [ ] Org settings: head-sampling rate (0.0-1.0) applied at the receiver edge per trace
- [ ] Tail-sampling rules: keep 100% of error traces, keep spans linked to `runs` regardless of rate, drop otherwise
- [ ] Sampling decisions exposed in span attributes for downstream correlation
- [ ] Rate changes effective within 60s (receiver config reload)

## Notes

- Tail sampling requires buffering per trace; bounded by a TTL

## Out of Scope

- Per-service sampling rates (Wave 3+)
- Probabilistic + rule-based hybrid samplers (Wave 3+)
