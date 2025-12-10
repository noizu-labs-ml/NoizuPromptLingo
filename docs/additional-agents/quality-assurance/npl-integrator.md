# npl-integrator

Multi-agent workflow testing and integration specialist that validates collaboration patterns, tests complex scenarios, and ensures reliable agent coordination.

## Purpose

Validates multi-agent workflows, tests communication protocols, and ensures reliable coordination between NPL agents. Transforms complex multi-agent coordination into validated, reliable workflows through systematic integration testing.

## Capabilities

- Multi-agent workflow scenario testing
- Cross-agent communication protocol validation
- Integration point dependency analysis
- Data flow and context preservation verification
- Error recovery and resilience testing
- Workflow performance and bottleneck identification

See [Capabilities](./npl-integrator.detailed.md#capabilities) for complete details.

## Usage

```bash
# Test multi-agent workflow
@npl-integrator test-workflow --agents="npl-tester,npl-grader,npl-technical-writer" --scenario="document-review-pipeline"

# Validate agent communication
@npl-integrator test-communication --source="npl-templater" --target="npl-grader" --iterations=50

# Integration health check
@npl-integrator health-check --workflow="content-generation" --depth="comprehensive"
```

See [Usage Reference](./npl-integrator.detailed.md#usage-reference) for all commands.

## Workflow Integration

```bash
# Custom workflow with config
@npl-integrator test-workflow --workflow-config=".claude/workflows/custom-pipeline.yaml"

# Performance testing
@npl-integrator performance-test --workflow="complex-analysis" --concurrent-flows=3 --duration="15m"

# CI/CD validation
@npl-integrator ci-validate --workflow-dir=".claude/workflows" --fail-on-error

# Failure injection testing
@npl-integrator test-workflow --scenario="document-pipeline" --mock-failures --failure-rate=0.1
```

See [Configuration Options](./npl-integrator.detailed.md#configuration-options) for all parameters.

## Key Resources

| Topic | Reference |
|-------|-----------|
| Technical architecture | [Technical Architecture](./npl-integrator.detailed.md#technical-architecture) |
| Testing categories | [Testing Categories](./npl-integrator.detailed.md#testing-categories) |
| Workflow definition | [Workflow Definition Format](./npl-integrator.detailed.md#workflow-definition-format) |
| NPL pump integration | [NPL Pump Integration](./npl-integrator.detailed.md#npl-pump-integration) |
| Output format | [Output Format](./npl-integrator.detailed.md#output-format) |
| Quality framework | [Integration Quality Framework](./npl-integrator.detailed.md#integration-quality-framework) |
| Best practices | [Best Practices](./npl-integrator.detailed.md#best-practices) |
| Limitations | [Limitations](./npl-integrator.detailed.md#limitations) |

## See Also

- Detailed reference: [npl-integrator.detailed.md](./npl-integrator.detailed.md)
- Core definition: `core/additional-agents/quality-assurance/npl-integrator.md`
- Related agents: [npl-tester](./npl-tester.md), [npl-validator](./npl-validator.md), [npl-benchmarker](./npl-benchmarker.md)
