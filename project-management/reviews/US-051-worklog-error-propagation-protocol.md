# Review: Worklog Error Propagation Protocol

- **Story**: `project-management/user-stories/US-051-worklog-error-propagation-protocol.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The story's protocol has no implementation in the Python server. There is no `worklog.jsonl` subsystem anywhere in `src/npl_mcp/` (searches for `worklog`, `recovery_hint`, and the story's error-entry schema return nothing), no cursor-based error subscription for parent agents, no severity taxonomy (recoverable/blocking/fatal), and no auto-routing that invokes a debugger agent on blocking errors. The nearest substrate is structured tool-error logging to Postgres: `log_tool_error` records tool name, exception type, message, session, and stack excerpt into `npl_tool_errors` (`src/npl_mcp/storage/error_log.py:4-27`) with a `list_tool_errors` reader (`error_log.py:31+`) — a server-side telemetry sink, not the agent-facing worklog protocol. No `npl-session log` command exists (the sessions module, `src/npl_mcp/sessions/sessions.py`, has no such entry point). The orchestration module also has no failure-routing hooks (`src/npl_mcp/orchestration/` patterns end at retry/fail).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Standard error entry schema in `worklog.jsonl` (action/agent_id/error_type/error_msg/stack_trace/recovery_hint) | Not Met | no evidence found — no worklog.jsonl subsystem exists |
| Parent agents subscribe to error events via cursor-based reads | Not Met | no evidence found — `list_tool_errors` is a limit-based listing (`error_log.py:31`), no cursor semantics |
| Error severity levels: recoverable, blocking, fatal | Not Met | no evidence found |
| Auto-routing: blocking errors trigger tdd-debugger invocation | Not Met | no evidence found |
| Recovery hints guide parent on retry vs. escalation | Not Met | no evidence found |
| Integration with existing `npl-session log` command | Not Met | no `npl-session log` command exists |

## Gaps / Risks

- The story depends on a worklog system (also assumed by US-031/US-050/US-057 in this epoch) that was never built; the whole cluster is blocked on that prerequisite.
- `npl_tool_errors` already captures error_type/message/stack per session — a protocol layer could build on it, but its rows lack agent_id, severity, and recovery_hint fields.

## BDD Scenario

```gherkin
Feature: Standardized agent error propagation via worklog

  Scenario: Child agent fails and parent reacts
    Given a child agent executing a pipeline stage
    When the child hits a blocking error
    Then the story expects a schema-compliant worklog error entry with severity and recovery hint,
      a parent cursor-read of that entry, and automatic tdd-debugger invocation
    But today no worklog, severity model, or routing exists, so this scenario cannot be executed
```
