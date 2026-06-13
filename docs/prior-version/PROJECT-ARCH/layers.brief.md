# Architectural Layers

**Type**: Architecture Documentation
**Category**: PROJECT-ARCH
**Status**: Core

## Purpose

Defines the four-layer system architecture of NoizuPromptLingo (NPL), documenting the flow from markdown-based language definitions through multiple interface patterns to LLM consumers. This architecture separates concerns cleanly: the Definition Layer contains pure NPL syntax and agent specifications; the Interface Layer exposes these through MCP Server tools, CLI scripts, and CLAUDE.md configuration; the Storage Layer provides persistence for collaboration features; and the Consumer Layer provides runtime environments that interpret NPL.

The layered design enables NPL to be consumed through multiple channels (Claude Code sessions via CLAUDE.md, external LLM clients via npl-load, MCP-compatible tools via protocol) while maintaining a single source of truth for language definitions and agent behaviors.

## Key Capabilities

- **Multi-interface access**: NPL exposed through MCP Server (23 tools), CLI scripts (npl-load, npl-persona), and CLAUDE.md injection
- **Hierarchical definition resolution**: project → user → system fallback paths for NPL components, agents, and personas
- **Persistent collaboration**: SQLite-backed artifact versioning, review systems, chat rooms with notifications
- **File-backed agent state**: Persona system with journals, tasks, knowledge bases stored as markdown
- **Clear separation of concerns**: Definitions contain no code; interfaces contain no logic; storage contains no interpretation
- **Cross-layer communication patterns**: Definition loading flow, MCP collaboration, persona state synchronization

## Usage & Integration

**Triggered by**: Consumer requests to load NPL context (CLAUDE.md injection), CLI invocations (npl-load commands), MCP tool calls from LLM clients

**Outputs to**: System prompts with NPL syntax, structured JSON responses from MCP tools, markdown content on stdout from CLI scripts

**Complements**: NPL syntax definitions (/npl/), agent specifications (/core/agents/), MCP Server tools (npl-mcp package)

## Core Operations

**Definition Loading (Consumer → Interface → Definition)**
```bash
# Load core NPL components with dependency tracking
npl-load c "syntax,agent" --skip ""
# Returns markdown content + npl.loaded=syntax,agent flag

# Subsequent loads skip already-loaded items
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
```

**MCP Collaboration (Consumer → MCP Server → Storage)**
```python
# Create versioned artifact with metadata
await create_artifact(
    name="feature-spec",
    type="document",
    content="# Feature X\n...",
    created_by="npl-author"
)
# Returns: {artifact_id, revision_id, paths}

# Start review session with inline comments
await create_review(artifact_id=1, revision_id=1, reviewer_persona="qa-engineer")
await add_inline_comment(review_id=1, location="line:58", comment="Edge case?")
```

**Persona State Management (Consumer → npl-persona → File System)**
```bash
# Initialize persona with role and expertise
npl-persona init sarah --role="QA Engineer" --expertise="testing,automation"

# Track experience in journal
npl-persona journal sarah add --message="Discovered race condition in auth flow"

# Manage active tasks
npl-persona task sarah add --task="Review PR #123" --priority=high
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `$NPL_HOME` | Base path for NPL definitions | `./.npl` → `~/.npl` → `/etc/npl/` | Hierarchical fallback |
| `$NPL_MCP_DATA_DIR` | MCP Server database and artifacts | `./data/` | Configurable via environment |
| `$NPL_PERSONA_DIR` | Persona definition files | `./.npl/personas` → `~/.npl/personas` | Per-layer resolution |
| `--skip` (npl-load) | Items already loaded | `""` | Comma-separated list from prior npl.loaded flags |
| `--definition` (agent load) | Include full NPL docs with agent | Not set | Adds syntax/pumps context |

## Integration Points

**Consumer Layer**
- **Upstream**: User prompts, Claude Code sessions, MCP client configurations
- **Downstream**: Interface Layer (CLAUDE.md system prompt, MCP tool calls, CLI invocations)

**Interface Layer**
- **Upstream**: Consumer requests via protocol/CLI/config
- **Downstream**: Definition Layer (file reads), Storage Layer (database/file operations)

**Definition Layer**
- **Upstream**: Interface Layer file read requests
- **Downstream**: None (pure definitions)

**Storage Layer**
- **Upstream**: Interface Layer managers (ArtifactManager, ChatManager, ReviewManager)
- **Downstream**: SQLite database, file system at `$NPL_MCP_DATA_DIR`

## Limitations & Constraints

- **No circular dependencies**: Storage Layer cannot reference Definition Layer; Definition Layer has no dependencies
- **File-based persona persistence**: Personas stored as markdown files, not in database (by design for human editability)
- **Single NPL version per session**: CLAUDE.md locks to NPL@1.0; no mixed-version support
- **MCP Server singleton**: Only one npl-mcp instance per data directory (PID file enforcement)

## Success Indicators

- **Definition loading**: npl-load returns content with tracking flags; no duplicate loads when --skip used correctly
- **MCP collaboration**: Artifacts created with unique revision IDs; reviews persist across sessions; chat events queryable
- **Layer isolation**: Changes to Definition Layer require no Storage Layer updates; Interface Layer changes don't affect Definition syntax
- **Cross-consumer compatibility**: Same NPL definitions work in Claude Code (via CLAUDE.md), external LLMs (via npl-load), and MCP clients (via tools)

---
**Generated from**: worktrees/main/docs/PROJECT-ARCH/layers.md