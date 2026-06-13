# PRD-012: Multi-Agent Orchestration Framework

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

The NPL framework documents 5 orchestration patterns for multi-agent coordination, but no implementation exists. Multi-agent workflows require structured coordination for consensus-building, pipeline execution, hierarchical decomposition, iterative refinement, and parallel synthesis. This PRD defines the complete orchestration framework including pattern implementations, communication protocols, and worklog integration.

**Current State**:
- 5 orchestration patterns documented
- 0 patterns implemented programmatically
- No inter-agent communication protocol
- No orchestration runtime

**Target State**:
- All 5 patterns implemented with reusable primitives
- Worklog-based communication between agents
- Orchestration engine for pattern execution
- Monitoring and progress tracking

## Problem Statement

Complex workflows require multiple specialized agents working in coordination. Without an orchestration framework:

1. Agents cannot reliably hand off work to each other
2. Consensus-driven decisions cannot be synthesized from multiple perspectives
3. Quality gates cannot enforce validation between pipeline stages
4. Hierarchical task decomposition lacks coordination infrastructure
5. Parallel execution results cannot be merged systematically

The lack of orchestration blocks implementation of TDD workflows, feature assessments, documentation overhauls, and other multi-agent use cases.

## Goals

1. Implement all 5 documented orchestration patterns
2. Provide worklog-based inter-agent communication
3. Enable real-time progress monitoring
4. Support graceful error recovery
5. Allow pattern composition for custom workflows

## Non-Goals

- Building a general-purpose workflow engine (focus is NPL-specific patterns)
- Supporting external orchestration frameworks (self-contained implementation)
- Real-time distributed execution across multiple machines (single-machine orchestration)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Priority |
|----|-------|----------|
| US-058 | [Facilitate Multi-Persona Consensus](../../user-stories/US-058-facilitate-multi-persona-consensus.md) | high |
| US-059 | [Chain Multi-Agent Workflows with Dependencies](../../user-stories/US-059-chain-multi-agent-workflows-with-dependencies.md) | high |
| US-060 | [Cross-Validate Agent Outputs](../../user-stories/US-060-cross-validate-agent-outputs.md) | high |
| US-064 | [Agent Handoff Protocol](../../user-stories/US-064-agent-handoff-protocol.md) | high |
| US-065 | [Parallel Agent Synthesis](../../user-stories/US-065-parallel-agent-synthesis.md) | medium |
| US-066 | [Agent Quality Gates](../../user-stories/US-066-agent-quality-gates.md) | high |
| US-079 | [Define Multi-Agent Orchestration Patterns](../../user-stories/US-079-define-multi-agent-orchestration-patterns.md) | high |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Orchestration Patterns

### Pattern 1: Consensus-Driven Analysis

**Purpose**: Gather multiple perspectives on a single problem, then synthesize into unified recommendation.

**Flow**:
```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Analyst 1  │    │   Analyst 2  │    │   Analyst 3  │
│  (Technical) │    │  (Marketing) │    │  (Security)  │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                    ┌──────▼──────┐
                    │ Synthesizer │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Decision  │
                    └─────────────┘
```

**Components**:
- **Analysts**: Parallel agents analyzing from distinct perspectives
- **Synthesizer**: Agent combining findings into cohesive recommendation
- **Voting Protocol**: Optional weighted voting before synthesis

See [FR-005](./functional-requirements/FR-005-consensus-pattern-implementation.md) for implementation details.

---

### Pattern 2: Pipeline with Quality Gates

**Purpose**: Sequential processing with validation checkpoints ensuring quality before proceeding.

**Flow**:
```
┌─────────┐    ┌──────────┐    ┌─────────┐    ┌──────────┐    ┌───────────┐
│Research │───►│ Validate │───►│ Design  │───►│ Validate │───►│Implement  │
└─────────┘    └──────────┘    └─────────┘    └──────────┘    └───────────┘
                   │                              │
                   ▼ (fail)                       ▼ (fail)
              ┌─────────┐                    ┌─────────┐
              │ Rework  │                    │ Rework  │
              └─────────┘                    └─────────┘
```

**Components**:
- **Stages**: Sequential processing steps with specific agents
- **Gates**: Validation checkpoints between stages
- **Feedback Loops**: Rework paths when validation fails

See [FR-006](./functional-requirements/FR-006-pipeline-pattern-implementation.md) for implementation details.

---

### Pattern 3: Hierarchical Task Decomposition

**Purpose**: Break complex problems into subtasks, assign to specialized teams, aggregate results.

