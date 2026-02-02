# Multi-Agent Orchestration Patterns (from Legacy Documentation)

## Introduction

Multi-agent orchestration enables complex workflows by coordinating specialized NPL agents through structured patterns. Rather than relying on a single agent to handle all aspects of a problem, orchestration distributes work across agents with complementary capabilities—research, development, validation, documentation, and analysis—maximizing parallel execution, domain expertise, and quality through validation gates.

This system transforms linear workflows into sophisticated coordination networks where agents collaborate through clear handoffs, shared knowledge bases, and iterative feedback loops. The patterns documented here provide reusable blueprints for common multi-agent scenarios.

---

## Pattern 1: Consensus-Driven Orchestration

### Description

Multiple agents independently analyze the same problem and propose solutions from different perspectives. A control agent synthesizes proposals through voting, weighted merging, or structured integration to produce a unified recommendation.

### Use Cases

- Architecture decisions requiring multiple viewpoints
- Code reviews with security, performance, and style considerations
- Risk assessment combining technical, business, and compliance perspectives
- Feature prioritization with stakeholder input

### When to Use

- When diverse perspectives improve decision quality
- When no single agent has complete domain expertise
- When validation through multiple lenses reduces bias
- When consensus builds stakeholder buy-in

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  Problem Statement                                              │
└─────────────────────────────────────────────────────────────────┘
              │
              ▼
    ┌─────────┴─────────┐
    │   Parallel Fan-Out │
    └─────────┬─────────┘
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
┌──────┐  ┌──────┐  ┌──────┐
│Agent │  │Agent │  │Agent │
│  A   │  │  B   │  │  C   │
│(Tech)│  │(Biz) │  │(Sec) │
└──────┘  └──────┘  └──────┘
    │         │         │
    └─────────┼─────────┘
              ▼
    ┌─────────────────┐
    │  Synthesis      │
    │  (Voting/Merge) │
    └─────────────────┘
              │
              ▼
    ┌─────────────────┐
    │  Unified Output │
    └─────────────────┘
```

### Implementation Example

```bash
# Parallel analysis from different perspectives
@npl-technical-writer analyze "Add real-time collaboration" --focus="technical feasibility"
@npl-marketing-writer analyze "Add real-time collaboration" --focus="market value"
@npl-threat-modeler analyze "Add real-time collaboration" --focus="security implications"

# Synthesis and decision
@npl-thinker synthesize "[technical],[marketing],[security]" --decision="implementation recommendation"
```

### Implementation Considerations

- Define clear voting weights or merge criteria upfront
- Ensure agents use consistent output formats for synthesis
- Handle conflicting recommendations with explicit resolution rules
- Document dissenting opinions for transparency

---

## Pattern 2: Pipeline with Quality Gates

### Description

Agents arranged in sequential stages with validation checkpoints between handoffs. Each stage transforms input and must pass quality criteria before the next stage begins. Failed gates trigger feedback loops for refinement.

### Use Cases

- Content creation with review cycles
- Document generation with editorial approval
- Multi-stage analysis with validation checkpoints
- Code generation with testing verification

### When to Use

- When work flows through clear transformation stages
- When quality must be verified before proceeding
- When feedback loops improve output quality
- When traceability between stages is required

### Workflow

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ Stage 1 │────▶│  Gate 1 │────▶│ Stage 2 │────▶│  Gate 2 │────▶ ...
└─────────┘     └─────────┘     └─────────┘     └─────────┘
                    │                               │
                    │ (fail)                        │ (fail)
                    ▼                               ▼
              ┌───────────┐                   ┌───────────┐
              │ Feedback  │                   │ Feedback  │
              │   Loop    │                   │   Loop    │
              └───────────┘                   └───────────┘
```

### Implementation Example

```bash
# Research → Validation → Design → Test → Implement → Final Review
@npl-gopher-scout research "agent patterns for code review"
@npl-grader validate research.md --criteria="completeness,accuracy"
@npl-author create agent-spec --name="code-reviewer" --based-on=research.md
@npl-qa-tester generate test-cases agent-spec.md
@npl-tdd-builder implement agent-spec.md --test-cases=test-cases.md
@npl-grader validate final-agent.md --criteria="npl-compliance,functionality"
```

### Implementation Considerations

