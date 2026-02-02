# PRD-013: CLI Utilities Implementation

**Version**: 1.0
**Status**: Draft
**Owner**: NPL Framework Team
**Last Updated**: 2026-02-02

---

## Executive Summary

The NPL framework documents 7 CLI utilities for resource loading, persona management, session coordination, and codebase exploration. Currently 0 utilities are implemented, blocking all workflows that depend on hierarchical resource loading or cross-agent coordination. This PRD defines complete implementation specifications for all CLI utilities.

**Current State**:
- 7 CLI utilities documented
- 0 utilities implemented
- Resource loading blocked
- Session coordination unavailable

**Target State**:
- All 7 utilities implemented and tested
- Hierarchical path resolution working
- Integration with MCP server tools
- Documentation with usage examples

---

## Problem Statement

The NPL framework requires CLI utilities for:

1. **Resource Loading**: Agents need to load syntax, agent definitions, and prompts from hierarchical paths
2. **Persona Management**: Multi-persona workflows require persistent state management
3. **Session Coordination**: Parent-child agent communication needs worklog infrastructure
4. **Codebase Exploration**: Context gathering requires structured file and directory access

Without these utilities, Claude Code cannot effectively use the NPL framework, and multi-agent orchestration cannot coordinate through worklogs.

---

## User Stories

| Story ID | Description |
|----------|-------------|
| US-001 | As a developer, I want to load NPL resources from hierarchical paths |
| US-002 | As a developer, I want resources resolved from environment, project, user, then system |
| US-003 | As a developer, I want to skip already-loaded resources using flags |
| US-025 | As a developer, I want to manage persistent persona state with journals and tasks |
| US-047 | As a developer, I want cross-agent communication through shared worklogs |
| US-085 | As a developer, I want to explore codebase structure respecting .gitignore |
| US-086 | As a developer, I want syntax validation via CLI |

---

## CLI Utility Specifications

### 1. npl-load (Hierarchical Resource Loader)

**Purpose**: Load NPL resources (syntax, agents, prompts, metadata) from hierarchical paths with dependency tracking.

**Usage**:
```bash
# Load core components
npl-load c "syntax,agent,pumps"

# Load with skip flag
npl-load c "syntax,agent" --skip {@npl.def.loaded}

# Load metadata
npl-load m "project,version"

# Load style definitions
npl-load s "format,output"

# Load specific agent
npl-load agent gopher-scout --definition

# Verbose output
npl-load c "syntax" --verbose
```

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | positional | Resource type: `c` (core), `m` (meta), `s` (style), `agent` |
| `items` | positional | Comma-separated list of items to load |
| `--skip` | optional | Flag expression for items to skip |
| `--verbose` | optional | Show detailed loading information |
| `--definition` | optional | For agents: load full definition |
| `--path` | optional | Override default search paths |

**Path Resolution**:
```
1. $NPL_HOME environment variable
2. ./.npl/ (project-local)
3. ~/.npl/ (user-global)
4. /etc/npl/ (system-wide)
```

**Output Format**:
```
⌜📦 NPL Resources⌝
  syntax: loaded (2.1kb)
  agent: loaded (4.5kb)
  pumps: skipped (already loaded)
⌞📦 NPL Resources⌟

{@npl.def.loaded = "syntax,agent,pumps"}
```

**Functional Requirements**:
- Resolve paths in hierarchical order
- Skip items matching `--skip` expression
- Output content with NPL boundary markers
- Set flags for loaded items
- Support glob patterns for items
- Handle missing resources gracefully

---

### 2. npl-persona (Persona Lifecycle Manager)

**Purpose**: Create, manage, and query persistent persona state including journals, tasks, and knowledge bases.

**Usage**:
```bash
# Initialize new persona
npl-persona init sarah-architect --role "Architect" --scope project

# Get persona info
npl-persona get sarah-architect

# List personas
npl-persona list --scope project

# Remove persona
npl-persona remove sarah-architect

# Journal operations
npl-persona journal sarah-architect add "Reviewed API design"
npl-persona journal sarah-architect list --last 10

# Task operations
npl-persona task sarah-architect add "Refactor schema" --priority high
npl-persona task sarah-architect complete TASK-001
npl-persona task sarah-architect list --status pending

# Knowledge base operations
npl-persona kb sarah-architect add api "REST endpoint conventions"
npl-persona kb sarah-architect query "authentication"

# Team operations
npl-persona team create backend-team --members sarah,bob,alice
npl-persona team synthesize backend-team --topic "API redesign"
```

