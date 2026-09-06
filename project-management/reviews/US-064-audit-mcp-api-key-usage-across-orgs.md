# Review: Audit MCP API Key Usage Across Organizations

- **Story**: `project-management/user-stories/US-064-audit-mcp-api-key-usage-across-orgs.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend gives platform admins cross-cutting visibility into MCP API keys: `list_all_mcp_keys` (`backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex:409-415`) lists keys across all users via `McpApiKeys.list_all/0` (`backend/lib/noizu_prompt_lingua/entities/mcp_api_keys.ex:206+`), and usage is tracked as `last_used_at`, stamped on each successful key verification (`mcp_api_keys.ex:236-255`, schema field at `backend/lib/noizu_prompt_lingua/schema/mcp_api_key.ex:32`). However: keys are strictly user-scoped (`belongs_to :user`, `schema/mcp_api_key.ex`) with no org/project association, so the "associated org/project" dimension and per-org filtering the story requires do not exist; there is no request-volume counter (only the single last-used timestamp); and there is no per-request history — an anomalous key's detail view cannot show past requests. Stale-key filtering ("unused in 90 days") is likewise absent from `list_all/0` and the admin listing.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Audit page shows last-used, request volume, associated org/project for keys across all orgs | Partially Met | platform-wide key list exists (`admin_controller.ex:409-415`) with `last_used_at` (`mcp_api_keys.ex:196, 255`); no request volume, and no org/project association on keys (`schema/mcp_api_key.ex` — user-scoped only) |
| Filter by org or "unused in last 90 days" | Not Met | `list_all/0` (`mcp_api_keys.ex:206+`) and the admin route accept no filters; org filtering impossible without an org link; last-used comparison exists only as a raw field |
| Key detail view shows request history sufficient to investigate anomalies | Not Met | only `last_used_at` is recorded — no request log or per-request history anywhere in `mcp_api_keys.ex` |

## Gaps / Risks

- Data-model gap is the blocker: without an org/project linkage on keys (or on key usage events), org-scoped auditing cannot be layered on later without a migration.
- Anomaly detection has no signal to work from: one timestamp per key cannot distinguish leakage from staleness.
- Revocation tooling exists (`revoke/1`, `mcp_api_keys.ex:269+`) — the response action for findings is ready even though detection is not.

## BDD Scenario

```gherkin
Feature: Platform admin audits MCP API key usage

  Scenario: Cross-org key overview
    Given Ilya is a platform admin
    When he lists all MCP API keys
    Then every user's keys appear with status, prefix, and last_used_at
    (no request volume and no org/project attribution shown — gaps)

  Scenario: Filter stale keys
    When Ilya filters for keys unused in the last 90 days
    Then no such filter exists — filtering must be done client-side from last_used_at (gap)

  Scenario: Investigate an anomalous key
    When Ilya opens a suspect key's detail
    Then only the most recent usage timestamp is available — no request history (gap)
```
