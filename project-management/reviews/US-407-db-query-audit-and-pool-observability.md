# Review: Audit DB tool queries and expose connection-pool observability

- **Story**: `project-management/user-stories/US-407-db-query-audit-and-pool-observability.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

This is the one story in the cluster with adjacent existing machinery — but it is generic tool-call telemetry, not DB-tool audit, and it fails open where the story demands fail-closed. `src/npl_mcp/storage/metrics.py:15-44` (`record_tool_call`) writes every registered-tool invocation to `npl_tool_calls` (tool name, session, arguments truncated to 4096, result summary, response time, error), and `list_tool_calls` (`metrics.py:85-112`) reads recent records back. However: (1) it stores *literal arguments* — directly contrary to the story's "never literal parameter values" policy for a DB tool; (2) it swallows all DB errors ("Never let metric logging break the caller", `metrics.py:42-44`) — the silent audit gap the story's last criterion forbids; (3) there are no caller/tool/time-window filters; (4) no normalized-SQL-shape, row-count, or outcome taxonomy (timeout/denial) exists; (5) zero pool instrumentation on either fleet — the asyncpg pool (`src/npl_mcp/storage/pool.py:23-31`, min 1 / max 5, no timeouts) exposes nothing, and the Elixir pool (`POOL_SIZE`, `backend/config/runtime.exs:119`, default 10) is likewise unmonitored. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Audit record per DB tool call: caller, tool, normalized SQL shape, duration, row count, outcome — never literal values | Partially Met | adjacent only: `src/npl_mcp/storage/metrics.py:15-44` records tool name/session/args/latency/error for all tools, but stores raw argument literals (conflicting with the no-values policy) and has no SQL shape/row-count/outcome fields; no DB tool exists to be audited |
| Audit log filterable by caller, tool, time window | Not Met | `metrics.py:85-112` `list_tool_calls` supports only a row limit, newest-first; no caller/tool/time filters |
| Pool metrics: size, in-use, waiters, wait time (both fleets) | Not Met | no evidence found — no instrumentation on `pool.py` or the Elixir repo pool |
| Saturated pool → prompt bounded-timeout "pool exhausted" error, visible in metrics | Not Met | `src/npl_mcp/storage/pool.py:23-31` configures no acquire/command timeout; asyncpg waits indefinitely by default; Elixir side has no saturation handling for this purpose |
| Audit pipeline failure → fail closed (or alarm); no silent gaps | Not Met | existing pattern is the opposite: `metrics.py:42-44` swallows exceptions silently |

## Gaps / Risks

- **Existing telemetry violates the story's content policy in spirit**: `record_tool_call` persists literal `arguments` for every tool (`metrics.py:37`). If DB tools inherit the metering decorator on registration, SQL text and parameter values would land in `npl_tool_calls` — a data-leak path the story explicitly exists to prevent. Any DB tool must opt out or redact before its first call.
- Fail-open vs fail-closed: the "best-effort, never break the caller" pattern is pervasive (also `record_llm_call`); introducing fail-closed auditing for DB tools is a deliberate inversion of house style and should be an explicit, tested decision.
- Pool contention is real today: the 1–5 connection pool is shared across sessions, tool_sessions, instructions, artifacts, executors, and browser secrets; no acquire timeout means a slow internal query already degrades the whole Python fleet — instrumenting the pool (AC3/AC4) has value independent of the DB-tool cluster.
- Elixir `repo.query!` sites (`backend/lib/noizu_prompt_lingua/mcp/toolset_provider.ex`) are also unaudited; the story's "both pools" scope should name the toolset-provider queries as in-audit-scope or explicitly out.

## BDD Scenario

```gherkin
Feature: DB tool audit and pool observability

  Scenario: Every DB call leaves an audit record
    Given a DB query tool call by caller "agent-7" that times out after 5s
    When the call completes
    Then an audit record exists with caller identity, tool name, normalized SQL shape,
      duration, row count, and outcome "timeout"
    And the record contains no literal parameter values or result rows

  Scenario: Administrator filters the audit log
    Given 500 audit records across callers and tools
    When an administrator queries by caller "agent-7", tool "db_query", last 24h
    Then only matching records are returned

  Scenario: Pool state is observable
    Given both the Python (max 5) and Elixir (POOL_SIZE 10) pools are running
    When metrics are scraped
    Then pool size, in-use count, waiters, and wait time are exposed per fleet

  Scenario: Saturation is bounded and visible
    Given all pool connections are in use
    When a new DB tool call arrives
    Then it fails with "pool exhausted" within the queue timeout
    And the saturation is visible in the pool metrics

  Scenario: Audit failure is not silent
    Given the audit sink (audit table / pipeline) is unavailable
    When a DB tool call arrives
    Then the call fails closed (or a paging alarm fires)
    And no un-audited DB call completes silently
```
