# PRD-011: Multi-Agent Orchestration Framework

**Version**: 1.0
**Status**: Draft
**Owner**: NPL Framework Team
**Last Updated**: 2026-02-02

---

## Executive Summary

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

---

## Problem Statement

Complex workflows require multiple specialized agents working in coordination. Without an orchestration framework:

1. Agents cannot reliably hand off work to each other
2. Consensus-driven decisions cannot be synthesized from multiple perspectives
3. Quality gates cannot enforce validation between pipeline stages
4. Hierarchical task decomposition lacks coordination infrastructure
5. Parallel execution results cannot be merged systematically

The lack of orchestration blocks implementation of TDD workflows, feature assessments, documentation overhauls, and other multi-agent use cases.

---

## User Stories

| Story ID | Description |
|----------|-------------|
| US-058 | As a developer, I want consensus-driven feature assessment from technical, marketing, and security perspectives |
| US-059 | As a developer, I want pipeline execution with quality gates between stages |
| US-060 | As a developer, I want complex problems decomposed into subtasks assigned to specialized agents |
| US-061 | As a developer, I want iterative refinement with quality scoring at each round |
| US-062 | As a developer, I want parallel analysis from multiple viewpoints merged into unified output |
| US-063 | As a developer, I want progress visibility during long-running orchestrations |
| US-064 | As a developer, I want failed orchestrations to recover gracefully |
| US-065 | As a developer, I want orchestration patterns to be composable for custom workflows |
| US-079 | As a developer, I want worklog-based communication between parent and child agents |

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
                    │ (@thinker)  │
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

**Configuration**:
```yaml
pattern: consensus
name: "Feature Assessment"
analysts:
  - agent: npl-technical-writer
    perspective: "technical feasibility"
    weight: 1.0
  - agent: npl-marketing-writer
    perspective: "market value"
    weight: 0.8
  - agent: npl-threat-modeler
    perspective: "security implications"
    weight: 1.2
synthesizer:
  agent: npl-thinker
  mode: synthesis
decision:
  format: recommendation
  include_dissent: true
```

**Outputs**:
- Individual analyst reports
- Synthesis summary with weighted considerations
- Final recommendation with confidence score
- Dissenting viewpoints (if any)

---

### Pattern 2: Pipeline with Quality Gates

**Purpose**: Sequential processing with validation checkpoints ensuring quality before proceeding.

**Flow**:
```
┌─────────┐    ┌──────────┐    ┌─────────┐    ┌──────────┐    ┌───────────┐
│Research │───►│ Validate │───►│ Design  │───►│ Validate │───►│Implement  │
│ @scout  │    │ @grader  │    │ @author │    │ @grader  │    │@tdd-builder│
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

**Configuration**:
```yaml
pattern: pipeline
name: "Agent Development Pipeline"
stages:
  - name: research
    agent: gopher-scout
    output: research.md
  - name: validate-research
    agent: npl-grader
    criteria: ["completeness", "accuracy"]
    threshold: 0.8
    on_fail: retry_previous
  - name: design
    agent: npl-author
    input: research.md
    output: agent-spec.md
  - name: generate-tests
    agent: npl-qa
    input: agent-spec.md
    output: test-cases.md
  - name: implement
    agent: tdd-driven-builder
    inputs: [agent-spec.md, test-cases.md]
    output: implementation/
  - name: validate-final
    agent: npl-grader
    criteria: ["npl-compliance", "test-coverage", "functionality"]
    threshold: 0.9
    on_fail: escalate
```

**Gate Behavior**:
- **Pass**: Proceed to next stage
- **Retry**: Return to previous stage with feedback
- **Escalate**: Flag for human review
- **Abort**: Terminate pipeline with error

---

### Pattern 3: Hierarchical Task Decomposition

**Purpose**: Break complex problems into subtasks, assign to specialized teams, aggregate results.

**Flow**:
```
                    ┌─────────────────┐
                    │   Coordinator   │
                    │   (@thinker)    │
                    └────────┬────────┘
                             │ decompose
           ┌─────────────────┼─────────────────┐
           ▼                 ▼                 ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │  Arch Team   │  │  Impl Team   │  │  Docs Team   │
    ├──────────────┤  ├──────────────┤  ├──────────────┤
    │@system-analyzer│ │@tdd-builder  │  │@tech-writer  │
    │@tech-writer   │  │@qa-tester    │  │@marketing    │
    └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
           │                 │                 │
           └─────────────────┼─────────────────┘
                             │ synthesize
                    ┌────────▼────────┐
                    │   Coordinator   │
                    │   (aggregate)   │
                    └─────────────────┘
