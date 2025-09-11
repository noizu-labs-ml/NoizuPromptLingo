# Research Agents

Research agents validate and optimize AI system performance through empirical measurement, cognitive load assessment, and performance monitoring. These agents provide data-driven insights for improving prompt effectiveness and model optimization.

## Agent Overview

### npl-research-validator
Empirical validation agent that tests AI outputs against defined hypotheses and quality metrics. Conducts systematic experiments to verify prompt effectiveness and model behavior consistency.

### npl-performance-monitor
Real-time performance tracking agent measuring response latency, token efficiency, and resource utilization. Identifies bottlenecks and optimization opportunities in AI workflows.

### npl-cognitive-load-assessor
Evaluates cognitive complexity of prompts and AI outputs. Measures information density, reasoning depth, and processing requirements to optimize for human-AI interaction efficiency.

### npl-claude-optimizer
Claude-specific optimization agent that tunes prompts for optimal performance with Claude models. Analyzes response patterns and adjusts prompting strategies for improved output quality.

## Core Capabilities

### Validation Framework
- Hypothesis testing for prompt effectiveness
- A/B testing of prompt variations
- Statistical significance analysis
- Reproducibility verification

### Performance Metrics
- Response time measurement
- Token usage optimization
- Context window efficiency
- Error rate tracking

### Cognitive Assessment
- Complexity scoring
- Readability analysis
- Information density measurement
- Task decomposition evaluation

### Model Optimization
- Prompt tuning strategies
- Temperature and parameter adjustment
- Context management optimization
- Response quality enhancement

## Research Validation Workflow

### Basic Validation Pipeline
```bash
# 1. Define hypothesis and metrics
@npl-research-validator define-hypothesis \
  --hypothesis="Structured prompts improve accuracy" \
  --metrics="accuracy,consistency,latency"

# 2. Monitor performance baseline
@npl-performance-monitor baseline \
  --duration=100 \
  --track="latency,tokens,errors"

# 3. Assess cognitive load
@npl-cognitive-load-assessor evaluate prompt.md \
  --metrics="complexity,density,clarity"

# 4. Optimize for Claude
@npl-claude-optimizer tune prompt.md \
  --target="claude-3" \
  --optimize="quality,efficiency"
```

### A/B Testing Workflow
```bash
# Test prompt variations
@npl-research-validator ab-test \
  --control=prompt-v1.md \
  --variant=prompt-v2.md \
  --samples=50 \
  --metrics="accuracy,speed"

# Monitor both versions
@npl-performance-monitor compare \
  --version-a=v1 \
  --version-b=v2 \
  --duration=1h

# Assess cognitive differences
@npl-cognitive-load-assessor compare \
  --prompt-a=prompt-v1.md \
  --prompt-b=prompt-v2.md

# Generate optimization report
@npl-claude-optimizer analyze-results \
  --test-id=ab-test-001 \
  --generate-report
```

### Continuous Optimization
```bash
# Set up monitoring pipeline
@npl-performance-monitor watch \
  --config=monitor.yaml \
  --alert-threshold="latency>2s" \
  --log=performance.log

# Periodic validation
@npl-research-validator schedule \
  --interval=daily \
  --test-suite=validation-suite.yaml

# Adaptive optimization
@npl-claude-optimizer auto-tune \
  --baseline=current-prompt.md \
  --iterations=10 \
  --improvement-threshold=5%
```

## Templaterized Customization

All research agents support NPL template customization for domain-specific validation:

### Custom Metrics Template
```npl
{{#research-metrics}}
- name: {{metric_name}}
  type: {{metric_type}}
  threshold: {{threshold_value}}
  aggregation: {{aggregation_method}}
{{/research-metrics}}
```

### Validation Suite Template
```npl
{{#validation-suite}}
hypothesis:
  statement: {{hypothesis}}
  null_hypothesis: {{null_hypothesis}}
tests:
  {{#each test}}
  - name: {{test_name}}
    type: {{test_type}}
    parameters: {{parameters}}
  {{/each}}
{{/validation-suite}}
```

