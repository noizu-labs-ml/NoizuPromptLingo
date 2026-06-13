---
id: US-123
title: Agent response streaming support
issue_type: story
slug: agent-streaming-response-support
status: draft
priority: P2
story_points: 5
estimated_scope: M
category: agent-connectors
components:
  - backend
  - frontend
labels:
  - wave-3
  - agents
  - streaming
assignee: null
reporter: null
epic: mvp-agents
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - derek-support-engineer
secondary_personas: []
related_stories:
  - US-012
  - US-063
  - US-016
dependencies:
  - US-012
blocks: []
duplicates: []
schema_refs:
  - run_steps
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Agent response streaming support

## Story

As a **Senior ML Engineer**,
I want **adapters to consume streaming agent responses (SSE, chunked) and surface tokens in real time**
so that **long-response runs show progress instead of looking frozen for 30 seconds**.

## Acceptance Criteria

- [ ] OpenAI, Anthropic, and HTTP adapters accept `stream: true` in request template
- [ ] Streaming tokens pushed through the run-step streaming channel (US-016 pattern)
- [ ] Final assembled response persisted to `run_steps.agent_message` at stream close
- [ ] Token counts and timing reflect streaming reality (first-token-latency vs. total-latency both captured)

## Notes

- Stream timeout honored per-adapter; graceful fallback to non-streaming if provider drops

## Out of Scope

- Stream-aware scoring (scorer waits for full response — Wave 3+)
