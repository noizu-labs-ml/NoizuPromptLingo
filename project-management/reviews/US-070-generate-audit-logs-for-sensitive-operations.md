# Review: Generate Audit Logs for Sensitive Operations

- **Story**: `project-management/user-stories/US-070-generate-audit-logs-for-sensitive-operations.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No cross-cutting audit-log system exists covering artifact, chat, or review operations. Grep for audit/audit_log/AuditLog across the Elixir backend `lib/` and the Python `src/` surfaces only scattered, domain-specific predecessors: an asset-lifecycle history tool (`backend/lib/noizu_prompt_lingua/domains/assets/tools/asset_history.ex:4` "View lifecycle audit log", assets domain only), and ToolGuard's authz "shadow log / audit trail" of authorization decisions (`backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex:37` — decisions only, not resource mutations). Artifact and chat managers (`domains/artifacts/`, `domains/chat/`) have no audit hooks; there is no `query_audit_log` MCP tool, no audit table with the story's field set, and no SIEM integration. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All artifact operations (create, read, update, delete) log to audit table | Not Met | no audit table or hooks; `domains/artifacts/tools/*` and `src/npl_mcp/artifacts/artifacts.py` contain no audit writes |
| All chat operations (join, leave, delete room) log to audit table | Not Met | `domains/chat/chat.ex` and `domains/chat/tools/*` contain no audit logging (room deletion sweeps data, `chat.ex:41-63`, but records nothing) |
| All review operations (create, add comment, complete) log to audit table | Not Met | no evidence found in `domains/review/` or `src/npl_mcp/artifacts/reviews.py` |
| Audit entries include timestamp, persona/user ID, operation type, resource ID, IP address | Not Met | no audit entries exist; asset history and ToolGuard shadow logs use different, partial field sets |
| Audit logs are immutable (append-only) | Not Met | no audit store exists to evaluate immutability |
| Query interface filters by persona, operation, date range | Not Met | no `query_audit_log` tool; nearest analogue is assets-only `Asset.History` (`asset_history.ex`) and it filters by asset entry, not persona/operation/date |

## Gaps / Risks

- This is the foundational dependency for US-068's "ACL changes logged to audit trail" criterion — both stories are blocked together.
- The story's own note that the event-sourced chat system provides immutability without authorization checks remains accurate: chat messages/events are append-style domain data, not audit records.
- Risk of double-counting in rollups: `Asset.History` and the ToolGuard shadow log can be mistaken for partial audit coverage; they do not satisfy any listed criterion.

## BDD Scenario

```gherkin
Feature: Audit logs for sensitive operations

  Scenario: Investigating who deleted an artifact (NOT YET POSSIBLE)
    Given an artifact was deleted yesterday
    When a senior developer queries the audit log filtered by resource ID and operation
    Then no audit table, MCP query tool, or log record exists to answer the question
    And the same is true for chat room deletion and review completion events
```
