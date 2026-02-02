# Scripts Summary

**Location**: `worktrees/main/core/scripts/`

## Overview
Collection of utility scripts for codebase exploration, resource loading, session management, and metadata operations. These scripts enable efficient navigation and orchestration of the NPL development ecosystem.

## Core NPL Scripts

### npl-load - Resource Loader
**Purpose**: Load NPL components, metadata, styles, prompts with hierarchical path resolution

| Subcommand | Purpose | Example |
|:-----------|:--------|:--------|
| `c <items>` | Load core components (syntax, fences, directives) | `npl-load c "syntax,agent"` |
| `m <items>` | Load metadata (personas, configs) | `npl-load m "persona.qa-engineer"` |
| `s <items>` | Load style guides (conventions) | `npl-load s "house-style"` |
| `agent <name>` | Load agent definition with optional NPL docs | `npl-load agent npl-gopher-scout --definition` |
| `init-claude` | Initialize/update CLAUDE.md with versioned prompts | `npl-load init-claude --update-all` |
| `syntax --file <f>` | Analyze NPL syntax elements in content | `npl-load syntax --file agent.md --matches` |

**Features**:
- Hierarchical path resolution: project → user → system
- Dependency tracking with skip flags to prevent reloading
- Patch overlays for customization
- Multi-tier resource loading in single call

### npl-persona - Persona Manager
**Purpose**: Comprehensive persona management for simulated agent identities

| Command Group | Commands | Purpose |
|:--------------|:---------|:--------|
| Lifecycle | `init`, `get`, `list`, `remove` | Create, retrieve, list, delete personas |
| Journal | `journal <id> add\|view\|archive` | Track experiences and learnings |
| Tasks | `task <id> add\|update\|complete\|list` | Manage persona goals and work |
| Knowledge | `kb <id> add\|search\|get` | Build persona knowledge bases |
| Teams | `team create\|add\|list\|synthesize` | Multi-persona collaboration |
| Maintenance | `health`, `sync`, `backup` | File integrity and state |

**Use Cases**:
- Persistent agent identity across sessions
- Multi-persona team collaboration and synthesis
- Knowledge base building for specialized agents
- Decision tracking and learning persistence

### npl-worklog (npl-session) - Session Management
**Purpose**: Cross-agent communication via shared worklogs with cursor-based reads

| Command | Purpose | Example |
|:--------|:--------|:--------|
| `init [--task=X]` | Create new session | `npl-session init --task="Implement auth"` |
| `current` | Get current session ID | `npl-session current` |
| `log --agent=X --action=Y` | Append entry to worklog | `npl-session log --agent=explore-001 --action=found` |
| `read --agent=X [--peek]` | Read entries since agent's cursor | `npl-session read --agent=primary` |
| `status` | Show session stats | `npl-session status --json` |
| `list [--all]` | List sessions | `npl-session list` |
| `close [--archive]` | Close current session | `npl-session close --archive` |

**Session Directory**:
```
.npl/sessions/YYYY-MM-DD/
├── meta.json              # Session metadata
├── worklog.jsonl          # Append-only entry log (shared)
├── .cursors/
│   └── <agent-id>.cursor  # Per-agent read cursor
└── tmp/                   # Interstitial files
    └── <agent-id>/
        ├── <task>.summary.md
        └── <task>.detailed.md
```

### npl-fim-config - Visualization Configuration
**Purpose**: Query tool-task compatibility matrix for visualization libraries

| Command | Purpose | Example |
|:--------|:--------|:--------|
| `query <desc>` | Find tools matching description | `npl-fim-config query "network graph"` |
| `list-tools` | List all supported visualization tools | `npl-fim-config list-tools` |
| `matrix` | Show full compatibility matrix | `npl-fim-config matrix` |

## Codebase Exploration Scripts

### dump-files
**Purpose**: Dump all file contents recursively with headers

```bash
dump-files <path> [-g "*.pattern"]
```

**Features**:
- Respects `.gitignore`
- Supports glob pattern filtering
- Includes file name headers
- Output suitable for LLM context

**Examples**:
```bash
./dump-files .                    # All files
./dump-files src/ -g "*.md"       # Only markdown in src/
./dump-files . -g "!*.min.js"     # Exclude minified JS
```

### git-tree
**Purpose**: Display directory tree structure

```bash
git-tree [path]
```

**Features**:
- Uses `tree` command if available
- Falls back to bash if needed
- Clean visual representation
- Default: current directory

### git-tree-depth
**Purpose**: List directories with nesting depth

```bash
git-tree-depth <path>
```

**Features**:
- Shows nesting level relative to target
- Useful for understanding structure complexity
- Helps identify deeply nested components

## Script Organization

```
scripts/
├── npl-load             # Resource loader
├── npl-persona          # Persona manager
├── npl-worklog          # Session/worklog management
├── npl-fim-config       # Visualization tool config
├── dump-files           # File content dumper
├── git-tree             # Directory tree display
├── git-tree-depth       # Nesting depth analyzer
├── README.md            # Script documentation
└── tests/               # Unit tests
    └── test_npl_persona.py
```

## Integration Points

### with Agents
- Agents invoke `npl-session log` to record work
- Agents read other agents' output via `npl-session read`
- Agents load resources via `npl-load`

### with Development
- `dump-files` used by explore agents for context gathering
- `git-tree*` scripts used for project navigation
- `npl-load` used in initialization and configuration

### with CI/CD
- Scripts can be invoked in build pipelines
- Session management for multi-stage builds
- Resource loading for dynamic configuration

## Key Characteristics
- **Self-Contained**: Each script is independent and runnable
- **Composable**: Scripts can be chained in workflows
- **Documented**: Each has embedded help and examples
- **Version-Aware**: Scripts track and handle version compatibility
- **Error-Resilient**: Graceful fallbacks and error handling

## Usage Patterns

### Single Agent Session
```bash
npl-session init --task="Implement feature"
npl-session log --agent=coder-001 --action=start
# ... work happens ...
npl-session log --agent=coder-001 --action=complete
npl-session close --archive
```

### Multi-Agent Orchestration
```bash
# Agent 1 explores and logs findings
npl-session log --agent=explore-001 --action=found --summary="Found auth.ts"

# Agent 2 reads findings and builds on them
npl-session read --agent=coder-001  # Gets explore's findings

# Agent 1 reads coder's work
npl-session read --agent=explore-001 --peek  # Peek without advancing cursor
```

### Resource Loading Chain
```bash
# Load dependencies once
npl-load c "syntax,agent" --skip ""

# Add more resources while preserving loaded set
npl-load c "syntax,agent,pumps" --skip "syntax,agent"

# Load from multiple sources
npl-load c "syntax" m "persona.qa-engineer" s "house-style" --skip ""
```

## Notes
- Scripts are located in `$NPL_HOME/scripts/` (typically `./.npl/scripts/` or `~/.npl/scripts/`)
- Many scripts have Python implementations and bash wrappers
- Environment variables control paths and behavior (see NPL environment configuration)
- Test suite included: `pytest scripts/tests/`
