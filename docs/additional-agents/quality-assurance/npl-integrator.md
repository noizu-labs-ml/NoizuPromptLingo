# npl-integrator

Multi-agent workflow testing and integration specialist that validates collaboration patterns, tests complex scenarios, and ensures reliable agent coordination.

## Purpose

Transforms complex multi-agent coordination into validated, reliable workflows through systematic integration testing. Validates communication protocols, data handoffs, and workflow reliability in production environments.

## Capabilities

- Multi-agent workflow scenario testing
- Cross-agent communication protocol validation
- Integration point dependency analysis
- Data flow and context preservation verification
- Error recovery and resilience testing
- Workflow performance and bottleneck identification

## Usage

```bash
# Test multi-agent workflow
@npl-integrator test-workflow --agents="npl-tester,npl-grader,npl-technical-writer" --scenario="document-review-pipeline"

# Validate agent communication
@npl-integrator test-communication --source="npl-templater" --target="npl-grader" --iterations=50

# Integration health check
@npl-integrator health-check --workflow="content-generation" --depth="comprehensive"

# Performance testing
@npl-integrator performance-test --workflow="complex-analysis" --concurrent-flows=3 --duration="15m"

# CI/CD validation
@npl-integrator ci-validate --workflow-dir=".claude/workflows" --fail-on-error
```

## Workflow Integration

```bash
# Document generation pipeline
@npl-integrator test-workflow --agents="npl-technical-writer,npl-validator,npl-grader" --scenario="document-generation"

# Custom workflow with config
@npl-integrator test-workflow --workflow-config=".claude/workflows/custom-pipeline.yaml"

# Failure injection testing
@npl-integrator test-workflow --scenario="document-pipeline" --mock-failures --failure-rate=0.1
```

## See Also

- Core definition: `core/additional-agents/quality-assurance/npl-integrator.md`
