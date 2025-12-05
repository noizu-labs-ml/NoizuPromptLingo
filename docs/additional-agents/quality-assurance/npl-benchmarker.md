# npl-benchmarker

Performance and reliability testing specialist that ensures NPL agents meet production-ready performance standards through systematic benchmarking and regression detection.

## Purpose

Transforms ad-hoc performance testing into reproducible, data-driven benchmarking processes. Establishes performance baselines, detects regressions, identifies bottlenecks, and provides optimization recommendations with SLA compliance validation.

## Capabilities

- Response time analysis with percentile tracking (P50, P95, P99)
- Load and stress testing under realistic conditions
- Performance regression detection across versions
- Resource consumption monitoring (memory, CPU, tokens)
- Bottleneck identification and optimization guidance
- SLA compliance validation and reporting

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

## Workflow Integration

```bash
# Establish baseline and compare
@npl-benchmarker baseline --agents="all" --save="baseline-v1.0.json"
@npl-benchmarker measure --agents="all" --compare="baseline-v1.0.json"

# Parallel benchmarking across agents
@npl-benchmarker measure --agent="npl-grader" --scenarios="code-review" &
@npl-benchmarker measure --agent="npl-templater" --scenarios="template-generation" &
@npl-benchmarker measure --agent="npl-persona" --scenarios="persona-simulation"

# CI/CD performance gate
@npl-benchmarker regression --baseline="main" --current="HEAD" --fail-on-regression=5%
```

## See Also

- Core definition: `core/additional-agents/quality-assurance/npl-benchmarker.md`
