# Architecture Summary — styleguide-engine

YAML-driven design system generator. Reads YAML config facets from 3 themes (with base-theme inheritance), produces CSS stylesheets and JSX components per theme, renders as a statically-exported Next.js site with client-side theme switching.

## Pipeline

```
Theme discovery (theme-* dirs)
  → base-theme fallback (child wins, base fills gaps)
  → override/variant resolution (per-theme manifest)
  → facet merge (Object.assign + array accumulation)
  → normalization (kebab→camel, defaults)
  → defaults cascade (seeds → base tokens → component tokens)
  → CSS generators (21) + JSX assembler (with import collation)
  → checksum cache → static HTML export
```

## Core Components

- **Theme Discovery** — scans `theme-*` dirs, requires `meta.yaml` with slug
- **Config Loader** — base-theme fallback, override resolution, array-merge for snippets/scoped-vars
- **Branding Loader** — standalone per-theme branding (name, logo, intent, tone)
- **Normalizer** — kebab-case YAML → camelCase TypeScript; injects `themeDir`
- **Defaults Cascade** — ~15 seed values derive 100+ component tokens; YAML overrides win at every level
- **CSS Generators** — 21 ordered modules: vars → code-terminal → globals; each is `(config) → CSS string`
- **JSX Generator** — topo-sorts snippets, extracts + collates imports, writes per-section `.tsx` files
- **CSS Cache** — SHA-256 checksum of all YAML; skip regeneration when unchanged
- **Section Registry** — 21 section IDs mapped to React components
- **Theme Switcher** — DOM attribute (`data-design-theme`) for CSS cascade + React context for data

## Multi-Theme

- 3 themes: style-guide (base), cyberpunk, sumi-e
- Non-base themes inherit missing facets from base theme
- Each theme has independent override/variant manifest
- Build loads all themes into `Record<slug, config>`
- Client switches via `data-design-theme` attribute + context; `localStorage` persists choice

## Rendering

- Server component loads all theme data at build time into pre-computed maps
- `ThemeAwareSections` (client) selects active slice by slug — no re-fetching
- Two-channel switching: DOM attribute (`data-design-theme`) for CSS + React context for data
- FOUC prevention: inline `<script>` restores theme/mode from `localStorage` before paint
- 21 sections registered across 6 source files, looked up by string key from YAML
- Per-section route (`/section/[name]`) uses separate rendering path via `ThemeAwareSectionContent`
- Token consumption via inline `style` with CSS vars, not Tailwind — theme switch is pure CSS

## Key Decisions

- Static export: style guide is a build artifact, no runtime server
- Server components do all generation via Node.js `fs` at build time
- YAML for authoring ergonomics
- Base-theme inheritance: define only what changes
- Defaults cascade: minimal seeds derive full token system
- DOM attribute + React context: two-channel theme switching
- CSS vars over Tailwind: components use `var(--token)` inline styles
- Import collation: JSX snippet imports extracted, deduped, tier-sorted
- Topological sort for snippet dependency ordering
