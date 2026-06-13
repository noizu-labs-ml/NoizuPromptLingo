---
id: US-094
title: SDK OTel bridge helper for emitting spans to CodeFresh
issue_type: story
slug: sdk-otel-bridge-helper
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: sdks
components:
  - sdk-python
  - sdk-elixir
  - sdk-typescript
labels:
  - wave-2
  - sdk
  - otel
  - tracing
assignee: null
reporter: null
epic: post-mvp-sdks
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas:
  - nia-academic
related_stories:
  - US-081
  - US-082
  - US-091
  - US-092
  - US-093
dependencies:
  - US-081
  - US-091
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

# SDK OTel bridge helper for emitting spans to CodeFresh

## Story

As a **Senior ML Engineer**,
I want **a one-line helper in each SDK that configures my agent's OTel exporter to ship spans to CodeFresh's ingestion endpoint**
so that **I don't have to know the OTLP endpoint URL, protocol, and auth header details — the SDK handles it**.

## Acceptance Criteria

- [ ] Python: `from codefresh.otel import install_exporter; install_exporter(client=client, service="my-agent")`
- [ ] Elixir: `Codefresh.OTel.install_exporter(client: client, service: "my-agent")`
- [ ] TypeScript: `import { installExporter } from '@codefresh/sdk/otel'; installExporter({ client, service })`
- [ ] Helper configures the runtime's OTel provider (opentelemetry-api / opentelemetry SDK) to use OTLP with the CodeFresh endpoint + auth token
- [ ] Supports trace_id propagation so spans emitted during a CodeFresh-triggered run get auto-linked to the right `run_step_id` (via US-082)
- [ ] Opt-in sampling config; default: 1.0 (record all spans during testing)

## Notes

- Provides the "happy path" for US-081 ingestion — agents don't need to hand-configure OTLP
- Trace propagation header convention: `X-Codefresh-Run-Id` + `X-Codefresh-Run-Step-Id` alongside standard `traceparent`

## Out of Scope

- Auto-instrumentation of LangChain/LlamaIndex (Wave 3 — use their auto-instrument packages + our exporter)
- Log forwarding via SDK (SDK handles spans; logs use native OTel log provider)
