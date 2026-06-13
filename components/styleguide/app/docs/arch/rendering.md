# Rendering

## Page Assembly (`page.tsx`)

The home page is a server component. All data loading happens at build/request time:

```
loadAllConfigs()          → Record<slug, StyleGuideConfig>
loadAllBrandings()        → Record<slug, BrandingConfig>
loadAllPageSections()     → Record<slug, SectionGroup[]>
generateCSSSections()     → per-theme CSS output (for inspector views)
```

`numberGroups()` walks YAML-defined section groups and assigns padded sequential numbers (`01`, `02`, …). All pre-computed maps are passed down — the client switches between them by slug without re-fetching.

**Render tree:**
```
ThemeConfigProvider              ← all configs + brandings injected
  PageContent
    ShellChrome
    LayoutBar                    ← theme switcher lives here
    .content
      ThemeAwareSections         ← receives all*Maps, picks active slice
```

## Two-Channel Theme Switching

Theme switching uses two synchronized mechanisms:

### Channel 1: DOM Attribute (CSS cascade)

`data-design-theme` on `<html>` drives all CSS variable scoping. Selectors like `[data-design-theme="cyberpunk"]` activate per-theme token values. Changing the attribute instantly switches the entire visual system — no React render needed for CSS.

### Channel 2: React Context (component data)

`ThemeConfigContext` provides `config`, `branding`, `allBrandings`, and `activeSlug`. Components call `useThemeConfig()` to get the active theme's data. When `activeSlug` changes, `ThemeAwareSections` selects the correct slice from the pre-loaded maps.

Both channels update simultaneously on theme switch. `localStorage` persists the user's choice.

## FOUC Prevention

`layout.tsx` injects an inline `<script>` in `<head>` that runs synchronously before paint:

1. Reads `sg-theme` from `localStorage` → sets `data-design-theme` on `<html>`
2. Reads `color-mode` from `localStorage` → sets `dark` class on `<html>`

This prevents flash of wrong theme/mode on page load. The server renders with the default theme; the inline script corrects before the browser paints.

## Section Registry (`sections/index.ts`)

A flat `Record<string, (props: SectionProps) => ReactNode>` mapping 21 section IDs to components across 6 source files:

| Source | Sections |
|--------|----------|
| `visual-foundation` | `typography`, `color`, `spacing`, `dividers`, `glyphs`, `code-blocks`, `terminal` |
| `structure` | `shell-layouts`, `content-layouts`, `site-archetypes`, `navigation` |
| `interaction` | `semantic-classes`, `status-indicators`, `ui-elements` |
| `reference` | `design-tokens`, `generated-css`, `theme-config`, `snippets`, `overrides` |
| `ink-effects` | `ink-effects` |
| `screens` | `screens` |

Lookup is by string key from `page-sections.yaml`. Unknown keys silently return `null`.

## Theme-Aware Sections (`ThemeAwareSections.tsx`)

Client component. Reads `activeSlug` from context, indexes into the pre-loaded maps, then renders:

```
IntroHero                        ← MutationObserver watches data-design-theme
StyleGuideProductBranding
  ThemeLogo                      ← also MutationObserver-driven
[SectionGroup]                   ← one per YAML group
  [Section]                      ← from registry, receives full theme config + CSS sections
```

Each section receives the full theme config and CSS sections — sections consume what they need.

## Per-Section Route (`/section/[name]`)

`ThemeAwareSectionContent` handles the standalone section view at `/section/[name]`. Uses a `switch(name)` to render individual showcase components (not the registry). Sections in `NEEDS_PICKER` get a `SemanticClassSummary` prepended.

This is a separate rendering path from the main page — detail views, not the registry-driven list.

## MutationObserver Pattern

`IntroHero` and `ThemeLogo` watch `data-design-theme` via `MutationObserver` rather than React context. This lets them react to theme changes without prop drilling or context subscription — the DOM attribute is the single source of truth for CSS-level concerns.

Pattern: receive all brandings as a server-side map, observe the DOM attribute client-side, select the active branding slice reactively.

## Token Consumption Convention

Components consume design tokens via inline `style={{ color: "var(--token)" }}` rather than Tailwind utility classes. This keeps components decoupled from the utility framework and makes theme switching a pure CSS operation — swapping `data-design-theme` redefines the variables, and all consuming elements update automatically.

Code/terminal showcases use micro-components (`KW`, `STR`, `CMT`, `FN`, `NUM`) that map to `--code-keyword`, `--code-string`, etc. — a lightweight DSL for themed code examples.
