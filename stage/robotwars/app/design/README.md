# Theme Setup Guide

How to create, preview, and integrate a YAML-driven design system using the `@noizu/styleguide` engine.

---

## Overview

The styleguide engine generates a complete CSS design system from a small set of YAML seed files. Instead of writing hundreds of CSS rules by hand, you declare **~12 design tokens** (colors, fonts, spacing unit) and the engine expands them into 300+ CSS custom properties, 22 component generators, and an interactive style guide viewer.

```
12 seed values (colors, fonts, spacing unit)
  -> 300+ CSS custom properties (gray ramp, spacing scale, component tokens)
    -> 22 CSS generators (cards, buttons, forms, shells, typography, ...)
      -> complete themed style guide (static HTML with live components)
```

The reference implementation lives in `frontend/src/config/theme-style-guide/` — 17 YAML files that define the base theme shipped with `start-app`.

---

## 1. Install the Package

The styleguide package is published to the Verdaccio registry at `npm.noizu.com`.

### Configure `.npmrc`

Your project needs an `.npmrc` that points `@noizu` scoped packages to Verdaccio:

```ini
@noizu:registry=https://npm.noizu.com/
```

> If your Verdaccio instance requires auth, add a token line:
> `//npm.noizu.com/:_authToken=${VERDACCIO_TOKEN}`

### Install

```bash
npm install @noizu/styleguide
```

This gives you:

| Export path | What it provides |
|---|---|
| `@noizu/styleguide/components` | `StyleGuideBtn`, `StyleGuideCard`, etc. |
| `@noizu/styleguide/viewer` | `ThemeConfigProvider`, `ButtonShowcase`, section renderers |
| `@noizu/styleguide/types` | TypeScript interfaces (`StyleGuideConfig`, etc.) |
| `@noizu/styleguide/css-gen` | CSS generation pipeline (used by `npm run regen`) |

The package also provides a CLI binary:

| Binary | Purpose |
|---|---|
| `styleguide-serve` | Preview themes in a standalone viewer (see Section 4) |

---

## 2. Create a Theme Directory

Themes live in directories named `theme-{slug}/` under your config root. The engine discovers them by globbing for `theme-*/style-guide.meta.yaml`.

### Directory structure

```
design/theme/
  theme-{your-slug}/
    style-guide.meta.yaml          # Required — theme identity
    style-guide.vars.yaml          # Required — design token seeds
    branding.yaml                  # Required — brand identity, logo, intro hero
    style-guide.typography.yaml    # Recommended — font families and type classes
    style-guide.color-palette.yaml # Optional — viewer color swatches
    style-guide.color-modes.yaml   # Optional — light/dark surface overrides
    style-guide.globals.yaml       # Optional — global CSS resets
    style-guide.spacing.yaml       # Optional — grid and spacing contexts
    style-guide.page-sections.yaml # Optional — viewer section ordering
    style-guide.page-layouts.yaml  # Optional — content width presets
    style-guide.shell-layouts.yaml # Optional — app shell patterns
    style-guide.design-sections.yaml # Optional — custom page sections
    style-guide.scoped-vars.yaml   # Optional — dark mode, surfaces, containers
    style-guide.css-snippets.yaml  # Optional — raw CSS injection
    style-guide.semantic-classes.yaml # Optional — utility class definitions
    style-guide.semantic-groups.yaml  # Optional — class group organization
    style-guide.glyphs.yaml       # Optional — icon/glyph definitions
```

> **Minimum viable theme**: `style-guide.meta.yaml` + `style-guide.vars.yaml` + `branding.yaml`. Everything else inherits from the base theme (`theme-style-guide/`).

### Starter theme

A minimal starter theme is provided in `design/themes/starter/`. Copy it to bootstrap a new project:

```bash
# From the project root
mkdir -p design/theme
cp -r design/themes/starter design/theme/theme-myproject

# Edit the meta to match your project
vi design/theme/theme-myproject/style-guide.meta.yaml
```

---

## 3. The 17 Config Files (Reference)

These are the files in `frontend/src/config/theme-style-guide/` that define the base theme. Your theme inherits defaults from the base — you only need to override what you want to change.

| File | Purpose | Key fields |
|---|---|---|
| `style-guide.meta.yaml` | Theme identity | `name`, `slug`, `title`, `description` |
| `style-guide.vars.yaml` | All CSS custom properties | Seed groups: Neutrals, Accent Primaries, Semantic, Typography, Spacing, Radius, Base, Branding, Cards, Buttons, Toggle, HUI |
| `branding.yaml` | Brand voice and intro hero | `name`, `logo-text`, `font-url`, `logo-style`, `intent`, `perception`, `audience`, `tone`, `keywords`, `intro` |
| `style-guide.typography.yaml` | Font families + type classes | `typography[]` (font defs), `typography-classes[]` (Display, H1, H2, Body, Code, Label, Data) |
| `style-guide.color-palette.yaml` | Viewer color swatches | `color-palette[]` groups with `colors[]` and `notes[]` |
| `style-guide.color-modes.yaml` | Light/dark surface tokens | Surface, text, border overrides per mode |
| `style-guide.globals.yaml` | Global CSS resets + toast config | `globals` (raw CSS string), `toast` settings |
| `style-guide.spacing.yaml` | Grid + spacing contexts | `grid`, `page-container`, `section-spacing` roles |
| `style-guide.page-sections.yaml` | Viewer section ordering | Section IDs and display order |
| `style-guide.page-layouts.yaml` | Content width presets | Width constraint definitions |
| `style-guide.shell-layouts.yaml` | App shell patterns | Sidebar, topbar, full-width layouts |
| `style-guide.design-sections.yaml` | Custom page sections | Theme-specific sections with custom rendering |
| `style-guide.scoped-vars.yaml` | Scoped CSS vars | Dark mode overrides, surface definitions, layout containers |
| `style-guide.css-snippets.yaml` | Raw CSS injection | Arbitrary CSS scoped to theme slug |
| `style-guide.semantic-classes.yaml` | Utility classes | Named CSS class definitions |
| `style-guide.semantic-groups.yaml` | Class grouping | Organization of semantic classes |
| `style-guide.glyphs.yaml` | Icons/glyphs | Unicode or SVG glyph definitions |

