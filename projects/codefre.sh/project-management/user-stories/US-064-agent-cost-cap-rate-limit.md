---
id: US-064
title: Set per-agent cost cap and rate limit
issue_type: story
slug: agent-cost-cap-rate-limit
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
  - governance
  - cost
assignee: null
reporter: null
epic: mvp-agents
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas: []
related_stories:
  - US-012
  - US-067
dependencies:
  - US-012
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

# Set per-agent cost cap and rate limit

## Story

As a **Senior ML Engineer**,
I want to **set a per-agent daily cost cap and per-minute rate limit**
so that **a runaway run (freeball loop, infinite retry) can't burn through my entire monthly API budget before I notice**.

## Acceptance Criteria

- [ ] Agent detail has governance fields: `daily_cost_cap_usd`, `rate_limit_per_min`, both optional
- [ ] Limits apply across all runs in the org that pin any version of this agent
- [ ] Cost cap hit → runs queued waiting on this agent move to `failed` with `error.type='cost_cap_exceeded'`
- [ ] Rate limit hit → in-flight step retries with backoff (up to 3 attempts), then fails
- [ ] Governance settings live on the agent *head* (not per-version) so they're immediately mutable

## Notes

- Daily spend tracked per-org via a rolling 24h sum of `run_steps.tokens_in/out × published rate`
- Rate limiter backed by Redis

## Out of Scope

- Monthly / quarterly budgets (Wave 3)
- Per-user cost quotas (Wave 3 — requires user-level usage tracking)
