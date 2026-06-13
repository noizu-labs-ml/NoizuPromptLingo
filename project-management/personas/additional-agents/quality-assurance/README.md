# Quality Assurance Agents

Agents focused on testing strategies, quality validation, performance benchmarking, and integration assurance.

## Agents

### npl-benchmarker
Establishes performance baselines, detects regressions, and optimizes critical paths. Maintains benchmarks across layers (API, database, frontend).

### npl-integrator
Conducts end-to-end integration testing, validates system workflows, and ensures component compatibility. Validates entire feature flows across systems.

### npl-tester
Designs test strategies, executes test suites, and maintains coverage metrics. Balances automation with exploratory testing approaches.

### npl-validator
Validates acceptance criteria compliance, conducts sign-off reviews, and verifies readiness for release. Acts as quality gate before production.

## Workflows

**Feature Testing Cycle**
1. npl-tester: Design test plan and write test cases
2. npl-integrator: Validate end-to-end workflows
3. npl-benchmarker: Performance validation and regression testing
4. npl-validator: Acceptance criteria verification and sign-off

**Performance Optimization**
1. npl-benchmarker: Identify performance bottlenecks
2. npl-tester: Verify fixes don't break functionality
3. npl-integrator: Validate fixes in integrated system
4. npl-validator: Confirm meets performance SLAs

## Integration Points

- **Upstream**: tdd-coder (implementation), tdd-tester (test design)
- **Downstream**: Release/production deployment
- **Cross-functional**: npl-code-reviewer (code quality), npl-prototyper (rapid testing)

## Key Responsibilities

| Agent | Primary | Secondary |
|-------|---------|-----------|
| **benchmarker** | Performance baselines, regression detection | Optimization, metrics tracking |
| **integrator** | End-to-end testing, workflow validation | System compatibility, data flows |
| **tester** | Test strategy, test execution, coverage | Exploratory testing, edge cases |
| **validator** | Acceptance criteria verification, sign-off | Release readiness, quality gates |

## Quality Gate Model

```
Implementation → Tester → Integrator → Benchmarker → Validator → Release
```

Each agent validates specific quality dimensions before passing to next stage.
