# Orchestration Examples

**Type**: Documentation
**Category**: root
**Status**: Core

## Purpose

Provides real-world patterns for coordinating multiple NPL agents in complex, multi-phase workflows. Demonstrates practical orchestration strategies across five comprehensive scenarios: agent development, documentation overhaul, security hardening, tool ecosystem creation, and knowledge base development. Each example shows how to combine parallel execution, validation gates, and iterative refinement to achieve production-quality results systematically.

These examples serve as templates for implementing multi-agent coordination in similar scenarios, showcasing best practices for resource management, quality assurance, and team collaboration patterns.

## Key Capabilities

- **Complete Agent Development Lifecycle**: Six-phase workflow from research through production deployment with TDD approach
- **Documentation System Overhaul**: Multi-perspective content creation with user research and usability testing
- **Security Assessment Pipeline**: Comprehensive threat analysis, risk assessment, and hardening implementation
- **Tool Ecosystem Development**: Parallel team coordination for coherent CLI tool suite creation
- **Knowledge Base Creation**: Swarm-based content generation with semantic linking and interactive features

## Usage & Integration

- **Triggered by**: Complex multi-phase projects requiring systematic agent coordination
- **Outputs to**: Executable orchestration scripts with agent invocations and handoff points
- **Complements**: `multi-agent-orchestration.md` (conceptual foundation), agent persona definitions

## Core Operations

### Agent Development Example
```bash
# Phase 1: Parallel research
@npl-gopher-scout research "code review agent patterns" --output=research.md &
@npl-system-analyzer analyze existing-agents/ --output=analysis.md &
wait

# Phase 2: Synthesis
@npl-thinker synthesize research.md analysis.md --goal="agent requirements"

# Phase 3: Validation loop
@npl-author create agent-spec --output=spec-v1.md
@npl-grader validate spec-v1.md --criteria="npl-compliance,completeness"
```

### Documentation Overhaul Pipeline
```bash
# Phase 4: Content creation with checkpoints
for section in $(cat unified-strategy.md | grep "^- " | cut -d' ' -f2); do
    @npl-gopher-scout research $section --output=research-$section.md
    @npl-technical-writer draft $section --output=draft-$section.md
    @npl-grader validate draft-$section.md --criteria="accuracy,clarity" || continue
    @npl-marketing-writer enhance-readability draft-$section.md --output=final-$section.md
done
```

### Security Implementation Loop
```bash
# Phase 4: Iterative control implementation
for control in $(extract-controls security-controls.md); do
    @npl-tdd-builder implement-control $control --test-first
    @npl-threat-modeler validate-control implementations/$control/
    @npl-grader integration-test implementations/$control/
done
```

## Configuration & Parameters

| Pattern | Purpose | Key Flags | Notes |
|---------|---------|-----------|-------|
| Parallel execution | Concurrent agent operations | `&`, `wait` | Resource-efficient research/analysis |
| Validation gates | Quality checkpoints | `\|\|`, conditional flows | Prevents cascading failures |
| Iterative refinement | Progressive improvement | Loop constructs | Continues until criteria met |
| Multi-team coordination | Coordinated parallel work | Grouped `&` blocks | Maintains ecosystem coherence |
| Hierarchical synthesis | Multi-level consolidation | Sequential agent chains | Builds consensus from diverse inputs |

## Integration Points

- **Upstream dependencies**: Agent persona definitions, NPL framework syntax, session management system
- **Downstream consumers**: Project managers, development teams, CI/CD pipelines, documentation systems
- **Related utilities**: `npl-session` (worklog management), `npl-persona` (agent identity management), task tracking systems

## Limitations & Constraints

- Examples assume bash-compatible shell environment with job control (`&`, `wait`)
- Requires all referenced agents to be properly configured and accessible
- Timelines are estimates based on typical complexity; adjust for project scale
- No error recovery patterns shown; production use requires robust error handling
- Assumes sufficient computational resources for parallel agent execution

## Success Indicators

- Clear phase boundaries with explicit handoff mechanisms
- Quality gates at each major milestone using `@npl-grader` validation
- Intermediate outputs enable progress tracking and debugging
- Parallel execution reduces wall-clock time while maintaining quality
- Reproducible patterns applicable across similar scenarios

---
**Generated from**: worktrees/main/docs/orchestration-examples.md
