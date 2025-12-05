# npl-author

Revises, improves, and generates NPL-compliant prompts and agent/service definitions using current NPL syntax patterns.

## Purpose

Creates and enhances prompts using NPL conventions for improved AI comprehension. Maps NPL component requirements, applies enhancement patterns, and validates compliance. Outputs production-ready agent definitions with proper loading directives.

## Capabilities

- Analyze existing prompts and identify NPL component requirements
- Generate new agent/service/persona definitions from specifications
- Apply semantic boundaries, attention anchors, and in-fill patterns
- Select appropriate `npl_load()` components based on complexity
- Create inline NPL digests for resource-constrained environments
- Validate NPL compliance and syntax density

## Usage

```bash
# Revise existing agent definition
@npl-author revise existing-agent.md --enhance-pumps

# Generate new service agent
@npl-author generate --type=service --name=data-processor --capabilities="csv,json,api"

# Enhance basic prompt with NPL patterns
@npl-author enhance basic-prompt.md --target-density=high
```

## Workflow Integration

```bash
# Generate then validate with grader
@npl-author generate --type=agent --name=reviewer && @npl-grader evaluate reviewer.md

# Revise then template
@npl-author revise agent.md && @npl-templater extract agent.md

# Chain with writer for documentation
@npl-author generate --type=service --name=api-doc && @writer generate readme
```

## See Also

- Core definition: `core/agents/npl-author.md`
- NPL syntax reference: `npl/syntax.md`
- Component directory: `core/agents/npl-author.md#npl-component-directory`
