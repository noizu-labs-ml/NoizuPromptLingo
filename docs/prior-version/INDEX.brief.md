# Documentation Master Index

## Core Documentation

### Orchestration & Patterns
- **multi-agent-orchestration.md** - Five core orchestration patterns, available agents (25+), coordination best practices, pitfalls, metrics
- **orchestration-examples.md** - Five real-world examples: agent development, documentation overhaul, security assessment, tool ecosystem, knowledge base
- **npl-syntax-elements.yaml** - 155+ NPL syntax elements mapped to file locations, types, regex patterns, descriptions

### Architecture & Design
- **PROJECT-ARCH.md** - High-level system architecture overview
  - **PROJECT-ARCH/layers.md** - Architectural layers
  - **PROJECT-ARCH/domain.md** - Domain model definitions
  - **PROJECT-ARCH/infrastructure.md** - Infrastructure layer
  - **PROJECT-ARCH/patterns.md** - Design patterns used
- **PROJECT-LAYOUT.md** - Directory structure and file organization

### Agents (25+ defined)
- **agents/README.md** - Agent overview and quick reference
- **agents/npl-{name}.md** - Individual agent documentation
  - Core: npl-author, npl-thinker, npl-grader, npl-technical-writer, npl-gopher-scout
  - Development: npl-tdd-builder, npl-qa, npl-qa-tester, npl-fim, npl-templater
  - Infrastructure: npl-tool-forge, npl-prd-manager, npl-system-digest
  - Specialized: npl-threat-modeler, npl-persona, npl-marketing-writer
  - Project Mgmt: nimps
  - (See additional-agents/ for 20+ more specialized agents)
- **agents/{name}.detailed.md** - Extended documentation with examples

### Additional Specialized Agents (20+)
- **additional-agents/infrastructure/** - Build, code review, prototyping
- **additional-agents/marketing/** - Community, positioning, copy, conversion
- **additional-agents/project-management/** - Coordination, risk, impact, reality checking
- **additional-agents/quality-assurance/** - Testing, validation, benchmarking, integration
- **additional-agents/research/** - Performance, cognitive load, optimization, validation
- **additional-agents/user-experience/** - Accessibility, onboarding, performance, research

### FastMCP Framework
- **fastmcp/README.md** - FastMCP overview
- **fastmcp/01-installation.md** - Setup and installation
- **fastmcp/02-core-concepts.md** - Fundamental concepts
- **fastmcp/03-tools.md** - Tool definitions and usage
- **fastmcp/04-resources.md** - Resource management
- **fastmcp/05-prompts.md** - Prompt definitions
- **fastmcp/06-context.md** - Context management
- **fastmcp/07-client.md** - Client interface
- **fastmcp/08-deployment.md** - Deployment strategies
- **fastmcp/09-migration.md** - Migration guides
- **fastmcp/10-examples.md** - Practical examples

### Scripts & Tools
- **scripts/README.md** - Script overview
- **scripts/npl-load.md** - Resource loader with hierarchical path resolution
- **scripts/npl-persona.md** - Persona management system
- **scripts/npl-session.md** - Session and worklog management
- **scripts/npl-fim-config.md** - Visualization tool configuration
- **scripts/{other}.md** - dump-files, git-tree, git-tree-depth

### Prompts & Reference
- **prompts/npl.md** - NPL framework reference (conventions, syntax, directives)
- **prompts/npl_load.md** - NPL load directive specification
- **prompts/scripts.md** - NPL scripts reference (command syntax)
- **prompts/sql-lite.md** - SQLite usage guide

### Project Setup & Commands
- **commands/init-project.md** - Full project initialization
- **commands/init-project-fast.md** - Quick project initialization
- **commands/update-arch.md** - Architecture update procedures
- **commands/update-layout.md** - Layout update procedures
- (See .detailed.md variants for extended documentation)

### Summaries
- **summary.md** - Overview of all documentation

## Organization Structure

```
docs/
├── (core orchestration & architecture files)
├── agents/                      # 25+ primary agents
├── additional-agents/           # 20+ specialized agents
│   ├── infrastructure/
│   ├── marketing/
│   ├── project-management/
│   ├── quality-assurance/
│   ├── research/
│   └── user-experience/
├── fastmcp/                     # MCP framework documentation
├── scripts/                     # Tool and script reference
├── prompts/                     # Prompt and convention reference
├── commands/                    # Project setup and commands
├── PROJECT-ARCH/               # Architecture deep-dives
└── README.md
```

## Purpose By Section

| Section | Primary Use | Key Files |
|---------|-------------|-----------|
| **Orchestration** | Multi-agent coordination patterns | multi-agent-orchestration.md, orchestration-examples.md |
| **Agents** | Agent capabilities and usage | agents/README.md, agents/*.md |
| **Architecture** | System design and structure | PROJECT-ARCH.md, PROJECT-ARCH/* |
| **FastMCP** | MCP framework integration | fastmcp/02-core-concepts.md, fastmcp/03-tools.md |
| **Scripts** | Tool usage and command reference | scripts/npl-load.md, scripts/npl-session.md |
| **Project Setup** | Getting started and initialization | commands/init-project.md, PROJECT-LAYOUT.md |
| **Reference** | NPL conventions and syntax | prompts/npl.md, npl-syntax-elements.yaml |

## Quick Navigation

**Getting Started**:
1. Read PROJECT-LAYOUT.md (understand structure)
2. Read PROJECT-ARCH.md (understand design)
3. Read multi-agent-orchestration.md (understand workflows)

**Using Agents**:
1. agents/README.md (overview)
2. Find specific agent: agents/npl-{name}.md or agents/{name}.detailed.md
3. See orchestration-examples.md for usage patterns

**Setting Up NPL**:
1. commands/init-project.md or commands/init-project-fast.md
2. prompts/npl.md (conventions reference)
3. scripts/npl-load.md (resource loading)

**Working with Specialized Agents**:
1. Browse additional-agents/ by domain
2. Read desired agent's .md file
3. See orchestration-examples.md for integration patterns

**Extending or Troubleshooting**:
1. PROJECT-ARCH/patterns.md (design patterns)
2. fastmcp/09-migration.md (upgrade/migration)
3. fastmcp/10-examples.md (reference implementations)

## File Statistics

- **Total Documentation Files**: 150+
- **Agent Documentation**: 45+ agent files (25 primary + 20 specialized)
- **FastMCP Framework**: 11 core files + examples
- **Scripts & Tools**: 10+ script documentation files
- **Architecture Deep-Dives**: 5 detailed architecture files
- **Examples & Commands**: 8+ procedural documentation files
- **Syntax Reference**: Comprehensive YAML mapping (155+ elements)

