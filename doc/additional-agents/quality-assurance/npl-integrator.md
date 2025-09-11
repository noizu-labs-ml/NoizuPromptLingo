# NPL Integrator Agent Documentation

## Overview

The NPL Integrator Agent is a specialized multi-agent workflow testing and integration specialist that validates collaboration patterns between NPL agents, tests complex workflow scenarios, and ensures reliable communication and coordination in production environments. Built on the Noizu Prompt Lingo (NPL) framework, it provides comprehensive integration testing capabilities for multi-agent systems.

## Purpose and Core Value

The npl-integrator agent transforms complex multi-agent coordination into validated, reliable workflows. It serves as an integration quality assurance tool that can:

- Validate multi-agent workflow reliability and performance
- Test communication protocols between NPL agents
- Ensure data integrity across agent handoffs
- Identify integration bottlenecks and failure points
- Generate comprehensive integration health reports
- Support CI/CD pipeline integration testing

## Key Capabilities

### Multi-Agent Workflow Testing
- **Sequential Workflow Validation**: Step-by-step agent handoff verification
- **Parallel Execution Testing**: Concurrent operations and synchronization validation
- **Conditional Branching**: Workflow path testing based on dynamic outputs
- **Error Recovery Testing**: Resilience validation for individual agent failures

### Communication Protocol Validation
- **Data Exchange Testing**: Structured information passing between agents
- **Context Preservation**: State maintenance across agent transitions
- **Message Integrity**: Data consistency validation throughout workflows
- **Timeout Handling**: Communication delay behavior testing

### Integration Analysis
- **Dependency Mapping**: Agent interdependency identification
- **Interface Compatibility**: Input/output compatibility testing
- **Version Compatibility**: Cross-version integration validation
- **Configuration Consistency**: Shared settings validation

## How to Invoke the Agent

### Basic Usage
```bash
# Test a multi-agent workflow
@npl-integrator test-workflow --agents="npl-tester,npl-grader,npl-technical-writer" --scenario="document-review-pipeline"

# Validate agent communication
@npl-integrator test-communication --source="npl-templater" --target="npl-grader" --iterations=50

# Perform integration health check
@npl-integrator health-check --workflow="content-generation" --depth="comprehensive"

# Test workflow performance
@npl-integrator performance-test --workflow="complex-analysis" --concurrent-flows=3 --duration="15m"

# CI/CD integration validation
@npl-integrator ci-validate --workflow-dir=".claude/workflows" --fail-on-error
```

### Advanced Usage with Custom Workflows
```bash
# Test with custom workflow definition
@npl-integrator test-workflow --workflow-config=".claude/workflows/custom-pipeline.yaml"

# Validate with specific integration configuration
@npl-integrator validate --integration-config=".claude/integration/config.yaml"

# Test with injected failures
@npl-integrator test-workflow --scenario="document-pipeline" --mock-failures --failure-rate=0.1
```

## Configuration Parameters

### Core Parameters
- `--workflow`: Path to workflow definition file
- `--agents`: List of agents to test
- `--scenario`: Predefined test scenario
- `--iterations`: Number of test iterations
- `--concurrent-flows`: Parallel workflow executions

### Testing Options
- `--depth`: Testing depth (quick, standard, comprehensive)
- `--timeout`: Maximum workflow execution time
- `--retry`: Retry failed integrations
- `--isolation`: Run in isolated environment
- `--mock-failures`: Inject synthetic failures

### Performance Parameters
- `--success-threshold`: Minimum success rate requirement
- `--communication-threshold`: Communication success rate target
- `--max-latency`: Maximum acceptable communication latency
- `--resource-limit`: Resource usage constraints

## Workflow Definition Format

The agent supports YAML-based workflow definitions:

```yaml
workflow:
  name: document-review-pipeline
  agents:
    - id: writer
      type: npl-technical-writer
      output: draft_document
    - id: validator
      type: npl-validator
      input: ${writer.output}
      output: validation_report
    - id: grader
      type: npl-grader
      input: 
        - ${writer.output}
        - ${validator.output}
      output: quality_assessment
  
  flow:
    - step: generate_draft
      agent: writer
      timeout: 30s
    - step: validate_syntax
      agent: validator
      depends_on: generate_draft
      timeout: 10s
    - step: assess_quality
      agent: grader
      depends_on: 
        - generate_draft
        - validate_syntax
      timeout: 20s
```

## Output Format

### Integration Test Report Structure
The agent generates comprehensive reports including:

1. **Executive Summary**: Overall workflow success metrics
2. **Workflow Execution Diagram**: Visual flow representation
3. **Communication Analysis**: Agent-to-agent messaging statistics
4. **Integration Points**: Critical dependency validation
5. **Data Flow Validation**: Context preservation analysis
6. **Error Handling**: Failure recovery statistics
7. **Performance Metrics**: Timing and resource usage
8. **Recommendations**: Actionable improvement suggestions

## Integration with Other NPL Agents

### Common Integration Patterns

#### Document Generation Pipeline
```bash
# Writer → Validator → Grader workflow
@npl-integrator test-workflow \
  --agents="npl-technical-writer,npl-validator,npl-grader" \
  --scenario="document-generation"
```

#### Code Review Pipeline
```bash
# Tester → Threat Modeler → Grader workflow
@npl-integrator test-workflow \
  --agents="npl-tester,npl-threat-modeler,npl-grader" \
  --scenario="code-review"
```

