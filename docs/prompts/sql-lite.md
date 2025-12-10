# sql-lite.md

Prompt file providing SQLite heredoc patterns and CRUD operations for shell-based database interactions.

**Source**: `core/prompts/sql-lite.md`
**Version**: 1.0.0

## Purpose

Enables LLMs to execute multi-line SQL via bash heredocs and construct correct SQLite command-line syntax. Used internally by NPL for session storage and persona data.

See [Purpose](./sql-lite.detailed.md#purpose) for details.

## Core Pattern

```bash
sqlite3 mydb.sqlite <<'EOF'
<SQL statements>
EOF
```

See [Heredoc Pattern](./sql-lite.detailed.md#structure) for heredoc details.

## Operations Covered

| Operation | Description |
|:----------|:------------|
| Create | `CREATE TABLE` with types and constraints |
| Insert | Single and multi-row inserts |
| Query | `SELECT` with conditions and ordering |
| Alter | `ALTER TABLE ADD COLUMN` |
| Update | `UPDATE` with `WHERE` clauses |
| Delete | `DELETE` with conditions |

See [SQLite Operations](./sql-lite.detailed.md#sqlite-operations) for examples.

## Loading

```bash
# Via init-claude (default prompt set)
npl-load init-claude

# Direct load
npl-load prompt sql-lite

# Check version status
npl-load init-claude --json
```

See [Integration with CLAUDE.md](./sql-lite.detailed.md#integration-with-claudemd) for version management.

## Quick Reference

### Multi-Line Operations

```bash
sqlite3 mydb.sqlite <<'EOF'
CREATE TABLE users (
  id   INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);
INSERT INTO users (name) VALUES ('Alice'), ('Bob');
EOF
```

### One-Liner Query

```bash
sqlite3 -header -column mydb.sqlite 'SELECT * FROM users;'
```

### Output Formats

```bash
sqlite3 -csv mydb.sqlite 'SELECT * FROM users;'
sqlite3 -json mydb.sqlite 'SELECT * FROM users;'
```

See [Output Formatting](./sql-lite.detailed.md#output-formatting) for format options.

## Common Issues

- Use `<<'EOF'` (quoted) to prevent variable expansion
- Escape single quotes by doubling: `'O''Brien'`
- Enable WAL mode for concurrent access

See [Common Issues](./sql-lite.detailed.md#common-issues) for solutions.

## See Also

- [Detailed Reference](./sql-lite.detailed.md) - Complete documentation
- [scripts.md](./scripts.md) - Tools that use SQLite internally
- [npl-session.detailed.md](../scripts/npl-session.detailed.md) - Session storage
