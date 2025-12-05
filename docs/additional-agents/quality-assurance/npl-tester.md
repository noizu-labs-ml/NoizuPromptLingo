# npl-tester

Comprehensive testing framework for NPL agents, prompts, and workflows that generates test suites, validates behavioral consistency, and supports continuous integration.

## Purpose

Transforms ad-hoc testing into systematic quality assurance through automated test generation, coverage analysis, and regression detection. Ensures agent reliability and behavioral consistency across scenarios.

## Capabilities

- Test suite generation for agents and prompts
- Behavioral consistency validation across scenarios
- Coverage analysis with gap identification
- Edge case and boundary condition testing
- Regression testing for prompt modifications
- CI/CD pipeline integration with quality gates

## Usage

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

## Workflow Integration

```bash
# Generate and execute tests
@npl-tester generate --agent="npl-grader" --output=test-suite.yaml && @npl-tester run --suite=test-suite.yaml

# Parallel test execution across agents
@npl-tester test --agent="npl-grader" --type="unit" &
@npl-tester test --agent="npl-templater" --type="unit" &
@npl-tester test --agent="npl-persona" --type="unit"

# Chain with grader for quality assessment
@npl-tester generate --output=test-suite.yaml && @npl-grader evaluate test-suite.yaml --rubric=test-quality.md
```

## See Also

- Core definition: `core/additional-agents/quality-assurance/npl-tester.md`
