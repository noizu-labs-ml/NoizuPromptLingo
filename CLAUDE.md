* * *
npl-instructions:
   name: npl-conventions
   version: 1.3.0
---

```🏳️
@command-and-control="task-master"
@work-log="standard"
@track-work=true
```

# NPL Conventions Reference

## Agent Delegation

Leverage sub-agents to conserve context and parallelize work.

### Command-and-Control Modes

| Mode | Behavior |
|:-----|:---------|
| `lone-wolf` | Work independently; use sub-agents only when explicitly requested |
| `team-member` | Suggest sub-agents during planning for complex/obvious delegation tasks |
| `task-master` | Aggressively parallelize; push investigation, docs, implementation to sub-agents |

Other values may be set—agents should apply best-effort interpretation. Custom definitions:
```
@command-and-control.{name}.definition="custom behavior description"
```

### Work-Log Flag

Controls interstitial file generation in `.npl/tmp/`:

| Value | Files Generated |
|:------|:----------------|
| `false` | None |
| `standard` (default) | `.summary.md` + `.detailed.md` |
| `verbose` | All: `.summary.md`, `.detailed.md`, `.yaml` |
| `yaml\|summary` | `.yaml` + `.summary.md` |
| `yaml\|detailed` | `.yaml` + `.detailed.md` |

### Track-Work Flag

Controls agent session logging (default: `true`). Set `@track-work=false` to disable.

### Available Agents

| Agent | Purpose |
|:------|:--------|
| `Explore` | Codebase exploration, pattern discovery |
| `Plan` | Implementation design, architecture |
| `npl-technical-writer` | Documentation, specs, PRs |
| `npl-gopher-scout` | Reconnaissance, analysis |
| `npl-grader` | Validation, QA, edge testing |

### Session Directory Layout

Sessions provide shared worklogs for cross-agent communication under `.npl/sessions/YYYY-MM-DD/`:

```
.npl/sessions/YYYY-MM-DD/
├── meta.json           # Session metadata
├── worklog.jsonl       # Append-only entry log (shared)
├── .cursors/           # Per-agent read cursors
│   └── <agent-id>.cursor
└── tmp/                # Interstitial files
    └── <agent-id>/
        ├── <task>.summary.md
        ├── <task>.detailed.md
        └── <task>.yaml
```

**Agent ID Format**: `<agent-type>-<task-slug>-<NNN>` (e.g., `explore-auth-001`, `gopher-scout-analyze-flow-002`)

### Interstitial Files (`tmp/<agent-id>/`)

Each agent writes to its own subdirectory to avoid naming collisions:

| Pattern | Purpose |
|:--------|:--------|
| `<task>.summary.md` | High-level findings; references headings in detailed file |
| `<task>.detailed.md` | Full content with `##` headings matching summary refs |
| `<task>.yaml` | Structured data (only in `verbose` or `yaml|*` modes) |

Agents read `.summary.md` first, then fetch specific `##` sections from `.detailed.md` as needed.

### Worklog Communication

When `@track-work=true`, agents append entries to `worklog.jsonl` and read new entries via cursor-based reads:

```bash
npl-session log --agent=explore-auth-001 --action=file_found --summary="Found auth.ts"
npl-session read --agent=primary  # Read new entries since cursor
```

See `npl/agent.md` for full worklog entry schema.

## Visualization Preferences

Structured formats render consistently and are machine-parseable. ASCII art fails both.

| Task | Preferred | Avoid |
|:-----|:----------|:------|
| Flowcharts | mermaid flowchart | ASCII boxes |
| Sequences | mermaid sequenceDiagram | ASCII arrows |
| Graphs | graphviz dot, YAML | ASCII trees |
| UI Mockups | SVG artifacts | ASCII frames |
| Data structures | YAML, JSON | ASCII tables |
| State machines | mermaid stateDiagram | ASCII diagrams |

## Codebase Tools

| Tool | Purpose | Example |
|:-----|:--------|:--------|
| Glob | Find files by pattern | `Glob("**/*.md")` |
| Grep | Search file contents | `Grep("def main", type="py")` |
| Read | View file contents | `Read("/path/to/file.py")` |
| Task | Delegate to agents | `Task("@reviewer analyze PR")` |

**Pattern**: Search first (`Glob`/`Grep`), then read relevant files.

## NPL Framework Quick Reference

**Agent invocation**: `@agent-name command args`

**Common fences**:
- `example` / `syntax` / `format` - Input/output specifications
- `diagram` - Mermaid, graphviz, plantuml
- `artifact` - Structured output with metadata

**Intuition pumps** (XHTML tags or fences):
- `<npl-intent>` - Clarify goals before acting
- `<npl-cot>` - Chain-of-thought reasoning
- `<npl-reflection>` - Evaluate output quality

**Key markers**:
- Highlight: `` `term` ``
- Attention: `🎯 instruction`
- In-fill: `[...]` or `[...|qualifier]`
- Placeholder: `<term>`, `{term}`

**Complete reference**: `${NPL_HOME}/npl.md`


* * *

* * *
npl-instructions:
   name: npl-load-directive
   version: 1.0.0
---

# NPL Load Directive

Hierarchical resource loading with multi-tier path resolution (environment → project → user → system). Projects inherit defaults and override only what they need.

## Environment Variables

