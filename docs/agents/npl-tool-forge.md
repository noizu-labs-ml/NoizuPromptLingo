# npl-tool-forge

NPL template for generating agents that create CLI tools, utility scripts, and MCP-compatible development tools.

## Purpose

Creates specialized agents that design, implement, and deploy development tooling. Each generated agent targets a specific technology stack and produces tested, documented tools with proper error handling.

See [Detailed Reference](./npl-tool-forge.detailed.md) for complete documentation.

## Capabilities

- CLI tool generation with argument parsing and help systems ([details](./npl-tool-forge.detailed.md#cli-tool-generation))
- MCP-compatible tool creation for agent capability extension ([details](./npl-tool-forge.detailed.md#mcp-tool-creation))
- Utility script and automation development ([details](./npl-tool-forge.detailed.md#utility-script-development))
- Multi-language support: Python, JavaScript, Go, Rust ([details](./npl-tool-forge.detailed.md#technology-stacks))
- Docker/Kubernetes deployment configuration ([details](./npl-tool-forge.detailed.md#deployment-configuration))
- Test suite and documentation generation ([details](./npl-tool-forge.detailed.md#quality-standards))

## Usage

```bash
# Generate a tool-forge agent for Python projects
@npl-templater "Create a tool-forge agent for Python CLI development"

# Use generated agent to build specific tools
@my-python-tool-forge "Create a CLI tool for database migration validation"

# Create MCP-compatible tools
@python-tool-forge scaffold mcp

# Add deployment configuration
@go-tool-forge deploy-config docker --to=my-tool
```

See [Command Reference](./npl-tool-forge.detailed.md#command-reference) for all commands.

## Workflow Integration

```bash
# Chain: analyze -> create agent -> build tool -> validate -> document
@npl-templater "Create tool-forge for Python"
@my-tool-forge "Build migration validator CLI"
@npl-grader "Review generated CLI against best practices"
@npl-technical-writer "Document the migration validator"
```

See [Integration Patterns](./npl-tool-forge.detailed.md#integration-patterns) for more examples.

## Template Variables

| Variable | Purpose |
|:---------|:--------|
| `primary_language` | Target language (Python, Go, JS, Rust) |
| `tool_types` | CLI, MCP server, utility script |
| `deployment_pattern` | Docker, Kubernetes, standalone |
| `cli_framework` | Click, Typer, Cobra, Commander.js |

See [Template Variables](./npl-tool-forge.detailed.md#template-variables) for complete list.

## See Also

- [Detailed Reference](./npl-tool-forge.detailed.md) - Complete documentation
- [npl-templater](./npl-templater.md) - Template hydration and agent generation
- [npl-grader](./npl-grader.md) - Code quality validation
- [npl-technical-writer](./npl-technical-writer.md) - Documentation generation