### Performance Profile Template
```npl
{{#performance-profile}}
monitoring:
  metrics: [{{metrics}}]
  sampling_rate: {{rate}}
alerts:
  {{#each alert}}
  - condition: {{condition}}
    action: {{action}}
  {{/each}}
{{/performance-profile}}
```

## Integration Examples

### With Development Agents
```bash
# Validate code generation quality
@npl-code-generator create function.py
@npl-research-validator test \
  --output=function.py \
  --criteria="correctness,efficiency,style"
```

### With Analysis Agents
```bash
# Assess complexity of generated analysis
@npl-data-analyzer process dataset.csv
@npl-cognitive-load-assessor evaluate \
  --output=analysis-report.md \
  --target-audience="technical"
```

### With Testing Agents
```bash
# Monitor test execution performance
@npl-test-generator create test-suite.py
@npl-performance-monitor track \
  --command="pytest test-suite.py" \
  --metrics="execution-time,memory-usage"
```

## Metrics and Reporting

### Validation Metrics
- Accuracy: Correctness of AI outputs
- Consistency: Reproducibility across runs
- Reliability: Error rate and failure patterns
- Efficiency: Resource utilization metrics

### Performance Indicators
- Latency: Time to first token and completion
- Throughput: Requests per second
- Token Efficiency: Input/output token ratio
- Context Utilization: Effective context window usage

### Cognitive Metrics
- Flesch Reading Ease: Output readability
- Halstead Complexity: Information complexity
- Cognitive Load Index: Processing difficulty
- Clarity Score: Instruction understanding

### Optimization Metrics
- Quality Score: Output excellence rating
- Efficiency Gain: Performance improvement percentage
- Cost Reduction: Token usage optimization
- Error Reduction: Decreased failure rate

## Best Practices

1. **Establish Baselines**: Always measure current performance before optimization
2. **Statistical Significance**: Ensure adequate sample sizes for validation
3. **Iterative Refinement**: Use continuous monitoring for gradual improvement
4. **Domain Specificity**: Customize metrics for your specific use case
5. **Holistic Assessment**: Consider multiple metrics, not just single indicators
6. **Version Control**: Track prompt versions with performance metrics
7. **Documentation**: Record optimization decisions and rationale

## Configuration

### Environment Variables
```bash
# Research validation settings
export NPL_RESEARCH_SAMPLE_SIZE=100
export NPL_RESEARCH_CONFIDENCE_LEVEL=0.95
export NPL_RESEARCH_LOG_LEVEL=INFO

# Performance monitoring
export NPL_MONITOR_INTERVAL=1000  # ms
export NPL_MONITOR_BUFFER_SIZE=1000
export NPL_MONITOR_ALERT_EMAIL=team@example.com

# Cognitive assessment
export NPL_COGNITIVE_TARGET_LEVEL=intermediate
export NPL_COGNITIVE_LANGUAGE=en

# Claude optimization
export NPL_CLAUDE_MODEL=claude-3-opus
export NPL_CLAUDE_TEMPERATURE=0.7
export NPL_CLAUDE_MAX_TOKENS=4096
```

## Individual Agent Documentation

- [npl-research-validator](./npl-research-validator.md) - Empirical validation and hypothesis testing
- [npl-performance-monitor](./npl-performance-monitor.md) - Real-time performance tracking
- [npl-cognitive-load-assessor](./npl-cognitive-load-assessor.md) - Cognitive complexity evaluation
- [npl-claude-optimizer](./npl-claude-optimizer.md) - Claude-specific optimization

## Related Agent Categories

- [Analysis Agents](../analysis/README.md) - Data processing and insight generation
- [Testing Agents](../testing/README.md) - Quality assurance and validation
- [Development Agents](../development/README.md) - Code generation and review