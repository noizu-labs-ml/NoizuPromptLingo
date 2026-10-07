# Review: Structured Error Logging for MCP Tools

- **Story**: `project-management/user-stories/US-049-structured-error-logging-for-mcp-tools.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The substance of tool-call instrumentation exists, but on PostgreSQL + stderr rather than the story's `.npl/logs/mcp-tools.jsonl` file. Every MCP-registered tool is wrapped by a metering decorator that records tool name, serialized arguments, result summary, response time, and error into `npl_tool_calls` (`src/npl_mcp/meta_tools/catalog.py:313-341`, applied via `mcp.tool(...)` at `:341`; the `ToolCall` dispatch path meters identically at `:361-398`), with failures additionally written to `npl_tool_errors` including a stack excerpt and session ID (`src/npl_mcp/storage/error_log.py:8-40`). Read paths exist as limit-only listings over HTTP (`src/npl_mcp/api/router.py:1724-1738`) with no filters. Separately, `src/npl_mcp/structured_logging.py:38-83` emits severity-tagged JSONL (with `exception.stacktrace`) to stderr. Missing: any file-based `.npl/logs/mcp-tools.jsonl` sink (grep: zero hits), agent/task-ID context on tool records, retention/pruning, date/tool/error-type filtering, and session-scoped log views. Tests cover the storage helpers (`tests/test_metrics.py:83-114`, `tests/test_launcher_logging.py`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All MCP tool calls logged with tool name, input params, output/error, duration, timestamp | Partially Met | Metering decorator captures name/args/result_summary/response_time_ms per call (`catalog.py:313-341`) into `npl_tool_calls` (timestamps via created_at, `storage/metrics.py:15-44`) — but stored in Postgres, not `.npl/logs/mcp-tools.jsonl` (no such path anywhere) |
| Errors include full stack traces and context (session/agent/task IDs) | Partially Met | Stack excerpt (2048 chars) + session_id on errors (`error_log.py:8-27`); no agent_id/task_id captured; service-level JSONL logs carry full `exception.stacktrace` (`structured_logging.py:62-68`) but lack session/agent context |
| Log retention policy (configurable, default 30 days) | Not Met | no retention/pruning code for `npl_tool_calls`/`npl_tool_errors` (grep: zero hits) |
| Query interface filtering by tool, error type, date range | Partially Met | listing endpoints exist (`router.py:1724-1738`, backed by `error_log.py:43-62`, `metrics.py:85+`) but accept only `limit` — newest-first, no filters |
| Session-scoped log views (integration with US-005) | Partially Met | `session_id` is stored on tool calls/errors (`metrics.py:22`, `error_log.py:11-12`) but no view filters or joins by it |
| Log level filtering (DEBUG/INFO/WARN/ERROR) | Partially Met | severity-tagged JSONL with configurable root level for *service* logs (`structured_logging.py:73-83`); tool-call records carry no severity and are not level-filterable |

## Gaps / Risks

- Coverage nuance: the decorator meters tools registered through `mcp_discoverable`/`catalog`; any tool invoked outside that path (e.g. FastMCP-native routes added later) bypasses metering — enforcement is by convention, not a central middleware.
- Unbounded growth mirrors US-046: no retention on the metrics/error tables means they grow forever once tool traffic ramps.
- The story's file-based target (`.npl/logs/mcp-tools.jsonl`) contradicts the repo's Postgres direction; recommend re-basing the criterion on the existing tables and dropping the file requirement, keeping JSONL only for stderr/OTel-style export.

## BDD Scenario

```gherkin
Feature: Structured error logging for MCP tools

  Scenario: A tool call is logged
    Given an agent invokes a registered MCP tool
    When the call completes or raises
    Then a row lands in npl_tool_calls with tool name, arguments,
    result summary or error, and response time — queryable via the
    /metrics listing endpoints (limit only)

  Scenario: A tool raises an error
    When the decorated tool raises
    Then npl_tool_errors records error type, message, stack excerpt, and session id
    But no agent/task identifiers are attached (fields do not exist)

  Scenario: Filter and retain (not implemented)
    When the developer filters logs by tool name and date range, or relies
    on 30-day retention to prune old entries
    Then neither exists — listings accept only a limit and nothing prunes
    the metrics or error tables
```
