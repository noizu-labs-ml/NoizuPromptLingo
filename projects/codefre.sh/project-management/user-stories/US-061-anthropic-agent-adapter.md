---
id: US-061
title: Configure an Anthropic agent adapter
issue_type: story
slug: anthropic-agent-adapter
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: agent-connectors
components:
  - backend
  - frontend
labels:
  - wave-2
  - agents
  - adapters
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
  - US-063
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

# Configure an Anthropic agent adapter

## Story

As a **Senior ML Engineer**,
I want to **configure an Anthropic agent adapter with model selection (Opus, Sonnet, Haiku) and an auth reference**
so that **I can run my scripts against Claude models with parity to my OpenAI setup**.

## Acceptance Criteria

- [ ] "New Agent" picker includes `anthropic` adapter
- [ ] Model selector includes current Claude tier aliases (e.g. `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5`)
- [ ] Anthropic-specific fields: `max_tokens` (required), optional `system` preamble (separate from script's own system)
- [ ] Tool defs (US-049) map to Anthropic's `tools` format
- [ ] Agent head + first draft version created on save

## Notes

- Matches `agent_versions.adapter='anthropic'` from `data-model.md` §5.6
- Cross-adapter score parity is not guaranteed; the schema captures what was used, not what "should" be equivalent

## Out of Scope

- Prompt caching hints (post-MVP perf optimization)
- Extended thinking / reasoning-mode toggles (Wave 3)