**Flow**:
```
                    ┌─────────────────┐
                    │   Coordinator   │
                    └────────┬────────┘
                             │ decompose
           ┌─────────────────┼─────────────────┐
           ▼                 ▼                 ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │  Arch Team   │  │  Impl Team   │  │  Docs Team   │
    └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
           │                 │                 │
           └─────────────────┼─────────────────┘
                             │ synthesize
                    ┌────────▼────────┐
                    │   Coordinator   │
                    └─────────────────┘
```

**Components**:
- **Coordinator**: Decomposes problem, assigns to teams, aggregates results
- **Teams**: Groups of agents working on specific aspects
- **Subproblems**: Independent work units with defined interfaces

See [FR-007](./functional-requirements/FR-007-hierarchical-pattern-implementation.md) for implementation details.

---

### Pattern 4: Iterative Refinement Spiral

**Purpose**: Cyclical improvement through multiple analysis/enhancement rounds with quality evaluation.

**Flow**:
```
                ┌─────────────┐
                │   Initial   │
                │   Draft     │
                └──────┬──────┘
                       │
         ┌─────────────▼─────────────┐
         │                           │
    ┌────▼────┐               ┌──────▼──────┐
    │ Analyze │               │   Enhance   │
    │  gaps   │◄──────────────│   content   │
    └────┬────┘               └──────┬──────┘
         │                           │
         └──────────┬────────────────┘
                    │
             ┌──────▼──────┐
             │  Evaluate   │
             │  quality    │
             └──────┬──────┘
                    │
            ┌───────┴───────┐
            ▼               ▼
       [Pass: Done]    [Fail: Loop]
```

**Components**:
- **Analyzer**: Identifies gaps and improvement opportunities
- **Enhancer**: Makes targeted improvements
- **Evaluator**: Scores quality against criteria
- **Termination**: Quality threshold or max iterations

See [FR-008](./functional-requirements/FR-008-iterative-pattern-implementation.md) for implementation details.

---

### Pattern 5: Multi-Perspective Synthesis

**Purpose**: Simultaneous parallel analysis from 4+ viewpoints with structured integration.

**Flow**:
```
    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
    │Technical │ │ Business │ │   User   │ │ Security │
    │Perspective│ │Perspective│ │Perspective│ │Perspective│
    └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘
         │            │            │            │
         └────────────┴────────────┴────────────┘
                           │
                    ┌──────▼──────┐
                    │ Integration │
                    │   Matrix    │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Conflict   │
                    │ Resolution  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Unified    │
                    │   Output    │
                    └─────────────┘
```

**Components**:
- **Perspective Agents**: Parallel analyzers with distinct viewpoints
- **Integration Matrix**: Structured comparison of findings
- **Conflict Resolver**: Handles contradictory conclusions
- **Synthesis Engine**: Produces unified output

See [FR-009](./functional-requirements/FR-009-synthesis-pattern-implementation.md) for implementation details.

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:

| ID | Name | Expected Tests | Coverage |
|----|------|----------------|----------|
| FR-001 | [Orchestration Engine](./functional-requirements/FR-001-orchestration-engine.md) | 18 | 100% |
| FR-002 | [Communication Protocol](./functional-requirements/FR-002-communication-protocol.md) | 13 | 100% |
| FR-003 | [Worklog Integration](./functional-requirements/FR-003-worklog-integration.md) | 11 | 100% |
| FR-004 | [Progress Monitoring](./functional-requirements/FR-004-progress-monitoring.md) | 9 | 100% |
| FR-005 | [Consensus Pattern](./functional-requirements/FR-005-consensus-pattern-implementation.md) | 11 | 100% |
| FR-006 | [Pipeline Pattern](./functional-requirements/FR-006-pipeline-pattern-implementation.md) | 13 | 100% |
| FR-007 | [Hierarchical Pattern](./functional-requirements/FR-007-hierarchical-pattern-implementation.md) | 11 | 100% |
| FR-008 | [Iterative Pattern](./functional-requirements/FR-008-iterative-pattern-implementation.md) | 11 | 100% |
| FR-009 | [Synthesis Pattern](./functional-requirements/FR-009-synthesis-pattern-implementation.md) | 11 | 100% |
| FR-010 | [Pattern Composition](./functional-requirements/FR-010-pattern-composition.md) | 9 | 100% |

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | Pattern overhead | Execution time | < 10% total agent time |
| NFR-3 | Worklog performance | Write latency | < 50ms |
| NFR-4 | Progress updates | Update frequency | Every 5 seconds |
| NFR-5 | Error recovery | Mean time to recovery | < 30 seconds |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid pattern config | ConfigurationError | "Pattern configuration invalid: {reason}" |
| Agent spawn failure | AgentSpawnError | "Failed to spawn agent {agent_id}: {reason}" |
| Worklog write failure | StorageError | "Failed to write worklog entry: {reason}" |
| Execution not found | ExecutionNotFoundError | "Execution {execution_id} not found" |
| Circular dependency | DependencyError | "Circular dependency detected in pattern composition" |
| Gate validation failure | ValidationError | "Quality gate {gate_id} failed: {criteria}" |
| Max retries exceeded | RetryExhaustedError | "Max retry attempts exceeded for {stage}" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Key tests:

| ID | Name | Category | Related FR |
|----|------|----------|------------|
| AT-001 | [Pattern Registration](./acceptance-tests/AT-001-pattern-registration-and-lookup.md) | Unit | FR-001 |
| AT-002 | [Consensus Execution](./acceptance-tests/AT-002-consensus-pattern-execution.md) | Integration | FR-005, FR-001 |
| AT-003 | [Pipeline Gate Failure](./acceptance-tests/AT-003-pipeline-with-gate-failure.md) | Integration | FR-006, FR-001 |
| AT-004 | [Worklog Handoff](./acceptance-tests/AT-004-worklog-handoff-communication.md) | Integration | FR-002, FR-003 |
| AT-005 | [Progress Monitoring](./acceptance-tests/AT-005-progress-monitoring-visibility.md) | Integration | FR-004, FR-001 |
| AT-006 | [Hierarchical Decomposition](./acceptance-tests/AT-006-hierarchical-decomposition-aggregation.md) | Integration | FR-007, FR-001 |
| AT-007 | [Iterative Termination](./acceptance-tests/AT-007-iterative-refinement-termination.md) | Integration | FR-008, FR-001 |
| AT-008 | [Synthesis Conflict Resolution](./acceptance-tests/AT-008-synthesis-pattern-conflict-resolution.md) | Integration | FR-009, FR-001 |
| AT-009 | [Pattern Composition](./acceptance-tests/AT-009-pattern-composition.md) | Integration | FR-010, FR-001 |
| AT-010 | [Error Recovery](./acceptance-tests/AT-010-error-recovery-and-retry.md) | Integration | FR-001, FR-003 |

---

## Success Criteria

1. **Pattern Coverage**: All 5 documented patterns implemented
2. **Worklog Integration**: Agents communicate reliably via worklog
3. **Progress Visibility**: Real-time status available for all orchestrations
4. **Error Recovery**: Failed agents trigger graceful recovery
5. **Composability**: Patterns can be combined for custom workflows
6. **Performance**: Orchestration overhead <10% of total agent execution time
7. **Test Coverage**: >= 80% line coverage for all new code
8. **All Acceptance Tests Passing**: 10/10 acceptance tests pass

---

## Out of Scope

- General-purpose workflow engines (focus is NPL-specific patterns)
- External orchestration framework integration (self-contained implementation)
- Distributed execution across multiple machines (single-machine focus)
- Real-time streaming of large datasets between agents
- Visual workflow editors (configuration via YAML/Python only)

---

## Dependencies

- **Worklog System**: Session-based worklog with cursor tracking
- **Agent Registry**: Catalog of available agents with capabilities
- **Task Queue**: Async task execution infrastructure
- **SQLite Database**: Persistent storage for execution state
- **FastMCP Framework**: MCP tool integration

---

## Architecture Notes

### Pattern Registry

```python
PATTERN_REGISTRY = {
    "consensus": ConsensusPattern,
    "pipeline": PipelinePattern,
    "hierarchical": HierarchicalPattern,
    "iterative": IterativePattern,
    "synthesis": SynthesisPattern,
}
```

### Pattern Base Class

All patterns inherit from `OrchestrationPattern` with standard interface for validation, execution, and agent assignment.

### Worklog Storage

- File: `.npl/sessions/YYYY-MM-DD/worklog.jsonl`
- Cursors: `.npl/sessions/YYYY-MM-DD/.cursors/{agent_id}`
- Summaries: `.npl/sessions/YYYY-MM-DD/.summary.md`

---

## Open Questions

- [ ] Should patterns support pause/resume at sub-stage granularity?
- [ ] How to handle agent version mismatches during orchestration?
- [ ] Should worklog entries be encrypted for sensitive workflows?
- [ ] What is the maximum reasonable orchestration depth for composites?

---

## Legacy Reference

- **Orchestration Patterns**: `.tmp/docs/multi-agent-orchestration.brief.md`
- **Pattern Examples**: `.tmp/docs/orchestration/summary.brief.md`
- **Orchestration Examples**: `.tmp/docs/orchestration-examples.brief.md`
