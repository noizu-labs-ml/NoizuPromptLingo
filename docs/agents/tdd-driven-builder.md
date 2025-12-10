# tdd-driven-builder

Agent template for implementing features using strict Test-Driven Development methodology with Red-Green-Refactor cycles.

**Detailed reference**: [tdd-driven-builder.detailed.md](tdd-driven-builder.detailed.md)

## Purpose

Enforces TDD discipline: write failing tests first, implement minimal code to pass, then refactor. Produces high-coverage, testable implementations that meet specification requirements.

## Capabilities

| Capability | Description | Details |
|:-----------|:------------|:--------|
| Spec parsing | Extract testable behaviors from requirements | [TDD Methodology](tdd-driven-builder.detailed.md#tdd-methodology) |
| Test planning | Generate unit, integration, contract, e2e plans | [Test Strategy](tdd-driven-builder.detailed.md#test-strategy) |
| Red-Green-Refactor | Execute strict TDD cycles | [Development Workflow](tdd-driven-builder.detailed.md#development-workflow) |
| Convention detection | Follow project-specific patterns | [Integration Patterns](tdd-driven-builder.detailed.md#integration-patterns) |
| Coverage validation | Verify >90% coverage targets | [Quality Metrics](tdd-driven-builder.detailed.md#quality-metrics) |

## Quick Start

```bash
# Plan phase: analyze specification
@tdd-builder plan "User authentication" --framework=pytest

# Red phase: write failing test
@tdd-builder red "Validate credentials"

# Green phase: minimal implementation
@tdd-builder green "Validate credentials"

# Refactor phase: improve structure
@tdd-builder refactor "Validate credentials"

# Validate: check coverage and conventions
@tdd-builder validate "User authentication"
```

See [Commands Reference](tdd-driven-builder.detailed.md#commands-reference) for all options.

## Template Hydration

```bash
python -m npl.templater hydrate \
  --template skeleton/agents/npl-tdd-builder.npl-template.md \
  --config project-tdd.yaml \
  --output agents/my-tdd-builder.md
```

See [Template Hydration](tdd-driven-builder.detailed.md#template-hydration) for configuration.

## Integration

```bash
# With test planning
@npl-qa-tester generate test-plan spec.md
@tdd-builder implement spec.md --test-plan=test-plan.md

# With quality validation
@tdd-builder "Implement feature" && @npl-grader evaluate --rubric=tdd-rubric.md

# With security review
@tdd-builder "Implement auth"
@npl-persona --role="security-expert" "Audit implementation"
```

See [Agent Collaboration](tdd-driven-builder.detailed.md#agent-collaboration) for patterns.

## See Also

- [Best Practices](tdd-driven-builder.detailed.md#best-practices)
- [Limitations](tdd-driven-builder.detailed.md#limitations)
- [Usage Examples](tdd-driven-builder.detailed.md#usage-examples)
- Source template: `skeleton/agents/npl-tdd-builder.npl-template.md`
