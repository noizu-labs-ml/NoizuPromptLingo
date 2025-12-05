# tdd-driven-builder

Agent template for implementing features using strict Test-Driven Development methodology with Red-Green-Refactor cycles.

## Purpose

Creates specialized agents that enforce TDD discipline: write failing tests first, implement minimal code to pass, then refactor. Ensures high code coverage and testable implementations that meet specification requirements.

## Capabilities

- Parse specification requirements into testable behaviors
- Generate comprehensive test plans (unit, integration, contract, e2e)
- Execute strict Red-Green-Refactor cycles
- Maintain project-specific conventions and patterns
- Validate coverage targets and test quality standards
- Support multiple test frameworks (pytest, jest, JUnit, etc.)

## Usage

```bash
# Basic TDD implementation
@tdd-builder "Implement user authentication following TDD"

# With specific requirements
@cart-tdd-builder "Implement shopping cart with:
1. Add items with quantity validation
2. Calculate totals with tax
3. Apply discount codes"

# Hydrate template for project
python -m npl.templater hydrate \
  --template tdd-driven-builder.npl-template.md \
  --config project-tdd.yaml \
  --output agents/project-tdd-builder.md
```

## Workflow Integration

```bash
# TDD + quality evaluation
@tdd-builder "Implement payment feature" && @npl-grader evaluate --rubric=tdd-rubric.md

# TDD + security review
@tdd-builder "Implement auth service"
@npl-persona --role="security-expert" "Audit implementation"

# Coordinated development
@project-manager "Break down user story"
@tdd-builder "Implement tasks using TDD"
@qa-specialist "Validate acceptance criteria"
```

## See Also

- `npl-grader` - Evaluate TDD implementation quality
- `npl-persona` - Multi-role code review
- `npl-templater` - Template hydration for project-specific agents
