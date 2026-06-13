---
id: US-012
title: Configure an OpenAI agent adapter
issue_type: story
slug: configure-openai-agent-adapter
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: agent-connectors
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - agents
  - adapters
assignee: null
reporter: null
epic: mvp-agents
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas:
  - alex-oss-maintainer
related_stories:
  - US-013
  - US-014
dependencies: []
blocks:
  - US-013
  - US-014
duplicates: []
schema_refs:
  - agent_versions
  - agents
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Configure an OpenAI agent adapter

## Story

As a **Senior ML Engineer**,
I want to **configure an OpenAI agent adapter with model selection and an auth reference**
so that **I can run my scripts against the agent without pasting credentials into this product**.

## Acceptance Criteria

- [ ] "New Agent" picker includes `openai` adapter
- [ ] User enters `name`, selects `model` (e.g. `gpt-4.1`, `o3`), supplies `auth_ref` pointer (no raw secret in-app)
- [ ] Optional `headers` and `request_template` overrides with sensible defaults
- [ ] Agent head + first draft version are created on save
- [ ] Raw API key input is explicitly *not* present; instead a pointer like `{"source":"vault","name":"openai-prod"}`

## Notes

- Secret storage is external — schema `agent_versions.auth_ref` holds opaque pointer only
- Anthropic, LangChain, and arbitrary HTTP adapters arrive in Wave 2

## Out of Scope

- Anthropic adapter (Wave 2)
- Custom HTTP adapter (Wave 2)
- Health check (US-013)
