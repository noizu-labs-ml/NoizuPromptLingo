# npl-claude-optimizer

Claude-specific optimization specialist that analyzes NPL configurations and provides performance recommendations tailored to Claude's constitutional training and context window capabilities.

## Purpose

Analyzes NPL configurations to deliver Claude-specific performance recommendations. Achieves 15-40% performance improvements through token efficiency, context utilization, and constitutional alignment optimization.

See: [Detailed Reference](./npl-claude-optimizer.detailed.md)

## Capabilities

- Reduce token overhead by 22-35% via syntax optimization
- Improve context window utilization from 60% to 80%+
- Align with Claude's constitutional training for natural instruction flow
- Implement dynamic pump selection based on task complexity
- Detect and prevent performance regression

Details: [Optimization Categories](./npl-claude-optimizer.detailed.md#optimization-categories)

## Usage

```bash
# Analyze current NPL configuration
@npl-claude-optimizer analyze --config=current-npl.yaml

# Optimize prompt in real-time
@npl-claude-optimizer optimize --prompt="complex-npl-prompt.md" --level=balanced

# Setup A/B testing experiment
@npl-claude-optimizer experiment --baseline=standard --treatment=optimized --duration=7d
```

Options: [Configuration Options](./npl-claude-optimizer.detailed.md#configuration-options)

## Workflow Integration

```bash
# Optimize then validate
@npl-claude-optimizer optimize --config=current.yaml && @npl-grader evaluate optimized.yaml

# Performance-driven optimization
@npl-performance-monitor baseline && @npl-claude-optimizer optimize --metrics=performance.json

# Research-backed optimization
@npl-research-validator provide-benchmarks && @npl-claude-optimizer optimize --benchmarks=benchmarks.json
```

Integration details: [Integration Guidelines](./npl-claude-optimizer.detailed.md#integration-guidelines)

## Quick Reference

| Optimization | Token Savings | Quality Impact |
|:-------------|:--------------|:---------------|
| Syntax Simplification | 25-35% | Neutral |
| Pump Optimization | 15-25% | +10-15% |
| Constitutional Alignment | 5-10% | +20-30% |
| Dynamic Selection | 30-40% | +25-35% |

Full benchmarks: [Performance Benchmarks](./npl-claude-optimizer.detailed.md#performance-benchmarks)

## See Also

- Detailed reference: [`npl-claude-optimizer.detailed.md`](./npl-claude-optimizer.detailed.md)
- Core definition: `core/additional-agents/research/npl-claude-optimizer.md`
- Performance tracking: `npl/pumps/npl-performance.md`
