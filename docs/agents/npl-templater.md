# npl-templater

Template creation and hydration agent with progressive complexity tiers and project-aware generation.

## Purpose

Converts files into reusable NPL templates and hydrates templates with project-specific values. Detects technology stacks, applies placeholders, and coordinates multi-file generation.

## Capabilities

- Create templates from existing files with dynamic placeholders
- Hydrate templates using detected project context (framework, database, auth)
- Four complexity tiers: zero-config, simple, smart, advanced
- Multi-template orchestration for project scaffolding
- Validate template syntax in sandbox environments
- Community marketplace for template discovery and sharing

## Commands

| Command | Description |
|:--------|:------------|
| `quick-start` | Auto-detect project and suggest templates |
| `create --from={file}` | Generate template from file |
| `apply {template} --smart-fill` | Hydrate template with detected values |
| `analyze {path}` | Examine files for templatization |
| `validate {template}` | Check syntax and test rendering |
| `orchestrate {suite}` | Coordinate multi-template generation |
| `gallery` | Browse template marketplace |
| `publish {template}` | Share to community |

See [Commands Reference](./npl-templater.detailed.md#commands-reference) for full options.

## Template Tiers

| Tier | Syntax | Use Case |
|:-----|:-------|:---------|
| 0 | `{auto-detect}` | Zero-config, full automation |
| 1 | `{name}`, `{date\|today}` | Simple placeholders |
| 2 | `{{#if}}`, `{{#each}}` | Conditional logic |
| 3 | `🧱`, NPL directives | Full NPL templates |

See [Template Tiers](./npl-templater.detailed.md#template-tiers) for syntax details.

## Usage

```bash
# Quick start with auto-detection
@templater quick-start

# Create template from existing file
@templater create --from=config.yml --tier=2

# Hydrate template for current project
@templater apply react-app.npl --smart-fill

# Batch generate configs
@templater orchestrate frontend:react backend:django infra:docker
```

## Integration

```bash
# Create then validate
@templater create --from=config.yml && @grader validate template.npl

# Analyze then generate
@thinker "Review my template structure" && @templater "Refactor based on analysis"

# Parallel generation
@templater orchestrate frontend:react backend:django infra:docker --parallel
```

## Configuration

| Flag | Values | Default |
|:-----|:-------|:--------|
| `--tier` | 0-3 | auto-detect |
| `--mode` | visual, cli, api | cli |
| `--marketplace` | official, community, private | official |

See [Configuration](./npl-templater.detailed.md#configuration) for all options.

## See Also

- **Detailed reference**: [npl-templater.detailed.md](./npl-templater.detailed.md)
  - [Template Syntax](./npl-templater.detailed.md#template-syntax) - Placeholders, control structures, directives
  - [Intelligence Layer](./npl-templater.detailed.md#intelligence-layer) - Pattern recognition and smart fill
  - [Best Practices](./npl-templater.detailed.md#best-practices) - Design and usage guidelines
  - [Limitations](./npl-templater.detailed.md#limitations) - Scope and resource constraints
- **Agent definition**: `core/agents/npl-templater.md`
- **Template syntax**: `npl/fences/template.md`
- **Handlebars reference**: `npl/instructing/handlebars.md`
