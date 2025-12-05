# PROJECT-LAYOUT: NoizuPromptLingo

Directory structure and file organization for the NPL prompt engineering framework.

---

## Root Structure

```
NoizuPromptLingo/
├── npl/                    # NPL syntax framework definitions
├── npl.md                  # Root NPL specification
├── core/                   # Core components (agents, scripts, commands)
├── mcp-server/             # Python MCP server package
├── docs/                   # Documentation
├── demo/                   # Usage examples and demonstrations
├── experimental/           # Experimental NPL features
├── meta/                   # Metadata resources (FIM solution inventory)
├── skeleton/               # Project template skeleton
├── installer/              # NPL installer (WIP)
├── setup/                  # Setup utilities
├── CLAUDE.md               # Claude Code project configuration
├── AGENT.md                # Master agent prompt
├── GEMINI.md               # Gemini LLM configuration
└── README.md               # Project overview
```

---

## Core Directories

### `/npl/` - NPL Syntax Framework
Core NPL language definitions and syntax specifications.

```
npl/
├── agent.md                # Agent declaration syntax
├── declarations.md         # Framework version boundaries
├── directive.md            # Specialized instruction patterns
├── directive/              # Individual directive definitions (emoji-keyed)
├── fences.md               # Special code section types
├── fences/                 # Fence type definitions
├── formatting.md           # Input/output shape instructions
├── formatting/             # Format-specific templates
├── instructing.md          # Behavior directing patterns
├── instructing/            # Instructing pattern details
├── planning.md             # Intuition pump overview
├── prefix.md               # Response mode indicators
├── prefix/                 # Prefix definitions (emoji-keyed)
├── pumps.md                # Reasoning pattern overview
├── pumps/                  # Individual pump definitions
├── special-section.md      # NPL/agent/tool declarations
├── special-section/        # Special section details
├── syntax.md               # Foundational syntax conventions
└── syntax/                 # Individual syntax element definitions
```

### `/core/` - Core Components
Agents, commands, scripts, and specifications.

```
core/
├── agents/                 # Core NPL agents (20+ definitions)
│   ├── npl-thinker.md
│   ├── npl-grader.md
│   ├── npl-fim.md
│   ├── npl-persona.md
│   └── ...
├── additional-agents/      # Extended agent library (25+ by category)
│   ├── marketing/
│   ├── quality-assurance/
│   ├── infrastructure/
│   ├── user-experience/
│   ├── research/
│   └── project-management/
├── commands/               # Slash command definitions
│   ├── init-project.md
│   ├── init-project-fast.md
│   ├── update-arch.md
│   └── update-layout.md
├── scripts/                # CLI utilities
│   ├── npl-load
│   ├── dump-files
│   ├── git-tree
│   ├── git-tree-depth
│   ├── npl-persona
│   └── npl-fim-config
├── prompts/                # Reusable prompt snippets
├── schema/                 # SQL schema definitions
│   ├── nimps.sql           # Project management schema
│   └── nb.sql              # Knowledge base schema
└── specifications/         # Document specifications
    ├── prd-spec.md
    ├── project-arch-spec.md
    └── project-layout-spec.md
```

### `/mcp-server/` - MCP Server Package
Python FastMCP server for runtime tooling.

```
mcp-server/
├── src/npl_mcp/
│   ├── server.py           # Main entry point (23 MCP tools)
│   ├── artifacts/
│   │   ├── manager.py      # Artifact versioning
│   │   └── reviews.py      # Review/annotation system
│   ├── chat/
│   │   └── rooms.py        # Chat rooms, events, notifications
│   ├── storage/
│   │   ├── db.py           # Async SQLite abstraction
│   │   └── schema.sql      # Database schema
│   └── scripts/
│       └── wrapper.py      # CLI script wrappers
├── tests/
│   ├── test_basic.py       # Core workflow tests
│   └── test_additional.py  # Extended tests
├── pyproject.toml          # Package configuration
└── README.md               # Server documentation
```

### `/docs/` - Documentation
Usage guides, agent documentation, and orchestration examples.

```
docs/
├── README.md               # Documentation index
├── agents/                 # Core agent documentation
├── additional-agents/      # Extended agent documentation
│   ├── marketing/
│   ├── quality-assurance/
│   ├── infrastructure/
│   ├── user-experience/
│   ├── research/
│   └── project-management/
├── scripts/                # CLI script documentation
├── multi-agent-orchestration.md
├── orchestration-examples.md
└── npl-syntax-elements.yaml
```

### `/demo/` - Examples and Demonstrations
Usage examples showcasing NPL capabilities.

```
demo/
├── npl-fim/                # Fill-in-the-middle examples
│   ├── cosmic-collector-game/
│   ├── rainy-day-ice-cream/
│   ├── set-theory-crash-course/
│   └── space-shooter-game/
├── persona-coordination/   # Multi-persona workflow example
│   ├── consolidated-feedback/
│   ├── cross-commentary/
│   └── revised/
├── react-by-fim/           # React generation example
└── pending/                # Planned demonstrations
```

### `/meta/` - Metadata Resources
FIM solution inventory with 150+ visualization tools.

```
meta/
└── fim/
    ├── INVENTORY.md        # Tool index
    ├── solution/           # Individual tool definitions
    │   ├── d3_js.md
    │   ├── three_js.md
    │   ├── mermaid.md
    │   └── ... (150+ tools)
    └── use-case/           # Use-case categories
        ├── data-visualization.md
        ├── 3d-graphics.md
        └── ...
```

---

## Configuration Files

| File | Purpose |
|:-----|:--------|
| `CLAUDE.md` | Claude Code project instructions |
| `AGENT.md` | Master agent prompt with NPL load directive |
| `.envrc` | direnv configuration (version exports, PATH) |
| `mcp-server/pyproject.toml` | Python package config for npl-mcp |
| `installer/pyproject.toml` | Python package config for npl-installer |
| `.aider.conf.yml` | Aider AI coding assistant config |

---

## Key File Types

| Extension | Purpose | Location |
|:----------|:--------|:---------|
| `.md` | NPL definitions, agents, docs | Throughout |
| `.py` | MCP server implementation | `mcp-server/src/` |
| `.sql` | Database schemas | `core/schema/`, `mcp-server/` |
| `.html` | Demo outputs | `demo/` |
| `.svg` | Generated visualizations | `demo/` |

---

## Statistics

- **Directories**: 107
- **Files**: 555
- **Core Agents**: 20+
- **Additional Agents**: 25+
- **FIM Solutions**: 150+
- **MCP Tools**: 23
