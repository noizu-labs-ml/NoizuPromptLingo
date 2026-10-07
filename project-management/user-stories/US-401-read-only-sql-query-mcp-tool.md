---
id: US-401
title: "Query the platform database read-only through an MCP tool"
slug: "read-only-sql-query-mcp-tool"
personas: [P-001, P-002]
epic: "Database Access Services"
priority: "must-have"
complexity: "M"
tags: [db, mcp, read-only, sql, postgis, pgvector]
---

# US-401: Query the platform database read-only through an MCP tool

## User Story

**As a** Harness Operator (P-001) directing an Autonomous Coding Agent (P-002),
**I want to** run read-only SQL SELECTs against the platform Postgres through a dedicated MCP tool,
**So that** I can answer data questions (session state, ticket counts, artifact lineage) directly instead of asking for bespoke one-off endpoints.

## Acceptance Criteria

- [ ] Given an authorized caller, when it submits a SELECT through the DB query tool, then it receives the result rows with column names and types serialized as JSON.
- [ ] Given a query that exceeds the configured statement timeout, when executed, then it is cancelled server-side and the caller receives a timeout error — the pool connection is returned to the pool.
- [ ] Given a query whose result exceeds the configured row limit, when executed, then the response is truncated at the limit with an explicit "truncated" marker and total-available count (or best-effort estimate).
- [ ] Given a statement containing INSERT, UPDATE, DELETE, DDL, or multi-statement text, when submitted to the read-only tool, then it is rejected before execution.
- [ ] Given more concurrent tool queries than the connection pool allows, when they arrive, then excess calls receive a clear "pool exhausted" error rather than hanging.

## Notes

Confirmed open space: no DB-access MCP tools exist on either fleet today. The Python legacy pool (`src/npl_mcp/storage/pool.py`, `NPL_DB_*` env, min 1 / max 5 connections) already demonstrates pool-bounded asyncpg access for internal services (sessions, tool_sessions, instructions, artifacts, executors, browser.secrets); the Elixir platform shares a Postgres with PostGIS + pgvector, DDL owned by Liquibase, credentials via Infisical. `docs/pending/implementation-tracker.yaml:316` lists "Database access (for npl-session, npl-persona)" as pending — this story and its cluster (US-402…US-407) are the realization path. Note PRD-N2 storage-providers covers toolset-config storage, not raw DB exposure; this cluster does not replace it.
