npl-instructions:
   name: sqlite-guide
   version: 1.0.0
---

# SQLite Quick Guide

## Heredoc Pattern
```bash
sqlite3 mydb.sqlite <<'EOF'
<SQL statements>
EOF
```

## Operations Reference

| Operation | SQL Example |
|-----------|-------------|
| Create | `CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT);` |
| Insert | `INSERT INTO t (name) VALUES ('val1'), ('val2');` |
| Query | `SELECT * FROM t WHERE condition;` |
| Alter | `ALTER TABLE t ADD COLUMN col TEXT;` |
| Update | `UPDATE t SET col = 'val' WHERE condition;` |
| Delete | `DELETE FROM t WHERE condition;` |

## One-Liner Query
```bash
sqlite3 -header -column mydb.sqlite 'SELECT * FROM users;'
```
