# NPL Benchmarker Agent Documentation

## Overview

The NPL Benchmarker Agent is a specialized performance and reliability testing system that ensures NPL agents and workflows meet production-ready performance standards. Built on the Noizu Prompt Lingo (NPL) framework, it provides comprehensive benchmarking capabilities including response time measurement, load testing, regression detection, and resource monitoring with actionable optimization recommendations.

## Purpose and Core Value

The npl-benchmarker agent transforms ad-hoc performance testing into systematic, reproducible benchmarking processes. It serves as an automated performance quality gate that can:

- Establish and maintain performance baselines across agent versions
- Execute realistic load and stress testing scenarios
- Detect performance regressions before they reach production
- Monitor resource consumption patterns and identify bottlenecks
- Generate data-driven optimization recommendations
- Ensure SLA compliance through continuous performance validation

## Key Capabilities

### Comprehensive Performance Testing Framework
- **Response Time Analysis**: Millisecond-precision latency measurement with percentile tracking
- **Load Testing**: Concurrent request handling, sustained load validation, spike testing
- **Resource Monitoring**: Memory usage, CPU utilization, token consumption, I/O performance
- **Regression Detection**: Statistical change analysis across versions with confidence intervals
- **Optimization Guidance**: Bottleneck identification and prioritized improvement recommendations

### Technology Stack Customization
Through the `npl-benchmarker.npl-template.md` template system, the agent adapts to specific technology stacks:

- **Python**: GIL impact analysis, memory profiling with tracemalloc, cProfile integration
- **Node.js**: Event loop monitoring, V8 heap analysis, async operation optimization
- **Go**: Goroutine management, pprof profiling, channel communication performance

### Monitoring Platform Integration
Native support for enterprise monitoring solutions:
- **Grafana**: Prometheus metrics with custom dashboards
- **DataDog**: APM tracing with anomaly detection
- **New Relic**: Distributed tracing and error analytics

## How to Invoke the Agent

### Basic Usage
```bash
# Measure single agent performance
@npl-benchmarker measure --agent="npl-technical-writer" --duration="10m" --requests="100"

# Execute load testing
@npl-benchmarker load-test --agents="npl-grader,npl-templater" --concurrent=5 --duration="30m"

# Perform regression analysis
@npl-benchmarker regression --baseline="v1.0" --current="v1.1" --significance=0.05

# Monitor resource usage
@npl-benchmarker resources --monitoring="memory,cpu,tokens" --agent="npl-persona" --scenarios="complex"

# Continuous monitoring
@npl-benchmarker monitor --interval="5m" --alert-threshold="p95>3000ms" --dashboard
```

### Advanced Usage with Templates
```bash
# Initialize benchmarker with Python-specific optimizations
@npl-benchmarker init --template=npl-benchmarker.npl-template.md \
  --tech-stack="Python" \
  --monitoring-tools="Grafana" \
  --cicd-platform="GitHub Actions"

# Configure custom SLA targets
@npl-benchmarker configure --sla-targets='[
  {"operation_type": "Simple Query", "threshold": 2000, "unit": "ms", "percentile": "P95"},
  {"operation_type": "Complex Analysis", "threshold": 10000, "unit": "ms", "percentile": "P99"}
]'

# Set performance thresholds
@npl-benchmarker configure --performance-thresholds='{
  "regression_threshold": 5,
  "failure_threshold": 10,
  "resources": [
    {"name": "Memory", "unit": "MB", "limit": "1024", "constraint": "sustained"}
  ]
}'
```

## Integration Patterns

### Continuous Integration Performance Gates

#### GitHub Actions Integration
```yaml
name: Performance Validation
on: 
  pull_request:
    paths: ['src/**', 'agents/**']

jobs:
  performance-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Performance Benchmarks
        run: |
          @npl-benchmarker regression \
            --baseline="main" \
            --current="${{ github.event.pull_request.head.sha }}" \
            --sla-config=".claude/benchmarks/sla.yaml" \
            --format=json > performance-report.json
      
      - name: Validate Performance Gates
        run: |
          @npl-benchmarker validate \
            --report=performance-report.json \
            --thresholds=".claude/benchmarks/thresholds.yaml" \
            --fail-on-regression=5%
      
      - name: Comment on PR
        if: always()
        uses: actions/github-script@v6
        with:
          script: |
            const report = require('./performance-report.json');
            github.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report.summary
            });
```

