# npl-grader

NPL validation and QA agent for syntax checking, edge testing, integration verification, and rubric-based scoring.

## Purpose

Validates NPL syntax compliance, tests boundary conditions, and provides structured assessments with weighted scoring. Transforms subjective evaluation into repeatable, objective grades.

## Capabilities

- Syntax validation (NPL compliance, Unicode symbols, nesting hierarchy)
- Edge case testing (malformed input, deep nesting, large files)
- Integration verification (multi-component workflows, data handoffs)
- Rubric-based scoring with weighted criteria
- Performance benchmarking (parsing time, memory, CPU usage)
- Custom rubric support for domain-specific evaluation

## Usage

```bash
# Validate NPL syntax
@grader validate-syntax src/prompt.md --level=production

# Comprehensive QA assessment
@grader qa-assessment project/ --qa-level=production

# Evaluate with custom rubric
@grader evaluate src/ --rubric=security.md --focus=security

# Compare against baseline
@grader regression-test current/ baseline/ --compare
```

## Workflow Integration

```bash
# Chain with writer for doc review
@writer generate readme > README.md && @grader evaluate README.md

# Parallel evaluation across directories
@grader evaluate src/ --rubric=code-quality.md
@grader evaluate test/ --rubric=test-coverage.md
@grader evaluate docs/ --rubric=documentation.md
```

## See Also

- Core definition: `core/agents/npl-grader.md`
