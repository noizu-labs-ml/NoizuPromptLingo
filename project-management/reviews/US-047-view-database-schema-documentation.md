# Review: View Database Schema Documentation

- **Story**: `project-management/user-stories/US-047-view-database-schema-documentation.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Substantial schema documentation exists, but it is hand-maintained, not generated from the schema as the story requires. `docs/PROJ-SCHEMA.md` contains Mermaid and PlantUML ERDs for the backend identity domain (`docs/PROJ-SCHEMA.md:35,56`), a table inventory for the Python MCP DB (`:224`), and changeset/migration references (`:243-264`); six per-domain detail files under `docs/schema/` (core-identity, backend-domains, project-management, etc., 790 lines total) list tables with column definitions and named indexes (e.g. `docs/schema/core-identity.md:112,129,148`). Everything is authored/maintained via the `/update-schema-doc` command family, not auto-generated from `schema.sql`/Liquibase — there is no introspection tool, no example-query section (grep for example/SQL snippets in the docs: none), and no export mechanism beyond "the docs are already markdown files". The story's `schema.sql` premise is stale (Liquibase changelogs own the schema).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Generate ERD diagram from schema (mermaid format) | Partially Met | Mermaid ERDs exist (`docs/PROJ-SCHEMA.md:35`) but are hand-maintained via doc-update commands — no generator from the live schema |
| List all tables with column definitions | Met | `docs/PROJ-SCHEMA.md:224` (table inventory) + `docs/schema/*.md` per-domain table/column details |
| Show foreign key relationships | Met | ERDs encode relationships (`docs/PROJ-SCHEMA.md:35,56`); domain files document belongs_to/has_many edges |
| Display indexes and their purposes | Partially Met | Named indexes listed per table (e.g. `docs/schema/core-identity.md:112` `idx_users_email (email, UNIQUE)`) but purposes/rationale mostly absent (only "Index" mentions: 1 hit in PROJ-SCHEMA.md) |
| Include example queries for common operations | Not Met | no example queries found anywhere in `docs/PROJ-SCHEMA.md` or `docs/schema/` |
| Export schema as markdown documentation | Partially Met | the docs ARE markdown, but no export/generation command exists — currency depends on manual `/update-schema-doc` runs |

## Gaps / Risks

- Documentation drift is the core risk: nothing regenerates these files from Liquibase changelogs or the running DB, so accuracy decays with every migration unless someone remembers to run the doc commands (CLAUDE.md only "flags" the need).
- The story's premise references `schema.sql`, which no longer exists — the schema is owned by Liquibase changelogs (`liquibase/changelogs/`); acceptance criteria should name the real sources of truth.
- Coverage is asymmetric: backend (Ecto/Postgres) domains are well documented; the Python MCP DB gets only a table inventory, not full column/FK detail.

## BDD Scenario

```gherkin
Feature: View database schema documentation

  Scenario: Developer looks up table relationships
    Given the repo is checked out
    When the developer opens docs/PROJ-SCHEMA.md and docs/schema/core-identity.md
    Then they find Mermaid ERDs, per-table column definitions, and named indexes
    But they find no example queries and no guarantee the docs match the
    latest migration (docs are hand-maintained, not generated)

  Scenario: Regenerate docs from the schema (not implemented)
    When a migration lands and the developer runs a schema-doc export command
    Then no such generator exists — docs update only via manual doc commands
```
