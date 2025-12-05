# npl-validator

NPL syntax and semantic validation specialist that ensures correctness of prompts, agent definitions, and workflows through comprehensive validation and actionable error reporting.

## Purpose

Prevents malformed NPL from reaching production through automated lexical, syntactic, and semantic validation. Provides immediate feedback with specific correction suggestions, maintaining NPL standard compliance across teams and versions.

## Capabilities

- Lexical analysis (Unicode symbols, encoding, structure)
- Syntax parsing (NPL elements, nesting, directives)
- Semantic analysis (references, flag scoping, template bindings)
- Edge case testing (boundaries, circular references, performance)
- Actionable error reporting with correction suggestions
- Custom validation rules for domain-specific requirements

## Usage

```bash
# Validate single file
@npl-validator validate prompt.md --version=1.0

# Validate directory
@npl-validator validate src/prompts/

# Strict validation with custom rules
@npl-validator validate agent-definition.md --strict --rules=.claude/validation-rules.yaml

# Auto-fix mode
@npl-validator validate src/prompts/ --fix --format=json

# CI/CD integration
@npl-validator validate . --format=junit-xml --baseline=main
```

## Workflow Integration

```bash
# Pre-commit validation
@npl-validator validate --changed-only --fix

# Comprehensive validation pipeline
@npl-validator validate src/ --mode=syntax
@npl-grader evaluate src/ --rubric=npl-quality.md
@npl-thinker analyze validation-report.json --focus=semantic-issues

# Template-driven validation
@npl-templater generate validation-rules --type=project-specific
@npl-validator validate . --rules=generated-rules.yaml
```

## See Also

- Core definition: `core/additional-agents/quality-assurance/npl-validator.md`
