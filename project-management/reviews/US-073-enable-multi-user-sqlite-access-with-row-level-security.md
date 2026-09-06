# Review: Enable Multi-User SQLite Access with Row-Level Security

- **Story**: `project-management/user-stories/US-073-enable-multi-user-sqlite-access-with-row-level-security.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The story targets the legacy SQLite architecture, which no longer matches reality: the Python MCP server now uses PostgreSQL via asyncpg (`src/npl_mcp/storage/pool.py`, tables `npl_artifacts`/`npl_artifact_revisions` in `src/npl_mcp/artifacts/artifacts.py:121-148`), and the Elixir backend uses Postgres via Ecto. Regardless of engine, **no row-level security exists in either codebase**. Queries carry no `owner`/`acl` predicates: `artifact_list`/`artifact_get` select unconditionally by id (`artifacts.py:238-288`); no `owner` or `acl` columns appear in any INSERT/SELECT against `npl_artifacts`, `npl_reviews`, or chat tables (grep for `acl|owner` in `src/npl_mcp/artifacts/` returns nothing). There is no query-filter-injection layer, no persona/identity propagation into SQL, and no manager-level enforcement. The Elixir side has org/project scoping on rows (e.g. `organization_id` filters in `domains/dashboard/dashboard.ex:100-103`) but that is tenant scoping, not per-user ACL filtering. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Artifacts table includes `owner` and `acl` columns | Not Met | `artifacts.py:123-126` INSERT lists only title/kind/description/created_by/latest_revision; `created_by` is a free-text label, not an enforced owner |
| Chat rooms table includes `owner` and `acl` columns | Not Met | `src/npl_mcp/chat/chat.py` — no owner/acl columns in any query (grep: no hits) |
| Reviews table includes `acl` column | Not Met | `src/npl_mcp/artifacts/reviews.py:9-19` SELECT lists reviewer_persona/status/overall_comment only — no acl |
| Database layer applies WHERE clauses filtering by current persona/user ID | Not Met | no evidence found; queries filter by artifact_id/review_id only |
| ACL columns store JSON arrays of authorized persona/user IDs | Not Met | no evidence found |
| Manager classes enforce RLS before returning query results | Not Met | no evidence found; all managers return rows directly |

## Gaps / Risks

- Any caller of the Python MCP server can read or mutate every artifact, revision, review, and chat room — multi-tenant isolation is entirely absent on that surface.
- The story's schema premises (SQLite) are stale; if revived, it should be respecified against Postgres (native RLS policies or query-scope helpers) for both codebases.

## BDD Scenario

```gherkin
Feature: Row-level security on shared databases
  Story is NOT implemented — scenario describes current, unisolated behavior.

  Scenario: Two agents share one database
    Given artifacts A (created_by "alice") and B (created_by "bob") exist
    When the agent identifying as "alice" calls ArtifactList
    Then the response includes BOTH A and B (no owner/acl filtering is applied)
    And "alice" can read and revise B without restriction
```
