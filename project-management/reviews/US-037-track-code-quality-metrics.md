# Review: Track Code Quality Metrics for Agent Output

- **Story**: `project-management/user-stories/US-037-track-code-quality-metrics.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No component of this story exists in either codebase. There is no `code_quality_metrics` table, no metric hooks on artifact save/review completion/test runs/lint, no aggregation service (`src/npl_mcp/metrics/aggregator.py` does not exist), no `/api/metrics/*` endpoints for code quality, and no dashboard or alerting. The nearest adjacent infrastructure is unrelated: `src/npl_mcp/storage/metrics.py` records tool-call/LLM-call telemetry (response times, token usage; `src/npl_mcp/storage/metrics.py:17-60`) exposed via `/metrics/tool-calls` and `/metrics/llm-calls` (`src/npl_mcp/api/router.py:1734-1747`) — operational observability, not code-quality measurement. The Elixir backend has a dashboard stats aggregate (`backend/lib/noizu_prompt_lingua/domains/dashboard/dashboard.ex:26-44`) but nothing measuring revision counts, review cycles, defect rates, or style violations.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Metric: revision count per artifact | Not Met | revisions are countable via `artifact_list_revisions` (`src/npl_mcp/artifacts/artifacts.py:330`) but nothing computes/stores the metric |
| Metric: review cycles to approval | Not Met | no cycle concept; reviews are single open→completed transitions (`src/npl_mcp/artifacts/reviews.py:179`) |
| Metric: defect rate post-merge | Not Met | no defect_reports table or merge concept |
| Metric: style violations per 1000 LOC | Not Met | no lint integration |
| Documented formula/units/baseline per metric | Not Met | no evidence found |
| `code_quality_metrics` table with indexes | Not Met | no evidence found (`src/npl_mcp/storage/` contains only pool, metrics, error_log) |
| Auto-capture on commit/review/test/lint events | Not Met | no evidence found |
| Daily aggregation scheduled task | Not Met | no evidence found |
| 90-day retention | Not Met | no evidence found |
| Queryable by agent/task_type/date/artifact_type | Not Met | no evidence found |
| Human-authored baseline comparison | Not Met | no author-attribution exists to base it on |
| Dashboard: current value, moving average, % change | Not Met | no evidence found |
| Trend charts with stddev bands | Not Met | no evidence found |
| CSV/JSON export | Not Met | no evidence found |
| Threshold alerts (defect rate, review cycles, style regressions) | Not Met | no evidence found |
| Alerts delivered to chat room or webhook | Not Met | no evidence found |
| `context_hash` correlation with context changes | Not Met | no evidence found |

## Gaps / Risks

- Prerequisite data is missing: no author/agent attribution on artifacts or tickets, and no defect tracking — four of the story's metrics cannot even be computed from current schemas.
- The name collision with existing `metrics.py` (tool-call telemetry) will confuse implementers; name the new module distinctly.

## BDD Scenario

```gherkin
Feature: Track Code Quality Metrics for Agent Output

  Scenario: Metric capture (not available)
    Given an agent completes an artifact and a developer reviews it
    When the artifact is revised and the review completed
    Then no code-quality metric is recorded
    And no code_quality_metrics table exists to query

  Scenario: Trend reporting (not available)
    Given a month of would-be metric history
    When a developer requests GET /api/metrics/trend
    Then no such endpoint exists
```