```

**Components**:
- **Coordinator**: Decomposes problem, assigns to teams, aggregates results
- **Teams**: Groups of agents working on specific aspects
- **Subproblems**: Independent work units with defined interfaces

**Configuration**:
```yaml
pattern: hierarchical
name: "CLI Tool Development"
coordinator: npl-thinker
decomposition:
  levels: 3
  strategy: domain-based
teams:
  - name: architecture
    agents: [npl-system-analyzer, npl-technical-writer]
    focus: "System design and architecture documentation"
  - name: implementation
    agents: [tdd-driven-builder, npl-qa-tester]
    focus: "Code implementation with tests"
  - name: documentation
    agents: [npl-technical-writer, npl-marketing-writer]
    focus: "User guides and marketing materials"
aggregation:
  strategy: structured_merge
  conflict_resolution: coordinator_decides
```

**Decomposition Strategies**:
- **Domain-based**: Split by functional domain
- **Phase-based**: Split by development phase
- **Complexity-based**: Split by estimated effort
- **Parallel-first**: Maximize parallelizable subtasks

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

**Configuration**:
```yaml
pattern: iterative
name: "Documentation Refinement"
initial:
  agent: npl-technical-writer
  output: draft.md
iterations:
  max: 5
  min_improvement: 0.05
  stages:
    - name: analyze
      agent: npl-grader
      mode: gap_analysis
      output: gaps.md
    - name: enhance
      agent: npl-technical-writer
      inputs: [draft.md, gaps.md]
      focus: "Address identified gaps"
    - name: evaluate
      agent: npl-grader
      criteria: ["completeness", "clarity", "accuracy", "structure"]
      threshold: 0.85
termination:
  condition: threshold_met OR max_iterations
  output: final.md
```

**Iteration Control**:
- **Threshold Met**: Quality score exceeds target
- **Max Iterations**: Hard limit on refinement rounds
- **Diminishing Returns**: Improvement delta below minimum
- **Resource Limit**: Token/time budget exhausted

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

**Configuration**:
```yaml
pattern: synthesis
name: "Requirement Validation"
perspectives:
  - name: technical
    agent: npl-technical-writer
    focus: "Implementation feasibility and constraints"
  - name: business
    agent: npl-marketing-writer
    focus: "Market value and competitive advantage"
  - name: user
    agent: npl-persona
    roles: [power-user, novice, admin]
    focus: "User needs and experience"
  - name: security
    agent: npl-threat-modeler
    focus: "Security risks and compliance"
integration:
  format: matrix
  dimensions: [feasibility, value, risk, effort]
  conflict_strategy: weighted_vote
  weights:
    technical: 1.0
    business: 0.8
    user: 1.2
    security: 1.1
output:
  format: recommendation
  sections: [summary, matrix, conflicts, decision]
```

**Conflict Resolution Strategies**:
- **Weighted Vote**: Perspectives vote with configured weights
- **Coordinator Decides**: Synthesizer agent makes final call
- **Escalate**: Flag for human decision
- **Conservative**: Choose lowest-risk option

---

## Functional Requirements

### 1. Orchestration Engine

```python
class OrchestrationEngine:
    """Executes orchestration patterns with agent coordination."""

    def execute(self, pattern: PatternConfig, context: ExecutionContext) -> OrchestrationResult:
        """Execute a configured orchestration pattern."""

    def pause(self, execution_id: str) -> None:
        """Pause a running orchestration."""

    def resume(self, execution_id: str) -> None:
        """Resume a paused orchestration."""

    def cancel(self, execution_id: str) -> None:
        """Cancel a running orchestration."""

    def status(self, execution_id: str) -> ExecutionStatus:
        """Get current execution status and progress."""
```

### 2. Communication Protocol

Agent-to-agent communication via worklog:

```yaml
# Worklog entry format
entry:
  id: "entry-uuid"
  timestamp: "2026-02-02T14:30:00Z"
  source_agent: "gopher-scout"
  target_agent: "npl-author"  # or "*" for broadcast
  entry_type: handoff | request | response | status | error
  payload:
    action: "completed_research"
    outputs:
      - file: "research.md"
        artifact_id: "art-123"
    next_steps:
      - "Create agent specification from research"
    metadata:
      tokens_used: 4500
      duration_ms: 12000
