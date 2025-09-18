# SQLite Quick Guide (Multi-Line Syntax)

* **Create DB & Table**

```bash
sqlite3 mydb.sqlite <<'EOF'
CREATE TABLE users (
  id   INTEGER PRIMARY KEY,
  name TEXT,
  age  INTEGER
);
EOF
```

* **Insert Data**

```bash
sqlite3 mydb.sqlite <<'EOF'
INSERT INTO users (name, age) VALUES
  ('Alice', 30),
  ('Bob',   25);
EOF
```

* **Query Data**

```bash
sqlite3 -header -column mydb.sqlite <<'EOF'
SELECT * FROM users;
EOF
```

* **Edit Structure (ALTER)**

```bash
sqlite3 mydb.sqlite <<'EOF'
ALTER TABLE users ADD COLUMN email TEXT;
EOF
```

* **Update Rows**

```bash
sqlite3 mydb.sqlite <<'EOF'
UPDATE users SET age = 31 WHERE name = 'Alice';
EOF
```

* **Delete Rows**

```bash
sqlite3 mydb.sqlite <<'EOF'
DELETE FROM users WHERE name = 'Bob';
EOF
```
