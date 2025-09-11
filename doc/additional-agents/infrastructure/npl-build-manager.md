# NPL Build Manager Agent Documentation

## Overview

The NPL Build Manager Agent is an intelligent prompt chain architect that optimizes tool combinations, prunes irrelevant context, and provides relevance scoring for NPL framework components. It transforms user requirements into optimized NPL configurations through advanced relevance scoring, dynamic context pruning, and attention-weight optimization specifically tuned for Claude's processing patterns.

## Purpose and Core Value

The npl-build-manager agent solves the critical challenge of prompt chain optimization in the NPL ecosystem. It serves as an automated infrastructure layer that:

- Analyzes user requirements to determine optimal tool combinations
- Reduces token usage by 40-60% while preserving output quality
- Provides data-driven recommendations based on semantic similarity and performance metrics
- Ensures compatibility and dependency resolution across NPL components
- Adapts to specific build systems and deployment targets through templated configuration

## Key Capabilities

### Intelligent Chain Construction
- **Relevance Scoring Engine**: Evaluates tools against task requirements using semantic analysis
- **Dependency Mapping**: Automatically resolves component relationships and requirements
- **Performance Prediction**: Estimates token usage, execution time, and quality metrics
- **Context Analysis**: Determines necessary background information and pruning opportunities
- **Attention Optimization**: Arranges content for optimal Claude processing patterns

### Dynamic Optimization
- **Context Pruning**: Removes redundant sections while preserving critical instructions
- **Token Efficiency**: Achieves 40-60% compression with 95%+ quality preservation
- **Adaptive Strategies**: Supports aggressive, moderate, and conservative pruning levels
- **Semantic Clustering**: Groups related concepts for improved coherence
- **Cache Utilization**: Maintains 80%+ hit rate on common patterns

### Build System Integration
- **Template Support**: Customizable for different build systems via `npl-build-manager.npl-template.md`
- **CI/CD Integration**: Native support for various continuous integration platforms
- **Migration Tools**: Incremental migration from existing build systems
- **Performance Comparison**: Benchmarking tools for before/after analysis

## How to Invoke the Agent

### Basic Usage
```bash
# Analyze user requirements and recommend optimal chain
@npl-build-manager analyze --request="need code review with testing"

# Optimize an existing prompt chain
@npl-build-manager optimize --chain="tool1,tool2,tool3" --target-tokens=4000

# Validate a prompt chain file
@npl-build-manager validate --chain-file="prompt.chain.md"

# Generate optimized chain from requirements
@npl-build-manager generate --for="code-review-pipeline"
```

### Advanced Usage Options
```bash
# Migrate from existing build system
@npl-build-manager migrate --from="collate.py all" --to-npl

# Compare performance between configurations
@npl-build-manager compare --old="collate.py" --new="optimized.chain"

# Generate with performance metrics
@npl-build-manager generate --measure-performance --report="metrics.md"

# Apply auto-fixes to validation issues
@npl-build-manager validate --chain-file="prompt.chain.md" --fix

# Debug mode for detailed analysis
@npl-build-manager analyze --request="complex task" --verbose --debug
```

### Templated Customization
```bash
# Use with custom build configuration
@npl-build-manager generate \
  --build-config=".claude/build-config.md" \
  --for="production-pipeline"

# Apply project-specific template variables
@npl-build-manager optimize \
  --template-vars="build_system=gradle,ci_platform=jenkins" \
  --chain="current.md"
```

## Configuration Options

### Build Parameters
```yaml
build_configuration:
  optimization:
    max_tokens: 8000           # Target token limit
    min_quality: 0.90          # Minimum quality threshold
    pruning_level: "moderate"  # aggressive|moderate|conservative
    
  scoring:
    relevance_threshold: 0.6   # Minimum tool relevance score
    confidence_minimum: 0.75    # Minimum recommendation confidence
    weights:
      semantic: 0.4            # Semantic similarity weight
      performance: 0.3         # Historical performance weight
      user_preference: 0.2     # User preference weight
      complexity: 0.1          # Task complexity weight
      
  preferences:
    prefer_tools: ["npl-*"]    # Prioritize NPL agents
    exclude_tools: []          # Blacklist specific tools
    preserve_sections: []      # Never prune these sections
```

### Template Variables
When using `npl-build-manager.npl-template.md`, the following variables can be customized:

| Variable | Description | Example Values |
|----------|-------------|----------------|
| `build_system` | Primary build system | `gradle`, `maven`, `make`, `npm` |
| `deployment_targets` | Target deployment environments | `aws`, `kubernetes`, `docker` |
| `ci_platform` | CI/CD platform | `jenkins`, `github-actions`, `gitlab-ci` |
| `max_tokens` | Maximum token budget | `4000`, `6000`, `8000` |
| `quality_threshold` | Minimum quality score | `0.85`, `0.90`, `0.95` |
| `pruning_strategy` | Context pruning aggressiveness | `aggressive`, `moderate`, `conservative` |
| `preferred_tools` | Prioritized tool list | `["npl-code-reviewer", "npl-test-generator"]` |

