# npl-prototyper Detailed Documentation

## Overview

`npl-prototyper` is an infrastructure agent for rapid project scaffolding and code generation. It bridges YAML-based workflow definitions with NPL template systems, enabling reproducible project creation with performance measurement capabilities.

The agent evolved from the `gpt-pro` virtual tool pattern, adding Claude Code integration for native file operations and git workflows.

## Capabilities

### YAML Workflow Orchestration

Defines multi-step generation pipelines in declarative YAML:

```yaml
# api-spec.yaml
workflow:
  name: user-service-api
  version: 1.0.0

steps:
  - id: scaffold
    template: django-api
    params:
      name: user-service
      database: postgres

  - id: models
    template: django-models
    depends_on: scaffold
    params:
      entities:
        - name: User
          fields: [id, email, created_at]
        - name: Profile
          fields: [user_id, bio, avatar_url]

  - id: endpoints
    template: rest-endpoints
    depends_on: models
    params:
      resources: [users, profiles]
      methods: [GET, POST, PUT, DELETE]

output:
  directory: ./generated/
  overwrite: false
```

### Template-Based Generation

Generates code from NPL-annotated templates with handlebar syntax:

```template
# {{project.name}}/models.py

{{foreach entity in entities}}
class {{entity.name}}(models.Model):
    {{foreach field in entity.fields}}
    {{field.name}} = models.{{field.type|infer_django_field}}()
    {{/foreach}}

    class Meta:
        db_table = '{{entity.name|lowercase}}'
{{/foreach}}
```

Templates support:
- Handlebar control structures (`{{if}}`, `{{foreach}}`, `{{with}}`)
- NPL qualifiers for transformation (`|lowercase`, `|pluralize`, `|infer_type`)
- Nested template inclusion via `{{> partial_name}}`
- Conditional blocks based on config flags

### Performance Measurement

Quantifies generation improvements with before/after comparisons:

```bash
@npl-prototyper measure --baseline="manual_impl/" --optimized="npl_impl/" --report="metrics.md"
```

Metrics collected:
- Lines of code generated
- Time to scaffold
- Template reuse percentage
- Consistency score (deviation from conventions)

Reports 15-30% improvement on complex reasoning tasks when using structured NPL patterns versus ad-hoc generation.

### Claude Code Integration

Native file system operations without shell indirection:
- Direct file read/write through Claude Code tools
- Git operations for commit scaffolding
- Path resolution respecting `$NPL_HOME` hierarchy

### Progressive Disclosure

Complexity scales with user needs:

| Level | Features | Example |
|:------|:---------|:--------|
| Simple | Single template, defaults | `@npl-prototyper create django-api` |
| Standard | Config file, multiple templates | `--config="spec.yaml"` |
| Advanced | Custom templates, measurements | `--template-dir="./custom/"` |

### Error Recovery

Validation with actionable messages:

```
ERROR: Template 'django-api' requires param 'database'
  Available options: postgres, mysql, sqlite
  Add: --database=postgres
  Or define in config: params.database: postgres
```

## Commands

### create

Scaffold a project from a built-in template:

```bash
@npl-prototyper create <template> --name="<project-name>" [options]
```

**Arguments:**
- `<template>`: Template identifier (e.g., `django-api`, `fastapi`, `microservice`)
- `--name`: Project name (required)
- `--output`: Output directory (default: `./<name>/`)
- `--force`: Overwrite existing files

**Example:**
```bash
@npl-prototyper create django-api --name="user-service" --output="./services/"
```

### prototype

Execute a YAML workflow specification:

```bash
@npl-prototyper prototype --config="<spec.yaml>" [options]
```

**Arguments:**
- `--config`: Path to YAML workflow file (required)
- `--output`: Override output directory
- `--dry-run`: Validate without generating files
- `--step`: Execute single step by ID

**Example:**
```bash
@npl-prototyper prototype --config="api-spec.yaml" --dry-run
```

### generate

Template-based generation with optimization flags:

```bash
@npl-prototyper generate --template="<name>" [options]
```

**Arguments:**
- `--template`: Template name or path
- `--optimize`: Optimization target (`performance`, `readability`, `size`)
- `--measure`: Emit performance metrics
- `--params`: JSON string of template parameters

**Example:**
```bash
@npl-prototyper generate --template="microservice" --optimize="performance" --measure
```

### measure

Compare implementations for performance metrics:

```bash
@npl-prototyper measure --baseline="<path>" --optimized="<path>" [options]
```

