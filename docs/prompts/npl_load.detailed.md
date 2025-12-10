# npl_load.md Detailed Reference

Prompt file that documents the NPL hierarchical resource loading system for inclusion in CLAUDE.md and agent contexts.

## Synopsis

The `npl_load.md` prompt file provides documentation for the NPL Load Directive - a hierarchical resource loading system with multi-tier path resolution. It is designed for injection into CLAUDE.md via `npl-load init-claude`.

**Source**: `core/prompts/npl_load.md`
**Version**: 1.0.0
**Load command**: `npl-load prompt npl_load`

---

## Purpose

This prompt enables LLMs to understand and utilize the NPL resource loading infrastructure. When loaded into context, it provides:

- Environment variable configuration for resource paths
- Multi-tier path resolution (environment, project, user, system)
- Dependency tracking to prevent duplicate loading
- Skip-flag management for session continuity

Without this prompt, agents lack knowledge of how NPL resources are discovered and loaded.

---

## Structure

### Frontmatter

```yaml
npl-instructions:
   name: npl-load-directive
   version: 1.0.0
```

The frontmatter enables version tracking for `npl-load init-claude` updates.

### Content Sections

| Section | Purpose |
|:--------|:--------|
| Environment Variables | Documents path override variables |
| Loading Dependencies | Explains the npl-load command syntax |
| Skip Flag Protocol | Describes duplicate prevention mechanism |

---

## Environment Variables

The prompt documents seven environment variables for path customization:

| Variable | Purpose | Fallback Path |
|:---------|:--------|:--------------|
| `$NPL_HOME` | Base path for NPL definitions | `./.npl`, `~/.npl`, `/etc/npl/` |
| `$NPL_META` | Metadata files | `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta` |
| `$NPL_STYLE_GUIDE` | Style conventions | `./.npl/conventions/`, `~/.npl/conventions/` |
| `$NPL_THEME` | Theme name for style loading | (e.g., "dark-mode", "corporate") |
| `$NPL_PERSONA_DIR` | Persona definitions | `./.npl/personas`, `~/.npl/personas` |
| `$NPL_PERSONA_TEAMS` | Team definitions | `./.npl/teams`, `~/.npl/teams` |
| `$NPL_PERSONA_SHARED` | Shared persona resources | `./.npl/shared`, `~/.npl/shared` |

### Path Resolution Order

The loader searches paths in priority order:

1. Environment variable override (highest priority)
2. Project directory (`./.npl/`)
3. User directory (`~/.npl/`)
4. System directory (`/etc/npl/` or platform equivalent)

First match wins. Projects inherit defaults and override only what they need.

---

## Loading Dependencies

### Command Syntax

Load resources using type prefixes:

```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded}
```

| Prefix | Resource Type | Tracking Flag |
|:-------|:--------------|:--------------|
| `c` | Core components | `npl.def.loaded` |
| `m` | Metadata | `npl.meta.loaded` |
| `s` | Style guides | `npl.style.loaded` |

### Multi-Type Loading

Load multiple resource types in a single command:

```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded} m "persona.qa-engineer" --skip {@npl.meta.loaded} s "house-style" --skip {@npl.style.loaded}
```

### Glob Pattern Support

Load resources matching patterns:

```bash
npl-load c "syntax,directive.*" --skip ""
```

---

## Skip Flag Protocol

The skip flag system prevents duplicate loading across agent invocations.

### How It Works

1. First load returns content and sets tracking flags:

```bash
npl-load c "syntax,agent" --skip ""
# Returns: npl.loaded=syntax,agent
```

2. Subsequent loads pass accumulated flags:

```bash
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
# Only loads: pumps (syntax,agent skipped)
```

### Flag Output Format

The loader outputs flag updates in a structured block:

```
# Flag Update

\`\`\`
@npl.def.loaded+="syntax,agent"
@npl.meta.loaded+="persona.qa-engineer"
\`\`\`

---
```

### Flag Variables

| Flag | Resource Type |
|:-----|:--------------|
| `@npl.def.loaded` | Core components |
| `@npl.meta.loaded` | Metadata |
| `@npl.style.loaded` | Style guides |
| `@npl.spec.loaded` | Specifications |
| `@npl.persona.loaded` | Agent personas |
| `@npl.prompt.loaded` | Prompts |
| `@npl.workflow.loaded` | Workflows |

---

## Integration with npl-load Script

The prompt documents the interface to the `npl-load` Python script.

### Script Location

The script resides at `core/scripts/npl-load` and is invoked directly:

```bash
npl-load <subcommand> [options]
```

### Related Subcommands

| Subcommand | Purpose |
|:-----------|:--------|
| `c <items>` | Load core components |
| `m <items>` | Load metadata |
| `s <items>` | Load style guides |
| `init` | Load main npl.md file |
| `agent <name>` | Load agent definitions |
| `schema <name>` | Load SQL schema |

See [npl-load.detailed.md](../scripts/npl-load.detailed.md) for complete script documentation.

---

## Integration with CLAUDE.md

### Default Prompt Set

The npl_load prompt is part of the default initialization:

```bash
npl-load init-claude --prompts "npl npl_load scripts sql-lite"
```

### Version Management

Check installed version:

```bash
npl-load init-claude
```

Output shows version status for each section:

```
NPL Prompt Version Status
============================================================

Section                   Source     Installed  Status
------------------------------------------------------------
npl-load-directive        1.0.0      1.0.0      current
```

Update outdated sections:

```bash
npl-load init-claude --update npl-load-directive
npl-load init-claude --update-all
```

### Manual Loading

Load directly into agent context:

```bash
npl-load prompt npl_load
```

---

## Usage Patterns

### Agent Bootstrapping

Include in agent system prompts:

```markdown
You must load before proceeding:

\`\`\`bash
npl-load c "syntax,agent,prefix" --skip {@npl.def.loaded}
\`\`\`
```

### Project-Level Overrides

Override specific resources in `./.npl/`:

```
project/
  .npl/
    npl/
      syntax.md          # Custom syntax extensions
    conventions/
      default/
        house-style.md   # Project style guide
```

The loader finds project resources first, falling back to user/system defaults.

### Environment Configuration

Set organization-wide paths:

```bash
export NPL_HOME=/opt/company/npl
export NPL_THEME=corporate
```

---

## Design Decisions

### Hierarchical Resolution

Multi-tier paths enable:
- Organization standards via environment variables
- Project overrides in `./.npl/`
- User preferences in `~/.npl/`
- System defaults as fallback

### Skip Flag Tracking

Flags prevent reloading because:
- Duplicate content wastes context tokens
- Repeated parsing adds latency
- Agents may load resources multiple times in a session

### Patch File Support

The loader supports `.patch.md` files that prepend to base content:

```
.npl/npl/syntax.patch.md  # Prepends to syntax.md
```

This enables additive customization without replacing entire files.

---

## Relationship to Other Prompts

| Prompt | Relationship |
|:-------|:-------------|
| `npl.md` | Core NPL syntax loaded via `npl-load init` |
| `scripts.md` | Documents npl-load and other tools |
| `sql-lite.md` | Database syntax for npl-session storage |

---

## Limitations

- **Static documentation**: Does not auto-update when npl-load changes
- **Subset of features**: Documents common flags, not all options
- **No validation**: Cannot verify environment paths are correct

For complete npl-load documentation, see [npl-load.detailed.md](../scripts/npl-load.detailed.md).

---

## See Also

- [npl_load.md](./npl_load.md) - Concise reference
- [npl-load.detailed.md](../scripts/npl-load.detailed.md) - Script documentation
- [scripts.detailed.md](./scripts.detailed.md) - Tool catalog