**Subcommands**:
| Subcommand | Action | Description |
|------------|--------|-------------|
| `init` | create | Initialize new persona |
| `get` | read | Get persona details |
| `list` | read | List personas by scope |
| `remove` | delete | Remove persona |
| `journal` | manage | Journal entry operations |
| `task` | manage | Task tracking operations |
| `kb` | manage | Knowledge base operations |
| `team` | manage | Team coordination |

**Persona Storage Structure**:
```
.npl/personas/
├── sarah-architect/
│   ├── definition.yaml
│   ├── journal.jsonl
│   ├── tasks.yaml
│   └── knowledge/
│       ├── api.md
│       └── architecture.md
└── bob-developer/
    └── ...
```

**Functional Requirements**:
- Persist persona state to filesystem
- Support project, user, and system scopes
- Maintain append-only journal
- Track task status and history
- Enable knowledge base queries
- Synthesize team discussions

---

### 3. npl-session (Cross-Agent Worklog Coordinator)

**Purpose**: Manage shared worklogs for parent-child agent communication with cursor-based reads.

**Usage**:
```bash
# Initialize session
npl-session init --task "Implement feature X"

# Log entry
npl-session log --agent explore-001 --action found --summary "Found config in src/"

# Read new entries
npl-session read --agent parent

# Peek without advancing cursor
npl-session read --agent parent --peek

# Get session status
npl-session status

# Close session
npl-session close --summary "Completed implementation"
```

**Subcommands**:
| Subcommand | Description |
|------------|-------------|
| `init` | Start new session |
| `log` | Append worklog entry |
| `read` | Read entries since cursor |
| `status` | Show session status |
| `close` | Close session with summary |

**Worklog Format**:
```jsonl
{"id":"e1","ts":"2026-02-02T14:00:00Z","agent":"explore-001","action":"start","summary":"Beginning exploration"}
{"id":"e2","ts":"2026-02-02T14:01:00Z","agent":"explore-001","action":"found","summary":"Located main.py","metadata":{"file":"src/main.py"}}
{"id":"e3","ts":"2026-02-02T14:02:00Z","agent":"explore-001","action":"complete","summary":"Finished exploration","outputs":["report.md"]}
```

**Session Storage**:
```
.npl/sessions/
└── 2026-02-02/
    ├── worklog.jsonl
    ├── .cursors/
    │   ├── parent
    │   └── explore-001
    ├── .summary.md
    └── .detailed.md
```

**Functional Requirements**:
- Append-only worklog with unique IDs
- Per-agent cursor tracking
- Atomic cursor updates
- Session summaries for quick reads
- Dependency tracking between entries
- Export session for archival

---

### 4. dump-files (File Content Extractor)

**Purpose**: Extract and display file contents with formatting suitable for context injection.

**Usage**:
```bash
# Dump all files in directory
dump-files src/

# Filter by glob pattern
dump-files src/ -g "*.py"

# Multiple patterns
dump-files src/ -g "*.py" -g "*.ts"

# Exclude patterns
dump-files src/ -g "*.py" --exclude "*_test.py"

# Output to file
dump-files src/ -g "*.md" > context.txt
```

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | positional | Target directory |
| `-g, --glob` | repeated | Glob patterns to include |
| `--exclude` | repeated | Glob patterns to exclude |
| `--max-size` | optional | Maximum file size in KB |
| `--no-header` | optional | Omit file headers |

**Output Format**:
```
===== src/main.py =====
import sys

def main():
    print("Hello, NPL!")

if __name__ == "__main__":
    main()

* * *

===== src/utils.py =====
def helper():
    pass

* * *
```

**Functional Requirements**:
- Respect `.gitignore` patterns
- Format with clear file delimiters
- Handle binary files gracefully (skip)
- Support size limits
- Preserve file encoding

---

### 5. git-tree (Git-Aware Directory Viewer)

**Purpose**: Display directory structure with Git awareness (respects .gitignore, shows tracked files).

**Usage**:
```bash
# Show project structure
git-tree

# Target specific directory
git-tree src/

# Limit depth
git-tree --depth 3

# Include hidden files
git-tree --all

# Show file sizes
git-tree --sizes

# JSON output
git-tree --format json
```

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | positional | Target directory (default: current) |
| `--depth` | optional | Maximum depth to display |
| `--all` | optional | Include hidden files |
| `--sizes` | optional | Show file sizes |
| `--format` | optional | Output format: text, json, tree |

**Output Format**:
```
.
├── src/
│   ├── main.py
│   ├── utils/
│   │   ├── __init__.py
│   │   └── helpers.py
│   └── tests/
│       └── test_main.py
├── pyproject.toml
└── README.md
```

