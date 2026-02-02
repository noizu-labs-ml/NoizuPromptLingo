# NPL Conventions Reference

**Type**: Prompt
**Category**: Core Conventions
**Status**: Core (v1.3.0)

## Purpose

The `npl.md` prompt establishes runtime conventions for NPL-powered agents, configuring agent delegation modes, work logging behavior, session tracking, and providing quick-reference documentation for visualization preferences, codebase tools, and core NPL syntax. It serves as the primary conventions reference loaded at the start of agent sessions, setting operational defaults that govern how agents collaborate, communicate, and document their work across the NPL ecosystem.

This file enables multi-agent orchestration by defining command-and-control strategies (lone-wolf, team-member, task-master), managing interstitial file generation patterns, and establishing session-based worklog communication protocols. It bridges agent capabilities with project conventions, ensuring consistent behavior across diverse workflows.

## Key Capabilities

- **Multi-mode agent delegation** with configurable strategies (lone-wolf, team-member, task-master)
- **Hierarchical work logging** with interstitial file generation (.summary.md, .detailed.md, .yaml)
- **Session-based worklog communication** using cursor-tracked JSONL logs
- **Visualization standardization** (mermaid, graphviz, SVG over ASCII)
- **Codebase tool reference** (Glob, Grep, Read, Task) with usage patterns
- **NPL syntax quick reference** including fences, markers, and intuition pumps

## Usage & Integration

- **Triggered by**: Loaded at session start via `npl-load c "npl" --skip {@npl.def.loaded}`
- **Outputs to**: Sets runtime flags (`@command-and-control`, `@work-log`, `@track-work`) that govern agent behavior
- **Complements**: `npl/agent.md` (full agent specs), `npl-session` script (worklog CLI), `CLAUDE.md` (project-level integration)

The file is typically loaded alongside core NPL syntax definitions and precedes agent-specific prompt loading, establishing the operational context for all subsequent agent interactions.

## Core Operations

### Loading the Prompt

```bash
npl-load c "npl" --skip {@npl.def.loaded}
```

### Overriding Default Delegation Mode

```
@command-and-control="lone-wolf"  # Work independently
@command-and-control="team-member"  # Balanced delegation
@command-and-control="task-master"  # Aggressive parallelization (default)
```

### Configuring Work Logging

```
@work-log="false"              # No interstitial files
@work-log="standard"           # .summary.md + .detailed.md (default)
@work-log="verbose"            # All files including .yaml
@work-log="yaml|summary"       # .yaml + .summary.md
```

### Session Worklog Workflow

```bash
# Initialize session
npl-session init --task="Implement auth feature"

# Sub-agent logs findings
npl-session log --agent=explore-auth-001 --type=Explore \
    --action=file_found --summary="Found auth.ts, auth.test.ts"

# Parent reads new entries
npl-session read --agent=primary
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `@command-and-control` | Agent delegation strategy | `task-master` | Supports custom modes with `.{name}.definition` |
| `@work-log` | Interstitial file generation | `standard` | Controls .summary/.detailed/.yaml creation |
| `@track-work` | Enable session worklog | `true` | Set to `false` to disable all logging |
| Agent ID format | Sub-agent identification | `<type>-<slug>-<NNN>` | E.g., `explore-auth-001` |
| Session path | Worklog directory | `.npl/sessions/YYYY-MM-DD/` | Auto-created on first sub-agent spawn |

## Integration Points

- **Upstream dependencies**: Core NPL syntax (`npl-load c "syntax"`), NPL load directive system
- **Downstream consumers**: All NPL agents (Explore, Plan, technical-writer, gopher-scout, grader), `npl-session` CLI script
- **Related utilities**: `npl/agent.md` (worklog schema), `npl-persona` (persona management), `npl-load` (resource loader)

The file integrates with the broader NPL framework through standardized loading patterns and flag-based configuration, enabling projects to customize agent behavior while maintaining consistent conventions across sessions.

## Session Directory Layout

Sessions organize shared worklogs and interstitial files under `.npl/sessions/YYYY-MM-DD/`:

```
.npl/sessions/YYYY-MM-DD/
├── meta.json           # Session metadata
├── worklog.jsonl       # Append-only shared log
├── .cursors/           # Per-agent read cursors
│   └── <agent-id>.cursor
└── tmp/                # Interstitial files
    └── <agent-id>/
        ├── <task>.summary.md
        ├── <task>.detailed.md
        └── <task>.yaml
```

Each agent maintains its own cursor for independent read tracking, enabling asynchronous multi-agent collaboration without shared state conflicts.

## Available Agents

| Agent | Purpose |
|:------|:--------|
| `Explore` | Codebase exploration, pattern discovery |
| `Plan` | Implementation design, architecture |
| `npl-technical-writer` | Documentation, specs, PRs |
| `npl-gopher-scout` | Reconnaissance, analysis |
| `npl-grader` | Validation, QA, edge testing |

## Limitations & Constraints

- Session directories require write access to `.npl/sessions/`
- Cursor-based read tracking does not support concurrent reads by same agent ID
- YAML interstitial files only generated in `verbose` or `yaml|*` modes
- Custom command-and-control modes require agent best-effort interpretation
- Sessions auto-create on first sub-agent spawn (no explicit init in standard workflow)

## Success Indicators

- Agents correctly delegate based on `@command-and-control` setting
- Interstitial files appear in `.npl/sessions/<date>/tmp/<agent-id>/` when `@work-log != "false"`
- Worklog entries append to `worklog.jsonl` when `@track-work=true`
- Agent cursors advance after reads (`.cursors/<agent-id>.cursor` updates)
- Visualization outputs use mermaid/graphviz instead of ASCII art

---
**Generated from**: worktrees/main/docs/prompts/npl.md, worktrees/main/docs/prompts/npl.detailed.md
