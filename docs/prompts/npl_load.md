# npl_load.md

Prompt file documenting the NPL hierarchical resource loading system for CLAUDE.md and agent contexts.

**Source**: `core/prompts/npl_load.md`
**Version**: 1.0.0

## Purpose

Enables LLMs to understand NPL resource loading infrastructure. Documents environment variables, multi-tier path resolution, and skip-flag dependency tracking.

See [Purpose](./npl_load.detailed.md#purpose) for details.

## Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `$NPL_HOME` | Base path for NPL definitions |
| `$NPL_META` | Metadata files |
| `$NPL_STYLE_GUIDE` | Style conventions |
| `$NPL_THEME` | Theme name for style loading |
| `$NPL_PERSONA_DIR` | Persona definitions |
| `$NPL_PERSONA_TEAMS` | Team definitions |
| `$NPL_PERSONA_SHARED` | Shared persona resources |

See [Environment Variables](./npl_load.detailed.md#environment-variables) for fallback paths.

## Loading Syntax

```bash
# Load components
npl-load c "syntax,agent" --skip {@npl.def.loaded}

# Load multiple types
npl-load c "syntax" --skip "" m "persona.qa" --skip "" s "house-style" --skip ""

# Glob patterns
npl-load c "directive.*" --skip ""
```

See [Loading Dependencies](./npl_load.detailed.md#loading-dependencies) for syntax details.

## Skip Flag Protocol

Flags prevent duplicate loading across invocations:

```bash
# First load
npl-load c "syntax,agent" --skip ""
# Returns: @npl.def.loaded+="syntax,agent"

# Subsequent load
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
# Only loads: pumps
```

See [Skip Flag Protocol](./npl_load.detailed.md#skip-flag-protocol) for flag variables.

## Path Resolution

1. Environment variable override
2. Project directory (`./.npl/`)
3. User directory (`~/.npl/`)
4. System directory (`/etc/npl/`)

First match wins. See [Path Resolution Order](./npl_load.detailed.md#path-resolution-order).

## Loading

```bash
# Via init-claude (default prompt set)
npl-load init-claude

# Direct load
npl-load prompt npl_load

# Check version status
npl-load init-claude --json
```

See [Integration with CLAUDE.md](./npl_load.detailed.md#integration-with-claudemd) for version management.

## See Also

- [Detailed Reference](./npl_load.detailed.md) - Complete documentation
- [npl-load.detailed.md](../scripts/npl-load.detailed.md) - Script documentation
- [scripts.detailed.md](./scripts.detailed.md) - Tool catalog
