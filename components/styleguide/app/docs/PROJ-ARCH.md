# Architecture — styleguide-engine

## Overview

A **YAML-driven design system generator** that reads structured config files from multiple themes, produces a complete CSS stylesheet and JSX component library per theme, and renders an interactive style guide as a statically-exported Next.js site.

All design tokens, semantic classes, layouts, typography, and component styles are defined in YAML. Themes inherit from a base theme with per-facet override capabilities. The system has no runtime server — Next.js server components do all generation at build time, producing a fully static site with client-side theme switching.

## System Diagram

```mermaid
graph LR
    subgraph Config ["YAML Config Layer"]
        T1[theme-style-guide/<br>19 facets + overrides]
        T2[theme-cyberpunk/<br>16 facets]
        T3[theme-sumi-e/<br>16 facets]
    end

    subgraph Load ["Config Pipeline"]
        D[listThemes()<br>discover theme-* dirs]
        L[loadConfigFromDir()<br>base-theme fallback + merge]
        N[normalizer.ts<br>Simple → Internal]
    end

    subgraph Gen ["Generation"]
        DF[defaults.ts<br>4-level token cascade]
        CG[css-gen/<br>22 generators]
        JG[jsx-gen/<br>snippet + import collation]
        Cache[css-cache.ts<br>SHA-256 checksum]
    end

    subgraph Out ["Output"]
        CSS[design-system.generated.css]
        JSX[components/generated/*.tsx]
        HTML[Static HTML export]
    end

    T1 & T2 & T3 --> D
    D --> L
    L --> N
    N --> DF
    DF --> CG
    N --> JG
    CG --> Cache
    Cache --> CSS
    JG --> JSX
    CSS --> HTML
    JSX --> HTML
```

## Core Components

| Component | Location | Purpose |
|-----------|----------|---------|
| Theme Discovery | `config/loader.ts` | Scans `theme-*` dirs, requires `meta.yaml` |
| Config Loader | `config/loader.ts` | Base-theme fallback, override resolution, facet merge |
| Branding Loader | `config/branding-loader.ts` | Standalone branding config per theme |
| Normalizer | `lib/normalizer.ts` | Converts YAML simple format to internal typed format |
| Defaults Cascade | `lib/css-gen/defaults.ts` | 3-level token derivation (seeds → base → components) |
| CSS Generators | `lib/css-gen/` (21 modules) | Produce CSS rules from normalized config |
| JSX Generator | `lib/jsx-gen/` | Assembles JSX snippets with import collation + topo sort |
| CSS Cache | `lib/css-cache.ts` | SHA-256 checksum invalidation, writes generated CSS |
| Section Registry | `components/sections/index.ts` | Maps 21 section IDs → React components |
| Theme Switcher | `components/ThemeAwareSections.tsx` | Client-side theme switching via context + DOM attribute |
| Style Injector | `components/StyleInjector.tsx` | Injects generated CSS via `<style>` tag |
| Override API | `app/api/save-config/route.ts` | Dev-time REST endpoint for variant management |

## Multi-Theme System

Themes are directories under `src/config/theme-*`. Each must have a `style-guide.meta.yaml` with a `slug` and `name`. Non-base themes declare a `base-theme` field (defaults to `theme-style-guide`). The loader fills missing facets from the base theme — child's own files always win.

At build time, `loadAllConfigs()` produces a `Record<slug, StyleGuideConfig>` passed to the page. Client-side switching uses two synchronized mechanisms: a `data-design-theme` attribute on `<html>` (drives CSS variable cascade) and React context (`ThemeConfigContext`) for component data.

→ *See [arch/config-pipeline.md](arch/config-pipeline.md) for override resolution and merge strategy*

## Config Pipeline

YAML config is split into ~16-21 "facet" files per theme (vars, typography, color-palette, semantic-classes, etc.). The loader discovers themes, resolves base-theme fallbacks, applies override variants, and merges facets with special array-accumulation handling for snippets, scoped-vars, and loads.

