# Review: Agent Performance Metrics Dashboard

- **Story**: `project-management/user-stories/US-050-agent-performance-metrics-dashboard.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python server records the raw substrate: per-tool-call rows (tool name, args, result summary, response time, error, session) in `npl_tool_calls` (`src/npl_mcp/storage/metrics.py:14-44`) and per-LLM-call token rows in `npl_llm_calls` (`metrics.py:47-72`), with tool-error rows (type, message, stack excerpt, session) in `npl_tool_errors` (`src/npl_mcp/storage/error_log.py:4-27`) and list endpoints for each (`metrics.py:85+,115+`; `error_log.py:31+`). Tests exist (`tests/test_metrics.py`). None of the story's aggregation layer exists: searches for `success rate`, per-agent grouping, outlier detection, trend queries, CSV/JSON export, and dashboard/real-time push across `src/` and `tests/` find nothing. Rows are session-scoped, not agent-typed, so "aggregate by agent type (idea-to-spec, tdd-coder)" has no supporting column today.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Metrics per agent: total tasks, success rate, avg duration, token usage | Partially Met | raw per-call duration/errors/tokens recorded (`metrics.py:14-72`) but no per-agent rollup — rows carry session_id only, no agent identity |
| Dashboard aggregates by agent type and time period | Not Met | no evidence found — only flat list endpoints (`metrics.py:115`, `error_log.py:31`) |
| Outlier detection (long tasks, high failure rates) | Not Met | no evidence found |
| Historical trend graphs over sprints | Not Met | no evidence found |
| Export to CSV/JSON | Partially Met | list endpoints return JSON dicts (`metrics.py:115+`), but no bulk export/report path |
| Real-time updates during active sessions | Not Met | no evidence found — request/response endpoints only |

## Gaps / Risks

- No agent-type column on `npl_tool_calls`/`npl_llm_calls`; the story's primary grouping dimension is uncapturable without a schema addition or a convention linking sessions to agents.
- Metrics inserts are best-effort and swallow DB errors (`metrics.py:32-33`), fine for telemetry but worth knowing before building dashboards on completeness assumptions.

## BDD Scenario

```gherkin
Feature: Agent performance metrics dashboard

  Scenario: Raw metrics are recorded
    Given an agent session invoking MCP tools and LLM calls
    When each call completes
    Then a row with duration, error, and token counts is persisted and listable

  Scenario: Aggregate by agent type over a sprint
    Given several weeks of recorded calls
    When the PM opens the dashboard filtered to npl-tdd-coder
    Then the story expects success rate, avg duration, and trend graphs
    But today no aggregation, dashboard, or agent-type attribution exists, so this scenario cannot be executed
```
