# npl-qa

Test case generation agent using equivalency partitioning methodology. Produces categorized test cases with visual organization and validation status indicators.

**Detailed reference**: [npl-qa.detailed.md](npl-qa.detailed.md)

## Purpose

Transforms manual test planning into structured, repeatable test coverage analysis. Systematically identifies input classes, boundary conditions, and generates organized test cases across multiple categories.

## Capabilities

| Capability | Description | Details |
|:-----------|:------------|:--------|
| Equivalency partitioning | Groups inputs into valid/invalid classes | [Equivalency Partitioning](npl-qa.detailed.md#equivalency-partitioning) |
| Boundary analysis | Identifies edge values at partition boundaries | [Boundary Value Analysis](npl-qa.detailed.md#boundary-value-analysis) |
| Multi-category testing | Happy path, negative, security, perf, E2E | [Test Categories](npl-qa.detailed.md#test-categories) |
| Framework output | pytest, Jest, Mocha, RSpec, generic | [Output Formats](npl-qa.detailed.md#output-formats) |
| Visual categorization | Glyph-based quick identification | [Glyph System](npl-qa.detailed.md#glyph-system) |

## Glyph System

| Glyph | Category | Description |
|:------|:---------|:------------|
| `[green circle]` | Happy Path | Standard successful execution |
| `[red circle]` | Negative Case | Error conditions, invalid inputs |
| `[warning sign]` | Security | Security-focused scenarios |
| `[wrench]` | Performance | Performance and optimization |
| `[globe]` | E2E/Integration | End-to-end testing |

## Quick Start

```bash
# Generate test cases for a function
@npl-qa "Analyze the user authentication module and generate comprehensive test cases"

# API endpoint testing
@npl-qa "Generate test cases for the /users/{id}/profile endpoint"

# Component testing
@npl-qa "Create test cases for UserCard component with props: user, onEdit, onDelete"

# Framework-specific output
@npl-qa "Generate tests for login endpoint" --framework=pytest
```

See [Usage Examples](npl-qa.detailed.md#usage-examples) for complete output samples.

## Example Output

```
1. [green circle] Valid User Profile Retrieval: GET /users/123/profile with valid JWT. [check]
   - Expected: 200 with complete user profile JSON

2. [red circle] Invalid User ID: GET /users/999999/profile. [check]
   - Expected: 404 with "User not found"

3. [warning sign] Authentication Required: GET /users/123/profile without JWT. [check]
   - Expected: 401 with authentication error
```

## Integration

```bash
# Complete QA workflow
@npl-qa "Generate test cases for payment processing"
@npl-grader "Evaluate test coverage completeness"
@npl-technical-writer "Document the testing strategy"

# Iterative refinement
@npl-qa "Generate initial tests" > @npl-thinker "Analyze effectiveness" > @npl-qa "Refine based on feedback"
```

See [Integration Patterns](npl-qa.detailed.md#integration-patterns) for CI/CD examples.

## See Also

- [Best Practices](npl-qa.detailed.md#best-practices)
- [Limitations](npl-qa.detailed.md#limitations)
- [Commands Reference](npl-qa.detailed.md#commands-reference)
- `@npl-grader` - Evaluate test coverage and quality
- `@npl-technical-writer` - Document testing approach
- `@npl-thinker` - Analyze test effectiveness
