* * *

## NPL Load Directive

### Environment Variables

NPL uses optional environment variables to locate resources, allowing projects to override only what they need:

**$NPL_HOME**
: Base path for NPL definitions. Fallback: `./.npl`, `~/.npl`, `/etc/npl/`

**$NPL_META**  
: Path for metadata files. Fallback: `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta`

**$NPL_STYLE_GUIDE**
: Path for style conventions. Fallback: `./.npl/conventions/`, `~/.npl/conventions/`, `/etc/npl/conventions/`

**$NPL_THEME**
: Theme name for style loading (e.g., "dark-mode", "corporate")

### Loading Dependencies

Prompts may specify dependencies to load using the `npl-load` command-line tool:

```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded} m "persona.qa-engineer" --skip {@npl.meta.loaded} s "house-style" --skip {@npl.style.loaded}
```

The tool searches paths in order (environment → project → user → system) and tracks what's loaded to prevent duplicates.

**Critical:** When `npl-load` returns content, it includes headers that set global flags for tracking what is in context:
- `npl.loaded=syntax,agent`
- `npl.meta.loaded=persona.qa-engineer`  
- `npl.style.loaded=house-style`

These flags **must** be passed back via `--skip` on subsequent calls to prevent reloading:

```bash
# First load sets flags
npl-load c "syntax,agent" --skip ""
# Returns: npl.loaded=syntax,agent

# Next load uses --skip to avoid reloading
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
```

### Purpose

This hierarchical loading system allows:
- **Organizations** to set company-wide standards via environment variables
- **Projects** to override specific components in `./.npl/`  
- **Users** to maintain personal preferences in `~/.npl/`
- **Fine-tuning** only the sections that need customization

Projects typically only need to create files for components they're modifying, inheriting everything else from parent paths. This keeps project-specific NPL directories minimal and focused.

* * *

## NPL Scripts
The following scripts are available.

dump-files <path>
: - Dumps all file contents recursively with file name header
- Respects `.gitignore`
- Supports glob pattern filter: `./dump-files . -g "*.md"`

git-tree-depth <path>
: - Show directory tree with nesting levels

git-tree <path>
: - Display directory tree
- Uses `tree` command if available, with pure-bash fallback
- Defaults to current directory

npl-fim-config [item] [options]
: Configuration and query tool for NPL-FIM agent - finds best visualization solutions via natural language queries

npl-load <command> [items...] [options]
: Loads NPL components, metadata, and style guides with dependency tracking and patch support

npl-persona <command> [options]
: Comprehensive persona management tool for lifecycle, journals, tasks, knowledge bases, health checks, teams, and analytics

### npl-fim-config

A command-line tool for querying, editing, and managing NPL-FIM (Noizu Prompt Lingua Fill-In-the-Middle) configuration, solution metadata, and local overrides. Supports natural language queries, compatibility matrix display, artifact path resolution, and delegation to `npl-load` for metadata loading.


### npl-load

A resource loader for NPL components, metadata, and style guides with dependency tracking. Supports hierarchical search (project, user, system), patch overlays, and skip flags to prevent redundant loading. Used for loading definitions, metadata, and style guides as required by NPL agents and scripts.

* * *

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
