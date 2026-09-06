# Review: Token Usage Tracking and Budget Alerts

- **Story**: `project-management/user-stories/US-056-token-usage-tracking-and-budget-alerts.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No token-usage tracking, cost estimation, budget threshold, alerting, dashboard, or export functionality exists in the Python MCP server. Greps across `src/npl_mcp/` for `token_usage`, `budget`, and cost-related terms return no implementation hits; `src/npl_mcp/storage/metrics.py` does not record per-agent token usage, and the task system (`src/npl_mcp/tasks/tasks.py`) stores title/status/priority/assignee only — no usage columns. The worklog integration the story assumes (per US-031) has no usage fields. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Token usage logged per agent task with cost estimation | Not Met | no evidence found in `src/npl_mcp/` |
| Budget thresholds configurable per session or sprint | Not Met | no evidence found |
| Alert when 80% budget consumed | Not Met | no evidence found |
| Hard stop option at 100% budget | Not Met | no evidence found |
| Dashboard shows token usage trends and projections | Not Met | no evidence found |
| Export for billing/accounting integration | Not Met | no evidence found |

## Gaps / Risks

- Entire story unimplemented; cost-control concerns for LLM-heavy agent runs are unaddressed.
- No schema groundwork (usage table/columns) exists, so implementation starts from zero.

## BDD Scenario

```gherkin
Feature: Token budget tracking and alerts

  Scenario: Agent run approaches budget
    Given an agent session with a configured token budget
    When cumulative usage passes 80% of the budget
    Then nothing happens — no usage is recorded and no alert exists today
```
