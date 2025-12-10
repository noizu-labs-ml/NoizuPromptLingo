# npl-performance

User performance measurement specialist that transforms invisible AI improvements into tangible metrics through baseline capture, A/B testing, statistical validation, and analytics dashboards.

**Detailed reference**: [npl-performance.detailed.md](npl-performance.detailed.md)

## Purpose

Addresses the fundamental UX challenge that users cannot perceive 15-40% improvements until measured and visualized. Transforms abstract AI benefits into defensible metrics through rigorous measurement frameworks.

## Capabilities

| Capability | Description | Details |
|:-----------|:------------|:--------|
| Baseline capture | Pre-NPL performance measurement | [Baseline Capture](npl-performance.detailed.md#baseline-capture) |
| A/B testing | Controlled experiments with randomization | [A/B Testing](npl-performance.detailed.md#ab-testing) |
| Statistical validation | Effect sizes, significance, confidence intervals | [Statistical Validation](npl-performance.detailed.md#statistical-validation) |
| Dashboard generation | Real-time trend visualization | [Dashboard Generation](npl-performance.detailed.md#dashboard-generation) |
| Report generation | Peer-reviewable validation documentation | [Report Formats](npl-performance.detailed.md#report-formats) |

## Quick Start

```bash
# Establish baseline
@npl-performance baseline --task="code-review" --duration="5min" --metrics="quality,time,satisfaction"

# Run A/B comparison
@npl-performance compare --control="standard-prompt" --treatment="npl-enhanced" --iterations=10

# Generate dashboard
@npl-performance dashboard --timeframe="30days" --visualizations="trends,stats,insights"

# Create statistical report
@npl-performance report --study-period="2024-01-01:2024-03-01" --confidence=95
```

See [Commands Reference](npl-performance.detailed.md#commands-reference) for all options.

## Metrics

| Category | Metrics |
|:---------|:--------|
| Quality | Accuracy, completeness, error rate |
| Speed | Task completion time, iteration count |
| Satisfaction | User rating, confidence score, NPS |

See [Measurement Framework](npl-performance.detailed.md#measurement-framework) for collection methods.

## Configuration

| Option | Values |
|:-------|:-------|
| `--confidence` | 90, 95, 99 (default: 95) |
| `--randomization` | balanced, stratified, adaptive, block |
| `--format` | executive-summary, detailed-technical |

See [Configuration Options](npl-performance.detailed.md#configuration-options) for environment variables.

## Integration

```bash
# With onboarding
@npl-onboarding baseline --performance-tracking=enabled
@npl-performance measure --after-onboarding --compare=baseline

# With accessibility
@npl-accessibility enable --high-contrast && @npl-performance measure --accessibility-enabled

# With user research
@npl-user-researcher survey --include-performance-metrics
@npl-performance correlate --user-feedback-data
```

See [Integration Patterns](npl-performance.detailed.md#integration-patterns) for CI/CD examples.

## See Also

- [Best Practices](npl-performance.detailed.md#best-practices)
- [Limitations](npl-performance.detailed.md#limitations)
- [Statistical Validation](npl-performance.detailed.md#statistical-validation)
- Core definition: `core/additional-agents/user-experience/npl-performance.md`
