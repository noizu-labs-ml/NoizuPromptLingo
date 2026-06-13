---
id: US-013
title: Test agent connectivity with a health check
issue_type: story
slug: test-agent-health-check
status: in-progress
priority: P0
story_points: 2
estimated_scope: S
category: agent-connectors
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - agents
assignee: null
reporter: null
epic: mvp-agents
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-012
  - US-014
dependencies:
  - US-012
blocks: []
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

# Test agent connectivity with a health check

## Story

As a **Senior ML Engineer**,
I want to **click "Test Connection" on an agent and see it respond to a trivial ping**
so that **I catch configuration errors before I trigger a full run**.

## Acceptance Criteria

- [ ] Agent detail page exposes a "Test Connection" button
- [ ] Backend sends a minimal prompt through the configured adapter
- [ ] Response status and latency are displayed to the user
- [ ] Common failure modes are surfaced with actionable messages (invalid auth_ref, network error, model not accessible)
- [ ] Test does not create a `run` or consume run-history quota

## Notes

- Stays out-of-band from the run pipeline so repeated health checks don't pollute history

## Out of Scope

- Periodic auto-health-checks (Wave 3)
- Health status badges on agent list page (Wave 2)