**Arguments:**
- `--baseline`: Path to baseline implementation
- `--optimized`: Path to optimized implementation
- `--report`: Output report path (default: stdout)
- `--format`: Report format (`md`, `json`, `yaml`)

**Example:**
```bash
@npl-prototyper measure --baseline="v1/" --optimized="v2/" --report="comparison.md"
```

## Integration Patterns

### Pipeline with Build Manager

Chain generation into build optimization:

```bash
@npl-prototyper generate --template="api" | @npl-build-manager optimize
```

### Code Review Integration

Generate then analyze for quality:

```bash
@npl-prototyper create --spec="requirements.md" | @npl-code-reviewer analyze
```

### CI/CD Scaffolding

Generate deployment configurations:

```bash
@npl-prototyper prototype --config="infra.yaml" --output=".github/workflows/"
```

### Multi-Agent Workflow

Combine with exploration and planning agents:

```bash
@explore analyze ./legacy-api/
@npl-prototyper create --from-analysis="./npl/sessions/current/explore.summary.md"
```

## Configuration

### Template Locations

Templates resolve in order:
1. `--template-dir` flag
2. `./.npl/templates/`
3. `$NPL_HOME/templates/`
4. Built-in templates

### YAML Schema

```yaml
workflow:
  name: string          # Workflow identifier
  version: string       # Semantic version
  description: string   # Optional description

params:                 # Global parameters
  key: value

steps:
  - id: string          # Step identifier
    template: string    # Template name
    depends_on: string|list  # Dependencies
    params:             # Step-specific parameters
      key: value
    condition: string   # Optional conditional expression

output:
  directory: string     # Output path
  overwrite: boolean    # Allow overwrites
  format: string        # Post-processing format
```

### Environment Variables

| Variable | Purpose | Default |
|:---------|:--------|:--------|
| `NPL_TEMPLATE_DIR` | Custom template path | `$NPL_HOME/templates/` |
| `NPL_PROTOTYPER_CACHE` | Generation cache location | `./.npl/cache/prototyper/` |
| `NPL_PROTOTYPER_METRICS` | Metrics output path | `./metrics/` |

## Template Authoring

### Basic Structure

```
templates/
  my-template/
    template.yaml       # Template metadata
    files/              # Template files with placeholders
      {{name}}/
        main.py
        config.yaml
```

### Metadata Schema

```yaml
# template.yaml
name: my-template
version: 1.0.0
description: Project template for X

params:
  - name: project_name
    type: string
    required: true

  - name: database
    type: enum
    values: [postgres, mysql, sqlite]
    default: sqlite

files:
  - pattern: "**/*.py"
    processor: python
  - pattern: "**/*.yaml"
    processor: yaml
```

### Processor Types

| Processor | Behavior |
|:----------|:---------|
| `python` | Handlebar expansion, import sorting |
| `yaml` | Handlebar expansion, schema validation |
| `json` | Handlebar expansion, JSON formatting |
| `raw` | Copy without processing |

## Best Practices

### Template Design

- Keep templates focused on single concerns
- Use NPL qualifiers for transformations rather than complex logic
- Document required and optional parameters
- Provide sensible defaults

### Workflow Organization

- Group related steps with clear `depends_on` chains
- Use conditions sparingly; prefer separate workflows for variants
- Version workflows alongside code

### Performance

- Enable `--measure` during development to track improvements
- Use `--dry-run` to validate before generation
- Cache templates locally for repeated use

## Limitations

- Templates require handlebar-compatible syntax
- YAML workflows do not support loops; use step repetition
- Performance measurement requires comparable directory structures
- No rollback mechanism; use git for recovery

## Error Reference

| Error | Cause | Resolution |
|:------|:------|:-----------|
| `TEMPLATE_NOT_FOUND` | Template path invalid | Check `--template-dir` or `$NPL_TEMPLATE_DIR` |
| `MISSING_PARAM` | Required parameter absent | Add parameter to command or config |
| `CYCLE_DETECTED` | Circular `depends_on` | Review step dependencies |
| `OUTPUT_EXISTS` | Target file exists | Use `--force` or change output path |

## See Also

- NPL Template System: `${NPL_HOME}/npl/formatting/template.md`
- Handlebar Syntax: `${NPL_HOME}/npl/instructing/handlebars.md`
- Build Manager: `docs/additional-agents/infrastructure/npl-build-manager.md`
- Code Reviewer: `docs/additional-agents/infrastructure/npl-code-reviewer.md`
