# PROJ-SCHEMA.md — Maintenance Guide

## Diagram Formats

Include **both** Mermaid and PlantUML ERD diagrams in `docs/PROJ-SCHEMA.md`. The summary file (`docs/PROJ-SCHEMA.summary.md`) uses Mermaid only (for brevity).

### Mermaid Conventions

- Use ` ```mermaid ` fenced blocks with `erDiagram`
- Underscores replace parentheses in types (e.g. `VARCHAR_255` not `VARCHAR(255)`)
- Mark PK/FK after type
- Relationship cardinality: `||--o{` (one-to-many), `||--||` (one-to-one), `}o--o{` (many-to-many)

### PlantUML Conventions

- Use ` ```plantuml ` fenced blocks with `@startuml` / `@enduml`
- Use `*` prefix for NOT NULL columns
- Mark `<<PK>>` and `<<FK>>` inline
- Use `--` separator between PK section and other columns
- Use `skinparam linetype ortho` for clean routing
- Group related tables with `package "Domain Name" { }` blocks

### Mermaid ERD Template

```
erDiagram
    parent ||--o{ child : "has many"

    parent {
        UUID id PK
        VARCHAR_255 name
    }

    child {
        UUID id PK
        UUID parent_id FK
    }
```

### PlantUML ERD Template

```
@startuml
!define TABLE(name) entity name <<(T,#FFAAAA)>>
skinparam linetype ortho

TABLE(parent) {
  * id : UUID <<PK>>
  --
  * name : VARCHAR(255)
}

TABLE(child) {
  * id : UUID <<PK>>
  --
  * parent_id : UUID <<FK>>
}

parent ||--o{ child : "has many"
@enduml
```

## Timestamp Conventions

All tables use `TIMESTAMP WITHOUT TIME ZONE` with `NOW()` defaults. Application code manages UTC.

All tables use `updated_at` as the modification timestamp column. This is the standardized convention — do not use `modified_at`.

## Purpose

`docs/PROJ-SCHEMA.md` provides a **database schema reference** with ERD diagrams, table details, and relationship documentation. It should remain the single source of truth for understanding the project's data model.

## Structure

```
docs/
├── PROJ-SCHEMA.md          # Main schema reference (keep small)
├── PROJ-SCHEMA.summary.md  # Condensed quick-reference (Mermaid only)
└── schema/
    ├── npl-content.md      # Detailed breakdowns by domain
    ├── sessions.md
    └── ...
```

## Content Guidelines

### What to Include in PROJ-SCHEMA.md

- ERD diagrams in both Mermaid and PlantUML formats
- Table-by-table details: columns, types, constraints, defaults
- Index documentation (especially non-obvious indexes like ivfflat, GIN, partial)
- Enum type definitions
- Domain groupings (NPL content, sessions, instructions, projects, PM, etc.)
- Migration history summary (changeset reference)
- References to detailed `schema/*.md` files if sections grow large

### Section Template

```markdown
## [Domain Name]

[1-2 sentence description of this table group's purpose]

### table_name

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | No | gen_random_uuid() | Primary key |
| ... | ... | ... | ... | ... |

**Indexes**: idx_name (column) — purpose
**Constraints**: uq_name (columns) — purpose
```

## Size Limits

| Location | Target Size | Action When Exceeded |
|----------|-------------|----------------------|
| PROJ-SCHEMA.md | < 500 lines | Extract domains to `schema/` |
| Individual domains | < 30 lines | Move to `schema/{domain}.md` |
| schema/*.md files | < 200 lines | Consider further decomposition |

## When to Extract

Move content to `schema/{domain}.md` when:

1. A domain section exceeds ~30 lines
2. The section contains query examples or usage patterns
3. Complex relationships need extended documentation

## Data Sources

Schema documentation is derived from:

1. **Primary**: Liquibase YAML changelogs in `liquibase/changelogs/`
2. **Secondary**: Model/manager code in `src/npl_mcp/` (for runtime behavior)
3. **Tertiary**: Test fixtures (for understanding data patterns)

When updating, always cross-reference the Liquibase changelogs as the authoritative source.

## Summary File Sync

`docs/PROJ-SCHEMA.summary.md` is a **companion document** that must be kept in sync with `docs/PROJ-SCHEMA.md`:

- **Purpose**: Quick-reference for tools and agents needing schema awareness
- **Content**: Table list with PK types, column counts, key relationships — no full column details
- **Format**: Compact tables and simplified Mermaid ERD (no PlantUML in summary)
- **Update Rule**: Whenever PROJ-SCHEMA.md changes, regenerate or manually update the summary

### Summary Maintenance

1. **After schema changes**: Sync table counts, relationships, and ERD in summary
2. **Keep ERDs aligned**: Summary Mermaid ERD should show the same relationships as main file
3. **Remove obsolete tables**: Delete entries when tables are dropped
4. **Brief descriptions only**: Summary uses one-line table descriptions

## Maintenance Checklist

- [ ] Both Mermaid and PlantUML ERDs reflect all current tables and relationships
- [ ] PROJ-SCHEMA.summary.md is in sync with main file
- [ ] All column types match Liquibase changeset definitions
- [ ] All timestamp columns use `updated_at` (not `modified_at`)
- [ ] Indexes and constraints are documented
- [ ] Enum types are listed with all values
- [ ] New changesets are reflected in both files
- [ ] No stale references to dropped tables or columns
- [ ] Updated when any `changeset-*.yaml` is added or modified
