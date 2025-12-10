# npl-project-coordinator

Cross-agent dependency management and orchestration specialist for multi-agent workflows.

## Purpose

Central orchestration hub for NPL agent ecosystems. Manages dependencies, sequences operations, facilitates handoffs, and tracks progress across complex workflows.

## Capabilities

- Determine optimal execution order for multi-agent tasks
- Map and resolve inter-agent dependencies
- Manage clean transitions between agent operations
- Coordinate simultaneous agent operations
- Track progress across multiple workstreams
- Detect and resolve workflow impediments
- Generate consolidated status updates

See [Detailed Reference: Capabilities](./npl-project-coordinator.detailed.md#capabilities) for dependency types, handoff validation, and parallel execution strategies.

## Usage

```bash
# Orchestrate multi-agent workflow
@npl-project-coordinator "Plan and execute: validation -> prototyping -> testing"

# Generate status report
@npl-project-coordinator "Generate status report for API redesign project"

# Manage agent handoff
@npl-project-coordinator "Manage handoff from npl-prototyper to npl-code-reviewer"

# Resolve workflow conflict
@npl-project-coordinator "Resolve conflicting documentation recommendations"
```

See [Detailed Reference: Usage Examples](./npl-project-coordinator.detailed.md#usage-examples) for complete invocation patterns.

## Integration

```bash
# Sequential pipeline
@npl-project-coordinator "Orchestrate pipeline" && \
  @npl-validator "Validate" && @npl-tester "Test"

# Parallel with aggregation
@npl-project-coordinator "Coordinate analysis" && \
  @npl-risk-monitor "Assess" & @npl-technical-reality-checker "Check" & wait

# Risk-aware coordination
@npl-project-coordinator "Execute with monitoring" && \
  @npl-risk-monitor "Assess risks"
```

See [Detailed Reference: Integration Patterns](./npl-project-coordinator.detailed.md#integration-patterns) for sequential, parallel, and hybrid strategies.

## Coordination Strategies

| Strategy | Use Case |
|:---------|:---------|
| Sequential | Strict dependency ordering |
| Parallel | Independent tasks, time optimization |
| Hybrid | Sequential phases with parallel sub-tasks |
| Adaptive | Runtime condition adjustments |

See [Detailed Reference: Coordination Strategies](./npl-project-coordinator.detailed.md#coordination-strategies) for strategy selection guidance.

## Success Metrics

| Metric | Target |
|:-------|:-------|
| Workflow completion | >95% |
| Handoff success | >98% |
| Parallel efficiency | >80% |
| Blocker detection | <5 min |

## See Also

- [Detailed Reference](./npl-project-coordinator.detailed.md) - Complete specification
- [Best Practices](./npl-project-coordinator.detailed.md#best-practices) - Design and execution guidance
- [Limitations](./npl-project-coordinator.detailed.md#limitations) - Known constraints
- [Project Management README](./README.md) - Category overview
