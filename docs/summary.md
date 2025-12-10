# NPL Project Summary

Quick-reference guide for agents and developers working with the Noizu PromptLingo (NPL) codebase.

## What is NPL?

NPL is an agentic framework for Claude Code that provides:
- **Structured prompting syntax** using Unicode markers for precise semantic communication
- **Pre-built AI agents** for specialized tasks (writing, grading, visualization, etc.)
- **Template system** for project-specific agent customization
- **Session management** for cross-agent communication and worklogs

## Repository Layout

```
npl/
├── core/                    # Framework core (agents, scripts, prompts)
│   ├── agents/              # 16+ core agent definitions (.md files)
│   ├── additional-agents/   # 30+ extended agents by category
│   ├── commands/            # Slash commands (/init-project-fast, /update-arch)
│   ├── scripts/             # CLI tools (npl-load, npl-persona, npl-session)
│   └── prompts/             # Prompt templates and conventions
├── npl/                     # NPL syntax reference documentation
│   ├── syntax/              # Syntax element definitions
│   ├── fences/              # Code fence types (example, syntax, artifact)
│   ├── pumps/               # Intuition pumps (cot, intent, reflection)
│   └── directive/           # Directive definitions
├── mcp-server/              # MCP server implementation
│   └── src/npl_mcp/         # Python package with tools, artifacts, chat
├── docs/                    # Technical documentation
│   ├── agents/              # Agent-specific docs
│   ├── scripts/             # Script usage docs
│   └── fastmcp/             # FastMCP integration docs
├── demo/                    # Examples and generated artifacts
├── experimental/            # Experimental features
├── meta/                    # Metadata (FIM tool configs)
└── skeleton/                # Project scaffolding templates
```

## Key Components

### Core Agents (`core/agents/`)

| Agent | Purpose |
|-------|---------|
| `npl-templater` | Template creation, hydration, progressive disclosure UI |
| `npl-grader` | NPL syntax validation, QA, edge testing |
| `npl-technical-writer` | Technical docs, specs, PRs (straight-to-point style) |
| `npl-marketing-writer` | Marketing content with persuasive language |
| `npl-persona` | AI persona development and simulation |
| `npl-thinker` | Multi-cognitive reasoning (CoT, reflection, mood) |
| `npl-fim` | Fill-in-middle visualization (SVG, Mermaid, D3, etc.) |
| `npl-gopher-scout` | Codebase reconnaissance and analysis |
| `npl-threat-modeler` | Security analysis (STRIDE methodology) |
| `npl-author` | NPL prompt/agent definition authoring |

### Utility Scripts (`core/scripts/`)

| Script | Purpose |
|--------|---------|
| `npl-load` | Resource loader with hierarchical path resolution |
| `npl-persona` | Persona lifecycle, journals, tasks, knowledge bases |
| `npl-session` | Session/worklog management for cross-agent communication |
| `npl-fim-config` | FIM visualization tool-task compatibility queries |
| `git-tree` | Directory structure visualization |
| `dump-files` | Git-aware file content extraction |

### MCP Server (`mcp-server/`)

Provides MCP tools for Claude Code integration:
- **Script wrappers**: `dump_files`, `git_tree`, `npl_load`
- **Artifact management**: Version-controlled artifacts with revisions
- **Review system**: Inline comments and image overlay annotations
- **Chat system**: Multi-persona collaboration with @mentions

## NPL Syntax Quick Reference

### Boundary Markers
- `⌜agent-name|type|version⌝ ... ⌞agent-name⌟` - Agent definition
- `⌜🏳️ ... ⌟` - Runtime flags
- `⌜🔒 ... ⌟` - Secure (highest-precedence) prompt sections

### Syntax Elements
- `` `term` `` - Highlight key concepts
- `🎯 instruction` - High-priority directive
- `<term>`, `{term}` - Placeholder
- `[...]`, `[...|qualifier]` - Fill-in / in-paint for text
- `...`, `etc.` - Infer additional entries

### Common Fences
- `example`, `syntax`, `format` - Input/output specifications
- `diagram` - Mermaid, graphviz, plantuml
- `artifact` - Structured output with metadata
- `alg`, `alg-pseudo` - Algorithm specification

### Intuition Pumps
- `<npl-intent>` - Clarify goals before acting
- `<npl-cot>` - Chain-of-thought reasoning
- `<npl-reflection>` - Evaluate output quality
- `<npl-critique>` - Critical analysis
- `<npl-panel>` - Multi-perspective discussion

## Configuration

### CLAUDE.md Integration

Projects using NPL should have a `CLAUDE.md` with:
```markdown
npl-instructions:
   name: npl-conventions
   version: 1.4.0
---
```🏳️
@command-and-control="task-master"
@work-log="standard"
@track-work=true
```
```

### Command-and-Control Modes

| Mode | Behavior |
|------|----------|
| `lone-wolf` | Work independently; sub-agents only when requested |
| `team-member` | Suggest sub-agents for complex tasks |
| `task-master` | Aggressively parallelize work to sub-agents |

## Common Workflows

### Project Setup
```bash
/init-project-fast    # Initialize CLAUDE.md
/update-arch          # Generate PROJECT-ARCH.md and PROJECT-LAYOUT.md
```

### Agent Invocation
```bash
@npl-technical-writer generate spec --component=auth
@npl-grader validate agent.md --syntax-check
@npl-gopher-scout explore "authentication flow"
```

### Session Management
```bash
npl-session init --task="Implement feature"
npl-session log --agent=explore-001 --action=found --summary="auth.ts"
npl-session read --agent=primary
```

## Documentation Deep-Dives

| Topic | Location |
|-------|----------|
| Full NPL syntax | `npl.md`, `npl/` subdirectories |
| Agent definitions | `core/agents/*.md` |
| Multi-agent orchestration | `docs/multi-agent-orchestration.md` |
| FastMCP integration | `docs/fastmcp/` |
| FIM tool compatibility | `meta/fim/` |

## Development Notes

- **Agent registration**: Place `.md` files in `~/.claude/agents/` or symlink from `core/agents/`
- **Slash commands**: Symlink `core/commands/` to `~/.claude/commands/`
- **Scripts**: Add `core/scripts/` to PATH
- **MCP server**: Install with `uv pip install -e .` in `mcp-server/`

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `NPL_HOME` | Base path for NPL definitions |
| `NPL_META` | Metadata files location |
| `NPL_STYLE_GUIDE` | Style conventions path |
| `NPL_MCP_DATA_DIR` | MCP server data directory |
