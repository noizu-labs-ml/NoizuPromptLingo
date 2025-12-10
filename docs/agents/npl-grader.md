# npl-grader

NPL validation and QA agent for syntax checking, edge testing, integration verification, and rubric-based scoring.

**Detailed reference**: [npl-grader.detailed.md](npl-grader.detailed.md)

## Purpose

Validates NPL syntax compliance, tests boundary conditions, and provides structured assessments with weighted scoring. Transforms subjective evaluation into repeatable, objective grades.

## Capabilities

| Capability | Description | Details |
|:-----------|:------------|:--------|
| Syntax validation | NPL compliance, Unicode, nesting | [Validation Types](npl-grader.detailed.md#validation-types) |
| Edge testing | Malformed input, deep nesting, large files | [Edge Case Testing](npl-grader.detailed.md#edge-case-testing) |
| Integration | Multi-component workflows, data handoffs | [Integration Verification](npl-grader.detailed.md#integration-verification) |
| Performance | Parsing time, memory, CPU usage | [Performance Benchmarking](npl-grader.detailed.md#performance-benchmarking) |
| Rubric scoring | Weighted criteria, custom rubrics | [NPL Pumps Integration](npl-grader.detailed.md#npl-pumps-integration) |

## Quick Start

```bash
# Validate syntax
@grader validate-syntax src/prompt.md --level=strict

# Full QA assessment
@grader qa-assessment project/ --qa-level=production

# Custom rubric
@grader evaluate src/ --rubric=security.md --focus=security

# Regression test
@grader regression-test current/ baseline/ --compare
```

See [Commands Reference](npl-grader.detailed.md#commands-reference) for all options.

## Configuration

| Option | Values |
|:-------|:-------|
| `--qa-level` | lenient, standard, strict, production |
| `--test-mode` | quick, standard, comprehensive, production |
| `--validate-syntax` | basic, standard, strict |

See [Configuration Options](npl-grader.detailed.md#configuration-options) for complete list.

## Integration

```bash
# Chain with writer
@writer generate readme > README.md && @grader evaluate README.md

# Parallel evaluation
@grader evaluate src/ --rubric=code-quality.md
@grader evaluate docs/ --rubric=documentation.md
```

See [Integration Patterns](npl-grader.detailed.md#integration-patterns) for CI/CD examples.

## See Also

- [Best Practices](npl-grader.detailed.md#best-practices)
- [Limitations](npl-grader.detailed.md#limitations)
- [Report Format](npl-grader.detailed.md#report-format)
- Core definition: `core/agents/npl-grader.md`