#### Jenkins Pipeline Integration
```groovy
pipeline {
    agent any
    stages {
        stage('Performance Testing') {
            steps {
                script {
                    sh """
                        @npl-benchmarker load-test \
                          --config=benchmarks/load-test.yaml \
                          --duration=30m \
                          --concurrent=10 \
                          --output=performance-results.json
                    """
                }
            }
            post {
                always {
                    publishHTML(target: [
                        reportDir: 'performance-reports',
                        reportFiles: 'benchmark-report.html',
                        reportName: 'Performance Benchmark Report'
                    ])
                }
                failure {
                    emailext(
                        subject: 'Performance Regression Detected',
                        body: 'Performance benchmarks failed. Check the report for details.',
                        to: 'team@example.com'
                    )
                }
            }
        }
    }
}
```

### Multi-Agent Performance Workflows
```bash
# Parallel comprehensive benchmarking
parallel:
  - @npl-benchmarker measure --agent="npl-grader" --scenarios="code-review"
  - @npl-benchmarker measure --agent="npl-templater" --scenarios="template-generation"
  - @npl-benchmarker measure --agent="npl-persona" --scenarios="persona-simulation"

# Sequential performance optimization workflow
@npl-benchmarker baseline --agents="all" --save="baseline-v1.0.json"
# Apply optimizations...
@npl-benchmarker measure --agents="all" --compare="baseline-v1.0.json"
@npl-benchmarker report --format="markdown" > performance-improvement.md
```

### Integration with Other NPL Agents
```bash
# Performance-driven agent selection
@npl-benchmarker recommend --task="code-review" --sla="<3s" --agents="available"

# Optimization validation with npl-grader
@npl-benchmarker optimize --agent="npl-technical-writer" --suggest
@npl-grader evaluate optimizations.md --rubric=.claude/rubrics/optimization-quality.md

# Load test with npl-thinker analysis
@npl-benchmarker load-test --export="load-test-data.json"
@npl-thinker analyze load-test-data.json --focus="bottlenecks"
```

## Template Customization

The `npl-benchmarker.npl-template.md` enables project-specific customization:

### Template Variables

#### Technology Stack Configuration
```yaml
tech_stack:
  type: string
  options: ["Python", "Node.js", "Go"]
  description: "Technology stack for performance optimization and profiling"
```

#### SLA Target Definition
```yaml
sla_targets:
  type: array
  schema:
    - operation_type: string      # e.g., "API Response"
    - threshold: number           # e.g., 500
    - unit: string               # e.g., "ms"
    - description: string        # e.g., "95th percentile response time"
    - metric: string            # e.g., "response_time"
    - operator: string          # e.g., "<"
    - percentile: string        # e.g., "P95"
```

#### Performance Thresholds
```yaml
performance_thresholds:
  type: object
  schema:
    regression_threshold: number    # Percentage degradation to flag
    failure_threshold: number       # Percentage to fail build
    gc_pressure_limit: number      # GC impact threshold (Python)
    event_loop_lag: number         # Event loop threshold (Node.js)
    goroutine_limit: number        # Goroutine count limit (Go)
    resources:
      - name: string              # Resource name
        unit: string              # Measurement unit
        limit: string             # Maximum allowed
        constraint: string        # Constraint type
        description: string       # Resource description
```

### Template Instantiation Example
```bash
# Create Python-optimized benchmarker
@npl-benchmarker create --from-template \
  --tech-stack="Python" \
  --monitoring-tools="DataDog" \
  --cicd-platform="GitHub Actions" \
  --sla-targets='[
    {
      "operation_type": "API Request",
      "threshold": 200,
      "unit": "ms",
      "percentile": "P95",
      "metric": "response_time",
      "operator": "<"
    }
  ]' \
  --performance-thresholds='{
    "regression_threshold": 5,
    "failure_threshold": 10,
    "gc_pressure_limit": 15,
    "resources": [
      {"name": "Memory", "unit": "MB", "limit": "512", "constraint": "peak"}
    ]
  }'
```

## Performance Metrics and Reporting

### Standard Metrics Collected
- **Response Time**: P50, P95, P99 percentiles with outlier analysis
- **Throughput**: Requests per second, completion rates
- **Error Rates**: Failure patterns and error categorization
- **Resource Usage**: Memory, CPU, I/O, token consumption
- **Concurrency**: Parallel execution efficiency
- **Stability**: Standard deviation and variance analysis

### Report Output Formats

#### Markdown Report
```markdown
# Performance Benchmark Report: npl-grader

## Executive Summary
- **Test Duration**: 30 minutes
- **Total Requests**: 1,500
- **Success Rate**: 99.2%
- **Average Response Time**: 850ms

## Response Time Analysis
| Percentile | Time (ms) | Target | Status |
|------------|-----------|--------|--------|
| P50        | 650       | <1000  | ✅     |
| P95        | 1,250     | <2000  | ✅     |
| P99        | 2,800     | <3000  | ✅     |

## Performance Trends
Last 5 versions show 15% improvement in P95 response time
```

