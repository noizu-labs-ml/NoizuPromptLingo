# npl-load - Persona

**Type**: Script
**Category**: Resource Management
**Version**: 1.0.0

## Overview

`npl-load` is a hierarchical resource loader that loads NPL components, metadata, styles, prompts, and other resources from a prioritized search path (environment → project → user → system). It provides dependency tracking via flags, supports glob patterns, patch overlays, and enables version-managed CLAUDE.md initialization.

## Purpose & Use Cases

- Load NPL syntax components and documentation into prompts or agent contexts
- Apply project-specific overrides to organization-wide NPL definitions
- Manage CLAUDE.md file initialization and version tracking for project instructions
- Export agent definitions with optimized NPL syntax documentation
- Discover and filter agents by category, metadata, or content
- Analyze NPL syntax usage in content or agent definitions
- Load schema SQL files for database initialization

## Key Features

✅ **Hierarchical path resolution** – project → user → system with environment variable overrides
✅ **Dependency tracking** – outputs flags to prevent redundant loading via `--skip`
✅ **Patch system** – customize resources without replacing originals (`.patch.md` files)
✅ **Glob pattern support** – load multiple resources with wildcards (`syntax.*`)
✅ **Theme-aware style loading** – supports themed style guides via `$NPL_THEME`
✅ **Agent discovery** – list, filter, and search agents by metadata or content
✅ **CLAUDE.md version management** – track and update versioned prompt sections
✅ **NPL syntax analysis** – detect and count NPL syntax elements in content
✅ **Schema loading** – output raw SQL for database initialization
✅ **Parallel component loading** – uses ThreadPoolExecutor for faster agent exports

## Usage

```bash
# Load components
npl-load c syntax agent directive

# Load with dot notation (subdirectories)
npl-load c syntax.fences pumps.intent

# Load using glob patterns
npl-load c "syntax.*"

# Skip already-loaded items
npl-load c syntax agent --skip "syntax"

# Load metadata
npl-load m persona.qa-engineer

# Load style guides (uses NPL_THEME if set)
npl-load s house-style

# Load agent
npl-load agent npl-gopher-scout

# Export agent with NPL docs
npl-load agent npl-gopher-scout --definition

# List all agents
npl-load agent --list

# Filter agents by category
npl-load agent --list --category writing

# Initialize CLAUDE.md
npl-load init-claude

# Update outdated sections
npl-load init-claude --update-all

# Analyze NPL syntax in a file
npl-load syntax --file agent.md --matches

# Load schema SQL
npl-load schema nimps | sqlite3 mydb.sqlite
```

## Integration Points

- **Triggered by**: Manual invocation, agent initialization scripts, CLAUDE.md setup workflows
- **Feeds to**: Agent contexts, prompt templates, CLAUDE.md files, database initialization
- **Complements**: `npl-session` (provides definitions for agents), `npl-persona` (loads persona metadata)

## Parameters / Configuration

- **Resource type commands**: `c` (components), `m` (metadata), `s` (style), `spec` (specifications), `persona`, `user-persona`, `prd`, `story`, `prompt`, `workflow`, `agent`, `schema`, `init`, `syntax`, `init-claude`
- **`--skip` patterns**: Comma/space-separated list of already-loaded items (supports wildcards)
- **`--quiet`**: Output only tracking flags, suppress content
- **`--verbose`**: Enable verbose output (for listing commands)
- **Environment variables**: `NPL_HOME`, `NPL_META`, `NPL_STYLE_GUIDE`, `NPL_THEME`, `NPL_PERSONA_DIR`, `NPL_USER_PERSONA_DIR`, `NPL_WORKFLOW_DIR`

### Agent-specific options

- **`--list`**: List all available agents
- **`--search <regex>`**: Filter agents by body content
- **`--filter-meta <field:value>`**: Filter by metadata field
- **`--category <cat>`**: Filter by category
- **`--definition`**: Export agent with NPL syntax documentation

### init-claude options

- **`--target <path>`**: Target CLAUDE.md path (default: `./CLAUDE.md`)
- **`--prompts <list>`**: Prompts to append (default: standard set)
- **`--update <sections>`**: Update specific sections (comma-separated)
- **`--update-all`**: Update all outdated/missing sections
- **`--dry-run`**: Preview changes without modifying files
- **`--json`**: Output version info as JSON

### Syntax analysis options

- **`--file <path>`**: File to analyze
- **`--matches`**: Show actual pattern matches

## Success Criteria

- Resources are loaded from the first matching path in the hierarchy
- Dependency tracking flags are correctly output and can be passed back via `--skip`
- Patch files (`.patch.md`) are prepended when found
- CLAUDE.md sections are version-tracked and can be selectively updated
- Agent discovery returns agents matching specified filters
- Syntax analysis detects all NPL pattern categories

## Limitations & Constraints

- **No interactive mode**: All operations are non-interactive
- **Single theme**: Only one theme active at a time via `$NPL_THEME`
- **First match wins**: Cannot merge content from multiple path levels
- **Patches prepend only**: Patches cannot replace or append to specific sections
- **No in-place edits**: Cannot modify source files, only load and combine

## Related Utilities

- **npl-session**: Manages worklog communication between agents; uses definitions loaded by `npl-load`
- **npl-persona**: Manages persistent personas; can load persona metadata via `npl-load m`
- **npl-fim-config**: Queries visualization tool compatibility; complements agent definition exports
- **dump-files**: Explores codebase content; `npl-load` explores NPL resource structure
