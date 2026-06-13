---
id: US-065
title: See agent connection health at a glance on the agent list
issue_type: story
slug: agent-health-on-list
status: in-progress
priority: P1
story_points: 2
estimated_scope: XS
category: agent-connectors
components:
  - frontend
  - backend
labels:
  - wave-2
  - agents
  - dashboards
assignee: null
reporter: null
epic: mvp-agents
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-013
dependencies:
  - US-013
blocks: []
duplicates: []
schema_refs:
  - agents
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# See agent connection health at a glance on the agent list

## Story

As a **Senior ML Engineer**,
I want to **see a health status badge next to each agent on the agent list**
so that **I notice a broken agent (expired credentials, provider outage) before I try to run against it**.

## Acceptance Criteria

- [ ] Agent list shows health badge: green (healthy, last check <15min ago), amber (stale, >15min), red (last check failed)
- [ ] Badge tooltip shows last check timestamp + last failure reason if applicable
- [ ] A scheduled background job probes each agent's health every 15 minutes (opt-out per-agent)
- [ ] Badge updates in real-time when a user manually triggers the health check (US-013)
- [ ] Opt-out agents show a neutral gray "unchecked" badge

## Notes

- 15-minute cadence balances freshness against free-tier API usage
- Health probes don't create `runs`; they hit the adapter's minimum-cost endpoint

## Out of Scope

- Alerting on health-state transitions (Wave 3)
- Per-region health (Wave 3)
