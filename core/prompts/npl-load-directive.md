npl-instructions:
   name: npl-load-directive
   version: 1.0.0
---

# NPL Load Directive

Hierarchical resource loading with multi-tier path resolution (environment → project → user → system). Projects inherit defaults and override only what they need.

## Environment Variables

| Variable | Purpose | Fallback Path |
|:---------|:--------|:--------------|
| `$NPL_HOME` | Base path for NPL definitions | `./.npl`, `~/.npl`, `/etc/npl/` |
| `$NPL_META` | Metadata files | `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta` |
| `$NPL_STYLE_GUIDE` | Style conventions | `./.npl/conventions/`, `~/.npl/conventions/` |
| `$NPL_THEME` | Theme name for style loading | (e.g., "dark-mode", "corporate") |
| `$NPL_PERSONA_DIR` | Persona definitions | `./.npl/personas`, `~/.npl/personas` |
| `$NPL_PERSONA_TEAMS` | Team definitions | `./.npl/teams`, `~/.npl/teams` |
| `$NPL_PERSONA_SHARED` | Shared persona resources | `./.npl/shared`, `~/.npl/shared` |

## Loading Dependencies

Load multiple resource types in a single call using type prefixes (`c`=core, `m`=meta, `s`=style):

```bash
npl-load c "syntax,agent" --skip {@npl.def.loaded} m "persona.qa-engineer" --skip {@npl.meta.loaded} s "house-style" --skip {@npl.style.loaded}
```

**Critical:** The tool returns content headers that set global flags:
- `npl.loaded=syntax,agent`
- `npl.meta.loaded=persona.qa-engineer`
- `npl.style.loaded=house-style`

These flags **must** be passed back via `--skip` on subsequent calls to prevent reloading:

```bash
# First load sets flags
npl-load c "syntax,agent" --skip ""
# Returns: npl.loaded=syntax,agent

# Subsequent loads pass --skip to avoid duplicates
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
```
