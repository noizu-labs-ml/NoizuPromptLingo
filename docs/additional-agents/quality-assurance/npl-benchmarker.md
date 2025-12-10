# npl-benchmarker

Performance and reliability testing specialist that ensures NPL agents meet production-ready performance standards through systematic benchmarking and regression detection.

## Purpose

Transforms ad-hoc performance testing into reproducible, data-driven benchmarking processes. Establishes performance baselines, detects regressions, identifies bottlenecks, and provides optimization recommendations with SLA compliance validation.

## Capabilities

- Response time analysis with percentile tracking (P50, P95, P99)
- Load and stress testing under configurable concurrency
- Performance regression detection with statistical significance
- Resource consumption monitoring (memory, CPU, tokens)
- Bottleneck identification and optimization guidance
- SLA compliance validation and reporting

See [Capabilities](./npl-benchmarker.detailed.md#capabilities) for complete details.

## Usage

```bash
# Measure agent performance
@npl-benchmarker measure --agent="npl-technical-writer" --duration="10m" --requests="100"

# Load testing
@npl-benchmarker load-test --agents="npl-grader,npl-templater" --concurrent=5 --duration="30m"

# Regression analysis
@npl-benchmarker regression --baseline="v1.0" --current="v1.1" --significance=0.05

# Resource monitoring
@npl-benchmarker resources --monitoring="memory,cpu,tokens" --agent="npl-persona" --scenarios="complex"

# Continuous monitoring
@npl-benchmarker monitor --interval="5m" --alert-threshold="p95>3000ms" --dashboard
```

See [Usage Reference](./npl-benchmarker.detailed.md#usage-reference) for all commands.

## Workflow Integration

```bash
# Establish baseline and compare
@npl-benchmarker baseline --create --agents="all" --save="baseline-v1.0.json"
@npl-benchmarker measure --agents="all" --compare="baseline-v1.0.json"

# Parallel benchmarking across agents
@npl-benchmarker measure --agent="npl-grader" --scenarios="code-review" &
@npl-benchmarker measure --agent="npl-templater" --scenarios="template-generation" &
@npl-benchmarker measure --agent="npl-persona" --scenarios="persona-simulation"

# CI/CD performance gate
@npl-benchmarker regression --baseline="main" --current="HEAD" --fail-on-regression=5%
```

See [Integration Patterns](./npl-benchmarker.detailed.md#integration-patterns) for complete workflow examples.

## Key Resources

| Topic | Reference |
|-------|-----------|
| Benchmarking framework | [Benchmarking Framework](./npl-benchmarker.detailed.md#benchmarking-framework) |
| Metrics collection | [Metrics Collection](./npl-benchmarker.detailed.md#metrics-collection) |
| Regression detection | [Regression Detection](./npl-benchmarker.detailed.md#regression-detection) |
| Load testing patterns | [Load Testing](./npl-benchmarker.detailed.md#load-testing) |
| NPL pump integration | [NPL Pump Integration](./npl-benchmarker.detailed.md#npl-pump-integration) |
| Output formats | [Output Formats](./npl-benchmarker.detailed.md#output-formats) |
| CI/CD setup | [CI/CD Integration](./npl-benchmarker.detailed.md#cicd-integration) |
| Anti-patterns | [Anti-Patterns](./npl-benchmarker.detailed.md#anti-patterns) |
| Limitations | [Limitations](./npl-benchmarker.detailed.md#limitations) |

## See Also

- Detailed reference: [npl-benchmarker.detailed.md](./npl-benchmarker.detailed.md)
- Core definition: `core/additional-agents/quality-assurance/npl-benchmarker.md`
- Related agents: [npl-tester](./npl-tester.md), [npl-validator](./npl-validator.md), [npl-integrator](./npl-integrator.md)