- Define measurable quality criteria for each gate
- Set maximum retry limits to prevent infinite loops
- Log gate failures for process improvement
- Consider parallel validation for independent criteria

---

## Pattern 3: Hierarchical Task Decomposition

### Description

A control agent breaks complex tasks into subtasks and delegates to specialist agents. Subtasks may be further decomposed recursively. Results are aggregated back up the hierarchy into a unified deliverable.

### Use Cases

- Project planning with work breakdown structures
- Feature implementation across multiple components
- Research synthesis from multiple domains
- Complex analysis requiring specialized expertise

### When to Use

- When complex tasks need expert breakdown
- When specialists provide higher quality for subtasks
- When parallel execution of subtasks is possible
- When aggregation benefits from hierarchical structure

### Workflow

```
┌─────────────────────────────────────────┐
│           Control Agent                  │
│      (Task Decomposition)               │
└─────────────────────────────────────────┘
              │
    ┌─────────┼─────────┬─────────┐
    ▼         ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Subtask │ │Subtask │ │Subtask │ │Subtask │
│   1    │ │   2    │ │   3    │ │   4    │
└────────┘ └────────┘ └────────┘ └────────┘
    │         │         │         │
    └─────────┴─────────┴─────────┘
              │
              ▼
    ┌─────────────────────────────┐
    │     Result Aggregation      │
    └─────────────────────────────┘
              │
              ▼
    ┌─────────────────────────────┐
    │      Unified Deliverable    │
    └─────────────────────────────┘
```

### Implementation Example

```bash
# Master coordinator decomposes problem
@npl-thinker decompose "Create NPL syntax validator CLI tool" --levels=3

# Architecture team
@npl-system-analyzer design architecture --tool="npl-validator"
@npl-technical-writer document architecture.md

# Implementation team
@npl-tool-creator implement cli-interface --spec=architecture.md
@npl-tdd-builder add tests --component=cli-interface

# Documentation team
@npl-technical-writer create user-guide --tool=npl-validator
@npl-marketing-writer create landing-page --product=npl-validator
```

### Implementation Considerations

- Control agent must understand task dependencies
- Define clear interfaces between subtask outputs
- Handle subtask failures with graceful degradation
- Balance decomposition depth against coordination overhead

---

## Pattern 4: Iterative Refinement

### Description

Agents cycle through draft-review-refine loops until a quality threshold is met. Each iteration incorporates feedback to improve the output. The loop terminates when criteria are satisfied or maximum iterations reached.

### Use Cases

- Writing and editing workflows
- Design refinement with stakeholder feedback
- Code optimization through profiling cycles
- Prompt engineering with quality scoring

### When to Use

- When quality improves through iteration
- When feedback can be systematically incorporated
- When "good enough" is measurable
- When diminishing returns justify termination

### Workflow

```
              ┌────────────────────────────────────┐
              │                                    │
              ▼                                    │
        ┌──────────┐                              │
        │  Draft   │                              │
        └──────────┘                              │
              │                                    │
              ▼                                    │
        ┌──────────┐                              │
        │  Review  │                              │
        └──────────┘                              │
              │                                    │
              ▼                                    │
        ┌──────────┐    (score < threshold)       │
        │ Evaluate │──────────────────────────────┘
        └──────────┘
              │
              │ (score >= threshold)
              ▼
        ┌──────────┐
        │  Output  │
        └──────────┘
```

### Implementation Example

```bash
# Initial draft
@npl-technical-writer generate documentation.md

# Review and score
@npl-grader evaluate documentation.md --criteria="clarity,completeness,accuracy"

# If score < 80%, refine and repeat
@npl-technical-writer refine documentation.md --feedback=evaluation.md

# Continue until threshold met or max iterations
```

### Implementation Considerations

- Set realistic quality thresholds and iteration limits
- Capture feedback in structured format for refinement
- Track improvement rate to detect plateaus
- Consider early termination if improvements stall

---

## Pattern 5: Multi-Perspective Synthesis

### Description

Agents analyze from different perspectives in parallel. Each perspective provides unique insights based on its domain expertise. A control agent merges insights into a unified, comprehensive output that incorporates all viewpoints.

### Use Cases

- Stakeholder analysis covering users, business, and technical views
- Impact assessment considering multiple affected parties
- Comprehensive evaluation from diverse criteria
- Design review from accessibility, performance, and usability lenses

### When to Use

