# sql-lite - Persona

**Type**: Prompt
**Category**: Database Operations
**Version**: 1.0.0

## Overview

The `sql-lite` prompt provides SQLite heredoc patterns and CRUD operation syntax for shell-based database interactions. It enables LLMs to execute multi-line SQL via bash heredocs and construct correct SQLite command-line syntax without external dependencies.

## Purpose & Use Cases

- Execute multi-line SQL statements via bash heredocs in shell environments
- Perform CRUD operations (Create, Read, Update, Delete) using SQLite CLI
- Query databases with formatted output (table, CSV, JSON)
- Manage session storage and persona knowledge bases in NPL workflows
- Enable ad-hoc data analysis using in-memory or file-based SQLite databases

## Key Features

✅ **Heredoc Pattern** - Template for multi-line SQL execution preventing variable expansion
✅ **CRUD Reference Table** - Quick-reference syntax for all common database operations
✅ **Output Formatting** - Support for table, CSV, and JSON output formats
✅ **NPL Integration** - Versioned loading via `npl-load` with dependency tracking
✅ **Zero Dependencies** - Pure SQLite CLI operations without external libraries
✅ **Session Storage Support** - Direct integration with NPL session worklogs and persona data

## Usage

```bash
# Load the prompt
npl-load prompt sql-lite

# Load as part of default prompt set
npl-load init-claude

# Execute multi-line SQL via heredoc
sqlite3 mydb.sqlite <<'EOF'
CREATE TABLE users (
  id   INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);
INSERT INTO users (name) VALUES ('Alice'), ('Bob');
EOF

# Query with formatted output
sqlite3 -header -column mydb.sqlite 'SELECT * FROM users;'
sqlite3 -json mydb.sqlite 'SELECT * FROM users;'
```

## Integration Points

- **Triggered by**: Loaded via `npl-load init-claude` or `npl-load prompt sql-lite`
- **Feeds to**: LLM context for database operations in NPL workflows
- **Complements**: `npl-session` (session storage), `npl-persona` (persona knowledge bases), `scripts.md` (tools using SQLite)

## Parameters / Configuration

- **name**: `sqlite-guide` (frontmatter identifier)
- **version**: `1.0.0` (tracks prompt updates for `init-claude` version management)
- **Loading flags**: `--skip` to prevent reloading, `--update` to fetch latest version
- **Output formats**: `-header`, `-column`, `-csv`, `-json` CLI flags
- **Heredoc quoting**: Use `<<'EOF'` (quoted) to prevent variable expansion

## Success Criteria

- LLM correctly constructs heredoc patterns with quoted EOF markers
- CRUD operations use proper SQLite syntax and constraints
- Output formatting flags are applied appropriately for the use case
- String escaping (doubling single quotes) is handled correctly
- File paths and database targets are validated before execution

## Limitations & Constraints

- **Basic operations only** - Does not cover transactions, indexes, triggers, views
- **No joins documented** - Assumes single-table operations for simplicity
- **SQLite-specific syntax** - May differ from MySQL/PostgreSQL equivalents
- **Limited ALTER TABLE** - SQLite cannot drop/rename columns without table recreation
- **No schema migrations** - Does not document migration patterns or version management

## Related Utilities

- `npl-load` - Resource loader for prompt initialization
- `npl-session` - Session worklog storage using SQLite
- `npl-persona` - Persona knowledge base management
- `scripts.md` - Catalog of tools using SQLite internally
