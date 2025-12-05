# npl-claude-optimizer

Claude-specific optimization specialist that analyzes NPL configurations and provides performance recommendations tailored to Claude's constitutional training and context window capabilities.

## Purpose

Analyzes NPL configurations to deliver Claude-specific performance recommendations. Leverages Claude's constitutional training, extended context window, and natural instruction-following capabilities to achieve 15-40% performance improvements through token efficiency, context utilization, and constitutional alignment optimization.

## Capabilities

- Analyze token overhead and reduce verbose syntax by 22-35%
- Optimize context window utilization from 60% to 80%+ efficiency
- Align with Claude's constitutional training for natural instruction flow
- Implement dynamic pump selection based on task complexity
- Detect and prevent performance regression in configurations
- Generate actionable optimization recommendations with quantified impact

## Usage

```bash
# Analyze current NPL configuration
@npl-claude-optimizer analyze --config=current-npl.yaml

# Optimize prompt in real-time
@npl-claude-optimizer optimize --prompt="complex-npl-prompt.md" --level=balanced

# Setup A/B testing experiment
@npl-claude-optimizer experiment --baseline=standard --treatment=optimized --duration=7d
```

## Workflow Integration

```bash
# Optimize then validate
@npl-claude-optimizer optimize --config=current.yaml && @npl-grader evaluate optimized.yaml

# Performance-driven optimization
@npl-performance-monitor baseline && @npl-claude-optimizer optimize --metrics=performance.json

# Research-backed optimization
@npl-research-validator provide-benchmarks && @npl-claude-optimizer optimize --benchmarks=benchmarks.json
```

## See Also

- Core definition: `core/additional-agents/research/npl-claude-optimizer.md`
- Performance tracking: `npl/pumps/npl-performance.md`
- Optimization strategies: `npl/optimization.md`
