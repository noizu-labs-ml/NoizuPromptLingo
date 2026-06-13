---
id: US-063
title: Configure an arbitrary HTTP agent adapter
issue_type: story
slug: http-agent-adapter
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: agent-connectors
components:
  - backend
  - frontend
labels:
  - wave-2
  - agents
  - adapters
  - custom
assignee: null
reporter: null
epic: mvp-agents
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas:
  - nia-academic
related_stories:
  - US-012
  - US-062
dependencies:
  - US-012
blocks: []
duplicates: []
schema_refs:
  - agent_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Configure an arbitrary HTTP agent adapter

## Story

As a **Senior ML Engineer**,
I want to **point CodeFresh at an arbitrary HTTP endpoint with a configurable request and response mapping**
so that **I can test my team's in-house agent service without CodeFresh needing a bespoke adapter for it**.

## Acceptance Criteria

- [ ] "New Agent" picker includes `http` adapter
- [ ] User supplies: `endpoint_url`, HTTP method (`POST` default), non-secret headers, auth_ref
- [ ] Request template: JSON body template with `{{messages}}`, `{{system}}` placeholders
- [ ] Response mapping: `response_jsonpath` to extract the assistant turn; optional `tool_calls_jsonpath`
- [ ] Error mapping: status codes → run_step error enum (timeout, auth, rate_limit, unknown)

## Notes

- Most-flexible adapter; expect custom-endpoint users to need this
- Keep the template language minimal (Mustache-style) — not Jinja, not Liquid

## Out of Scope

- gRPC agent endpoints (Wave 3)
- Streaming SSE response parsing from the agent (Wave 3)
