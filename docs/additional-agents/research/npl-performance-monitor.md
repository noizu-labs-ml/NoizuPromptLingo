# npl-performance-monitor

Real-time metrics collection and performance analysis agent for NPL systems.

## Purpose

Validates NPL performance claims through empirical measurement. Tracks latency distributions (P50/P95/P99), token consumption, response quality, and experiment results with <5ms overhead per request.

## Capabilities

- Collect latency, token usage, and quality metrics in real-time
- Execute A/B tests with power analysis and statistical validation
- Detect regressions within 5-minute windows
- Generate dashboard, academic, and structured reports

## Quick Start

```bash
# Start monitoring
@npl-performance-monitor start --experiment="validation-v1"

# Track specific agents
@npl-performance-monitor track agent=npl-grader duration=1h

# Generate report
@npl-performance-monitor report --format=dashboard --timerange=7d
```

## Commands

| Command | Purpose | Details |
|:--------|:--------|:--------|
| `start` | Initialize session | [Configuration](#configuration) |
| `track` | Monitor agent performance | [Metrics Reference](./npl-performance-monitor.detailed.md#metrics-reference) |
| `baseline` | Capture baseline | [Workflow Examples](./npl-performance-monitor.detailed.md#workflow-examples) |
| `compare` | Compare against baseline | [Statistical Methods](./npl-performance-monitor.detailed.md#statistical-methods) |
| `experiment` | Manage A/B tests | [Commands - experiment](./npl-performance-monitor.detailed.md#experiment) |
| `report` | Generate reports | [Output Formats](./npl-performance-monitor.detailed.md#output-formats) |
| `alert` | Configure alerts | [Commands - alert](./npl-performance-monitor.detailed.md#alert) |

## Configuration

```yaml
# monitor-config.yaml
collection:
  interval: 1000  # ms
metrics:
  latency: { enabled: true, percentiles: [50, 95, 99] }
  tokens: { enabled: true }
  quality: { enabled: true }
alerts:
  - metric: latency.p99
    threshold: 3000
    action: log
```

Full schema: [Configuration](./npl-performance-monitor.detailed.md#configuration)

## Integration

```bash
# Baseline-optimize-compare workflow
@npl-performance-monitor baseline --save=before && \
@npl-claude-optimizer optimize && \
@npl-performance-monitor compare --baseline=before

# Research validation pipeline
@npl-performance-monitor experiment analyze --id=exp_001 && \
@npl-research-validator verify --data=results
```

Additional patterns: [Integration](./npl-performance-monitor.detailed.md#integration)

## Reference

- [Architecture](./npl-performance-monitor.detailed.md#architecture)
- [Metrics Reference](./npl-performance-monitor.detailed.md#metrics-reference)
- [Statistical Methods](./npl-performance-monitor.detailed.md#statistical-methods)
- [Troubleshooting](./npl-performance-monitor.detailed.md#troubleshooting)

## See Also

- [npl-claude-optimizer](./npl-claude-optimizer.md) - Optimization using monitor data
- [npl-research-validator](./npl-research-validator.md) - Statistical validation
- [npl-cognitive-load-assessor](./npl-cognitive-load-assessor.md) - UX metrics
