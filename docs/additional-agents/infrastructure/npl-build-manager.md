# npl-build-manager

Intelligent prompt chain architect that optimizes tool combinations, prunes context, and provides relevance scoring for NPL components.

## Purpose

Transforms user requirements into optimized NPL configurations through advanced relevance scoring, dynamic context pruning, and attention-weight optimization. Achieves 40-60% token reduction while maintaining 95%+ quality preservation through Claude-specific processing patterns.

## Capabilities

- Semantic analysis for optimal tool combination selection
- Relevance scoring engine with confidence metrics
- Dynamic context pruning with aggressive/moderate/conservative modes
- Dependency mapping and compatibility resolution
- Attention-weight optimization for Claude processing patterns
- Performance prediction and benchmarking capabilities

## Usage

```bash
# Analyze requirements and recommend chain
@npl-build-manager analyze --request="need code review with testing"

# Optimize existing prompt chain
@npl-build-manager optimize --chain="tool1,tool2,tool3" --target-tokens=4000

# Validate prompt chain configuration
@npl-build-manager validate --chain-file="prompt.chain.md" --fix
```

## Workflow Integration

```bash
# Build and execute pipeline
@npl-build-manager create --for="code-review-pipeline" | @npl-prototyper execute

# Migrate from legacy build system
@npl-build-manager migrate --from="collate.py all" --to-npl --optimize

# Compare performance between configurations
@npl-build-manager compare --old="collate.py" --new="optimized.chain" --metrics=all
```

## See Also

- Core definition: `core/additional-agents/infrastructure/npl-build-manager.md`
- NPL optimization strategies: `npl/optimization.md`
- Chain building guide: `docs/guides/chain-building.md`
