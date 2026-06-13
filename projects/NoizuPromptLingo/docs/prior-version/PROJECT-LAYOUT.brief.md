# PROJECT-LAYOUT

**Type**: Documentation
**Category**: root
**Status**: Core

## Purpose

PROJECT-LAYOUT defines the complete directory structure and file organization for the NoizuPromptLingo (NPL) framework. It serves as the canonical reference for understanding how NPL's syntax definitions, agents, MCP server, documentation, demonstrations, and metadata are structured across the repository. This document enables developers and AI agents to quickly locate components, understand organizational conventions, and navigate the codebase efficiently across 107 directories and 555 files.

## Key Capabilities

- **Hierarchical directory mapping**: Complete tree visualization of all major NPL components
- **Component categorization**: Clear separation of syntax framework, core utilities, server infrastructure, documentation, and examples
- **File type classification**: Detailed breakdown of markdown, Python, SQL, and visualization artifacts
- **Statistics overview**: Quantitative summary of agents, tools, files, and directories
- **Configuration mapping**: Index of project-level config files and their purposes
- **Extension conventions**: Standardized file extensions and their semantic meanings

## Usage & Integration

- **Triggered by**: Onboarding sessions, codebase exploration tasks, agent initialization, documentation generation
- **Outputs to**: Navigation systems, build scripts, documentation generators, agent path resolution
- **Complements**: PROJECT-ARCH (architecture), CLAUDE.md (project instructions), agent definitions

## Core Structure

### Root Organization
```
NoizuPromptLingo/
├── npl/                    # NPL syntax framework (23 components)
├── core/                   # Agents, commands, scripts, schemas
├── mcp-server/             # Python FastMCP server (23 tools)
├── docs/                   # Documentation and guides
├── demo/                   # Usage examples and demonstrations
├── meta/                   # FIM solution inventory (150+ tools)
├── experimental/           # Experimental NPL features
├── skeleton/               # Project template skeleton
└── [config files]          # CLAUDE.md, AGENT.md, etc.
```

### NPL Syntax Framework (`/npl/`)
Core language definitions organized by syntax element type:
- **Top-level specs**: `agent.md`, `syntax.md`, `directive.md`, `fences.md`, `formatting.md`, `instructing.md`, `planning.md`, `prefix.md`, `pumps.md`, `special-section.md`
- **Subdirectories**: Each spec has a corresponding directory with individual element definitions (emoji-keyed for directives/prefixes)

### Core Components (`/core/`)
```
core/
├── agents/                 # 20+ core NPL agents
├── additional-agents/      # 25+ agents by category (marketing, QA, infrastructure, UX, research, PM)
├── commands/               # Slash command definitions (init-project, update-arch, etc.)
├── scripts/                # CLI utilities (npl-load, dump-files, git-tree, npl-persona, npl-fim-config)
├── prompts/                # Reusable prompt snippets
├── schema/                 # SQL schemas (nimps.sql, nb.sql)
└── specifications/         # Document specs (prd-spec, project-arch-spec, project-layout-spec)
```

### MCP Server (`/mcp-server/`)
FastMCP-based Python package with 23 runtime tools:
```
mcp-server/
├── src/npl_mcp/
│   ├── server.py           # Main entry (23 MCP tools)
│   ├── artifacts/          # Artifact versioning + reviews
│   ├── chat/               # Chat rooms, events, notifications
│   ├── storage/            # Async SQLite + schema
│   └── scripts/            # CLI wrappers
├── tests/                  # Core + extended test suites
├── pyproject.toml          # Package config
└── README.md
```

### Documentation (`/docs/`)
- **Agent docs**: Core and additional agent documentation (mirrors `/core/` structure)
- **Scripts**: CLI script usage guides
- **Orchestration**: `multi-agent-orchestration.md`, `orchestration-examples.md`
- **Syntax index**: `npl-syntax-elements.yaml`

### Demonstrations (`/demo/`)
- **npl-fim**: Fill-in-the-middle examples (4 projects: cosmic-collector, rainy-day-ice-cream, set-theory, space-shooter)
- **persona-coordination**: Multi-persona workflows (consolidated feedback, cross-commentary, revised outputs)
- **react-by-fim**: React component generation
- **pending**: Planned demonstrations

### Metadata (`/meta/`)
FIM solution inventory with 150+ visualization tools organized by use-case categories (data-viz, 3D graphics, etc.)

## Configuration & Parameters

| File | Purpose | Location |
|------|---------|----------|
| `CLAUDE.md` | Claude Code project instructions | Root |
| `AGENT.md` | Master agent prompt with NPL load directive | Root |
| `.envrc` | direnv configuration (version exports, PATH) | Root |
| `mcp-server/pyproject.toml` | Python package config for npl-mcp | mcp-server/ |
| `installer/pyproject.toml` | Python package config for npl-installer | installer/ |
| `.aider.conf.yml` | Aider AI coding assistant config | Root |

## Integration Points

- **Upstream dependencies**: Git repository structure, direnv environment setup
- **Downstream consumers**: Claude Code navigation, agent path resolution, documentation builds, MCP server initialization
- **Related utilities**: `npl-load` (resource loading), `git-tree` (directory visualization), `dump-files` (file extraction)

## Organizational Principles

- **Separation of concerns**: Definitions (`/npl/`) vs. implementation (`/mcp-server/`) vs. documentation (`/docs/`)
- **Emoji-keyed organization**: Directives, prefixes, and pumps use emoji-based file/directory naming
- **Agent categorization**: Core agents in `/core/agents/`, domain-specific in `/core/additional-agents/`
- **Template-driven setup**: `/skeleton/` provides project initialization templates
- **Metadata-driven FIM**: 150+ visualization tools indexed in `/meta/fim/` with solution-to-use-case mappings

## Statistics

- **Directories**: 107
- **Files**: 555
- **Core Agents**: 20+
- **Additional Agents**: 25+ (across 6 categories)
- **FIM Solutions**: 150+
- **MCP Tools**: 23

## Key File Types

| Extension | Purpose | Primary Locations |
|-----------|---------|-------------------|
| `.md` | NPL definitions, agents, documentation | Throughout (npl/, core/, docs/) |
| `.py` | MCP server implementation | mcp-server/src/ |
| `.sql` | Database schemas | core/schema/, mcp-server/ |
| `.html` | Demo outputs | demo/ |
| `.svg` | Generated visualizations | demo/ |

## Limitations & Constraints

- Document predates `/worktrees/` structure (seen in git status but not documented)
- Multiple `pyproject.toml` files require manual coordination (mcp-server, installer)
- Status of `/experimental/` directory unclear (active vs. deprecated)

## Success Indicators

- Clear path resolution for all NPL components
- Successful navigation to agents, scripts, commands by category
- Accurate file counts and statistics matching repository state
- Config files properly mapped to their functional roles
- MCP server structure accessible for development and debugging

---
**Generated from**: worktrees/main/docs/PROJECT-LAYOUT.md
