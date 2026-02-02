# NPL - Persona

**Type**: Prompt
**Category**: Core Conventions
**Version**: 1.0.0

## Overview

The NPL (Noizu Prompt Lingo) conventions prompt establishes runtime operational standards for NPL-powered agent systems. It defines agent delegation strategies, work logging protocols, session tracking mechanisms, and provides quick-reference documentation for visualization preferences, codebase exploration tools, and core NPL syntax elements.

## Purpose & Use Cases

- Establish command-and-control modes for agent delegation (lone-wolf, team-member, task-master)
- Configure work logging behavior for interstitial file generation
- Enable cross-agent communication through shared session worklogs
- Provide quick-reference tables for visualization library selection
- Document codebase exploration tool patterns (Glob, Grep, Read, Task)

## Key Features

✅ Three delegation modes with extensible custom mode definitions
✅ Configurable work-log generation (none, standard, verbose, YAML variants)
✅ Session-based worklog tracking with per-agent cursor management
✅ Structured interstitial file patterns (summary → detailed → YAML)
✅ Visualization preference matrix (Mermaid, GraphViz over ASCII art)
✅ Quick-reference tables for codebase tools and NPL framework syntax

## Usage

```bash
npl-load c "npl" --skip {@npl.def.loaded}
```

This prompt is typically loaded as the primary conventions reference for agent sessions. It sets global runtime flags that govern how agents collaborate, communicate, and document their work. Projects inherit default settings and override them via flag declarations:

```
@command-and-control="task-master"
@work-log="standard"
@track-work=true
```

## Integration Points

- **Triggered by**: Manual load via `npl-load c "npl"`, or auto-loaded in project `CLAUDE.md` initialization
- **Feeds to**: Sub-agents inherit conventions; worklog entries feed cross-agent communication
- **Complements**: `npl/agent.md` (full agent specification), `npl-session` CLI (worklog management), style guides

## Parameters / Configuration

- **@command-and-control** - Delegation strategy: `lone-wolf` (minimal delegation), `team-member` (balanced planning), `task-master` (aggressive parallelization)
- **@work-log** - Interstitial file generation: `false`, `standard` (summary+detailed), `verbose` (includes YAML), `yaml|summary`, `yaml|detailed`
- **@track-work** - Enable session worklog tracking: `true` (default), `false`
- **Agent ID format** - Pattern: `<agent-type>-<task-slug>-<NNN>` (e.g., `explore-auth-001`)
- **Session directory** - Structure: `.npl/sessions/YYYY-MM-DD/` with `meta.json`, `worklog.jsonl`, `.cursors/`, `tmp/`

## Success Criteria

- Agents correctly apply delegation mode based on `@command-and-control` flag
- Interstitial files are generated per `@work-log` configuration in agent-specific subdirectories
- Worklog entries follow schema and append to `worklog.jsonl` when `@track-work=true`
- Agents prefer Mermaid/GraphViz over ASCII for visualizations per preference matrix
- Sub-agents maintain independent read cursors and advance on each `npl-session read`

## Limitations & Constraints

- Custom command-and-control modes require explicit definition via `@command-and-control.{name}.definition`
- Session directory layout assumes date-based partitioning (one session per day)
- Worklog cursors are file-based; concurrent reads from the same agent ID may conflict
- Interstitial files use heading-based cross-references; inconsistent `##` headings break navigation

## Related Utilities

- **npl-session** - Session and worklog CLI management
- **npl-load** - Hierarchical resource loader
- **npl/agent.md** - Full agent specification and worklog schema
- **CLAUDE.md** - Project-level NPL instruction integration
