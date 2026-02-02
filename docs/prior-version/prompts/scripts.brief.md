# scripts

**Type**: Prompt
**Category**: prompts
**Status**: Core

## Purpose

The `scripts.md` prompt file provides LLMs with awareness of available NPL command-line tools during conversations. It acts as a catalog documenting codebase exploration utilities, persona management capabilities, session infrastructure, and visualization configuration tools. When injected into CLAUDE.md via `npl-load init-claude`, it enables agents to discover and utilize the full NPL toolset without requiring explicit knowledge of each tool's existence.

Without this prompt, agents lack knowledge of NPL tooling beyond standard shell commands, limiting their ability to leverage specialized scripts for tasks like session coordination, persona synthesis, or hierarchical resource loading.

## Key Capabilities

- Catalogs seven core NPL scripts with subcommand documentation
- Provides tabular quick-reference format optimized for LLM context scanning
- Documents command syntax patterns with practical examples
- Groups commands by function (lifecycle, journal, tasks) for conceptual clarity
- Integrates with `npl-load init-claude` version management system
- Supports manual context injection via `npl-load prompt scripts`

## Usage & Integration

- **Triggered by**: `npl-load init-claude` (default prompt set) or `npl-load prompt scripts` (direct load)
- **Outputs to**: CLAUDE.md as versioned instruction block
- **Complements**: `npl.md` (core syntax), `npl_load.md` (loader details), `sql-lite.md` (database ops)

The prompt is typically loaded during CLAUDE.md initialization and remains available throughout agent sessions. Version tracking via frontmatter YAML enables incremental updates without full reloads.

## Core Operations

### Loading into CLAUDE.md

```bash
# Via default prompt set
npl-load init-claude

# Direct prompt load
npl-load prompt scripts

# Check version status
npl-load init-claude --json
```

### Updating to Latest Version

```bash
# Update single prompt
npl-load init-claude --update scripts

# Update all prompts
npl-load init-claude --update-all
```

### Agent Bootstrapping

Include in agent definitions to provide tool awareness:

```markdown
```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded}
```
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `name` | Prompt identifier | `npl-scripts` | Set in frontmatter YAML |
| `version` | Version string | `1.1.0` | Enables update tracking |
| `--update` | Update flag | None | Passed to `npl-load init-claude` |
| `--json` | Output format | Text | Returns version status as JSON |

## Integration Points

- **Upstream dependencies**: `npl-load` command for prompt injection
- **Downstream consumers**: Claude Code, custom agents, LLM contexts
- **Related utilities**: `npl-load.detailed.md` (full loader docs), `npl-session.detailed.md` (session management), `npl-persona.detailed.md` (persona lifecycle)

## Documented Scripts

### npl-load
Resource loader with hierarchical path resolution (project → user → system). Supports core components (`c`), metadata (`m`), styles (`s`), agent definitions, and CLAUDE.md initialization.

### npl-persona
Persona lifecycle management including journals (track experiences), tasks (manage goals), knowledge bases (build expertise), and teams (multi-persona collaboration).

### npl-session
Session and worklog management for cross-agent communication. Cursor-based reads allow independent tracking by multiple agents.

### npl-fim-config
Visualization tool configuration with natural language queries for finding appropriate libraries (network graphs, charts, diagrams).

### Codebase Exploration
Three utilities: `dump-files` (recursive content dump), `git-tree` (directory visualization), `git-tree-depth` (nesting depth analysis).

## Limitations & Constraints

- Not exhaustive: Does not document all command options or flags
- Reference only: Does not teach workflows, best practices, or architecture
- Static: Requires manual updates when scripts change (no auto-generation)
- Token overhead: Adds 200-300 tokens to every CLAUDE.md context

## Success Indicators

- Agents discover and use NPL scripts without explicit instruction
- `npl-load init-claude` successfully detects version mismatches
- Agents can bootstrap sessions, manage personas, and query visualization tools
- Cross-agent communication via `npl-session` worklog functions correctly

---
**Generated from**: worktrees/main/docs/prompts/scripts.md, worktrees/main/docs/prompts/scripts.detailed.md