#### Template Processing Pipeline
```bash
# Templater → Persona → Technical Writer workflow
@npl-integrator test-workflow \
  --agents="npl-templater,npl-persona,npl-technical-writer" \
  --scenario="template-processing"
```

## Template Customization

The npl-integrator supports template-based customization through `npl-integrator.npl-template.md`, allowing project-specific configurations:

### Template Variables
- `workflow_config_path`: Path to workflow configurations
- `integration_config_path`: Path to integration settings
- `agent_registry_path`: Path to agent definitions
- `project_agents`: List of available project agents
- `standard_workflows`: Predefined workflow definitions
- `performance_thresholds`: Project-specific performance targets

### Example Template Usage
```bash
# Generate project-specific integrator configuration
@npl-templater hydrate \
  --template="npl-integrator.npl-template.md" \
  --output=".claude/agents/npl-integrator.md" \
  --vars="project-config.yaml"
```

## Performance Targets

### Default Integration Health Metrics
- **Communication Success Rate**: >98% target
- **Workflow Completion Rate**: >95% target
- **Error Recovery Rate**: >90% target
- **Integration Performance**: <30s for complex workflows
- **Resource Utilization**: <80% peak usage

### Customizable Thresholds
Projects can define custom performance thresholds in their integration configuration:

```yaml
performance_thresholds:
  completion_rate: 95
  communication_rate: 98
  recovery_rate: 90
  max_execution_time: 30s
  max_resource_usage: 80
  max_response_time: 500ms
  max_concurrent: 5
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: NPL Integration Testing
  run: |
    @npl-integrator ci-validate \
      --workflow-dir=".claude/workflows" \
      --fail-on-error \
      --success-threshold=95 \
      --output-format=junit
```

### Jenkins Pipeline Example
```groovy
stage('Integration Testing') {
  steps {
    sh '@npl-integrator ci-validate --workflow-dir=".claude/workflows" --fail-on-error'
  }
}
```

## Best Practices

### Workflow Design
1. **Start Simple**: Begin with basic two-agent workflows
2. **Incremental Complexity**: Gradually add agents and dependencies
3. **Clear Dependencies**: Explicitly define agent dependencies
4. **Timeout Configuration**: Set realistic timeouts for each step
5. **Error Handling**: Define recovery strategies for failures

### Testing Strategies
1. **Baseline Testing**: Establish performance baselines first
2. **Progressive Load**: Gradually increase concurrent flows
3. **Failure Injection**: Test with synthetic failures
4. **Resource Monitoring**: Track resource usage patterns
5. **Regression Testing**: Include in CI/CD pipelines

### Integration Monitoring
1. **Health Checks**: Regular workflow health validation
2. **Performance Tracking**: Monitor degradation over time
3. **Communication Analysis**: Track messaging patterns
4. **Bottleneck Detection**: Identify slow integration points
5. **Continuous Improvement**: Regular optimization cycles

## Common Use Cases

### 1. Production Workflow Validation
Validate critical production workflows before deployment:
```bash
@npl-integrator test-workflow \
  --workflow="production-pipeline.yaml" \
  --depth="comprehensive" \
  --fail-on-error
```

### 2. Performance Benchmarking
Establish performance baselines for multi-agent workflows:
```bash
@npl-integrator performance-test \
  --workflow="benchmark-workflow.yaml" \
  --iterations=100 \
  --output="benchmark-report.json"
```

### 3. Communication Protocol Testing
Validate agent communication reliability:
```bash
@npl-integrator test-communication \
  --agents="all" \
  --protocol="npl-message" \
  --iterations=1000
```

### 4. Failure Recovery Testing
Test workflow resilience to failures:
```bash
@npl-integrator test-workflow \
  --scenario="critical-path" \
  --mock-failures \
  --failure-types="timeout,invalid-input,resource-exhaustion"
```

### 5. Regression Testing
Prevent breaking changes in agent integrations:
```bash
@npl-integrator regression-test \
  --baseline="previous-release.json" \
  --current="current-build" \
  --tolerance=5
```

## Troubleshooting

### Common Issues

#### Communication Timeouts
- **Symptom**: Agent handoffs timing out
- **Solution**: Increase timeout values or optimize agent response times

#### Data Corruption
- **Symptom**: Context lost between agents
- **Solution**: Validate data serialization/deserialization

#### Resource Exhaustion
- **Symptom**: Workflows failing under load
- **Solution**: Reduce concurrent flows or increase resources

#### Version Incompatibility
- **Symptom**: Agents failing to communicate
- **Solution**: Ensure compatible agent versions

## Related Agents

- **npl-grader**: Provides quality assessment for integration test results
- **npl-validator**: Validates workflow definitions and configurations
- **npl-tester**: Unit testing for individual agent behaviors
- **npl-threat-modeler**: Security validation for agent communications
- **system-digest**: System monitoring during integration tests

## Version History

- **1.0.0**: Initial release with core integration testing
- **1.1.0**: Added template customization support
- **1.2.0**: Enhanced performance testing capabilities
- **1.3.0**: CI/CD pipeline integration support

## Support and Resources

- **Documentation**: Full agent specification in `agentic/scaffolding/additional-agents/quality-assurance/`
- **Templates**: Customization templates in `npl-integrator.npl-template.md`
- **Examples**: Sample workflows in `.claude/workflows/examples/`
- **Issues**: Report issues through project issue tracker