→ *See [arch/config-pipeline.md](arch/config-pipeline.md) for details*
→ *See [arch/yaml-configuration.md](arch/yaml-configuration.md) for the full YAML schema reference*

## Generation

CSS generation runs 21 ordered generators (vars → globals). A defaults cascade engine derives ~300 component tokens from a small set of seed values before the main generators run. The full stylesheet is checksum-cached via SHA-256. Import collation for JSX snippets is now fully implemented — imports are extracted, deduplicated, and sorted into tiered blocks.

→ *See [arch/generation.md](arch/generation.md) for details*

## Rendering

The home page is a server component that loads all theme configs at build time and passes pre-computed maps to `ThemeAwareSections` (client component). The client selects the active theme slice by slug — no re-fetching. Theme switching uses two synchronized channels: a `data-design-theme` DOM attribute (CSS cascade) and React context (component data). An inline `<script>` restores the user's choice from `localStorage` before paint to prevent FOUC.

→ *See [arch/rendering.md](arch/rendering.md) for details*

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| **Static export** (`output: "export"`) | No server needed — the style guide is a build artifact |
| **Server components for generation** | `loadConfig()` runs at build time with full Node.js fs access |
| **YAML over JSON/TS** | Authoring ergonomics — non-developers can edit design tokens |
| **Base-theme inheritance** | Non-base themes only define what they change; gaps filled from base |
| **Defaults cascade engine** | ~12 seed values derive ~300 component tokens across 4 passes, YAML overrides win at every level |
| **Checksum caching** | Avoids regenerating CSS when YAML hasn't changed |
| **DOM attribute + React context** | Two-channel theme switching: CSS cascade (attribute) + component data (context) |
| **CSS vars over Tailwind** | Components use `var(--token)` inline styles — decoupled from utility framework |
| **Import collation** | JSX snippets have imports extracted, deduped, and sorted automatically |
| **Topological sort for snippets** | CSS/JSX snippets can declare dependencies for correct ordering |

## User-Facing Documentation

Detailed guides and references live in `app/docs/`:

| Doc | Audience | What it covers |
|-----|----------|----------------|
| [Overview & Purpose](./overview.md) | All | Why the engine exists, skill workflow, leverage ratio |
| [Creating Themes](./guides/creating-themes.md) | Theme authors | Scaffolding, inheritance, custom sections |
| [YAML Config Reference](./reference/yaml-config.md) | Theme authors | All 19 config file schemas |
| [Token Reference](./reference/token-reference.md) | Theme authors | ~300 auto-generated CSS custom properties |
| [Variable Cascade](./reference/cascade.md) | Theme authors | 4-pass resolver, seed → token derivation |
| [Branding & Intro](./guides/branding.md) | Theme authors | Logo, intro hero, font loading |
| [Variants](./guides/variants.md) | Theme authors | Override/variant file system |
| [CSS Generators](./reference/css-generators.md) | Engine devs | 22 generators, pipeline order |
| [Adding Generators](./arch/adding-generators.md) | Engine devs | How to extend the CSS pipeline |
| [CSS Scoping](./arch/css-scoping.md) | Engine devs | Multi-theme scoping model |
| [Snippets](./arch/snippets.md) | Engine devs | CSS/JSX snippet assembly and rendering |
| [Custom Sections](./arch/custom-sections.md) | Engine devs | Adding page sections to the style guide |
| [Troubleshooting](./troubleshooting/troubleshooting.md) | All | Common issues and diagnostic checklists |

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 15 (App Router, static export) |
| Styling | Tailwind CSS v4 + generated CSS custom properties |
| Config format | YAML (js-yaml) |
| Language | TypeScript (strict) |
| UI Components | Headless UI (React), Sonner (toasts) |
| Code editor | Monaco Editor (config viewer) |
| Runtime | Node.js 22 (asdf `.tool-versions`) |
