---
id: US-092
title: Elixir SDK core — install, authenticate, trigger runs
issue_type: story
slug: elixir-sdk-core
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: sdks
components:
  - sdk-elixir
  - docs
labels:
  - wave-2
  - sdk
  - elixir
assignee: null
reporter: null
epic: post-mvp-sdks
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-091
  - US-094
  - US-096
dependencies:
  - US-096
blocks: []
duplicates: []
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Elixir SDK core — install, authenticate, trigger runs

## Story

As a **Senior ML Engineer**,
I want to **add `{:codefresh, "~> 0.1"}` to my `mix.exs` and call CodeFresh from my Phoenix app**
so that **my Elixir-based agent platform can hit CodeFresh programmatically with the language's native async story (`Task`, `GenServer`) rather than wrapping HTTP by hand**.

## Acceptance Criteria

- [ ] Package published to Hex as `codefresh`
- [ ] Config via `config :codefresh, api_token: "..."` or `Codefresh.Client.new(token: ...)`
- [ ] Functions: `Codefresh.Scripts.list/1`, `Codefresh.Scripts.get/2`, `Codefresh.Runs.create/2`, `Codefresh.Runs.get/2`, `Codefresh.Runs.await/2`
- [ ] Typed structs via `Ecto.Schema.embedded_schema/1` for parity with backend types
- [ ] Returns tagged tuples `{:ok, result}` / `{:error, reason}` per Elixir convention
- [ ] Supports `Req`-based HTTP with retry and rate-limit backoff

## Notes

- Backend already depends on `req`; SDK can share the client config
- Telemetry events emitted for every request so users can hook their own instrumentation

## Out of Scope

- GenServer-managed session state (Wave 3 — most users don't need it)
- Phoenix LiveView helpers for displaying run progress (Wave 3)
