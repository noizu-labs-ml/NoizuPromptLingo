# npl-build-manager

Prompt chain optimization agent. Analyzes requirements, scores tool relevance, prunes context, and generates optimized NPL configurations with 40-60% token reduction.

## Capabilities

- **Relevance Scoring**: Semantic analysis to recommend optimal tool combinations. See [Relevance Scoring Engine](./npl-build-manager.detailed.md#relevance-scoring-engine).
- **Context Pruning**: Token reduction via aggressive/moderate/conservative modes. See [Context Pruning](./npl-build-manager.detailed.md#context-pruning).
- **Attention Optimization**: Reorders content for Claude processing patterns. See [Attention Optimization](./npl-build-manager.detailed.md#attention-optimization).
- **Dependency Resolution**: Maps tool interdependencies and validates compatibility.
- **Performance Metrics**: Tracks token reduction, quality preservation, and build speed.

## Quick Start

```bash
# Analyze requirements and get recommendations
@build analyze --request="need code review with testing"

# Optimize existing chain to target token budget
@build optimize --chain="tool1,tool2,tool3" --target-tokens=4000

# Validate chain configuration
@build validate --chain-file="prompt.chain.md" --fix
```

## Operations

| Command | Purpose |
|:--------|:--------|
| `analyze` | Evaluate requirements, recommend tools |
| `optimize` | Reduce tokens in existing chains |
| `validate` | Check syntax and compatibility |
| `migrate` | Convert legacy configs to NPL |
| `compare` | Benchmark configurations |

See [Build Operations](./npl-build-manager.detailed.md#build-operations) for full parameter reference.

## Pruning Modes

| Mode | Reduction | Use Case |
|:-----|:----------|:---------|
| `aggressive` | 50-70% | Simple, well-defined tasks |
| `moderate` | 30-50% | General usage (default) |
| `conservative` | 10-30% | Complex or ambiguous tasks |

See [Context Pruning](./npl-build-manager.detailed.md#context-pruning) for pruning rules.

## Configuration

```yaml
build_configuration:
  optimization:
    max_tokens: 8000
    min_quality: 0.90
    pruning_level: "moderate"
  scoring:
    relevance_threshold: 0.6
    confidence_minimum: 0.75
```

See [Configuration Reference](./npl-build-manager.detailed.md#configuration-reference) for all options.

## Integration

```bash
# Pipeline execution
@build create --for="code-review-pipeline" | @npl-prototyper execute

# Migration from legacy
@build migrate --from="collate.py all" --to-npl --optimize
```

See [Integration Patterns](./npl-build-manager.detailed.md#integration-patterns) for CI/CD examples.

## Detailed Documentation

- [Architecture Overview](./npl-build-manager.detailed.md#architecture-overview)
- [Relevance Scoring Engine](./npl-build-manager.detailed.md#relevance-scoring-engine)
- [Context Pruning](./npl-build-manager.detailed.md#context-pruning)
- [Attention Optimization](./npl-build-manager.detailed.md#attention-optimization)
- [Build Operations](./npl-build-manager.detailed.md#build-operations)
- [Configuration Reference](./npl-build-manager.detailed.md#configuration-reference)
- [Error Handling](./npl-build-manager.detailed.md#error-handling)
- [Performance Metrics](./npl-build-manager.detailed.md#performance-metrics)
- [Best Practices](./npl-build-manager.detailed.md#best-practices)
- [Limitations](./npl-build-manager.detailed.md#limitations)

## See Also

- Core definition: `core/additional-agents/infrastructure/npl-build-manager.md`
- [Infrastructure Agents Overview](./README.md)
