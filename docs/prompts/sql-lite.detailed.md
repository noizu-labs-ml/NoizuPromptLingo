# sql-lite.md Detailed Reference

Prompt file providing SQLite command-line syntax for shell-based database operations in NPL contexts.

## Synopsis

The `sql-lite.md` prompt teaches LLMs the heredoc pattern for multi-line SQLite operations and provides a quick-reference table of common SQL operations.

**Source**: `core/prompts/sql-lite.md`
**Version**: 1.0.0
**Load command**: `npl-load prompt sql-lite`

---

## Purpose

This prompt enables LLMs to:

- Execute multi-line SQL statements via bash heredocs
- Construct correct SQLite command-line syntax
- Perform CRUD operations without external dependencies
- Query databases with formatted output

SQLite is used internally by NPL for session storage and persona data. This prompt ensures agents can interact with these stores correctly.

---

## Structure

### Frontmatter

```yaml
npl-instructions:
   name: sqlite-guide
   version: 1.0.0
```

Enables version tracking for `npl-load init-claude` updates.

### Heredoc Pattern

The core pattern for multi-line SQL:

```bash
sqlite3 mydb.sqlite <<'EOF'
<SQL statements>
EOF
```

Key details:
- `<<'EOF'` (quoted) prevents variable expansion in SQL
- Multiple statements can be included between markers
- Database file is created if it does not exist

### Operations Reference Table

| Operation | SQL Pattern |
|:----------|:------------|
| Create | `CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT);` |
| Insert | `INSERT INTO t (name) VALUES ('val1'), ('val2');` |
| Query | `SELECT * FROM t WHERE condition;` |
| Alter | `ALTER TABLE t ADD COLUMN col TEXT;` |
| Update | `UPDATE t SET col = 'val' WHERE condition;` |
| Delete | `DELETE FROM t WHERE condition;` |

### One-Liner Query

For simple queries without heredocs:

```bash
sqlite3 -header -column mydb.sqlite 'SELECT * FROM users;'
```

Flags:
- `-header`: Include column names in output
- `-column`: Align output in columns

---

## SQLite Operations

### Creating Tables

```bash
sqlite3 mydb.sqlite <<'EOF'
CREATE TABLE users (
  id   INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  age  INTEGER,
  email TEXT UNIQUE
);
EOF
```

SQLite types: `INTEGER`, `TEXT`, `REAL`, `BLOB`, `NULL`

Common constraints: `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `DEFAULT`

### Inserting Data

Single row:

```bash
sqlite3 mydb.sqlite <<'EOF'
INSERT INTO users (name, age) VALUES ('Alice', 30);
EOF
```

Multiple rows:

```bash
sqlite3 mydb.sqlite <<'EOF'
INSERT INTO users (name, age) VALUES
  ('Alice', 30),
  ('Bob',   25),
  ('Carol', 28);
