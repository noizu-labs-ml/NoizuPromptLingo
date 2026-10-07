# Review: Introspect the Liquibase-managed schema from an MCP tool

- **Story**: `project-management/user-stories/US-402-schema-introspection-mcp-tool.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No schema-introspection MCP tool exists on either fleet. The Python server registers no catalog-listing tool; the Elixir backend exposes MCP tools under `lib/noizu_prompt_lingua/domains/*/tools/` and `lib/noizu_prompt_lingua/tools/`, none of which query `information_schema`/`pg_catalog`. Liquibase ownership of DDL is confirmed as the story assumes (`backend/db/changelog/`, `backend/liquibase.properties` — Elixir backend), so the "read the live catalog, not changelogs" premise is sound but unrealized. No allow/deny list, no deterministic ordering, no code path of any kind. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Table listing returns tables with columns, types, nullability | Not Met | no evidence found — no introspection tool in `src/npl_mcp/launcher.py` or `backend/lib/noizu_prompt_lingua/tools/` |
| Internal tables excluded per configurable allow/deny list | Not Met | no evidence found |
| Read-only catalogs, never mutates; deterministic ordering | Not Met | no evidence found (nothing exists to be read-only or ordered) |
| New Liquibase changelog appears without tool-code change | Not Met | no evidence found — introspection would satisfy this by construction once built against `pg_catalog` |

## Gaps / Risks

- Liquibase location note for implementers: changelogs live in the Elixir backend repo (`/Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend/db/changelog`), not this Python repo — but per the story, the tool should read the live catalog, not the changelog files, so placement is only a docs concern.
- If the tool ships in the Python fleet, it needs the same credential/scoping work as US-401/403/404 (the story's cross-links are load-bearing).
- Ecto schemas exist alongside Liquibase; an implementer might be tempted to derive the listing from Ecto — that violates the story's DDL-owner invariant and should be tested against (e.g., a table present in Liquibase but absent from Ecto schemas).

## BDD Scenario

```gherkin
Feature: Schema introspection MCP tool

  Scenario: List Liquibase-managed tables
    Given an authorized MCP caller with the introspection tool in its toolset
    When it requests the schema listing for schema "public"
    Then it receives every Liquibase-managed table with columns, types, and nullability
    And results are ordered deterministically (table name, then ordinal position)

  Scenario: Internal tables are excluded
    Given the deny list contains "liquibase*" and "npl_tool_llm_debug"
    When the listing is produced
    Then no denied table appears in the result
    And editing the deny list config changes the result without a code change

  Scenario: Introspection is read-only
    When the tool is invoked repeatedly
    Then no schema or data mutation occurs (catalog reads only)
    And consecutive invocations return identical output for an unchanged schema

  Scenario: New changelog is visible immediately
    Given a Liquibase changelog adding table "billing_invoices" was applied
    When introspection runs afterward
    Then "billing_invoices" and its columns appear in the listing with no tool-code change
```
