# Review: Exception Alerting for Long-Running Processes

- **Story**: `project-management/user-stories/US-053-exception-alerting-for-long-running-processes.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No implementation in either codebase. The story's premise is failure/duration alerting on long-running tasks, and neither the Python server nor the Elixir backend has an alerting layer. The Elixir notification infrastructure is live and rich — `Notifications.Dispatch` supports exactly six kinds: mention, chat_digest, watch_update, comment, ticket_assigned, ticket_update (`backend/lib/noizu_prompt_lingua/domains/notifications/dispatch.ex`); none is a failure or long-running alert, and there is no webhook or desktop-notification channel (delivery is in-app notification rows). The background worker inventory (`domains/notifications/workers/`: cleanup_worker, memory, session_inactivity_worker) contains no watchdog for process duration or exceptions. On the Python side, `npl_tool_errors` records tool exceptions (`src/npl_mcp/storage/error_log.py:4-27`) and `npl_tool_calls`/`npl_llm_calls` record durations (`src/npl_mcp/storage/metrics.py:14-72`), but nothing reads those tables to raise alerts: no rule engine, no per-task-type thresholds, no snooze state, no alert-history table distinct from the raw error/metric rows.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Alerting rules configurable per task type (thresholds, failure triggers) | Not Met | no evidence found in either codebase |
| Notifications via CLI, desktop notification, or webhook | Not Met | no evidence found — Elixir dispatch has no webhook/desktop channels (`dispatch.ex` kinds: mention, chat_digest, watch_update, comment, ticket_assigned, ticket_update) |
| Alert includes task ID, duration, error summary, suggested action | Not Met | no evidence found — raw rows exist (`error_log.py`, `metrics.py`) but no alert enrichment or suggested-action logic |
| Snooze/dismiss to avoid alert fatigue | Not Met | no evidence found |
| Historical alert log for post-mortem analysis | Not Met | no evidence found — only raw error/call tables, no alert records |
| Integration with session dashboard (US-005) | Not Met | no evidence found |

## Gaps / Risks

- The substrate exists on both sides (Elixir notification dispatch + persistence; Python error/metric tables) but the alerting layer — rules, thresholds, channels, lifecycle — was never built. US-022's notification infra is a real foundation; this story is an unbuilt extension of it.
- Story status is "draft" and depends on US-005's dashboard, which similarly lacks an alert surface; sequencing the implementation after US-005 is the natural path.

## BDD Scenario

```gherkin
Feature: Alerting for long-running processes

  Scenario: Persona synthesis exceeds threshold
    Given a rule "persona team synthesis > 10min"
    When a synthesis runs 12 minutes and fails
    Then the story expects an alert with task ID, duration, error summary,
      and suggested action via CLI/desktop/webhook, snoozeable,
      and recorded in a historical alert log
    But no rule engine, alert channels, or alert log exists, so this scenario cannot be executed
```