| Variable | Purpose | Fallback Path |
|:---------|:--------|:--------------|
| `$NPL_HOME` | Base path for NPL definitions | `./.npl`, `~/.npl`, `/etc/npl/` |
| `$NPL_META` | Metadata files | `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta` |
| `$NPL_STYLE_GUIDE` | Style conventions | `./.npl/conventions/`, `~/.npl/conventions/` |
| `$NPL_THEME` | Theme name for style loading | (e.g., "dark-mode", "corporate") |
| `$NPL_PERSONA_DIR` | Persona definitions | `./.npl/personas`, `~/.npl/personas` |
| `$NPL_PERSONA_TEAMS` | Team definitions | `./.npl/teams`, `~/.npl/teams` |
| `$NPL_PERSONA_SHARED` | Shared persona resources | `./.npl/shared`, `~/.npl/shared` |

## Loading Dependencies

Load multiple resource types in a single call using type prefixes (`c`=core, `m`=meta, `s`=style):

```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded} m "persona.qa-engineer" --skip {@npl.meta.loaded} s "house-style" --skip {@npl.style.loaded}
```

**Critical:** The tool returns content headers that set global flags:
- `npl.loaded=syntax,agent`
- `npl.meta.loaded=persona.qa-engineer`
- `npl.style.loaded=house-style`

These flags **must** be passed back via `--skip` on subsequent calls to prevent reloading:

```bash
# First load sets flags
npl-load c "syntax,agent" --skip ""
# Returns: npl.loaded=syntax,agent

# Subsequent loads pass --skip to avoid duplicates
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
```


* * *

* * *
npl-instructions:
   name: npl-scripts
   version: 1.1.0
---

## NPL Scripts

The following scripts are available in `core/scripts/`.

### npl-load

**Resource loader with hierarchical path resolution and dependency tracking.**

Loads NPL components, metadata, styles, prompts, and other resources from project → user → system paths. Supports patch overlays and skip flags to prevent redundant loading.

| Subcommand | Purpose | Example |
|:-----------|:--------|:--------|
| `c <items>` | Load core components (syntax, fences, directives) | `npl-load c "syntax,agent" --skip ""` |
| `m <items>` | Load metadata (personas, configs) | `npl-load m "persona.qa-engineer"` |
| `s <items>` | Load style guides (conventions) | `npl-load s "house-style"` |
| `agent <name>` | Load agent definition with optional NPL docs | `npl-load agent npl-gopher-scout --definition` |
| `init-claude` | Initialize/update CLAUDE.md with versioned prompts | `npl-load init-claude --update-all` |
| `syntax --file <f>` | Analyze NPL syntax elements in content | `npl-load syntax --file agent.md --matches` |

### npl-persona

**Comprehensive persona management for simulated agent identities.**

Creates and manages persistent personas with journals, tasks, and knowledge bases. Enables multi-persona teams for collaborative problem-solving and simulated discussions.

| Command Group | Commands | Purpose |
|:--------------|:---------|:--------|
| Lifecycle | `init`, `get`, `list`, `remove` | Create, retrieve, list, delete personas |
| Journal | `journal <id> add\|view\|archive` | Track experiences, decisions, learnings |
| Tasks | `task <id> add\|update\|complete\|list` | Manage persona goals and active work |
| Knowledge | `kb <id> add\|search\|get` | Build persona-specific knowledge bases |
| Teams | `team create\|add\|list\|synthesize` | Multi-persona collaboration and synthesis |
| Maintenance | `health`, `sync`, `backup` | File integrity, state sync, backups |

### npl-session

**Session and worklog management for cross-agent communication.**

Provides shared worklogs for parent agents and sub-agents. Each reader maintains its own cursor.

| Command | Purpose | Example |
|:--------|:--------|:--------|
| `init [--task=X]` | Create new session | `npl-session init --task="Implement auth"` |
| `current` | Get current session ID | `npl-session current` |
| `log --agent=X --action=Y --summary="..."` | Append entry to worklog | `npl-session log --agent=explore-001 --action=found --summary="auth.ts"` |
| `read --agent=X [--peek] [--since=N]` | Read entries since this agent's cursor | `npl-session read --agent=primary` |
| `status` | Show session stats | `npl-session status --json` |
| `list [--all]` | List sessions | `npl-session list` |
| `close [--archive]` | Close current session | `npl-session close --archive` |

Each reader agent maintains its own cursor at `.cursors/<agent-id>.cursor`, allowing multiple agents to independently track their read position. Use `--peek` to read without advancing cursor.

### npl-fim-config

**Configuration tool for NPL-FIM visualization agent.**

Queries the tool-task compatibility matrix to find appropriate visualization libraries. Supports natural language queries and manages artifact paths.

| Command | Purpose | Example |
|:--------|:--------|:--------|
| `query <desc>` | Find tools matching description | `npl-fim-config query "network graph"` |
| `list-tools` | List all supported visualization tools | `npl-fim-config list-tools` |
| `matrix` | Show full compatibility matrix | `npl-fim-config matrix` |

### Codebase Exploration

| Script | Purpose | Example |
|:-------|:--------|:--------|
| `dump-files <path>` | Dump all file contents with headers (respects .gitignore) | `dump-files src/ -g "*.md"` |
| `git-tree [path]` | Display directory tree (uses `tree` or bash fallback) | `git-tree core/` |
| `git-tree-depth <path>` | List directories with nesting depth relative to target | `git-tree-depth src/` |


* * *

* * *
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
