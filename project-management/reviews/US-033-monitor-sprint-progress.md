# Review: Monitor Sprint Progress with Agent Metrics

- **Story**: `project-management/user-stories/US-033-monitor-sprint-progress.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Foundations exist on the Elixir backend: sprint/iteration entities (`board_iteration` schema with name/dates/status/goal, `backend/lib/noizu_prompt_lingua/schema/board_iteration.ex:15-22`), iteration CRUD + queue `status_counts` (`backend/lib/noizu_prompt_lingua/domains/tickets/queues.ex:121,155-174`), tickets link to iterations (`backend/lib/noizu_prompt_lingua/schema/ticket.ex:29`), and an org-level dashboard with counts, daily/weekly series and heatmaps (`backend/lib/noizu_prompt_lingua/domains/dashboard/dashboard.ex:26-44`). The Python MCP side has a basic task queue with the same five statuses (`src/npl_mcp/tasks/tasks.py:22`). However, none of the story's named surfaces exist: no `get_sprint_metrics`/`get_sprint_burndown`/`get_velocity_trends`/`get_blocked_task_summary` tools, no agent-vs-human attribution anywhere, no burndown/velocity/forecast/blocked-analysis logic (grep for burndown/velocity across both codebases: no evidence found).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Retrieve sprint metrics via `get_sprint_metrics` (sprint_id / date range) | Not Met | no evidence found in either codebase |
| Sprint summary (total/completed/%, days remaining, projected completion) | Not Met | only generic org stats: `backend/lib/noizu_prompt_lingua/domains/dashboard/dashboard.ex:27-44` |
| Agent-completed vs human-completed task split | Not Met | no agent/human attribution field on tickets (`backend/lib/noizu_prompt_lingua/schema/ticket.ex`) |
| Status breakdown (pending/in_progress/blocked/review/done) with split | Partially Met | status split exists per queue: `backend/lib/noizu_prompt_lingua/domains/tickets/queues.ex:121`; no agent/human split |
| Filter metrics by priority | Not Met | no evidence found |
| Avg completion time for agents vs humans | Not Met | no evidence found |
| Web UI burndown chart (planned vs actual) | Not Met | no evidence found |
| Separate agent/human throughput lines | Not Met | no evidence found |
| Velocity anomaly highlighting | Not Met | no evidence found |
| Adaptive ideal burndown line | Not Met | no evidence found |
| Blocked tasks as separate metric | Partially Met | "blocked" is a tracked ticket status (`backend/lib/noizu_prompt_lingua/schema/ticket.ex`); no dedicated blocked analysis |
| Task-count vs story-point toggle | Not Met | no complexity/points field found |
| Velocity for last 3 sprints with breakdown | Not Met | no evidence found |
| Rolling-average velocity | Not Met | no evidence found |
| Forecast completion date | Not Met | no evidence found |
| Forecast confidence intervals | Not Met | no evidence found |
| Compare to historical baseline | Not Met | no evidence found |
| Alert when velocity < 80% of average | Not Met | no evidence found |
| Blocked >24h section | Not Met | no evidence found |
| Blocker source per blocked task | Not Met | no evidence found |
| Common blocker types aggregation | Not Met | no evidence found |
| Dependency chain visualization | Not Met | no evidence found |
| Average time to unblock | Not Met | no evidence found |
| Filter to individual agent/human contributions | Not Met | no evidence found |
| Individual view metrics | Not Met | no evidence found |
| Agent retry/escalation/quality metrics | Not Met | no evidence found |
| Human review turnaround / pairing metrics | Not Met | no evidence found |
| Compare individual to team average | Not Met | no evidence found |
| Flag >70% agent-completed sprints | Not Met | no evidence found |
| Rework/review-return ratio | Not Met | no evidence found |
| Test failure rate by author type | Not Met | no evidence found |
| Alert on estimate vs actual mismatch | Not Met | no evidence found |

## Gaps / Risks

- No agent-vs-human attribution anywhere in the ticket model — this is the story's central concept and would need schema work before any metric can be computed.
- Python `npl_tasks` and Elixir tickets are parallel task stores; metric work must pick one source of truth.
- Story itself recommends adding sprint metadata to the task schema; Elixir `board_iteration` exists but the Python task schema has no sprint field.

## BDD Scenario

```gherkin
Feature: Monitor Sprint Progress with Agent Metrics

  Scenario: View sprint progress (today's partial capability)
    Given a project manager has a ticket queue with tickets assigned to an iteration
    When they query the queue's status counts (Queues.status_counts)
    Then they receive current counts of tickets per status
    But they see no agent/human split, no burndown, and no velocity forecast

  Scenario: Sprint metrics with forecasting (not available)
    Given a sprint that is partway complete with mixed agent and human work
    When the project manager requests sprint metrics for that sprint
    Then no get_sprint_metrics, burndown, or velocity tool exists to answer
    And the request fails as unimplemented
```