#### JSON Report (CI/CD Integration)
```json
{
  "agent": "npl-grader",
  "timestamp": "2024-01-15T10:30:00Z",
  "metrics": {
    "response_time": {
      "p50": 650,
      "p95": 1250,
      "p99": 2800
    },
    "throughput": {
      "average_rps": 0.83,
      "peak_rps": 2.5
    },
    "resources": {
      "memory_avg_mb": 256,
      "memory_peak_mb": 412,
      "cpu_avg_percent": 35
    }
  },
  "sla_compliance": {
    "passed": true,
    "violations": []
  }
}
```

## Best Practices

### Performance Testing Strategy
1. **Establish Baselines Early**: Create performance baselines before feature development
2. **Test Continuously**: Integrate benchmarks into CI/CD pipeline
3. **Use Realistic Scenarios**: Test with production-like data and usage patterns
4. **Monitor Trends**: Track performance over time, not just point-in-time
5. **Set Realistic SLAs**: Base targets on actual user requirements

### Optimization Workflow
1. **Measure First**: Always benchmark before optimizing
2. **Profile Systematically**: Use appropriate profiling tools for the tech stack
3. **Focus on Bottlenecks**: Address the most impactful issues first
4. **Validate Improvements**: Re-benchmark after each optimization
5. **Document Changes**: Track what worked and what didn't

### Common Pitfalls to Avoid
- Testing with unrealistic data volumes
- Ignoring warmup periods in measurements
- Focusing only on average metrics (percentiles matter)
- Optimizing without clear performance goals
- Not accounting for variance in measurements

## Troubleshooting

### Common Issues and Solutions

#### High Variance in Results
- **Cause**: Insufficient warmup or environmental noise
- **Solution**: Increase warmup period, isolate test environment

#### Memory Leaks During Load Tests
- **Cause**: Resource cleanup issues in agents
- **Solution**: Use memory profiling, implement proper cleanup

#### False Positive Regressions
- **Cause**: Natural variance exceeding thresholds
- **Solution**: Increase sample size, adjust significance levels

#### Incomplete Test Runs
- **Cause**: Resource exhaustion or timeouts
- **Solution**: Adjust concurrent load, increase timeout values

## Advanced Features

### Custom Benchmark Scenarios
```python
# custom_benchmark.py
@npl-benchmarker.scenario("complex-workflow")
def complex_workflow_benchmark():
    """Multi-agent workflow performance test"""
    return {
        "agents": ["npl-grader", "npl-templater", "npl-persona"],
        "workflow": "sequential",
        "iterations": 100,
        "metrics": ["end_to_end_time", "agent_transition_time"]
    }
```

### Performance Correlation Analysis
```bash
# Correlate performance with code changes
@npl-benchmarker correlate \
  --metrics="performance-history.json" \
  --commits="git-log.json" \
  --output="correlation-report.md"
```

### Predictive Performance Modeling
```bash
# Predict performance at scale
@npl-benchmarker predict \
  --current-load="10rps" \
  --target-load="100rps" \
  --model="linear-regression" \
  --confidence=0.95
```

## Configuration Reference

### Environment Variables
- `NPL_BENCHMARK_BASELINE`: Path to baseline performance data
- `NPL_BENCHMARK_CONFIG`: Path to benchmark configuration file
- `NPL_MONITORING_ENDPOINT`: Monitoring platform API endpoint
- `NPL_PERFORMANCE_THRESHOLDS`: JSON string of performance limits

### Configuration File Structure
```yaml
# .claude/benchmarks/config.yaml
benchmarker:
  version: "1.0"
  tech_stack: "Python"
  monitoring:
    platform: "Grafana"
    endpoint: "http://grafana.local:3000"
    dashboard_id: "npl-performance"
  
  sla_targets:
    - operation: "simple_query"
      threshold: 1000
      unit: "ms"
      percentile: "P95"
    
    - operation: "complex_analysis"
      threshold: 5000
      unit: "ms"
      percentile: "P99"
  
  performance_gates:
    regression_threshold: 5  # percent
    failure_threshold: 10   # percent
    confidence_level: 0.95
  
  test_scenarios:
    standard:
      duration: "10m"
      requests: 1000
      concurrent: 5
    
    stress:
      duration: "30m"
      requests: 10000
      concurrent: 50
      ramp_up: "5m"
```

## See Also

- [NPL Grader Agent](../npl-grader.md) - For evaluating optimization quality
- [NPL Thinker Agent](../npl-thinker.md) - For analyzing performance bottlenecks
- [NPL Framework Documentation](../../npl/README.md) - Core NPL concepts
- [Agent Template System](../../npl/agentic/templates/README.md) - Template customization guide