EOF
```

### Querying Data

Basic query:

```bash
sqlite3 -header -column mydb.sqlite <<'EOF'
SELECT * FROM users;
EOF
```

With conditions:

```bash
sqlite3 -header -column mydb.sqlite <<'EOF'
SELECT name, age FROM users WHERE age > 25 ORDER BY age DESC;
EOF
```

### Modifying Structure

Add column:

```bash
sqlite3 mydb.sqlite <<'EOF'
ALTER TABLE users ADD COLUMN created_at TEXT;
EOF
```

Note: SQLite has limited `ALTER TABLE` support. Cannot drop or rename columns without table recreation.

### Updating Records

```bash
sqlite3 mydb.sqlite <<'EOF'
UPDATE users SET age = 31 WHERE name = 'Alice';
EOF
```

### Deleting Records

```bash
sqlite3 mydb.sqlite <<'EOF'
DELETE FROM users WHERE name = 'Bob';
EOF
```

---

## Integration with CLAUDE.md

### Loading via init-claude

Included in the default prompt set:

```bash
npl-load init-claude --prompts "npl npl_load scripts sql-lite"
```

### Manual Loading

```bash
npl-load prompt sql-lite
```

### Version Updates

```bash
npl-load init-claude --update sql-lite
```

---

## Usage Patterns

### Session Storage

NPL sessions use SQLite for worklog persistence:

```bash
sqlite3 /tmp/npl-session/sessions.sqlite <<'EOF'
SELECT * FROM worklogs WHERE session_id = 'abc123' ORDER BY timestamp;
EOF
```

### Persona Data

Query persona knowledge bases:

```bash
sqlite3 ~/.npl/personas/dev-001/knowledge.sqlite <<'EOF'
SELECT topic, content FROM entries WHERE topic LIKE '%auth%';
EOF
```

### Ad-hoc Data Analysis

Create temporary databases for analysis:

```bash
sqlite3 :memory: <<'EOF'
CREATE TABLE temp (x INTEGER);
INSERT INTO temp VALUES (1), (2), (3);
SELECT SUM(x) FROM temp;
EOF
```

---

## Output Formatting

### Table Format

```bash
sqlite3 -header -column mydb.sqlite 'SELECT * FROM users;'
```

Output:
```
id    name    age
----  ------  ---
1     Alice   30
2     Bob     25
```

### CSV Format

```bash
sqlite3 -csv mydb.sqlite 'SELECT * FROM users;'
```

Output:
```
id,name,age
1,Alice,30
2,Bob,25
```

### JSON Format

```bash
sqlite3 -json mydb.sqlite 'SELECT * FROM users;'
```

Output:
```json
[{"id":1,"name":"Alice","age":30},{"id":2,"name":"Bob","age":25}]
```

---

## Common Issues

### Quoting in Heredocs

Use `<<'EOF'` (quoted) to prevent shell variable expansion:

```bash
# Correct - no variable expansion
sqlite3 db.sqlite <<'EOF'
INSERT INTO t VALUES ('$USER');
EOF

# Wrong - $USER will expand
sqlite3 db.sqlite <<EOF
INSERT INTO t VALUES ('$USER');
EOF
```

### String Escaping

SQLite uses single quotes for strings. Escape embedded quotes by doubling:

```sql
INSERT INTO t (name) VALUES ('O''Brien');
```

### File Locking

SQLite locks the database during writes. For concurrent access, use WAL mode:

```bash
sqlite3 mydb.sqlite <<'EOF'
PRAGMA journal_mode=WAL;
EOF
```

---

## Relationship to Other Prompts

| Prompt | Relationship |
|:-------|:-------------|
| `scripts.md` | Documents tools that may use SQLite internally |
| `npl_load.md` | Loading mechanism for this prompt |
| `npl.md` | Core NPL syntax this prompt follows |

---

## Design Decisions

### Heredoc Focus

The prompt emphasizes heredocs over one-liners because:
- Multi-line SQL is more readable
- Complex queries require multiple statements
- Session/persona operations involve structured data

### Minimal Scope

The prompt covers only essential operations:
- Reduces token usage in context
- Covers 90% of LLM use cases
- Avoids advanced features (triggers, views, indexes)

### No ORM Patterns

Raw SQL is preferred over abstraction because:
- Direct control over queries
- No dependency on external libraries
- Matches shell-based NPL tooling

---

## Limitations

- **Basic operations only**: Does not cover transactions, indexes, triggers, views
- **No joins**: Assumes single-table operations
- **No schema migrations**: Does not document migration patterns
- **SQLite-specific**: Syntax may differ from MySQL/PostgreSQL

For complex database needs, consider dedicated database tooling.

---

## See Also

- [sql-lite.md](./sql-lite.md) - Concise reference
- [scripts.detailed.md](./scripts.detailed.md) - Script catalog including SQLite users
- [npl-session.detailed.md](../scripts/npl-session.detailed.md) - Session storage using SQLite
