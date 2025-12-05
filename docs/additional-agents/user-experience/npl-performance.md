# npl-performance

User performance measurement specialist that demonstrates NPL value through before/after comparisons, A/B testing frameworks, analytics dashboards, and statistical validation to make invisible AI improvements visible and measurable.

## Purpose

Addresses the fundamental UX challenge that users cannot perceive the 15-40% performance improvements NPL provides until they are measured and visualized. Transforms abstract AI benefits into tangible metrics through rigorous measurement frameworks, statistical validation, and clear visualizations that drive user adoption.

## Capabilities

- Establish comprehensive performance baselines before NPL implementation
- Design controlled A/B experiments comparing standard vs NPL-enhanced approaches
- Build real-time analytics dashboards with trend visualization
- Measure response quality, task completion time, iteration count, and satisfaction
- Calculate effect sizes and statistical significance with confidence intervals
- Generate peer-reviewable validation reports with methodology documentation

## Usage

```bash
# Establish baseline performance
@npl-performance baseline --task="code-review" --duration="5min" --metrics="quality,time,satisfaction"

# Run A/B comparison
@npl-performance compare --control="standard-prompt" --treatment="npl-enhanced" --iterations=10

# Generate performance dashboard
@npl-performance dashboard --timeframe="30days" --visualizations="trends,stats,insights"

# Create statistical report
@npl-performance report --study-period="2024-01-01:2024-03-01" --confidence=95 --format="executive-summary"
```

## Workflow Integration

```bash
# Measure onboarding effectiveness
@npl-onboarding baseline --performance-tracking=enabled && @npl-performance measure --after-onboarding --compare=baseline

# Validate accessibility impact
@npl-accessibility enable --high-contrast --large-text && @npl-performance measure --accessibility-enabled --baseline-comparison

# Correlate with user research
@npl-user-researcher survey --include-performance-metrics && @npl-performance correlate --user-feedback-data
```

## See Also

- Core definition: `core/additional-agents/user-experience/npl-performance.md`
- Statistical methods: `npl/performance/statistical-validation.md`
- Dashboard templates: `npl/performance/dashboard-templates.md`
