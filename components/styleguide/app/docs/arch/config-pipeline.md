# Config Pipeline

## Theme Discovery

`listThemes()` scans `src/config/` for directories prefixed `theme-`. Each must have a `style-guide.meta.yaml` to be recognized — the meta file provides a `slug` (used as map key) and `name`. Directories without a meta file are silently excluded.

Current themes: `theme-style-guide`, `theme-cyberpunk`, `theme-sumi-e`.

## Base Theme Inheritance

Non-base themes can declare a `base-theme` field in `style-guide.meta.yaml` (defaults to `"theme-style-guide"` if omitted). During loading:

1. Read the theme's own `style-guide.*.yaml` files and track which sections it owns
2. Read the base theme's files and append any sections the child does **not** own as fallback entries
3. Child's own files always win; base theme fills the gaps

`theme-style-guide` is the base — it gets no fallback.

## YAML Facet System

Each theme has ~16-21 independently-editable YAML files:

```
style-guide.meta.yaml          # name, slug, title, description
style-guide.vars.yaml           # CSS custom property definitions
style-guide.color-palette.yaml  # Named color groups
style-guide.color-modes.yaml    # Light/dark mode overrides
style-guide.typography.yaml     # Font families, type scale
style-guide.spacing.yaml        # Spacing token scale (base theme only)
style-guide.globals.yaml        # Global CSS reset/base
style-guide.semantic-classes.yaml
style-guide.semantic-groups.yaml
style-guide.shell-layouts.yaml
style-guide.page-layouts.yaml
style-guide.page-sections.yaml
style-guide.design-sections.yaml
style-guide.scoped-vars.yaml
style-guide.css-snippets.yaml
style-guide.jsx-snippets.yaml   # Base theme only
style-guide.glyphs.yaml
style-guide.overrides.yaml      # Override manifest (per-theme)
branding.yaml                   # Brand identity (standalone, loaded separately)
```

## Override/Variant System

Each theme has its own `style-guide.overrides.yaml` manifest. Any facet can have named variants using the naming convention `style-guide.{section}.{variant}.yaml`.

**Resolution flow:**
1. `getBaseFiles()` finds base files (exactly 2 dot-segments: `style-guide.{section}`)
2. `loadOverrideManifest()` reads the active overrides map
3. `resolveFiles()` swaps base files for their active variant (if the variant file exists)
4. Only one file per facet is ever loaded — variant replaces base entirely

```yaml
# style-guide.overrides.yaml
overrides:
  color-palette: user
  color-modes: user
```

## Merge Strategy

Files are merged via `Object.assign` with special handling for **mergeable keys** that accumulate across files:

| Key | Merge behavior |
|-----|----------------|
| `scoped-vars` | Array items concatenated; object config preserved |
| `css-snippets` | Arrays concatenated |
| `jsx-snippets` | Arrays concatenated |
| `css-load` / `jsx-load` | Arrays concatenated |

Each mergeable key supports a companion `*-defaults` key that provides file-level defaults applied to items in that file before joining the pool.

All other keys use simple `Object.assign` — last file wins.

## Normalization

`normalizer.ts` converts `SimpleStyleGuideConfig` → `StyleGuideConfig`:

- `Record<string, string>` → `Var[]` (name/value pairs, supports both record and array input)
- kebab-case keys → camelCase properties
- Missing optional fields → sensible defaults (e.g., spacing grid defaults to 12 columns)
- `flatVars` computed as a lookup map of all design tokens (after defaults cascade)
- `themeDir` injected — used to resolve `css-load` / `jsx-load` paths

## Loader Exports

| Export | Purpose |
|---|---|
| `listThemes()` | Discover all theme-* dirs, returns `ThemeInfo[]` |
| `loadConfig()` | Load default theme (theme-style-guide) |
| `loadConfigForTheme(dir)` | Load a specific theme by directory path |
| `loadAllConfigs()` | Load all themes, returns `Record<slug, StyleGuideConfig>` |
| `loadPageSections(dir?)` | Load page-section groups for a theme |
| `loadAllPageSections()` | Load page sections for all themes, keyed by slug |
| `loadBranding(path?)` | Load branding for one theme |
| `loadAllBrandings()` | Load branding for all themes, keyed by slug |
| `loadConfigRaw()` | Raw YAML file contents with fallback flags (for editor UI) |

## Dev-Time Override API

`/api/save-config` (POST) provides three actions for the in-browser config editor:

| Action | Purpose |
|--------|---------|
| `save` | Write a new variant YAML file |
| `set-override` | Activate/deactivate a variant in the manifest |
| `get-overrides` | Return manifest + available variants per section |
