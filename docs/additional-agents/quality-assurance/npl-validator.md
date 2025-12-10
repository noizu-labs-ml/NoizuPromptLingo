# npl-validator

NPL syntax and semantic validation specialist. Validates prompts, agent definitions, and workflows through lexical, syntactic, and semantic analysis.

## Purpose

Prevents malformed NPL from reaching production. Provides actionable error reporting with correction suggestions.

## Capabilities

- Lexical analysis (Unicode, encoding, structure markers)
- Syntax parsing (declarations, nesting, directives, fences)
- Semantic analysis (references, flag scoping, template bindings)
- Auto-fix mode for correctable issues
- Custom validation rules via YAML configuration

See: [Validation Layers](./npl-validator.detailed.md#validation-layers)

## Usage

```bash
# Validate file
@npl-validator validate prompt.md --version=1.0

# Validate directory
@npl-validator validate src/prompts/

# Strict mode
@npl-validator validate agent.md --strict --rules=.claude/validation-rules.yaml

# Auto-fix
@npl-validator validate src/ --fix

# CI/CD
@npl-validator validate . --format=junit-xml --baseline=main
```

See: [CLI Options](./npl-validator.detailed.md#cli-options)

## Validation Modes

| Mode | Description |
|:-----|:------------|
| `lexical` | Token-level validation |
| `syntax` | Structure and grammar |
| `semantic` | References and logic |
| `all` | All layers (default) |

See: [Validation Modes](./npl-validator.detailed.md#validation-modes)

## Output Formats

| Format | Use Case |
|:-------|:---------|
| `console` | Terminal display (default) |
| `json` | Machine parsing |
| `junit-xml` | CI/CD pipelines |
| `sarif` | GitHub Code Scanning |

See: [Output Formats](./npl-validator.detailed.md#output-formats)

## Custom Rules

```yaml
# .claude/validation-rules.yaml
version: "1.0"
rules:
  required-sections:
    - Purpose
    - Usage
  forbidden-patterns:
    - pattern: "TODO"
      severity: warning
```

See: [Custom Validation Rules](./npl-validator.detailed.md#custom-validation-rules)

## Workflow Integration

```bash
# Pre-commit
@npl-validator validate --changed-only --fix

# Quality pipeline
@npl-validator validate src/ --mode=syntax && \
@npl-grader evaluate src/ --rubric=npl-quality.md
```

See: [CI/CD Integration](./npl-validator.detailed.md#cicd-integration)

## See Also

- [Detailed Reference](./npl-validator.detailed.md) - Full documentation
- [npl-tester](./npl-tester.md) - Test generation
- [npl-integrator](./npl-integrator.md) - Workflow testing
- [Quality Assurance Overview](./README.md) - Category docs
