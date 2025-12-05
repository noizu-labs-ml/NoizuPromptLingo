# npl-templater

Template creation and hydration agent with progressive complexity tiers and project-aware generation.

## Purpose

Converts concrete files into reusable NPL templates and hydrates templates with project-specific values. Detects technology stacks, applies appropriate placeholders, and coordinates multi-file generation.

## Capabilities

- Create templates from existing files with dynamic placeholders
- Hydrate templates using detected project context (framework, database, auth)
- Four complexity tiers: zero-config, simple, smart, advanced
- Coordinate multi-template orchestration for project scaffolding
- Validate template syntax and test in sandbox environments

## Usage

```bash
# Create template from existing file
@templater create --from={file}

# Quick start with auto-detection
@templater quick-start

# Hydrate template for current project
@templater apply {template} --smart-fill

# Batch generate configs
@templater orchestrate {suite} --coordinate
```

## Template Tiers

| Tier | Syntax | Use Case |
|------|--------|----------|
| 0 | `{auto-detect}` | Zero-config, full auto |
| 1 | `{name}`, `{date\|today}` | Simple placeholders |
| 2 | `{{#if}}`, `{{#each}}` | Conditional logic |
| 3 | `⌜🧱⌝`, `⟪📊:⟫` | Full NPL directives |

## Workflow Integration

```bash
# Create then validate
@templater create --from=config.yml && @grader validate template.npl

# Analyze then generate
@thinker "Review my template structure" && @templater "Refactor based on analysis"

# Parallel generation
@templater orchestrate frontend:react backend:django infra:docker
```

## See Also

- Core definition: `core/agents/npl-templater.md`
- Template syntax: `npl/fences/template.md`
- Named templates: `npl/special-sections/named-template.md`
