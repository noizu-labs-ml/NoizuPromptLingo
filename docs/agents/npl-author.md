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

See [Capabilities](npl-author.detailed.md#capabilities) for complete details.

## Commands

| Command | Purpose |
|:--------|:--------|
| `revise` | Enhance existing prompt with NPL patterns |
| `generate` | Create new NPL-compliant definition |
| `enhance` | Upgrade basic prompt with NPL syntax |

See [Commands](npl-author.detailed.md#commands) for options and examples.

## Usage

```bash
# Revise existing agent definition
@npl-author revise existing-agent.md --enhance-pumps

# Generate new service agent
@npl-author generate --type=service --name=data-processor --capabilities="csv,json,api"

# Enhance basic prompt with NPL patterns
@npl-author enhance basic-prompt.md --target-density=high
```

## Component Selection

| Prompt Type | Components |
|:------------|:-----------|
| Simple | `agent`, `syntax`, `fences` |
| Reasoning | `planning` + `pumps.*` |
| Template-heavy | `formatting` + `instructing.handlebars` |
| Specialized | `directive.*` as needed |

See [NPL Component Directory](npl-author.detailed.md#npl-component-directory) for complete reference with byte sizes.

## Workflow Integration

```bash
# Generate then validate with grader
@npl-author generate --type=agent --name=reviewer && @npl-grader evaluate reviewer.md

# Revise then template
@npl-author revise agent.md && @npl-templater extract agent.md

# Chain with writer for documentation
@npl-author generate --type=service --name=api-doc && @writer generate readme
```

See [Workflow Integration](npl-author.detailed.md#workflow-integration) for patterns.

## Inline Digests

For resource-constrained environments, use inline digest blocks instead of full component loading. Reduces token usage by ~89%.

See [Inline NPL Digests](npl-author.detailed.md#inline-npl-digests) for syntax and guidelines.

## See Also

- [Detailed Documentation](npl-author.detailed.md)
- Core definition: `core/agents/npl-author.md`
- NPL syntax reference: `npl/syntax.md`
