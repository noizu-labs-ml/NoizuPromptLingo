# npl-performance-monitor

Real-time metrics collection and performance analysis agent for NPL systems, focusing on latency tracking, token usage optimization, quality benchmarking, and statistical validation of prompt effectiveness.

## Purpose

Quantifies the 15-40% performance improvements documented in NPL research through empirical measurement and validation. Provides real-time monitoring, A/B testing capabilities, and academic-grade statistical analysis for NPL system optimization with sub-second latency tracking and minimal overhead.

## Capabilities

- Collect real-time metrics: latency (P50/P95/P99), token usage, response quality
- Execute controlled A/B tests with power analysis and statistical validation
- Generate academic-grade reports supporting research publication
- Detect performance regressions within 5 minutes of deployment
- Track cognitive load: learning curves, error patterns, feature adoption
- Validate empirical claims with confidence intervals and effect sizes

## Usage

```bash
# Start monitoring session
@npl-performance-monitor start --experiment="NPL-validation-v1"

# Monitor specific agent performance
@npl-performance-monitor track agent=npl-grader duration=1h

# Generate performance report
@npl-performance-monitor report --format=dashboard --timerange=7d

# Setup A/B test
@npl-performance-monitor experiment create --control="standard" --treatment="npl-enhanced" --duration=14d
```

## Workflow Integration

```bash
# Baseline and optimize workflow
@npl-performance-monitor baseline --save=before && @npl-claude-optimizer optimize && @npl-performance-monitor compare --baseline=before

# Parallel agent monitoring
@npl-performance-monitor track agent=npl-grader,npl-thinker,npl-templater --metrics=latency,quality

# Research validation pipeline
@npl-performance-monitor experiment analyze --id=exp_001 && @npl-research-validator verify --data=results
```

## See Also

- Core definition: `core/additional-agents/research/npl-performance-monitor.md`
- Metrics pump: `npl/pumps/npl-metrics.md`
- Benchmarking guidelines: `npl/benchmarking.md`
