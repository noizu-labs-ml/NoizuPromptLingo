# Review: Scope DB tool results to the caller's org/project tenant

- **Story**: `project-management/user-stories/US-403-tenant-scoped-db-tool-results.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No DB-access MCP tools exist to scope, and no Postgres-native tenant enforcement exists anywhere in the codebase: a search for `CREATE POLICY`, `ROW LEVEL SECURITY`, `set_config`, and `current_setting` across the Elixir backend (`lib/`, `priv/`, `db/`) returns nothing. The story's preference for RLS/per-tenant roles over application-side filtering is therefore not just unimplemented — there is zero RLS groundwork. Adjacent (not equivalent): the Elixir MCP layer does enforce org-scoped authorization at the *tool* layer — `ToolGuard.before_call` with HITL elevation URIs (`lib/noizu_prompt_lingua/mcp/dispatch.ex:28-46`) and org fields on domain tools (e.g., `lib/noizu_prompt_lingua/domains/memory/tools/recall.ex:12`) — but that is per-tool authorization, not row-level confinement of arbitrary SQL, and the Python fleet has no tenant notion at all (its pool is a single shared credential). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Rows restricted to caller's org/project at query or role layer (not prompt convention) | Not Met | no evidence found — no RLS in `backend/lib`, `backend/priv`, `backend/db`; no DB tool exists |
| Cross-org identifiers return zero rows / explicit denial | Not Met | no evidence found |
| Explicit, auditable elevation path for legitimate cross-tenant visibility | Not Met | no evidence found for DB access; nearest adjacent primitive is the HITL elevation URI in `backend/lib/noizu_prompt_lingua/mcp/dispatch.ex:35-46`, which is tool-authz step-up, not DB-scope elevation |
| Tenant filtering composes with user WHERE clauses (not bypassable) | Not Met | no evidence found — RLS would be the mechanism; none exists |
| Adversarial tests: subselects, CTEs, functions, joins escaping scope | Not Met | no evidence found — no tenant-scoping tests exist (`tests/` covers internal services only) |

## Gaps / Risks

- The shared Python fleet credential (`src/npl_mcp/storage/pool.py:26-28`) is org-agnostic; until US-404 lands, no Python-side scoping is even possible at the role layer.
- The existing tool-layer authz (ToolGuard/effective_toolset) could create a false sense of security: it gates *which tools* run, not *which rows* arbitrary SQL returns. Reviews of future implementations must not conflate the two.
- Platform tables are shared across orgs in one schema (`docs/PROJ-SCHEMA`); RLS enablement is a platform-wide schema change requiring Liquibase coordination — non-trivial sequencing risk for the cluster.

## BDD Scenario

```gherkin
Feature: Tenant-scoped DB tool results

  Scenario: Org-scoped caller sees only own rows
    Given an MCP session bound to org "acme" under row-level tenant enforcement
    When the caller runs "SELECT * FROM projects"
    Then every returned row has organization_id = "acme"

  Scenario: Explicit cross-tenant targeting is denied
    Given an MCP session bound to org "acme"
    When the caller runs "SELECT * FROM projects WHERE organization_id = 'rival'"
    Then the result is zero rows (or an explicit denial)
    And no "rival" rows are ever returned

  Scenario: Scope composes with user WHERE clauses
    Given an MCP session bound to org "acme"
    When the caller runs "SELECT count(*) FROM tickets WHERE status = 'open'"
    Then the count reflects only acme's tickets
    And no SQL text (subselect, CTE, function call, or join) can observe rows outside acme

  Scenario: Auditable elevation for cross-tenant work
    Given an administrator authorized to act with cross-tenant authority
    When they request an elevated DB session
    Then the elevation is explicit, time-bounded, and recorded in the audit log
    And non-elevated sessions default to tenant confinement
```
