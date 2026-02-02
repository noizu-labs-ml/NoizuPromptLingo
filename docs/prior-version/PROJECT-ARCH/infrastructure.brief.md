# Infrastructure

**Type**: Documentation
**Category**: PROJECT-ARCH
**Status**: Core

## Purpose

Infrastructure documentation consolidates all service configuration, deployment, and tooling information for the NoizuPromptLingo project. This serves as the single source of truth for developers deploying locally, managing SQLite databases, understanding Python packages, and utilizing CLI scripts. It defines the local-first, development-only deployment model with embedded SQLite databases and hierarchical resource loading.

## Key Capabilities

- **Three embedded SQLite databases** with distinct schemas for MCP server operations, NIMPS project management, and knowledge base storage
- **Two Python packages** (`npl-mcp` and `npl-installer`) with FastMCP server and installation utilities
- **Six CLI tools** providing hierarchical resource loading, persona management, session tracking, and codebase exploration
- **Comprehensive environment configuration** with hierarchical path resolution (project → user → system)
- **Local-first deployment model** with no cloud infrastructure or containerization
- **FTS5 full-text search** capabilities in the knowledge base with automatic maintenance

## Usage & Integration

- **Triggered by**: Developer setup, MCP server initialization, CLI script invocation
- **Outputs to**: Running MCP server, local SQLite databases, file system artifacts
- **Complements**: TDD workflow documentation, agent orchestration system, NPL conventions

## Core Operations

### Database Management

```bash
# MCP server creates database on first run
NPL_MCP_DATA_DIR=./data npl-mcp

# Query database directly
sqlite3 -header -column ./data/npl-mcp.db 'SELECT * FROM artifacts;'
```

### Package Installation

```bash
# Install MCP server package
cd mcp-server
pip install -e .

# Run MCP server
npl-mcp
```

### CLI Tool Usage

```bash
# Load NPL components with skip flags
npl-load c "syntax,agent" --skip "syntax"

# Initialize persona
npl-persona init tech-lead --role="Technical Lead"

# Session management
npl-session init --task="Implement auth"
npl-session log --agent=explore-001 --action=found --summary="auth.ts"
npl-session read --agent=primary

# Codebase exploration
dump-files src/ -g "*.py"
git-tree-depth core/
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `NPL_HOME` | Base path for NPL definitions | `./.npl`, `~/.npl`, `/etc/npl/` | Hierarchical fallback |
| `NPL_MCP_DATA_DIR` | Data directory for MCP server | `./data` | Contains SQLite DB |
| `NPL_PERSONA_DIR` | Base path for persona definitions | `./.npl/personas` | Multi-tier resolution |
| `NPL_META` | Path for metadata files | `$NPL_HOME/meta` | Used by npl-load |
| `NPL_STYLE_GUIDE` | Path for style conventions | `$NPL_HOME/conventions` | Theme support |
| `NPL_THEME` | Theme name for style loading | `default` | Optional customization |

## Integration Points

- **Upstream dependencies**: Git repository, Python >=3.10, PyYAML, FastMCP framework
- **Downstream consumers**: Claude MCP client, TDD agent workflows, persona-based collaboration
- **Related utilities**: mise task runner (test execution), yq (YAML index management), FTS5 search engine

## Database Schemas

### MCP Server Database (`npl-mcp.db`)

| Table | Indexes | Purpose |
|-------|---------|---------|
| artifacts, revisions | `idx_revisions_artifact` | Versioned artifact tracking |
| reviews, inline_comments | `idx_reviews_artifact`, `idx_inline_comments_review` | Code/doc review system |
| chat_rooms, chat_events | `idx_chat_events_room`, `idx_chat_events_timestamp` | Persona collaboration |
| notifications | `idx_notifications_persona`, `idx_notifications_read` | @mention tracking |

### NIMPS Database (`nimps.sql`)

Status workflow: `discovery` → `analysis` → `persona` → `planning` → `architecture` → `creation` → `mockup` → `documentation` → `completed`

22 tables covering project registry, business analysis (SWOT), personas with relationships, epics/user stories (US-XXX format), acceptance criteria (Gherkin), components with dependencies, assets, and diagrams.

### Knowledge Base Database (`nb.sql`)

FTS5-powered full-text search on articles with automatic maintenance triggers. Cross-references between articles with typed relationships (see_also, prerequisite, extends, related). Access tracking with timestamps and counters.

## Limitations & Constraints

- **No production deployment** - local development only, no CI/CD pipeline
- **Single-user model** - SQLite databases not designed for concurrent multi-user access
- **No migration system** - schemas created on-demand at runtime, manual updates required
- **Bash dependency** - CLI scripts require Git repository context and standard Unix tools (`tree`, `grep`)
- **Python version requirement** - Minimum Python 3.10 for MCP server, 3.9 for installer
- **Local file system only** - no cloud storage, object stores, or distributed file systems

## Success Indicators

- MCP server starts successfully and responds to tool invocations
- SQLite databases created with correct schemas and indexes
- CLI tools resolve resources via hierarchical path search
- Session worklogs enable cross-agent communication with cursor-based reads
- Personas maintain file integrity (definition, journal, tasks, knowledge base)
- FTS5 search returns relevant articles from knowledge base
- Environment variables correctly override defaults in hierarchical resolution

---
**Generated from**: worktrees/main/docs/PROJECT-ARCH/infrastructure.md
