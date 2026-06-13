# npl_load

**Type**: Prompt
**Category**: Core Resource Loading
**Status**: Core

## Purpose

The `npl_load` prompt documents the NPL hierarchical resource loading system for integration with CLAUDE.md and agent contexts. It enables LLMs to understand and utilize NPL's multi-tier resource discovery infrastructure, including environment variable configuration, path resolution, dependency tracking, and skip-flag management. Without this prompt, agents lack knowledge of how NPL resources (syntax, metadata, styles, personas) are discovered, loaded, and prevented from duplicate loading across invocations.

This prompt is designed for injection into CLAUDE.md via `npl-load init-claude` and provides the foundational knowledge required for agents to interact with the NPL loading infrastructure effectively.

## Key Capabilities

- **Environment-based path overrides** - Documents seven environment variables (`$NPL_HOME`, `$NPL_META`, `$NPL_STYLE_GUIDE`, etc.) for customizing resource locations
- **Multi-tier path resolution** - Explains the hierarchical search order: environment → project (`./.npl/`) → user (`~/.npl/`) → system (`/etc/npl/`)
- **Dependency tracking** - Describes skip-flag protocol to prevent duplicate resource loading across agent invocations
- **Resource type prefixes** - Documents `c` (core), `m` (metadata), `s` (style) loading syntax and their corresponding tracking flags
- **Version management** - Explains version tracking via frontmatter for `npl-load init-claude` updates
- **Patch file support** - Documents `.patch.md` files that prepend to base content for additive customization

## Usage & Integration

- **Triggered by**: `npl-load init-claude` (as part of default prompt set), `npl-load prompt npl_load` (manual loading)
- **Outputs to**: CLAUDE.md (versioned sections), agent system prompts
- **Complements**: `npl.md` (core NPL syntax), `scripts.md` (tool catalog), `sql-lite.md` (database syntax)

The prompt is part of the default initialization set alongside `npl`, `scripts`, and `sql-lite` prompts. It provides context for the `npl-load` script interface and enables agents to construct proper load commands.

## Core Operations

### Load Components with Skip Flags

```bash
# First load
npl-load c "syntax,agent" --skip ""
# Returns: @npl.def.loaded+="syntax,agent"

# Subsequent load (skip already loaded)
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
# Only loads: pumps
```

### Multi-Type Loading

```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded} \
         m "persona.qa-engineer" --skip {@npl.meta.loaded} \
         s "house-style" --skip {@npl.style.loaded}
```

### Glob Pattern Support

```bash
npl-load c "directive.*" --skip ""
```

### Check Version Status

```bash
npl-load init-claude --json
```

## Configuration & Parameters

| Variable | Purpose | Default Fallback | Notes |
|----------|---------|------------------|-------|
| `$NPL_HOME` | Base path for NPL definitions | `./.npl`, `~/.npl`, `/etc/npl/` | First match wins |
| `$NPL_META` | Metadata files | `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta` | Persona/config storage |
| `$NPL_STYLE_GUIDE` | Style conventions | `./.npl/conventions/`, `~/.npl/conventions/` | Theme-based loading |
| `$NPL_THEME` | Theme name for style loading | - | Examples: "dark-mode", "corporate" |
| `$NPL_PERSONA_DIR` | Persona definitions | `./.npl/personas`, `~/.npl/personas` | Agent identities |
| `$NPL_PERSONA_TEAMS` | Team definitions | `./.npl/teams`, `~/.npl/teams` | Multi-agent teams |
| `$NPL_PERSONA_SHARED` | Shared persona resources | `./.npl/shared`, `~/.npl/shared` | Cross-team assets |

## Integration Points

- **Upstream dependencies**: None (loaded first in init-claude sequence)
- **Downstream consumers**: All agents requiring NPL resource loading, `npl-load` script (consumes environment variables)
- **Related utilities**: `npl-load init-claude` (version management), `npl-load prompt` (manual loading), agent bootstrapping sequences

The prompt acts as the foundational knowledge layer enabling all resource loading operations. Agents reference this documentation to construct valid `npl-load` commands with proper skip flags.

## Limitations & Constraints

- **Static documentation** - Does not auto-update when `npl-load` script changes; requires manual version bumps
- **Subset of features** - Documents common flags and workflows but not all command options
- **No validation** - Cannot verify environment paths are correct or resources exist
- **Frontmatter dependency** - Version tracking requires consistent frontmatter format across prompt files

## Success Indicators

- Agents correctly construct `npl-load` commands with appropriate resource type prefixes
- Skip flags are properly accumulated and passed to prevent duplicate loading
- Version status checks return expected versions for installed prompts
- Project/user/system path overrides work as documented

---
**Generated from**: worktrees/main/docs/prompts/npl_load.md, worktrees/main/docs/prompts/npl_load.detailed.md
