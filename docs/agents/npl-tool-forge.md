# npl-tool-forge

NPL template for generating agents that create CLI tools, utility scripts, and MCP-compatible development tools.

## Purpose

Creates specialized agents that design, implement, and deploy development tooling. Each generated agent targets a specific technology stack (Python/Click, Node/Commander.js, Go/Cobra) and produces tested, documented tools with proper error handling.

## Capabilities

- CLI tool generation with argument parsing and help systems
- MCP-compatible tool creation for agent capability extension
- Utility script and automation development
- Multi-language support (Python, JavaScript, Go, Rust)
- Docker/Kubernetes deployment configuration
- Test suite and documentation generation

## Usage

```bash
# Generate a tool forge agent for Python projects
@npl-templater "Create a tool-forge agent for Python CLI development"

# Use generated agent to build specific tools
@my-python-tool-forge "Create a CLI tool for database migration validation"

# DevOps automation tools
@npl-templater "Create a tool-forge agent for Kubernetes DevOps automation"
```

## Workflow Integration

```bash
# Chain: analyze -> create agent -> build tool -> validate -> document
@npl-templater "Create tool-forge for Python"
@my-tool-forge "Build migration validator CLI"
@npl-grader "Review generated CLI against best practices"
@npl-technical-writer "Document the migration validator"
```

## Template Variables

| Variable | Purpose |
|----------|---------|
| `primary_language` | Target language (Python, Go, JS) |
| `tool_types` | CLI, MCP server, utility script |
| `deployment_pattern` | Docker, Kubernetes, standalone |
| `cli_technologies` | Click, Typer, Cobra, Commander.js |

## See Also

- `@npl-templater` - Template hydration and agent generation
- `@npl-grader` - Code quality validation
- `@npl-technical-writer` - Documentation generation
