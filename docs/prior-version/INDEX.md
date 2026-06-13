# Documentation Index

## Specifications Briefs

These are concise summaries of the core specification documents from `worktrees/main/core/specifications/`:

### [prd-spec.brief.md](./prd-spec.brief.md)
**PRD Specification** - Convention for structuring Product Requirements Documents

- Design principles: clarity, completeness, testability, traceability, prioritization
- Core NPL directives for PRD structure
- Main file template (200-400 lines max) + sub-files
- Priority levels (P0-P3)
- Quality checklist with SMART requirements
- Agent integration points

### [project-arch-spec.brief.md](./project-arch-spec.brief.md)
**PROJECT-ARCH Specification** - Convention for architecture documentation

- Design principles: modularity, discoverability, consistency, progressive detail
- Architectural layers, domain model, patterns, infrastructure
- Main file template + 7 sub-file types (layers, domain, patterns, infrastructure, auth, database, api)
- Agent integration (gopher-scout, project-coordinator)
- Quick reference directives and cross-reference syntax

### [project-layout-spec.brief.md](./project-layout-spec.brief.md)
**PROJECT-LAYOUT Specification** - Convention for directory structure documentation

- 11 required sections for comprehensive layout documentation
- Tree diagram conventions and annotation style
- Framework-specific adaptations (Rails, Django, Phoenix, Next.js, Express)
- Validation checklist
- Naming conventions and quick reference guide

---

## Folder Summaries

These are comprehensive guides to major subsystems and patterns:

### [agents.summary.md](./agents.summary.md)
**Core Agents** - Specialized AI personas for workflow tasks

- TDD Workflow Agents (coder, tester, debugger)
- Discovery & Analysis Agents (gopher-scout, grader, threat-modeler)
- Documentation & Planning Agents (technical-writer, project-coordinator)
- Code & Infrastructure Agents (build-master, sql-architect, perf-profiler)
- Utility & Support Agents (persona, thinker, templater)
- File structure and integration patterns

### [additional-agents.summary.md](./additional-agents.summary.md)
**Extended Agents** - Domain-specific agent library

- Infrastructure agents (build-manager, code-reviewer, prototyper)
- Quality assurance agents (validator, tester, integrator, benchmarker)
- Marketing agents (community, conversion, marketing-copy, positioning)
- User experience agents (accessibility, onboarding, performance, user-researcher)
- Project management agents (technical-reality-checker, risk-monitor, impact-assessor)
- Research agents (validator, performance-monitor, claude-optimizer)
- Usage patterns and workflow integration

### [orchestration.summary.md](./orchestration.summary.md)
**Agent Orchestration** - Multi-agent workflow system

- Primary TDD workflow (5-phase pipeline)
- Agent roles & responsibilities (discovery → specification → testing → implementation → debug)
- Command-and-control modes (lone-wolf, team-member, task-master)
- Session management with cursor-based worklog
- Parallel execution patterns for batch processing
- Heavy parallelization best practices
- Monitoring, health, and debugging multi-agent workflows

### [commands.summary.md](./commands.summary.md)
**Commands** - Documented command workflows

- Project initialization commands (full vs. fast)
- Data & metadata generation commands
- Command structure and parameters
- Integration with TDD workflow and agents
- Typical usage patterns and examples

### [scripts.summary.md](./scripts.summary.md)
**Scripts** - Utility scripts for codebase operations

- **npl-load** - Resource loader with hierarchical path resolution
- **npl-persona** - Persona lifecycle management
- **npl-worklog/npl-session** - Cross-agent communication via shared worklog
- **npl-fim-config** - Visualization tool compatibility queries
- **Codebase exploration** - dump-files, git-tree, git-tree-depth
- Script organization and integration patterns

### [fastmcp.summary.md](./fastmcp.summary.md)
**FastMCP** - MCP server framework and architecture

- FastMCP overview and key characteristics
- Core packages (unified, launcher, storage, artifacts, web, etc.)
- Server architecture and entry points
- Process management and lifecycle
- Tool types and integration with Claude
- Running the server (minimal, full, development)
- Testing, deployment, and configuration
- Development workflow

### [prompts.summary.md](./prompts.summary.md)
**Prompts** - Prompt templates and agent behavior definitions

- Sub-agent prompts for reusable batch processing
- Agent definitions and personas
- CLAUDE.md instructions
- Batch processing template pattern (create → test → scale)
- Prompt versioning and maintenance workflow
- Quality checklist for prompts
- Integration with agent invocation and parallel execution
- Prompt storage and access (project, user, system levels)
- Chain-of-thought, checklist, and template-fill prompt types

---

## Quick Navigation

### By Role
- **Project Manager**: Start with [orchestration.summary.md](./orchestration.summary.md)
- **Agent Developer**: Read [agents.summary.md](./agents.summary.md) + [scripts.summary.md](./scripts.summary.md)
- **Documentation Writer**: Review [prd-spec.brief.md](./prd-spec.brief.md) + [project-arch-spec.brief.md](./project-arch-spec.brief.md)
- **DevOps/Infrastructure**: Check [fastmcp.summary.md](./fastmcp.summary.md) + [commands.summary.md](./commands.summary.md)

