# npl-project-coordinator

Cross-agent dependency management and orchestration specialist that coordinates multi-agent workflows, manages handoffs, tracks dependencies, and ensures efficient project execution.

## Purpose

Serves as the central orchestration hub for multi-agent workflows, managing dependencies, sequencing operations, facilitating handoffs, and ensuring optimal coordination between specialized NPL agents. Addresses critical orchestration needs in complex AI/ML project management scenarios.

## Capabilities

- Determine optimal execution order for multi-agent tasks
- Ensure clean transitions and validation between agent operations
- Map and resolve inter-agent dependencies systematically
- Coordinate simultaneous agent operations for maximum efficiency
- Track progress across multiple agent workstreams
- Detect and resolve workflow impediments proactively
- Generate consolidated status updates across all agents

## Usage

```bash
# Orchestrate multi-agent workflow
@npl-project-coordinator "Plan and execute feature development with validation, prototyping, and testing"

# Monitor ongoing project
@npl-project-coordinator "Generate status report for API redesign project involving 5 agents"

# Handle agent handoff
@npl-project-coordinator "Manage handoff from prototyper to code-reviewer with artifacts"

# Resolve workflow conflict
@npl-project-coordinator "Resolve conflicting documentation recommendations"
```

## Workflow Integration

```bash
# Core agent integration
@npl-project-coordinator "Orchestrate validation-prototyping-testing pipeline" && @npl-validator "Validate requirements" && @npl-tester "Execute tests"

# Documentation workflow
@npl-project-coordinator "Manage parallel documentation workflow" && @npl-technical-writer "Generate docs" & @npl-grader "Evaluate all documentation"

# Risk-aware coordination
@npl-project-coordinator "Execute high-risk feature with monitoring" && @npl-risk-monitor "Assess risks" && @npl-technical-reality-checker "Verify feasibility"
```

## See Also

- Core definition: `core/additional-agents/project-management/npl-project-coordinator.md`
- Workflow patterns: Sequential, parallel, and hybrid coordination strategies
- Success metrics: >95% workflow completion, >98% handoff success, >80% parallel efficiency
