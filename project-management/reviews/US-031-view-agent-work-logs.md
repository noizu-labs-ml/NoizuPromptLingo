# Review: View Agent Work Logs

- **Story**: `project-management/user-stories/US-031-view-agent-work-logs.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

None of the three primary tools exist: greps for `get_agent_work_log`, `export_work_log`, `get_agent_metrics`, and `agent_work_log` across `src/` return zero hits (the only `work_log` hit in `tests/` was an unrelated test name `test_tdd_agent_workflow`). There is no `agent_work_log` table, no logging wrapper on MCP tool calls, and no web dashboard: `src/npl_mcp/web/` contains only a `.gitignore`, and `src/npl_mcp/api/router.py` has no `/logs` or `/agents/logs` route. The related-but-different `task_feed`/`queue_feed` readers exist (`src/npl_mcp/tasks/tasks.py:465,510`) but nothing in the codebase writes task events (`INSERT INTO npl_task_events` has zero occurrences), so even those adjacent feeds are always empty.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `get_agent_work_log` with filters (agent, task, session, time range, action type) | Not Met | no evidence found |
| Log entries include timestamp, agent, action type, target, outcome, duration | Not Met | no evidence found |
| Failed actions include error message, stack trace, retry count | Not Met | no evidence found |
| `export_work_log` CSV/JSON export | Not Met | no evidence found |
| `get_agent_metrics` summary statistics | Not Met | no evidence found |
| Web dashboard route (`/logs`) | Not Met | `src/npl_mcp/web/` empty; no route in `src/npl_mcp/api/router.py` |
| Filterable table + search | Not Met | no evidence found |
| Summary cards / timeline / detail views | Not Met | no evidence found |
| Export button for filtered data | Not Met | no evidence found |
| Real-time SSE updates | Not Met | no evidence found |
| Pagination for 1000+ entries | Not Met | no evidence found |

## Gaps / Risks

- This is an instrumentation story: it requires an append-only log store plus automatic capture at tool-call boundaries. Neither exists; retrofitting capture middleware into the existing launcher-registered tools is the main implementation cost.
- The story's own architecture notes (SQLite table) conflict with the repo's PostgreSQL storage layer (`src/npl_mcp/storage`, asyncpg) — schema guidance in the story is stale relative to the codebase.
- Feed-write orphan confirmed as a cross-cutting gap: task feeds read from `npl_task_events` but no code path inserts events, so any work-log implementation will likely need to seed that same event stream.

## BDD Scenario

```gherkin
Feature: View agent work logs

  Scenario: PM reviews today's agent activity
    Given agent "agent-01" performed task updates, artifact creates, and messages today
    When the PM calls get_agent_work_log filtered by agent and start_time
    Then chronologically sorted entries are returned with timestamp, action type, target, and outcome

  Scenario: Metrics summary
    When the PM calls get_agent_metrics for an agent over today
    Then totals, success rate, and average duration are returned

  Scenario: Dashboard with live updates
    Given the PM is viewing the /logs dashboard
    When an agent completes a task
    Then a new log entry appears at the top of the timeline without a page refresh
```

(Scenario describes target behavior — none of it is executable today.)
