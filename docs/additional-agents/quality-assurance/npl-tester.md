# npl-tester

Comprehensive testing framework for NPL agents, prompts, and workflows.

## Purpose

Transforms ad-hoc testing into systematic quality assurance through automated test generation, coverage analysis, and regression detection.

## Capabilities

- Test suite generation for agents and prompts
- Behavioral consistency validation across scenarios
- Coverage analysis with gap identification
- Edge case and boundary condition testing
- Regression testing for prompt modifications
- CI/CD pipeline integration with quality gates

## Quick Reference

```bash
# Generate comprehensive test suite
@npl-tester generate --agent="npl-technical-writer" --coverage="comprehensive"

# Run test suite
@npl-tester run --suite="tests/agent-behaviors.yaml"

# Validate NPL syntax
@npl-tester validate-syntax --directory="npl/pumps"

# Regression testing
@npl-tester regression --baseline="v1.0" --current="v1.1"

# Performance testing
@npl-tester performance --agent="npl-grader" --concurrent-requests=10 --duration="5m"

# CI/CD integration
@npl-tester ci-test --config=.claude/test-config.yaml --fail-threshold=95
```

## Test Types

| Type | Description | See |
|:-----|:------------|:----|
| Unit | Individual agent behavior validation | [Test Types](./npl-tester.detailed.md#test-types) |
| Integration | Multi-agent workflow testing | [Test Types](./npl-tester.detailed.md#test-types) |
| Regression | Version-to-version comparison | [Test Types](./npl-tester.detailed.md#test-types) |
| Performance | Load and stress testing | [Test Types](./npl-tester.detailed.md#test-types) |
| Syntax | NPL prompt structure validation | [Test Types](./npl-tester.detailed.md#test-types) |

## Configuration

| Parameter | Description |
|:----------|:------------|
| `--coverage` | `minimal`, `standard`, `comprehensive` |
| `--parallel` | Number of concurrent test workers |
| `--format` | `text`, `json`, `junit-xml`, `html` |
| `--timeout` | Max time per test case |

Full configuration reference: [Configuration Reference](./npl-tester.detailed.md#configuration-reference)

## Workflow Examples

```bash
# Generate and execute tests
@npl-tester generate --agent="npl-grader" --output=test-suite.yaml && \
@npl-tester run --suite=test-suite.yaml

# Parallel test execution across agents
@npl-tester test --agent="npl-grader" --type="unit" &
@npl-tester test --agent="npl-templater" --type="unit" &
@npl-tester test --agent="npl-persona" --type="unit"

# Chain with grader for quality assessment
@npl-tester generate --output=test-suite.yaml && \
@npl-grader evaluate test-suite.yaml --rubric=test-quality.md
```

## Detailed Documentation

- [Architecture](./npl-tester.detailed.md#architecture) - Testing pipeline design
- [Test Generation](./npl-tester.detailed.md#test-generation) - Systematic test case creation
- [Coverage Analysis](./npl-tester.detailed.md#coverage-analysis) - Gap identification and metrics
- [NPL Pump Integration](./npl-tester.detailed.md#npl-pump-integration) - Intent, critique, reflection usage
- [Test Data Management](./npl-tester.detailed.md#test-data-management) - Fixtures and mocks
- [Output Formats](./npl-tester.detailed.md#output-formats) - Report structures
- [Execution Strategies](./npl-tester.detailed.md#execution-strategies) - Parallel and progressive testing
- [CI/CD Integration](./npl-tester.detailed.md#cicd-integration) - Quality gates and automation
- [Best Practices](./npl-tester.detailed.md#best-practices) - Testing patterns and priorities

## See Also

- Core definition: `core/additional-agents/quality-assurance/npl-tester.md`
- [npl-benchmarker](./npl-benchmarker.md) - Performance testing
- [npl-integrator](./npl-integrator.md) - CI/CD pipelines
- [npl-validator](./npl-validator.md) - Schema validation
