## NPL Load Directive

### Environment Variables

NPL uses optional environment variables to locate resources, allowing projects to override only what they need:

**$NPL_HOME**
: Base path for NPL definitions. Fallback: `./.npl`, `~/.npl`, `/etc/npl/`

**$NPL_META**  
: Path for metadata files. Fallback: `./.npl/meta`, `~/.npl/meta`, `/etc/npl/meta`

**$NPL_STYLE_GUIDE**
: Path for style conventions. Fallback: `./.npl/conventions/`, `~/.npl/conventions/`, `/etc/npl/conventions/`

**$NPL_THEME**
: Theme name for style loading (e.g., "dark-mode", "corporate")

### Loading Dependencies

Prompts may specify dependencies to load using the `npl-load` command-line tool:

```bash
npl-load c "syntax,agent" --skip {@npl.loaded} m "persona.qa-engineer" --skip {@npl.meta.loaded} s "house-style" --skip {@npl.style.loaded}
```

The tool searches paths in order (environment → project → user → system) and tracks what's loaded to prevent duplicates.

**Critical:** When `npl-load` returns content, it includes headers that set global flags for tracking what is in context:
- `npl.loaded=syntax,agent`
- `npl.meta.loaded=persona.qa-engineer`  
- `npl.style.loaded=house-style`

These flags **must** be passed back via `--skip` on subsequent calls to prevent reloading:

```bash
# First load sets flags
npl-load c "syntax,agent" --skip ""
# Returns: npl.loaded=syntax,agent

# Next load uses --skip to avoid reloading
npl-load c "syntax,agent,pumps" --skip "syntax,agent"
```

### Purpose

This hierarchical loading system allows:
- **Organizations** to set company-wide standards via environment variables
- **Projects** to override specific components in `./.npl/`  
- **Users** to maintain personal preferences in `~/.npl/`
- **Fine-tuning** only the sections that need customization

Projects typically only need to create files for components they're modifying, inheriting everything else from parent paths. This keeps project-specific NPL directories minimal and focused.
