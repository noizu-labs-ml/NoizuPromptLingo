# npl_load - Persona

**Type**: Script / Prompt
**Category**: Resource Loading & Infrastructure
**Version**: 1.0.0

## Overview

The `npl_load` utility is NPL's hierarchical resource loading system that enables LLMs to discover, load, and track NPL components across multi-tier paths. It prevents duplicate loading through skip-flag dependency tracking and supports environment-based overrides for organizational, project, user, and system-level resource customization.

## Purpose & Use Cases

- **Agent bootstrapping**: Load required NPL syntax, directives, and definitions before agents begin work
- **Context initialization**: Inject CLAUDE.md sections with versioned prompts via `init-claude` subcommand
- **Resource discovery**: Find components across project → user → system path hierarchy
- **Dependency tracking**: Prevent redundant loading using skip flags (`@npl.def.loaded`, etc.)
- **Environment customization**: Override paths for organization-wide standards or project-specific resources

## Key Features

✅ **Multi-tier path resolution** - Searches environment → project (`./.npl/`) → user (`~/.npl/`) → system (`/etc/npl/`)
✅ **Skip-flag protocol** - Tracks loaded resources to prevent duplicate injection across agent invocations
✅ **Multi-type loading** - Load core components, metadata, styles, and prompts in a single command
✅ **Glob pattern support** - Use wildcards like `directive.*` to load matching resources
✅ **Version management** - Track and update versioned prompt sections in CLAUDE.md
✅ **Patch file support** - Overlay `.patch.md` files for additive customization without replacing base files

## Usage

```bash
# Load core components (syntax, agent definitions, etc.)
npl-load c "syntax,agent" --skip {@npl.def.loaded}

# Multi-type loading (core, metadata, styles)
npl-load c "syntax" --skip "" m "persona.qa" --skip "" s "house-style" --skip ""

# Initialize/update CLAUDE.md with default prompts
npl-load init-claude --update-all

# Load via glob patterns
npl-load c "directive.*" --skip ""

# Direct prompt loading
npl-load prompt npl_load
```

First invocation returns skip-flag updates that must be passed on subsequent calls to avoid reloading:

```bash
# First load
npl-load c "syntax,agent" --skip ""
# Returns: @npl.def.loaded+="syntax,agent"

# Subsequent load passes accumulated flags
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
# Only loads: pumps
```

## Integration Points

- **Triggered by**: `init-claude` for CLAUDE.md injection, agent system prompts for bootstrapping, manual invocation for context loading
- **Feeds to**: LLM context windows (Claude, GPT, etc.), CLAUDE.md versioned sections
- **Complements**: `npl-session` (session management), `npl-persona` (agent definitions), project-level `.npl/` overrides

## Parameters / Configuration

- **Type prefixes**: `c` (core), `m` (metadata), `s` (style guides) specify resource category
- **`--skip <flags>`**: Comma-separated list of already-loaded resources to prevent duplication
- **Environment variables**: Override default paths (e.g., `$NPL_HOME`, `$NPL_THEME`, `$NPL_PERSONA_DIR`)
- **Glob patterns**: Match multiple resources with wildcards (e.g., `directive.*`, `agent.*`)
- **`--update-all`**: Force refresh all versioned CLAUDE.md sections (used with `init-claude`)

## Success Criteria

- **Unique loading**: Resources loaded once per session even with multiple invocations
- **Path fallback**: Project overrides take precedence; system defaults used when no override exists
- **Version tracking**: CLAUDE.md sections show current/outdated status correctly
- **Flag propagation**: Skip flags returned in structured format for next invocation

## Limitations & Constraints

- **Static documentation**: Prompt content doesn't auto-update when `npl-load` script changes
- **Manual flag tracking**: Agents must explicitly pass skip flags between invocations
- **No validation**: Cannot verify environment paths exist or are accessible
- **Subset of features**: Prompt documents common flags but not all script options

## Related Utilities

- **npl-session**: Session worklog management for cross-agent communication
- **npl-persona**: Persona lifecycle and knowledge base management
- **init-claude**: CLAUDE.md initialization with versioned prompt injection
- **npl-fim-config**: Visualization tool selection for FIM agent