### By Task
- **Understand the workflow**: [orchestration.summary.md](./orchestration.summary.md)
- **Work with agents**: [agents.summary.md](./agents.summary.md) + [additional-agents.summary.md](./additional-agents.summary.md)
- **Write specifications**: [prd-spec.brief.md](./prd-spec.brief.md)
- **Document architecture**: [project-arch-spec.brief.md](./project-arch-spec.brief.md)
- **Navigate codebase**: [project-layout-spec.brief.md](./project-layout-spec.brief.md)
- **Run commands**: [commands.summary.md](./commands.summary.md)
- **Use utility scripts**: [scripts.summary.md](./scripts.summary.md)
- **Deploy server**: [fastmcp.summary.md](./fastmcp.summary.md)
- **Create prompts**: [prompts.summary.md](./prompts.summary.md)

### By System
- **Core Framework**: [fastmcp.summary.md](./fastmcp.summary.md)
- **Agents**: [agents.summary.md](./agents.summary.md) + [additional-agents.summary.md](./additional-agents.summary.md)
- **Workflow**: [orchestration.summary.md](./orchestration.summary.md)
- **Specifications**: [prd-spec.brief.md](./prd-spec.brief.md), [project-arch-spec.brief.md](./project-arch-spec.brief.md), [project-layout-spec.brief.md](./project-layout-spec.brief.md)
- **Tooling**: [scripts.summary.md](./scripts.summary.md) + [commands.summary.md](./commands.summary.md)

---

## Document Relationships

```
Specifications (What documents should contain)
├── prd-spec.brief.md ─────────────────┐
├── project-arch-spec.brief.md ────────┤
└── project-layout-spec.brief.md ──────┤
                                       ├─→ Used by agents to generate docs
                                       │
Agents & Orchestration (Who does the work)
├── agents.summary.md ──────┐
├── additional-agents.summary.md │
└── orchestration.summary.md ────┤
                                 ├─→ Enabled by infrastructure
                                 │
Infrastructure & Tools
├── fastmcp.summary.md ─────┐
├── scripts.summary.md ─────│
├── commands.summary.md ────┤
└── prompts.summary.md ─────┘
```

---

## Key Concepts Across All Documents

### Modularity
- Specifications emphasize splitting main files when exceeding 50-100 lines
- Agents specialize to focused responsibilities
- Prompts are reusable templates, not monolithic
- Scripts are independent and composable

### Traceability
- Requirements trace to stories, user goals, and business objectives
- Sessions track agent work via worklog
- Personas maintain journals of decisions and learnings
- Artifacts are versioned and reviewed

### Orchestration
- TDD workflow coordinates 5 specialized agent phases
- Parallel execution scales through batch processing templates
- Session worklog enables async agent communication
- Extensions through additional agents

### Integration Points
- Agents read/write session worklogs
- Scripts (npl-load, npl-persona) support agent needs
- FastMCP provides tool invocation for agents
- Prompts guide agent behavior consistently

---

## Usage Patterns

### For First-Time Users
1. Read [orchestration.summary.md](./orchestration.summary.md) to understand workflow
2. Review [agents.summary.md](./agents.summary.md) to see available agents
3. Check [scripts.summary.md](./scripts.summary.md) for utility commands
4. Reference [commands.summary.md](./commands.summary.md) to bootstrap projects

### For Advanced Users
1. Study [prompts.summary.md](./prompts.summary.md) for batch processing
2. Review [orchestration.summary.md](./orchestration.summary.md) parallel patterns
3. Extend with [additional-agents.summary.md](./additional-agents.summary.md)
4. Deep dive into specifications briefs for quality standards

### For Project Setup
1. Read specifications briefs to understand documentation conventions
2. Use [commands.summary.md](./commands.summary.md) to initialize
3. Reference [project-layout-spec.brief.md](./project-layout-spec.brief.md) during development
4. Deploy using [fastmcp.summary.md](./fastmcp.summary.md)

---

## Document Maintenance

All documents in this directory are summaries created from source specifications:
- **Source**: `worktrees/main/core/specifications/` and `worktrees/main/core/*/`
- **Updated**: When specifications or patterns change
- **Location**: `.tmp/docs/` for session-scoped access, can be moved to persistent location

Last generated: 2026-02-02

---

## Related Resources

- **Project Root**: CLAUDE.md - Project instructions and best practices
- **Specifications Source**: `worktrees/main/core/specifications/*.md`
- **Agent Definitions**: `worktrees/main/core/agents/*.md`
- **Additional Agents**: `worktrees/main/core/additional-agents/*/`
- **Commands**: `worktrees/main/core/commands/*.md`
- **Scripts**: `worktrees/main/core/scripts/`
