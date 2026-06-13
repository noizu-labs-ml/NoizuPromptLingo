# PROJECT-ARCH

**Type**: Architectural Documentation
**Category**: root
**Status**: Core

## Purpose

NoizuPromptLingo (NPL) is a modular prompt engineering framework designed for advanced AI agent simulation and structured prompting with Claude Code integration. It provides a comprehensive architecture based on markdown-as-code principles, enabling human-readable agent definitions that are directly interpreted by LLMs as behavioral specifications.

The architecture supports event-sourced collaboration, hierarchical resource loading, and runtime artifact management through a layered approach: Consumer (runtime environments) → Interface (MCP server, CLI tools) → Definition (NPL syntax, agents) → Storage (SQLite, files).

## Key Capabilities

- **80+ NPL syntax definitions** covering directives, fences, pumps, prefixes, and special sections
- **45+ markdown-based agent specifications** across 8 categories for diverse workflows
- **23 MCP server tools** for artifact management, reviews, chat rooms, and collaboration
- **Hierarchical loading system** with multi-tier path resolution (environment → project → user → system)
- **Event-sourced chat** with immutable typed events (messages, reactions, artifact shares, todos)
- **File-backed persona system** supporting journals, tasks, knowledge bases, and team collaboration

## Usage & Integration

- **Triggered by**: Claude Code via CLAUDE.md injection or MCP tool invocations
- **Outputs to**: LLM runtime environments, file artifacts, SQLite databases
- **Complements**: FastMCP framework, CLI utilities (npl-load, npl-persona, dump-files)

The framework is consumed through three primary paths:
1. **Claude Code integration** via CLAUDE.md configuration files that inject NPL prompts
2. **MCP Server** exposing 23 tools for runtime collaboration and artifact management
3. **CLI Scripts** for resource loading, persona management, and codebase exploration

## Core Operations

**Load NPL framework**:
```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded}
```

**Start MCP server**:
```bash
uv run -m npl_mcp.launcher
# or via mise
mise run run
```

**Initialize persona**:
```bash
npl-persona init --name "QA Engineer" --role qa
```

**Query session worklog**:
```bash
npl-session read --agent=primary
```

## Configuration & Parameters

| Layer | Key Components | Configuration Location |
|-------|----------------|------------------------|
| Consumer | Claude Code, LLM clients, MCP tools | Runtime environment |
| Interface | MCP Server (23 tools), CLI scripts | `mcp-server/pyproject.toml` |
| Definition | NPL syntax (80+), Agents (45+) | `/npl/`, `/core/agents/` |
| Storage | SQLite (3 databases), file artifacts | `*/schema/*.sql` |

**Environment Variables**:
- `$NPL_HOME` - Base path for NPL definitions (fallback: `./.npl`, `~/.npl`, `/etc/npl/`)
- `$NPL_META` - Metadata files location
- `$NPL_PERSONA_DIR` - Persona definition directory

## Integration Points

- **Upstream dependencies**: FastMCP framework, Python >=3.10, SQLite/aiosqlite
- **Downstream consumers**: Claude Code sessions, LLM clients, collaborative workflows
- **Related utilities**:
  - `npl-load` - hierarchical resource loading
  - `npl-persona` - persona management
  - `npl-session` - cross-agent communication via worklogs
  - `dump-files`, `git-tree` - codebase exploration

## Architectural Patterns

**Markdown-as-Code**: Agent definitions and syntax rules structured as markdown files, interpretable by LLMs as behavioral specifications while remaining human-readable.

**Manager/Service Pattern**: Domain managers (ArtifactManager, ReviewManager, ChatManager) encapsulate business logic, initialized via FastMCP lifespan hooks.

**Unicode Boundary Markers**: Corner brackets (⌜⌝⌞⌟) delineate agent definitions with embedded metadata (name|type|version).

**Event-Sourced Chat**: All chat interactions stored as immutable typed events with JSON payloads, enabling replay and audit trails.

## Bounded Contexts

**NPL Framework**: Core prompt syntax (Agents, Directives, Prefixes, Pumps, Fences). Aggregate Root: Agent.

**MCP Tooling**: Runtime artifact management (Artifacts, Revisions, Reviews, InlineComments, ChatRooms, Notifications). Aggregate Roots: Artifact, Review, ChatRoom.

**Personas**: AI identity management (Personas, Teams, Journals, Tasks, KnowledgeBases, Relationships). Aggregate Roots: Persona, Team.

## Limitations & Constraints

- **Local-only deployment** - No containerization or cloud deployment model (by design)
- **No migration system** - Database schemas applied directly without version tracking
- **Stub installer** - `npl-installer` package incomplete, requiring manual pip installation
- **No CI/CD pipeline** - Tests exist but require manual execution
- **Python >=3.10 required** - No backward compatibility with older Python versions

## Success Indicators

- **MCP server responds** at `/sse` endpoint with 23 registered tools
- **NPL resources load** via `npl-load` without errors, returning content headers with flags
- **Agent definitions parse** with valid Unicode boundary markers and metadata
- **Personas persist** with journals, tasks, and knowledge bases in file-backed storage
- **Session worklogs track** cross-agent communication with cursor-based reads
- **Test suite passes** via `mise run test-status` returning success

---
**Generated from**: worktrees/main/docs/PROJECT-ARCH.md
**Word count**: ~650 words
