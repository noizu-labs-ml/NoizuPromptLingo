---
id: US-082
title: Correlate inbound OTel spans to run_steps
issue_type: story
slug: correlate-otel-spans-to-run-steps
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: otel-ingestion
components:
  - backend
labels:
  - wave-2
  - otel
  - correlation
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
  - US-099
dependencies:
  - US-081
blocks:
  - US-099
  - US-100
duplicates: []
schema_refs:
  - otel_spans
  - otel_logs
  - run_steps
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Correlate inbound OTel spans to run_steps

## Story

As a **Senior ML Engineer**,
I want **OTel spans ingested during a run to be automatically linked to the run step that was in flight at that moment**
so that **I can jump from a failed step directly to the agent's internal trace without correlating trace IDs by hand**.

## Acceptance Criteria

- [ ] A background worker walks freshly-ingested `otel_spans` rows where `run_id IS NULL` every 30s
- [ ] Worker matches `otel_spans.trace_id` against `run_steps.trace_id` and `runs.trace_id`
- [ ] On match, sets `otel_spans.run_id`, `otel_spans.run_step_id`, and `otel_spans.organization_id`
- [ ] Same correlation for `otel_logs`
- [ ] Correlation is idempotent; re-running doesn't double-set
- [ ] Backlog metrics exposed: uncorrelated span count over time

## Notes

- Agents attach the `trace_id` CodeFresh told them via the runner (propagated via step-start header)
- Uncorrelated spans (agents that didn't respect the trace_id) stay `run_id IS NULL` and remain queryable by `trace_id` if user knows what to search for

## Out of Scope

- Synchronous correlation at ingest (accepted async latency)
- Cross-org span leakage detection (Wave 3)
