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