## Integration Patterns

### CI/CD Pipeline Integration
```yaml
# GitHub Actions example
name: Optimize NPL Chain
on: [push]
jobs:
  optimize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Analyze and Optimize Chain
        run: |
          @npl-build-manager analyze --request="${{ github.event.head_commit.message }}" \
            --ci-platform=github-actions > analysis.md
          @npl-build-manager optimize --chain="current.chain.md" \
            --target-tokens=6000 > optimized.chain.md
      - name: Validate Optimized Chain
        run: |
          @npl-build-manager validate --chain-file="optimized.chain.md" --strict
```

### Multi-Agent Workflows
```bash
# Chain analysis with grading
@npl-build-manager analyze --request="review security vulnerabilities" | \
  @npl-grader evaluate --rubric=chain-quality.md

# Optimized chain execution
@npl-build-manager generate --for="test-generation" | \
  @npl-prototyper execute --measure-performance

# Template-driven optimization
@npl-templater hydrate build-config.template.md --vars="env=production" | \
  @npl-build-manager optimize --build-config=- --chain="current.md"
```

### Migration Workflows
```bash
# Analyze existing collate.py workflow
@npl-build-manager migrate --from="collate.py" --analyze > migration-plan.md

# Incremental migration with comparison
@npl-build-manager migrate --from="collate.py gpt-pro gpt-git" --to-npl > phase1.chain.md
@npl-build-manager compare --old="collate.py gpt-pro gpt-git" --new="phase1.chain.md"

# Full migration with optimization
@npl-build-manager migrate --from="collate.py all" --to-npl --optimize
```

## Core Workflow Process

```mermaid
flowchart TD
    A[User Request] --> B[Context Analysis Engine]
    B --> C[Relevance Scoring System]
    C --> D[Dependency Mapper]
    D --> E[Context Pruning Engine]
    E --> F[Attention Optimizer]
    F --> G[Chain Generator]
    G --> H[Validation Layer]
    H --> I[Optimized Prompt Chain]
    
    J[Performance Metrics] --> C
    J --> E
    J --> F
    
    K[Build Config] -.-> B
    L[CI Platform Config] -.-> G
    M[Template Variables] -.-> E
```

## Example Usage Scenarios

### Scenario 1: Optimizing Complex Code Review Pipeline

**Context**: Large codebase requiring comprehensive review with multiple aspects.

```bash
# Step 1: Analyze requirements
@npl-build-manager analyze --request="comprehensive code review including security, performance, and maintainability" --verbose

# Output:
# Tool Relevance Scores:
# - npl-code-reviewer:     0.92 [HIGH]
# - npl-threat-modeler:    0.88 [HIGH]  
# - npl-grader:           0.78 [MEDIUM]
# - npl-test-generator:    0.45 [LOW]
# 
# Recommended Chain: [npl-code-reviewer, npl-threat-modeler, npl-grader]
# Expected Tokens: ~8,432
# Confidence: 87%

# Step 2: Optimize for token budget
@npl-build-manager optimize --chain="npl-code-reviewer,npl-threat-modeler,npl-grader" --target-tokens=5000

# Output:
# Optimization Report:
# Original Tokens: 8,432
# Optimized Tokens: 4,956 (41.2% reduction)
# 
# Pruned:
# - Redundant security examples (saved 1,400 tokens)
# - Duplicate review criteria (saved 1,200 tokens)
# - Verbose descriptions (saved 876 tokens)
#
# Quality Impact: Minimal (<2% degradation)

# Step 3: Validate and apply
@npl-build-manager validate --chain-file="optimized.chain.md" --fix
```

### Scenario 2: Build System Migration

**Context**: Migrating from collate.py to NPL build manager with Gradle integration.

```bash
# Create build configuration template
cat > build-config.template.md << EOF
build_system: gradle
deployment_targets: [aws, kubernetes]
ci_platform: jenkins
max_tokens: 6000
quality_threshold: 0.90
pruning_strategy: moderate
preferred_tools: [npl-code-reviewer, npl-test-generator]
EOF

# Hydrate template and migrate
@npl-templater hydrate build-config.template.md --output=.claude/build-config.md
@npl-build-manager migrate --from="collate.py all" --to-npl --build-config=.claude/build-config.md

# Compare performance
@npl-build-manager compare --old="collate.py all" --new="migrated.chain.md" --metrics=all
```

### Scenario 3: Dynamic Chain Generation for Different Environments

**Context**: Creating environment-specific chains for development, staging, and production.