- When different viewpoints enrich outcomes
- When comprehensive coverage requires specialized lenses
- When integration of perspectives creates emergent insights
- When stakeholders have diverse concerns

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                        Analysis Target                          │
└─────────────────────────────────────────────────────────────────┘
              │
    ┌─────────┼─────────┬─────────┬─────────┐
    ▼         ▼         ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Perspec-│ │Perspec-│ │Perspec-│ │Perspec-│ │Perspec-│
│tive A  │ │tive B  │ │tive C  │ │tive D  │ │tive N  │
│(User)  │ │(Tech)  │ │(Biz)   │ │(Legal) │ │(...)   │
└────────┘ └────────┘ └────────┘ └────────┘ └────────┘
    │         │         │         │         │
    └─────────┴─────────┴─────────┴─────────┘
              │
              ▼
    ┌─────────────────────────────┐
    │   Insight Collection        │
    └─────────────────────────────┘
              │
              ▼
    ┌─────────────────────────────┐
    │   Synthesis & Integration   │
    └─────────────────────────────┘
              │
              ▼
    ┌─────────────────────────────┐
    │   Unified Output            │
    │   (All perspectives merged) │
    └─────────────────────────────┘
```

### Implementation Example

```bash
# Parallel perspective analysis
@npl-user-researcher analyze feature-x --lens="user needs"
@npl-technical-writer analyze feature-x --lens="implementation complexity"
@npl-threat-modeler analyze feature-x --lens="security implications"
@npl-marketing-writer analyze feature-x --lens="market positioning"

# Synthesis
@npl-thinker synthesize --inputs="[user,tech,security,marketing]" --format="comprehensive-report"
```

### Implementation Considerations

- Define perspectives upfront with clear scope boundaries
- Use consistent output structure for easier synthesis
- Handle conflicting insights with explicit reconciliation
- Weight perspectives based on decision context

---

## Selection Guide: When to Use Each Pattern

| Pattern | Best For | Avoid When |
|---------|----------|------------|
| **Consensus-Driven** | Decisions requiring diverse expertise | Simple, single-domain problems |
| **Pipeline with Gates** | Sequential transformations with quality needs | Highly iterative, non-linear work |
| **Hierarchical Decomposition** | Complex tasks with clear subtask boundaries | Simple tasks; high coordination overhead |
| **Iterative Refinement** | Quality-sensitive outputs with measurable criteria | Time-critical deliverables; subjective quality |
| **Multi-Perspective Synthesis** | Comprehensive analysis from multiple lenses | Single-perspective problems; speed priority |

### Pattern Combinations

Complex workflows often combine patterns:

- **Hierarchical + Pipeline**: Decompose into subtasks, each executed as a pipeline
- **Consensus + Iterative**: Multiple agents vote on iterations until consensus threshold met
- **Multi-Perspective + Pipeline**: Parallel perspectives feed into sequential refinement
- **Pipeline + Hierarchical**: Quality gates delegate failures to specialized repair agents

---

## Limitations & Constraints

- **Over-coordination risk**: Excessive overhead slows simple tasks; use 2-3 agents initially before scaling
- **Context propagation**: Important context must be explicitly passed through agent chains to avoid loss
- **State inconsistency**: Agents working in parallel require shared state management to avoid conflicts
- **Bottleneck identification**: Single-agent choke points require load distribution or capability enhancement
- **Coordination complexity**: Network effects grow with agent count; hierarchical patterns mitigate but don't eliminate complexity

---

## Success Indicators

- **Throughput**: Tasks completed per unit time exceeds single-agent baseline
- **Quality**: Validation scores show improvement over single-agent outputs
- **Efficiency**: Coordination overhead < 25% of total execution time
- **Reliability**: Success rate >= 85%, graceful failure handling with recovery paths
- **Scalability**: Performance degradation < 20% as problem complexity doubles

---

## Legacy Reference

- **Source**: `.tmp/docs/multi-agent-orchestration.brief.md`
- **Original**: `worktrees/main/docs/multi-agent-orchestration.md`

## Implementation Status

**Status**: Documented only

These patterns are architectural blueprints extracted from legacy documentation. Current implementation coverage is minimal. See [PRD-011](../prds/PRD-011-orchestration-framework.md) for implementation roadmap.

---

*Extracted from legacy NPL documentation for reference. Current implementation may vary.*