**Functional Requirements**:
- Respect `.gitignore` patterns
- Show only tracked and untracked (not ignored) files
- Use tree command if available, fallback to bash
- Support multiple output formats
- Handle large directories efficiently

---

### 6. npl-syntax (Syntax Validator CLI)

**Purpose**: Validate NPL documents for syntax correctness.

**Usage**:
```bash
# Validate file
npl-syntax validate path/to/file.md

# Validate directory
npl-syntax validate path/to/dir --recursive

# List syntax elements
npl-syntax list path/to/file.md

# Check specific category
npl-syntax validate file.md --category agent-directives

# Output formats
npl-syntax validate file.md --format json
npl-syntax validate file.md --format github
```

**Subcommands**:
| Subcommand | Description |
|------------|-------------|
| `validate` | Check document syntax |
| `list` | List syntax elements in document |
| `check` | Quick pass/fail check |

**Exit Codes**:
| Code | Meaning |
|------|---------|
| 0 | Valid, no errors |
| 1 | Validation errors found |
| 2 | File not found or unreadable |

**Functional Requirements**:
- Parse all 155 syntax elements
- Report line/column for errors
- Support GitHub Actions output format
- Aggregate results for directories
- Return appropriate exit codes

---

### 7. npl-check (Health Check Utility)

**Purpose**: Verify NPL installation and configuration health.

**Usage**:
```bash
# Full health check
npl-check

# Check specific component
npl-check paths
npl-check agents
npl-check server

# Verbose output
npl-check --verbose

# JSON output
npl-check --format json
```

**Check Categories**:
| Category | Checks |
|----------|--------|
| `paths` | Verify all path resolution levels exist and are readable |
| `agents` | Validate agent definitions load correctly |
| `server` | Check MCP server health and tool registration |
| `syntax` | Verify syntax element patterns compile |
| `personas` | Check persona storage is accessible |
| `sessions` | Verify session directory structure |

**Output Format**:
```
NPL Health Check
================

Paths:
  [OK] Project: ./.npl/
  [OK] User: ~/.npl/
  [WARN] System: /etc/npl/ (not found)

Agents:
  [OK] 45 agent definitions loaded
  [OK] All agents validate

Server:
  [OK] MCP server reachable at localhost:8000
  [OK] 23 tools registered

Overall: HEALTHY (1 warning)
```

**Functional Requirements**:
- Check all installation components
- Report actionable warnings
- Support CI-friendly output formats
- Exit with appropriate codes
- Provide fix suggestions for failures

---

## Hierarchical Loading System

All CLI utilities respect the hierarchical path resolution:

```
Priority (highest to lowest):
1. Environment variables ($NPL_HOME, $NPL_AGENTS, etc.)
2. Project-local (./.npl/)
3. User-global (~/.npl/)
4. System-wide (/etc/npl/)
```

**Resolution Rules**:
- First match wins (higher priority shadows lower)
- Missing directories are skipped (not errors)
- Resources can be merged from multiple levels
- Explicit `--path` overrides all resolution

**Environment Variables**:
| Variable | Purpose |
|----------|---------|
| `NPL_HOME` | Base path for all NPL resources |
| `NPL_AGENTS` | Path to agent definitions |
| `NPL_PERSONAS` | Path to persona storage |
| `NPL_SESSIONS` | Path to session worklogs |
| `NPL_META` | Path to metadata files |

---

## Success Criteria

1. **CLI Coverage**: All 7 utilities implemented and documented
2. **Path Resolution**: Hierarchical loading works at all levels
3. **Integration**: Utilities integrate with MCP server
4. **Testing**: >90% test coverage for all utilities
5. **Documentation**: Man pages and usage examples for each
6. **Performance**: Operations complete in <1s for typical use
7. **Error Handling**: Clear error messages with suggestions

---

## Testing Strategy

### Unit Tests
- Path resolution at each hierarchy level
- Individual subcommand functionality
- Output format correctness

### Integration Tests
- Full workflows (init → use → cleanup)
- Cross-utility integration (session + persona)
- MCP server interaction

### E2E Tests
- Complete resource loading scenarios
- Multi-persona team coordination
- Session-based agent handoffs

---

## Legacy Reference

- **Scripts Summary**: `.tmp/docs/scripts/summary.brief.md`
- **npl-load**: `.tmp/docs/scripts/npl-load.brief.md`
- **npl-persona**: `.tmp/docs/scripts/npl-persona.brief.md`
- **npl-session**: `.tmp/docs/scripts/npl-session.brief.md`
- **dump-files**: `.tmp/docs/scripts/dump-files.brief.md`
- **git-tree**: `.tmp/docs/scripts/git-tree.brief.md`
