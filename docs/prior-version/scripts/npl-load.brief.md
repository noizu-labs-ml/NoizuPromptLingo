# npl-load

**Type**: Script
**Category**: Core Resource Loader
**Status**: Core

## Purpose

`npl-load` is a command-line tool for loading NPL resources with hierarchical path resolution and dependency tracking. It enables organizations to set system-wide defaults while allowing projects and users to selectively override specific components. The tool supports multiple resource types including components, metadata, style guides, agent definitions, PRD documents, user stories, prompts, and workflows. It prevents redundant loading through dependency tracking flags and supports patch overlays for customizing content without replacing originals.

The loader implements a first-match-wins path resolution strategy that searches in priority order: environment variables → project paths (`./.npl/`) → user paths (`~/.npl/`) → system paths (platform-specific). This hierarchy enables flexible deployment scenarios where teams can inherit organizational conventions while customizing project-specific elements.

## Key Capabilities

- **Multi-tiered path resolution** - Searches environment, project, user, and system paths in priority order
- **Dependency tracking** - Outputs tracking flags to prevent redundant reloading via `--skip` parameter
- **Patch overlays** - Customize loaded content without replacing originals using `.patch.md` files
- **Glob patterns** - Load multiple resources using wildcards (`syntax.*`, `persona.*`)
- **Versioned prompt management** - Initialize and update CLAUDE.md with version-tracked prompt sections
- **Agent discovery** - List, filter, and search agent definitions with metadata queries
- **NPL syntax analysis** - Detect and report NPL syntax elements in content files

## Usage & Integration

**Triggered by**: Command-line invocation or programmatic calls from scripts/workflows
**Outputs to**: STDOUT (content + tracking flags), STDERR (errors/warnings)
**Complements**: `npl-session` (shared worklogs), `npl-persona` (agent identities), CLAUDE.md (project configuration)

The loader is typically invoked at the start of agent sessions to load required NPL definitions. It outputs tracking flags that must be passed back via `--skip` on subsequent calls to avoid reloading:

```bash
# First load
npl-load c syntax agent
# Returns: @npl.def.loaded+="agent,syntax"

# Subsequent load with skip
npl-load c syntax agent directive --skip "agent,syntax"
# Only loads directive
```

## Core Operations

### Load Components
```bash
npl-load c syntax agent directive --skip ""
```

### Load with Dot Notation (Subdirectories)
```bash
npl-load c syntax.fences pumps.intent
```

### Load Metadata
```bash
npl-load m persona.qa-engineer --skip {@npl.meta.loaded}
```

### Load Style Guides (with Theme Support)
```bash
NPL_THEME=corporate npl-load s house-style
```

### Agent Discovery and Loading
```bash
# List agents
npl-load agent --list --verbose

# Search and filter
npl-load agent --list --search "database|sql" --category "code"

# Load with NPL syntax docs
npl-load agent npl-author --definition
```

### CLAUDE.md Version Management
```bash
# Check version status
npl-load init-claude

# Update all outdated sections
npl-load init-claude --update-all --dry-run
```

### NPL Syntax Analysis
```bash
npl-load syntax --file prompt.md --matches
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `--skip` | Patterns to skip (wildcards supported) | `""` | Prevents redundant loading |
| `--quiet` | Output tracking flags only | false | Suppresses content output |
| `--verbose` | Enable verbose output | false | Shows detailed resolution paths |
| `--definition` | Export agent with NPL docs | false | Agent command only |
| `--list` | List available agents | false | Agent command only |
| `--update-all` | Update all outdated sections | false | init-claude command only |

## Integration Points

**Upstream dependencies**:
- NPL resource files in `.npl/`, `~/.npl/`, or system paths
- Environment variables (`NPL_HOME`, `NPL_META`, `NPL_STYLE_GUIDE`, `NPL_THEME`)
- Patch files (`.patch.md`) for content customization

**Downstream consumers**:
- Claude Code sessions reading CLAUDE.md
- Agent workflows requiring NPL component definitions
- Scripts tracking loaded resources via flags
- Version control systems managing CLAUDE.md updates

**Related utilities**:
- `npl-session` - Session and worklog management
- `npl-persona` - Persona identity management
- `npl-fim-config` - Visualization tool queries

## Limitations & Constraints

- **First match wins** - Cannot merge content from multiple path levels
- **Single theme active** - Only one theme can be active via `$NPL_THEME` at a time
- **Patches prepend only** - Patches cannot replace or append to specific sections within files
- **Non-interactive** - All operations execute without user prompts or interactive menus

## Success Indicators

- **Exit code 0** - Resources loaded successfully, tracking flags output
- **Tracking flags present** - Output includes `@npl.{type}.loaded+="..."` flags
- **No "not found" errors** - All requested resources resolved from configured paths
- **Version checks pass** - init-claude reports sections as current (exit code 0) or identifies outdated sections (exit code 2)

---
**Generated from**: worktrees/main/docs/scripts/npl-load.md, worktrees/main/docs/scripts/npl-load.detailed.md
