# sql-lite

**Type**: Prompt
**Category**: Core Prompts
**Status**: Core

## Purpose

The `sql-lite` prompt provides LLMs with SQLite command-line syntax patterns for shell-based database operations. It teaches the heredoc pattern for multi-line SQL execution and provides a quick-reference table of common CRUD operations. This prompt is essential for NPL contexts where agents need to interact with SQLite databases for session storage, persona knowledge bases, and ad-hoc data analysis without external dependencies.

SQLite is used internally by NPL for session persistence and persona data management, making this prompt a critical component for agents performing storage operations.

## Key Capabilities

- Execute multi-line SQL statements via bash heredocs
- Construct correct SQLite command-line syntax with proper quoting
- Perform CRUD operations (Create, Read, Update, Delete) without external libraries
- Query databases with formatted output (table, CSV, JSON)
- Handle complex operations including multi-row inserts and conditional queries
- Manage database structure with ALTER TABLE operations

## Usage & Integration

- **Triggered by**: Loaded via `npl-load prompt sql-lite` or included in default prompt set via `npl-load init-claude`
- **Outputs to**: LLM context for database interaction guidance
- **Complements**: `scripts.md` (tools using SQLite), `npl-session` (session storage), `npl-persona` (persona knowledge bases)

## Core Operations

### Multi-line SQL via Heredoc
```bash
sqlite3 mydb.sqlite <<'EOF'
CREATE TABLE users (
  id   INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);
INSERT INTO users (name) VALUES ('Alice'), ('Bob');
EOF
```

### One-liner Query with Formatting
```bash
sqlite3 -header -column mydb.sqlite 'SELECT * FROM users;'
```

### Output Format Options
```bash
# CSV format
sqlite3 -csv mydb.sqlite 'SELECT * FROM users;'

# JSON format
sqlite3 -json mydb.sqlite 'SELECT * FROM users;'
```

### Session Storage Query
```bash
sqlite3 /tmp/npl-session/sessions.sqlite <<'EOF'
SELECT * FROM worklogs WHERE session_id = 'abc123' ORDER BY timestamp;
EOF
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `<<'EOF'` | Heredoc delimiter | Required | Quoted form prevents variable expansion |
| `-header` | Include column names | Off | Use for formatted output |
| `-column` | Align columns | Off | Use for readable table output |
| `-csv` | CSV output format | Off | Machine-parseable format |
| `-json` | JSON output format | Off | Structured data format |
| `PRAGMA journal_mode=WAL` | WAL mode | Default | Enable for concurrent access |

## Integration Points

- **Upstream dependencies**: None (standalone tool)
- **Downstream consumers**: `npl-session` (worklog persistence), `npl-persona` (knowledge base queries), agent tasks requiring data storage
- **Related utilities**: `npl-load` (loading mechanism), `scripts.md` (catalog of SQLite-using tools)

## Limitations & Constraints

- Basic operations only: Does not cover transactions, indexes, triggers, or views
- No joins documented: Assumes single-table operations
- No schema migrations: Does not document migration patterns
- SQLite-specific syntax: May differ from MySQL/PostgreSQL
- Limited ALTER TABLE support: Cannot drop or rename columns without table recreation

## Success Indicators

- Correct heredoc quoting (`<<'EOF'`) prevents variable expansion
- Multi-line SQL statements execute without syntax errors
- Output formatting flags produce expected results
- String escaping (doubled single quotes) handles embedded quotes correctly
- WAL mode enabled for concurrent access when needed

## Common Pitfalls

**Quoting**: Use `<<'EOF'` (quoted) to prevent shell variable expansion in SQL statements.

**String escaping**: Double single quotes for embedded quotes: `'O''Brien'`

**File locking**: Enable WAL mode for concurrent access: `PRAGMA journal_mode=WAL;`

---
**Generated from**: worktrees/main/docs/prompts/sql-lite.md, sql-lite.detailed.md
**Word count**: 579
