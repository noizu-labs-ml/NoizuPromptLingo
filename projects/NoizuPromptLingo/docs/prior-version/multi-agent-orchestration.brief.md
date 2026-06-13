# Multi-Agent Orchestration Patterns

**Type**: Framework / Methodology
**Category**: Agent Coordination
**Status**: Core

## Purpose

Multi-agent orchestration enables complex workflows by coordinating specialized NPL agents through structured patterns. Rather than relying on a single agent to handle all aspects of a problem, orchestration distributes work across agents with complementary capabilities—research, development, validation, documentation, and analysis—maximizing parallel execution, domain expertise, and quality through validation gates.

This system transforms linear workflows into sophisticated coordination networks where agents collaborate through clear handoffs, shared knowledge bases, and iterative feedback loops. The patterns documented here provide reusable blueprints for common multi-agent scenarios, from consensus-driven decision-making to hierarchical task decomposition.

## Key Capabilities

- **Consensus-driven analysis** - Multiple agents analyze problems from different perspectives (technical, marketing, security) then synthesize findings
- **Pipeline with quality gates** - Sequential processing with validation checkpoints and feedback loops between creation, testing, and refinement stages
- **Hierarchical decomposition** - Break complex problems into specialized sub-tasks with dedicated agent teams (architecture, implementation, documentation)
- **Iterative refinement spirals** - Cyclical improvement through multiple analysis/enhancement rounds with quality evaluation at each iteration
- **Multi-perspective synthesis** - Simultaneous viewpoint analysis with structured integration matrix and conflict resolution
- **Dynamic agent selection** - Runtime agent routing based on problem type and context characteristics

## Usage & Integration

**Triggered by**: Complex workflows requiring specialized expertise, quality validation, or parallel execution
**Outputs to**: Consolidated artifacts, validated deliverables, comprehensive analysis reports
**Complements**: Individual agent capabilities, task tracking systems, quality assurance processes

Multi-agent patterns are invoked explicitly through scripted workflows or dynamically based on problem analysis. Agents communicate through artifact handoffs, shared knowledge bases, and worklog entries. Coordination occurs at multiple levels: sequential pipelines for staged workflows, parallel execution for independent analyses, and hierarchical networks for complex decomposition.

## Core Operations

### Consensus-Driven Feature Assessment
```bash
# Parallel analysis from different perspectives
@npl-technical-writer analyze "Add real-time collaboration" --focus="technical feasibility"
@npl-marketing-writer analyze "Add real-time collaboration" --focus="market value"
@npl-threat-modeler analyze "Add real-time collaboration" --focus="security implications"

# Synthesis and decision
@npl-thinker synthesize "[technical],[marketing],[security]" --decision="implementation recommendation"
```

### Pipeline with Quality Gates (NPL Agent Development)
```bash
# Research → Validation → Design → Test → Implement → Final Review
@npl-gopher-scout research "agent patterns for code review"
@npl-grader validate research.md --criteria="completeness,accuracy"
@npl-author create agent-spec --name="code-reviewer" --based-on=research.md
@npl-qa-tester generate test-cases agent-spec.md
@npl-tdd-builder implement agent-spec.md --test-cases=test-cases.md
@npl-grader validate final-agent.md --criteria="npl-compliance,functionality"
```

### Hierarchical Task Decomposition
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

## Agent Roster

| Category | Agents | Primary Function |
|----------|--------|------------------|
| **Analysis & Research** | `@npl-gopher-scout`, `@npl-system-analyzer` | Framework exploration, system documentation |
| **Development** | `@npl-author`, `@npl-tool-creator`, `@npl-tdd-builder`, `@npl-tool-forge` | NPL creation, CLI development, TDD implementation |
| **Quality** | `@npl-grader`, `@npl-qa-tester`, `@npl-qa` | Validation, test case generation, analysis |
| **Documentation** | `@npl-technical-writer`, `@npl-marketing-writer`, `@nb`, `@npl-system-digest` | Technical docs, marketing content, knowledge management |
| **Planning** | `@npl-thinker`, `@npl-persona`, `@npl-threat-modeler`, `@nimps` | Multi-cognitive reasoning, security analysis, project planning |

## Integration Points

- **Upstream dependencies**: Problem decomposition, requirements analysis, resource availability
- **Downstream consumers**: Consolidated artifacts, validated deliverables, comprehensive reports
- **Related utilities**: `npl-session` (worklog communication), `npl-persona` (simulated identities), task tracking systems

Orchestration patterns integrate with session management for cross-agent communication via `worklog.jsonl` and agent-specific cursors (`.npl/sessions/YYYY-MM-DD/.cursors/`). Agents read summaries first (`.summary.md`), then fetch detailed sections (`.detailed.md`) as needed. Dynamic agent selection leverages `@npl-thinker` for problem-type analysis and conditional routing.

## Advanced Coordination

**Error Recovery Network**: Multi-layered handling with escalation—local recovery via diagnostics (`@npl-grader`), retry with fixes, expert escalation (`@npl-thinker` deep analysis) if primary recovery fails.

**Knowledge Sharing Network**: Agents contribute to shared KB (`@npl-gopher-scout` research, `@npl-system-analyzer` documentation), query KB for context, validate entries via cross-reference.

**Dynamic Agent Selection**: Context analysis (`@npl-thinker`) determines problem type, routes to appropriate agent (technical → `@npl-technical-writer`, creative → `@npl-fim`, security → `@npl-threat-modeler`).

## Limitations & Constraints

- **Over-coordination risk**: Excessive overhead slows simple tasks; use 2-3 agents initially before scaling
- **Context propagation**: Important context must be explicitly passed through agent chains to avoid loss
- **State inconsistency**: Agents working in parallel require shared state management to avoid conflicts
- **Bottleneck identification**: Single-agent choke points require load distribution or capability enhancement
- **Coordination complexity**: Network effects grow with agent count; hierarchical patterns mitigate but don't eliminate complexity

## Success Indicators

- **Throughput**: Tasks completed per unit time exceeds single-agent baseline
- **Quality**: Validation scores show improvement over single-agent outputs (measured via `@npl-grader` criteria)
- **Efficiency**: Coordination overhead < 25% of total execution time
- **Reliability**: Success rate ≥ 85%, graceful failure handling with recovery paths
- **Scalability**: Performance degradation < 20% as problem complexity doubles

**Monitoring**: Progress tracking via validation checkpoints, agent performance metrics, quality scores, error rates with recovery success percentages.

---
**Generated from**: worktrees/main/docs/multi-agent-orchestration.md
