npl-instructions:
   name: npl-scripts
   version: 1.2.0
---

## NPL Scripts

The following scripts are available in `core/scripts/`. MCP equivalents are available via `mcp__npl-mcp__*` tools.

### MCP Tool Equivalents

| CLI Script | MCP Tool | Notes |
|:-----------|:---------|:------|
| `dump-files` | `mcp__npl-mcp__dump_files(path, glob_filter?)` | Full parity |
| `git-tree` | `mcp__npl-mcp__git_tree(path?)` | Full parity |
| `git-tree-depth` | `mcp__npl-mcp__git_tree_depth(path)` | Full parity |
| `npl-load c/m/s` | `mcp__npl-mcp__npl_load(resource_type, items, skip?)` | c/m/s types only |

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

### npl-worklog

**Worklog management for cross-agent communication.**

Provides shared worklogs for parent agents and sub-agents. Each reader maintains its own cursor.

| Command | Purpose | Example |
|:--------|:--------|:--------|
| `init [--task=X]` | Create new worklog | `npl-worklog init --task="Implement auth"` |
| `current` | Get current worklog ID | `npl-worklog current` |
| `log --agent=X --action=Y --summary="..."` | Append entry to worklog | `npl-worklog log --agent=explore-001 --action=found --summary="auth.ts"` |
| `read --agent=X [--peek] [--since=N]` | Read entries since this agent's cursor | `npl-worklog read --agent=primary` |
| `status` | Show worklog stats | `npl-worklog status --json` |
| `list [--all]` | List worklogs | `npl-worklog list` |
| `close [--archive]` | Close current worklog | `npl-worklog close --archive` |

Each reader agent maintains its own cursor at `.cursors/<agent-id>.cursor`, allowing multiple agents to independently track their read position. Use `--peek` to read without advancing cursor.

**Note**: MCP sessions (`mcp__npl-mcp__create_session`) serve a different purpose—grouping artifacts and chat rooms for collaboration. Use `npl-worklog` for inter-agent JSONL communication.

### npl-fim-config

**Configuration tool for NPL-FIM visualization agent.**

Queries the tool-task compatibility matrix to find appropriate visualization libraries. Supports natural language queries and manages artifact paths.

| Command | Purpose | Example |
|:--------|:--------|:--------|
| `query <desc>` | Find tools matching description | `npl-fim-config query "network graph"` |
| `list-tools` | List all supported visualization tools | `npl-fim-config list-tools` |
| `matrix` | Show full compatibility matrix | `npl-fim-config matrix` |

### Codebase Exploration

| Script | MCP Equivalent | Example |
|:-------|:---------------|:--------|
| `dump-files <path>` | `mcp__npl-mcp__dump_files(path, glob?)` | `dump-files src/ -g "*.md"` |
| `git-tree [path]` | `mcp__npl-mcp__git_tree(path?)` | `git-tree core/` |
| `git-tree-depth <path>` | `mcp__npl-mcp__git_tree_depth(path)` | `git-tree-depth src/` |

### MCP-Only Features

These features are only available via MCP tools:

| Feature | Tools | Purpose |
|:--------|:------|:--------|
| **Artifacts** | `create_artifact`, `add_revision`, `get_artifact`, `list_artifacts`, `get_artifact_history` | Version-controlled documents |
| **Reviews** | `create_review`, `add_inline_comment`, `add_overlay_annotation`, `complete_review`, `generate_annotated_artifact` | Collaborative review with annotations |
| **Sessions** | `create_session`, `get_session`, `list_sessions`, `update_session` | Group artifacts and chat rooms |
| **Chat** | `create_chat_room`, `send_message`, `react_to_message`, `share_artifact`, `create_todo`, `get_chat_feed`, `get_notifications` | Team collaboration with @mentions |
