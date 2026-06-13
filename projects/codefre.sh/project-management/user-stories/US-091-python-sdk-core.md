---
id: US-091
title: Python SDK core — install, authenticate, trigger runs
issue_type: story
slug: python-sdk-core
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: sdks
components:
  - sdk-python
  - docs
labels:
  - wave-2
  - sdk
  - python
  - oss
assignee: null
reporter: null
epic: post-mvp-sdks
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas:
  - nia-academic
related_stories:
  - US-092
  - US-093
  - US-094
  - US-095
  - US-096
dependencies:
  - US-096
blocks:
  - US-094
  - US-095
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

# Python SDK core — install, authenticate, trigger runs

## Story

As a **Senior ML Engineer**,
I want to **`pip install codefresh` and drive CodeFresh from my Python tooling with a clean client object**
so that **I can trigger eval runs from my release-pipeline scripts, regression harnesses, and experiment notebooks without shelling out to the CLI**.

## Acceptance Criteria

- [ ] Package published to PyPI as `codefresh` (or namespaced alt if taken)
- [ ] Client API: `client = Codefresh(api_token=...)` — reads env `CODEFRESH_API_TOKEN` by default
- [ ] Resource methods: `client.scripts.list()`, `client.scripts.get(slug)`, `client.runs.create(script=..., agent=..., personas=[...])`, `client.runs.get(id)`, `client.runs.wait_for(id)`
- [ ] Typed pydantic models for every response (scripts, runs, run_steps, scores, freeball_nodes)
- [ ] Raises typed exceptions: `AuthError`, `NotFound`, `RateLimited`, `CostCapExceeded`, `ValidationError`
- [ ] Async variant: `AsyncCodefresh` with `await client.runs.create(...)`

## Notes

- Prefer `httpx` over `requests` (first-class async, better modern defaults)
- Target Python 3.10+; no 3.8 support
- Documentation on `codefresh.readthedocs.io` (or equivalent)

## Out of Scope

- Streaming run results in SDK (Wave 3)
- Webhook subscription helpers (Wave 3)
- CLI bundled inside the Python package (keep CLI as standalone binary)
