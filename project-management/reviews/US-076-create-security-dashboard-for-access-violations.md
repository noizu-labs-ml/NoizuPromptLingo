# Review: Create Security Dashboard for Access Violations

- **Story**: `project-management/user-stories/US-076-create-security-dashboard-for-access-violations.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The only dashboard implementation is `backend/lib/noizu_prompt_lingua/domains/dashboard/dashboard.ex`, which is a **usage/activity** dashboard (counts, daily/weekly series, heatmap, open reviews, blocked tickets, recent items — `dashboard.ex:23-45`); it contains nothing security-related (grep for violation/security/denied in the domain: no hits). No audit-log/violation data source exists to feed such a dashboard (US-070 audit logging is unimplemented; no `audit` hits in the Python server). The nearest adjacent capability is the RBAC shadow-log: `MCP.ToolGuard` logs would-be denials (`backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex` moduledoc, "every decision is logged"), but there is no aggregation, query API, retention, or UI over those logs. No CSV export, no date/persona/type filtering, no real-time streaming (the backend does have a `domains/pubsub/` but it is not wired to security events). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Dashboard displays last 50 access violations with timestamp, persona, resource, operation | Not Met | `dashboard.ex` computes usage stats only; no violation data exists |
| Shows failed permission checks grouped by persona | Not Met | shadow-mode denial logs exist in principle (`tool_guard.ex`) but are not queried or grouped anywhere |
| Displays secret detection events with artifact name and pattern matched | Not Met | secret detection does not exist (see US-071 secret-leakage review) |
| Allows filtering by date range, persona, violation type | Not Met | no evidence found |
| Export to CSV for compliance reporting | Not Met | no evidence found |
| Real-time updates when violations occur | Not Met | no evidence found |

## Gaps / Risks

- The story's data sources are all unimplemented (audit logging US-070, secret detection US-071, enforced authz US-072), so this is a downstream story with no feed — sequencing should treat it as blocked.
- A security dashboard over shadow-mode RBAC would show *would-be* violations only, which may still be useful during rollout but must be labeled as such.

## BDD Scenario

```gherkin
Feature: Security dashboard for access violations
  Story is NOT implemented — scenario describes intended behavior, currently absent.

  Scenario: PM reviews recent violations
    Given access violations and secret detections were recorded (no such recording exists today)
    When the project manager opens the security dashboard
    Then no security view is available — the existing dashboard (`Dashboard.stats/2`) shows usage counts, series, and heatmaps only
```
