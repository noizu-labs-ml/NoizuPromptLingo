# NPL Project Summary

**Type**: Documentation
**Category**: root
**Status**: Core

## Purpose

The NPL Project Summary serves as a quick-reference guide for agents and developers working with the Noizu PromptLingo (NPL) codebase. It provides a consolidated view of the framework's architecture, key components, syntax conventions, and common workflows, enabling rapid onboarding and efficient navigation of the NPL ecosystem.

NPL is an agentic framework for Claude Code that combines structured prompting syntax, pre-built AI agents, a template system, and session management to enable precise semantic communication and multi-agent collaboration.

## Key Capabilities

- **Framework Overview**: Comprehensive introduction to NPL's purpose (structured prompting, pre-built agents, templates, session management)
- **Repository Navigation**: Complete directory structure mapping (`core/`, `npl/`, `mcp-server/`, `docs/`, `demo/`, `experimental/`)
- **Component Catalog**: Quick-reference tables for 16+ core agents, utility scripts, and MCP server tools
- **Syntax Quick Reference**: Essential NPL markers (boundary markers, syntax elements, fences, intuition pumps)
- **Configuration Guide**: `CLAUDE.md` integration, command-and-control modes, environment variables
- **Workflow Examples**: Common task patterns (project setup, agent invocation, session management)

## Usage & Integration

- **Triggered by**: Developer/agent onboarding, codebase exploration, context establishment
- **Outputs to**: Human developers, AI agents (as reference material in prompts/context)
- **Complements**: `npl.md` (full syntax), agent definitions (`core/agents/*.md`), `docs/multi-agent-orchestration.md`

## Core Operations

### Quick Component Lookup

```bash
# View agent catalog
grep -A 10 "Core Agents" summary.md

# Find script reference
grep -A 5 "Utility Scripts" summary.md

# Check environment variables
grep -A 10 "Environment Variables" summary.md
```

### Integration Patterns

**CLAUDE.md setup**:
```markdown
npl-instructions:
   name: npl-conventions
   version: 1.4.0
---
```🏳️
@command-and-control="task-master"
@work-log="standard"
@track-work=true
```
```

**Agent invocation**:
```bash
@npl-technical-writer generate spec --component=auth
@npl-grader validate agent.md --syntax-check
@npl-gopher-scout explore "authentication flow"
```

## Configuration & Parameters

| Section | Content | Purpose |
|---------|---------|---------|
| What is NPL? | Framework overview | Define NPL's role and capabilities |
| Repository Layout | Directory tree | Map file system structure |
| Key Components | Agent/script/MCP tables | Catalog available tools |
| NPL Syntax Quick Reference | Markers, fences, pumps | Essential syntax elements |
| Configuration | CLAUDE.md, env vars | Setup instructions |
| Common Workflows | Code examples | Task patterns |
| Documentation Deep-Dives | Link table | Further reading |

**Environment Variables**:

| Variable | Purpose |
|----------|---------|
| `NPL_HOME` | Base path for NPL definitions |
| `NPL_META` | Metadata files location |
| `NPL_STYLE_GUIDE` | Style conventions path |
| `NPL_MCP_DATA_DIR` | MCP server data directory |

## Integration Points

- **Upstream dependencies**: None (top-level reference document)
- **Downstream consumers**: All NPL agents, developers, onboarding materials
- **Related utilities**: `npl-load` (loads components referenced here), `npl-session` (uses session layout described), `git-tree` (visualizes directory structure)

## Limitations & Constraints

- **Snapshot nature**: As a static summary, may become outdated as components are added/modified
- **Depth trade-off**: Prioritizes breadth over depth; links to detailed docs for comprehensive information
- **Version drift**: References versioned components (agents, commands) that may evolve independently

## Success Indicators

- **Onboarding efficiency**: New users can locate components and understand project structure within 5 minutes
- **Context establishment**: Agents can quickly load relevant context for specialized tasks
- **Navigation speed**: Developers can resolve "where is X" queries without exploring multiple directories

---
**Generated from**: worktrees/main/docs/summary.md
