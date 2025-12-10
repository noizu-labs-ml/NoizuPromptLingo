npl-instructions:
   name: npl-conventions
   version: 1.5.0
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
npl-worklog log --agent=explore-auth-001 --action=file_found --summary="Found auth.ts"
npl-worklog read --agent=primary  # Read new entries since cursor
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
| `mcp__npl-mcp__git_tree` | Directory structure | `mcp__npl-mcp__git_tree("docs/")` |
| `mcp__npl-mcp__dump_files` | Dump file contents | `mcp__npl-mcp__dump_files("src/", "*.md")` |
| `mcp__npl-mcp__npl_load` | Load NPL components | `mcp__npl-mcp__npl_load("c", "syntax,agent")` |

**Pattern**: Search first (`Glob`/`Grep`), then read relevant files.

## MCP Server Integration

The `npl-mcp` server provides collaboration tools. Features are discoverable via the `mcp__npl-mcp__*` prefix.

### MCP Tool Categories

| Category | Tools | Purpose |
|:---------|:------|:--------|
| **Scripts** | `dump_files`, `git_tree`, `git_tree_depth`, `npl_load` | Codebase exploration |
| **Artifacts** | `create_artifact`, `add_revision`, `get_artifact`, `list_artifacts` | Version-controlled documents |
| **Reviews** | `create_review`, `add_inline_comment`, `complete_review` | Collaborative review |
| **Sessions** | `create_session`, `get_session`, `list_sessions` | Group artifacts and chat rooms |
| **Chat** | `create_chat_room`, `send_message`, `get_notifications` | Team collaboration |

### When to Use MCP

- **Artifact sharing**: Use `create_artifact` + `share_artifact` for documents that need revision tracking
- **Code reviews**: Use `create_review` + `add_inline_comment` for structured feedback
- **Team discussions**: Use `create_chat_room` + `send_message` with @mentions
- **Session grouping**: Use `create_session` to organize related artifacts and discussions

### 🎯 Documentation Discovery (Critical)

Before exploring code or beginning any task, **always check for existing documentation**:

1. **Check for `docs/` folder** at the project root
2. **Read `docs/summary.md`** if present—this provides curated context about the codebase
3. **Run `git-tree docs/`** to discover available documentation structure

```bash
# Discover documentation structure
git-tree docs/

# Read the summary first for high-level context
Read("docs/summary.md")
```

Documentation often contains architecture decisions, API contracts, onboarding guides, and domain knowledge that eliminates guesswork. Reading docs before code prevents redundant exploration and ensures inference aligns with project conventions.

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
