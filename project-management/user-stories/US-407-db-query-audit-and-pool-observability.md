---
id: US-407
title: "Audit DB tool queries and expose connection-pool observability"
slug: "db-query-audit-and-pool-observability"
personas: [P-006, P-003]
epic: "Database Access Services"
priority: "should-have"
complexity: "M"
tags: [db, audit, observability, pool, metrics]
---

# US-407: Audit DB tool queries and expose connection-pool observability

## User Story

**As a** Platform Administrator (P-006), with the Delivery Lead (P-003) reviewing platform health,
**I want to** have every DB-access tool call audited and connection-pool state observable,
**So that** I can answer "who queried what, when, and how expensive was it" after an incident, and catch pool saturation before it becomes an outage.

## Acceptance Criteria

- [ ] Given any DB tool call, when it completes (success, timeout, denial, or error), then an audit record exists capturing caller identity, tool, normalized SQL shape, duration, row count, and outcome — but never literal parameter values or result data.
- [ ] Given the audit log, when an administrator queries it, then records are filterable by caller, tool, and time window.
- [ ] Given the DB tool's connection pool, when monitored, then metrics expose pool size, in-use count, waiters, and wait time (covering both the Elixir platform pool and the legacy Python min-1/max-5 asyncpg pool).
- [ ] Given a saturated pool, when a call arrives, then the caller gets a prompt "pool exhausted" error (bounded by a queue timeout) rather than an unbounded hang — and the saturation is visible in metrics.
- [ ] Given the audit pipeline itself, when it fails, then DB tool calls fail closed (or the failure alarms) — audit gaps are never silent.

## Notes

Audit content policy mirrors the secrets posture (no values on screen/logs): record shape and metadata, not data. Pool facts to build on: Python legacy fleet pool is `min_size 1 / max_size 5` (`src/npl_mcp/storage/pool.py`) shared across sessions/tool_sessions/instructions/artifacts/executors/browser.secrets — i.e., already a contention point worth instrumenting on day one. Statement timeout/row-limit events from US-401 and approvals from US-405 should surface here as first-class audit outcomes.