```

**Communication Patterns**:
- **Handoff**: Pass work to next agent in sequence
- **Request/Response**: Ask agent for specific output
- **Broadcast**: Notify all agents in orchestration
- **Status Update**: Progress reporting to coordinator

### 3. Worklog Integration

```python
class WorklogCoordinator:
    """Manages inter-agent communication via worklog."""

    def write(self, entry: WorklogEntry) -> None:
        """Append entry to shared worklog."""

    def read(self, agent_id: str, since_cursor: str = None) -> list[WorklogEntry]:
        """Read entries for agent since cursor position."""

    def subscribe(self, agent_id: str, callback: Callable) -> None:
        """Subscribe to real-time worklog updates."""

    def get_cursor(self, agent_id: str) -> str:
        """Get agent's current cursor position."""

    def set_cursor(self, agent_id: str, cursor: str) -> None:
        """Update agent's cursor position."""
```

**Worklog Storage**:
- File: `.npl/sessions/YYYY-MM-DD/worklog.jsonl`
- Cursors: `.npl/sessions/YYYY-MM-DD/.cursors/{agent_id}`
- Summaries: `.npl/sessions/YYYY-MM-DD/.summary.md`

### 4. Progress Monitoring

```python
class ProgressMonitor:
    """Tracks orchestration progress and provides visibility."""

    def get_progress(self, execution_id: str) -> ProgressReport:
        """Get current progress across all stages/agents."""

    def get_timeline(self, execution_id: str) -> list[TimelineEvent]:
        """Get chronological event timeline."""

    def get_metrics(self, execution_id: str) -> Metrics:
        """Get execution metrics (duration, tokens, errors)."""
```

**Progress Report**:
```yaml
progress:
  execution_id: "exec-123"
  pattern: "pipeline"
  status: in_progress
  started_at: "2026-02-02T14:00:00Z"
  stages:
    - name: research
      status: completed
      agent: gopher-scout
      duration_ms: 15000
    - name: validate-research
      status: completed
      agent: npl-grader
      score: 0.87
    - name: design
      status: in_progress
      agent: npl-author
      progress: 0.6
    - name: implement
      status: pending
  estimated_completion: "2026-02-02T14:45:00Z"
  metrics:
    total_tokens: 12500
    error_count: 0
```

---

## Architecture

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

```python
class OrchestrationPattern(ABC):
    """Base class for orchestration patterns."""

    @abstractmethod
    def validate_config(self, config: dict) -> ValidationResult:
        """Validate pattern configuration."""

    @abstractmethod
    def execute(self, context: ExecutionContext) -> OrchestrationResult:
        """Execute the orchestration pattern."""

    @abstractmethod
    def get_agent_assignments(self) -> list[AgentAssignment]:
        """Get list of agents required for this pattern."""
```

### Composable Patterns

Patterns can be composed for complex workflows:

```yaml
pattern: composite
name: "Full Feature Development"
stages:
  - pattern: consensus
    name: "Feature Assessment"
    # ... consensus config
  - pattern: pipeline
    name: "Implementation Pipeline"
    depends_on: ["Feature Assessment"]
    # ... pipeline config
  - pattern: iterative
    name: "Documentation Polish"
    depends_on: ["Implementation Pipeline"]
    # ... iterative config
```

---

## Success Criteria

1. **Pattern Coverage**: All 5 documented patterns implemented
2. **Worklog Integration**: Agents communicate reliably via worklog
3. **Progress Visibility**: Real-time status available for all orchestrations
4. **Error Recovery**: Failed agents trigger graceful recovery
5. **Composability**: Patterns can be combined for custom workflows
6. **Performance**: Orchestration overhead <10% of total agent execution time

---

## Testing Strategy

### Unit Tests
- Pattern configuration validation
- Worklog entry parsing and writing
- Progress calculation accuracy

### Integration Tests
- Multi-agent handoffs through worklog
- Gate validation and feedback loops
- Parallel execution synchronization

### E2E Tests
- Complete consensus pattern with 3+ agents
- Pipeline with gate failures and retries
- Hierarchical decomposition with team coordination

---

## Legacy Reference

- **Orchestration Patterns**: `.tmp/docs/multi-agent-orchestration.brief.md`
- **Pattern Examples**: `.tmp/docs/orchestration/summary.brief.md`
- **Orchestration Examples**: `.tmp/docs/orchestration-examples.brief.md`