```bash
# Development environment - verbose, all tools
@npl-build-manager generate \
  --for="development-pipeline" \
  --template-vars="pruning_strategy=conservative,max_tokens=10000" \
  --include-debug-tools

# Staging environment - balanced
@npl-build-manager generate \
  --for="staging-pipeline" \
  --template-vars="pruning_strategy=moderate,max_tokens=6000" \
  --exclude="npl-debug-*"

# Production environment - optimized
@npl-build-manager generate \
  --for="production-pipeline" \
  --template-vars="pruning_strategy=aggressive,max_tokens=4000" \
  --only-essential-tools
```

## Performance Metrics and Reporting

### Key Performance Indicators
- **Token Reduction**: 40-60% average compression ratio
- **Quality Preservation**: 95%+ output quality maintained
- **Build Speed**: <2 seconds for standard chains
- **Cache Hit Rate**: 80%+ on common patterns
- **Recommendation Accuracy**: 90%+ user satisfaction
- **Error Prevention**: 95%+ compatibility issue detection

### Sample Performance Report
```markdown
Build Performance Report
========================
Date: 2024-01-15 10:30:00
Chain: [npl-code-reviewer, npl-test-generator, npl-grader]
Build System: gradle
CI Platform: jenkins

Token Efficiency:
- Original: 12,456 tokens
- Optimized: 4,823 tokens
- Reduction: 61.3%

Quality Metrics:
- Output Quality: 96.2% preserved
- Response Time: 1.8s faster
- Error Rate: 2.1% reduced

Optimization Details:
- Pruning Strategy: moderate
- Sections Preserved: 8
- Sections Pruned: 15
- Dependencies Resolved: 12

Recommendations:
1. Consider adding npl-cache for repeated queries
2. Enable progressive loading for contexts >8000 tokens
3. Review pruning rules for domain-specific content
```

## Best Practices

### Chain Building Best Practices
1. **Start with Analysis**: Always analyze requirements before building chains
2. **Set Token Budgets**: Define clear token limits based on use case
3. **Preserve Critical Context**: Never sacrifice correctness for size reduction
4. **Test Edge Cases**: Validate chains with unusual or complex requests
5. **Document Decisions**: Record why specific tools were included/excluded

### Optimization Best Practices
1. **Benchmark Regularly**: Track optimization effectiveness over time
2. **Learn from Usage**: Adapt scoring weights based on actual performance
3. **Balance Trade-offs**: Consider speed vs quality vs token usage
4. **Enable Debugging**: Use verbose mode during development
5. **Version Control Chains**: Track chain evolution in source control

### Integration Best Practices
1. **Gradual Migration**: Move from existing systems incrementally
2. **Maintain Compatibility**: Support legacy workflows during transition
3. **Provide Clear Feedback**: Explain optimization decisions to users
4. **Enable Rollback**: Keep original configurations accessible
5. **Share Learning**: Export optimization patterns for team reuse

## Troubleshooting

### Common Issues and Solutions

**High Token Usage Despite Optimization**
- Check pruning strategy setting (may be too conservative)
- Review preserved sections list for unnecessary inclusions
- Analyze tool redundancy in the chain
- Consider splitting into multiple smaller chains

**Low Quality Scores After Optimization**
- Adjust quality threshold parameter
- Switch to moderate or conservative pruning
- Identify and preserve critical sections
- Review specific tool dependencies

**Validation Failures**
- Use `--explain` flag for detailed error messages
- Apply `--fix` flag for automatic corrections
- Check NPL syntax compliance
- Verify tool compatibility and versions

**Poor Recommendation Accuracy**
- Adjust scoring weight parameters
- Update historical performance data
- Refine semantic similarity thresholds
- Incorporate user feedback into preferences

## Advanced Features

### Custom Scoring Algorithms
```yaml
custom_scoring:
  algorithm: "weighted-ensemble"
  components:
    - semantic_embeddings
    - performance_history
    - user_feedback
    - domain_expertise
  ensemble_method: "gradient-boosting"
```

### Progressive Chain Loading
```bash
# Enable progressive loading for large contexts
@npl-build-manager generate \
  --progressive-loading \
  --chunk-size=2000 \
  --overlap=200
```

### Chain Caching and Reuse
```bash
# Enable caching for common patterns
@npl-build-manager configure --enable-cache --cache-ttl=3600

# Export successful patterns
@npl-build-manager export-patterns --min-usage=10 --min-satisfaction=0.9
```

## Conclusion

The NPL Build Manager Agent represents critical infrastructure for making the NPL framework accessible and performant at scale. By intelligently analyzing requirements, optimizing token usage, and ensuring compatibility, it transforms complex prompt engineering into an optimized, measurable process. The agent's template support enables seamless integration with various build systems and deployment targets, making it a versatile tool for any NPL-based workflow.

Through its sophisticated scoring algorithms, dynamic pruning strategies, and attention optimization techniques, the npl-build-manager ensures that NPL chains deliver maximum value within token constraints while maintaining output quality. Whether migrating from legacy systems, optimizing existing chains, or building new configurations from scratch, this agent provides the intelligence and automation needed for efficient NPL prompt chain management.