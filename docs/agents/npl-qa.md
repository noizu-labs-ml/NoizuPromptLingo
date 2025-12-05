# npl-qa

Test case generation agent using equivalency partitioning methodology. Produces categorized test cases with visual organization and validation status indicators.

## Purpose

Transforms manual test planning into structured, repeatable test coverage analysis. Systematically identifies input classes, boundary conditions, and generates organized test cases across multiple categories.

## Capabilities

- Function/module analysis with equivalency partitioning
- Multi-category test generation (happy path, edge cases, security, performance, integration)
- Glyph-based visual categorization for quick identification
- Framework-aware output (pytest, Jest, etc.)
- Implementation status indicators (pass/fail expectations)

## Glyph System

| Glyph | Category | Description |
|-------|----------|-------------|
| `[green circle]` | Happy Path | Standard successful execution |
| `[red circle]` | Negative Case | Error conditions, invalid inputs |
| `[warning sign]` | Security | Security-focused scenarios |
| `[wrench]` | Performance | Performance and optimization |
| `[globe]` | E2E/Integration | End-to-end testing |

## Usage

```bash
# Generate test cases for a function
@npl-qa "Analyze the user authentication module and generate comprehensive test cases"

# API endpoint testing
@npl-qa "Generate test cases for the /users/{id}/profile endpoint"

# Component testing
@npl-qa "Create test cases for UserCard component with props: user, onEdit, onDelete"
```

**Example Output:**
```
1. [green circle] Valid User Profile Retrieval: GET /users/123/profile with valid JWT. [check]
   - Expected: 200 with complete user profile JSON

2. [red circle] Invalid User ID: GET /users/999999/profile. [check]
   - Expected: 404 with "User not found"

3. [warning sign] Authentication Required: GET /users/123/profile without JWT. [check]
   - Expected: 401 with authentication error
```

## Workflow Integration

```bash
# Complete QA workflow
@npl-qa "Generate test cases for payment processing"
@npl-grader "Evaluate test coverage completeness"
@npl-technical-writer "Document the testing strategy"

# Iterative refinement
@npl-qa "Generate initial tests" > @npl-thinker "Analyze effectiveness" > @npl-qa "Refine based on feedback"
```

## See Also

- `@npl-grader` - Evaluate test coverage and quality
- `@npl-technical-writer` - Document testing approach
- `@npl-thinker` - Analyze test effectiveness