### Customization depth

| Depth | Effort | What you control |
|---|---|---|
| **Seeds only** | ~12 values | Colors, fonts, spacing unit — everything else cascades |
| **Component overrides** | ~30-50 values | Override specific card/button/form tokens |
| **Full theme** | ~270 values | Every token, every component, every detail |
| **Custom sections** | YAML + TSX | Theme-unique page sections with custom rendering |
| **CSS snippets** | YAML with raw CSS | Inject arbitrary CSS into specific sections |

Most projects should start at **seeds only**. The cascade handles the rest.

---

## 4. Preview with `styleguide-serve`

Two ways to preview your theme:

### Option A: `styleguide-serve` (standalone viewer)

After installing `@noizu/styleguide`, the `styleguide-serve` binary is available:

```bash
npx @noizu/styleguide serve ./design/theme/
```

Point it at the directory containing your `theme-*/` folders. It starts a standalone viewer with live preview.

### Option B: `serve-project.sh` (engine dev server)

From the incubator repo root, use `serve-project.sh` to preview a portfolio project's themes in the full engine:

```bash
# From incubator root
./serve-project.sh myproject
```

This:
1. Validates your project has `design/theme/theme-*/` dirs with `style-guide.meta.yaml`
2. Sets `STYLEGUIDE_CONFIG_ROOT` to your project's theme directory
3. Runs CSS regeneration and starts the Next.js dev server

Expected project structure for `serve-project.sh`:

```
projects/{name}/
  design/
    theme/
      theme-{name}/
        style-guide.meta.yaml   # Required
        style-guide.vars.yaml   # Required
        branding.yaml           # Required
```

### Option C: In-project dev server

If your project uses the `start-app` scaffold, CSS generation is built in:

```bash
cd frontend
npm run regen    # Regenerate CSS from theme-* configs
npm run dev      # Start Next.js dev server with /styleguide route
```

---

## 5. Integrate Generated CSS into Next.js

The `start-app` scaffold already has this wired up. Here's what's happening under the hood:

### CSS generation script

`frontend/src/scripts/generate-css.ts` reads all `theme-*/` directories under `src/config/`, runs them through the engine's cascade + generators, and writes:

- `src/app/design-system.generated.css` — composite CSS with all themes
- `public/themes/{slug}.css` — per-theme CSS (lazy-loadable)

### Build integration

```json
{
  "scripts": {
    "regen": "rm -rf .cache && npm run generate-css",
    "build": "npm run generate-css && next build",
    "dev": "next dev"
  }
}
```

- `npm run regen` — force-regenerate CSS (clears cache first)
- `npm run build` — regenerates CSS then builds Next.js

### Import in layout

```tsx
// src/app/layout.tsx
import "./design-system.generated.css";
```

### Theme switching

The engine scopes all CSS with `html[data-design-theme="{slug}"]`. To switch themes at runtime:

```tsx
document.documentElement.setAttribute("data-design-theme", "my-theme-slug");
```

The `ThemeConfigProvider` from `@noizu/styleguide/viewer` handles this automatically if you're using the viewer components.

### Using components

```tsx
import { StyleGuideBtn, StyleGuideCard } from "@noizu/styleguide/components";
import { ThemeConfigProvider, ButtonShowcase } from "@noizu/styleguide/viewer";
import type { StyleGuideConfig } from "@noizu/styleguide/types";
```

---

## 6. Workflow Summary

```
1. Copy themes/starter/ -> design/theme/theme-{slug}/
2. Edit style-guide.meta.yaml (name, slug)
3. Edit style-guide.vars.yaml (colors, fonts, spacing)
4. Edit branding.yaml (logo, intent, audience)
5. npm run regen (or styleguide-serve for preview)
6. Iterate on tokens until the style guide looks right
7. Build: npm run build (CSS is generated automatically)
```

### For new portfolio projects

```bash
# Scaffold the project
init-proj-scaffold myproject.com myproject MyProject

# Copy starter theme
cp -r start-app/design/themes/starter projects/myproject.com/design/theme/theme-myproject

# Preview in the engine
./serve-project.sh myproject.com
```

---

## Files in This Directory

| Path | Purpose |
|---|---|
| `README.md` | This guide |
| `themes/starter/` | Minimal YAML seed files — copy to start a new theme |
