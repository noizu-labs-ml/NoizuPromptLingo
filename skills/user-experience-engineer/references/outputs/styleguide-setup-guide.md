# Style Guide Setup Guide

> End-to-end instructions for setting up an interactive style guide using the styleguide-engine. Covers both workflows: the centralized engine viewer and project-local hosting.

---

## 1. Overview

The styleguide-engine is a Next.js 15 app that generates interactive HTML style guides from YAML configuration files. It provides:

- **4-pass defaults cascade:** ~12 seed values expand to ~300 CSS custom properties
- **Theme auto-discovery:** any `theme-*` directory with a `style-guide.meta.yaml` is registered
- **Per-theme CSS scoping:** `html[data-design-theme="{slug}"]` isolates themes
- **Live previews:** color modes, component showcases, typography specimens, theme switching

There are **two workflows** for using the engine, described in §2 and §3. Choose one based on your project's needs.

### When to Read This vs. Other Docs

| You want to... | Read this |
|---|---|
| Set up a new project's style guide from scratch | **This document** (§2 or §3) |
| Convert a completed markdown style guide to YAML | [engine-styleguide.md](engine-styleguide.md) §5-6 |
| Understand the YAML schema in depth | [engine-styleguide.md](engine-styleguide.md) §6 + engine `docs/arch/yaml-configuration.md` |
| Build the markdown style guide itself | [style-guide-construction.md](../process/style-guide-construction.md) |
| Compare design directions (A/B/C/D) | §4 of this document |
| Understand the CSS cascade | Engine `docs/reference/cascade.md` |
| Use components in your app | [engine-styleguide.md](engine-styleguide.md) §10 |

---

## 2. Workflow A: Engine Viewer (`serve-project.sh`)

Use this workflow when you want to preview themes in the centralized styleguide-engine viewer — useful during design exploration, direction comparison, and early-stage work before the project has its own frontend.

### 2.1 Directory Structure

```
projects/{domain}/
  design/
    README.md                          # Design overview, direction comparison
    direction-a-{name}.md             # Design direction A (markdown style guide)
    direction-b-{name}.md             # Design direction B
    logo.svg                           # Logo asset
    theme/                             # ← Engine-compatible theme configs
      theme-{slug-a}/
        style-guide.meta.yaml         # Required
        style-guide.vars.yaml         # Required
        branding.yaml                  # Required
        style-guide.color-modes.yaml  # Required
        ...                            # Optional facets
      theme-{slug-b}/
        style-guide.meta.yaml
        style-guide.vars.yaml
        branding.yaml
        style-guide.color-modes.yaml
```

### 2.2 Setup Steps

**Step 1: Create the design directory**

```bash
mkdir -p projects/{domain}/design/theme/theme-{slug}
```

**Step 2: Copy the theme template**

```bash
cp skills/user-experience-engineer/assets/theme-template/* \
   projects/{domain}/design/theme/theme-{slug}/
```

This copies skeleton YAML files with documented placeholders. At minimum, populate:

| File | What to fill in |
|---|---|
| `style-guide.meta.yaml` | `name`, `slug`, `title`, `description` |
| `style-guide.vars.yaml` | Seed colors (`white`, `black`, accent colors), fonts, radius |
| `branding.yaml` | `name`, `logo-text`, `font-url`, brand identity fields |

**Step 3: Verify slug consistency**

The `slug` in `style-guide.meta.yaml` must match the directory suffix:

```
theme-codefresh-minimal/  →  slug: codefresh-minimal
theme-codefresh-forge/    →  slug: codefresh-forge
```

**Step 4: Preview in the engine**

```bash
./serve-project.sh {domain}
```

This script:
1. Removes all symlinked themes from the engine's `src/config/`
2. Symlinks your `design/theme/theme-*` directories into the engine
3. Runs `regen.sh` (CSS generation) and starts the dev server

Open http://localhost:3000 — the theme picker shows your theme(s) alongside the base theme.

### 2.3 Requirements

- The engine must be cloned (`styleguide-engine/` submodule initialized)
- Node 22+, npm installed
- `.npmrc` configured for Verdaccio (`npm.noizu.com`) for the `@noizu/styleguide` dependency
- Engine dependencies installed: `cd styleguide-engine/app && npm install`

---

## 3. Workflow B: Project-Local Hosting (Starter)

Use this workflow when the project has its own frontend and you want the style guide as part of the project's web app — the `/styleguide` route lives alongside your product pages.

### 3.1 Directory Structure

This is the codefre.sh pattern:

```
projects/{domain}/
  app/
    frontend/
      src/
        config/
          theme-style-guide/             # Base theme (rename or customize in place)
            style-guide.meta.yaml
            style-guide.vars.yaml
            branding.yaml
            style-guide.color-modes.yaml
            style-guide.color-palette.yaml
            style-guide.css-snippets.yaml
            style-guide.design-sections.yaml
            style-guide.globals.yaml
            style-guide.glyphs.yaml
            style-guide.page-layouts.yaml
            style-guide.page-sections.yaml
            style-guide.scoped-vars.yaml
            style-guide.semantic-classes.yaml
            style-guide.semantic-groups.yaml
            style-guide.shell-layouts.yaml
            style-guide.spacing.yaml
            style-guide.typography.yaml
            style-guide.vars.yaml
        app/
          styleguide/
            page.tsx                      # Full interactive viewer
          design-system.generated.css     # Generated (gitignored)
```

### 3.2 Setup Steps

**Option A: From starter tarball**

```bash
tar xzf skills/user-experience-engineer/assets/styleguide-starter.tar.gz \
  -C projects/{domain}/web

cd projects/{domain}/web
npm install
npm run regen
npm run dev
```

**Option B: From init-proj-scaffold (full-stack)**

```bash
init-proj-scaffold {domain} {slug} {ElixirModule}
cd projects/{domain}/app
make init && make build && make run
```

The scaffold includes `frontend/src/config/theme-style-guide/` with all YAML facets pre-populated with documented placeholders. Edit them in place.

**Option C: Manual setup** (when integrating into an existing Next.js project)

1. Add `@noizu/styleguide` to `package.json`
2. Add webpack alias and tsconfig paths for `@styleguide-engine/`
3. Create `src/config/theme-{slug}/` with the 3 required files
4. Add `src/scripts/generate-css.ts` (calls `generateCSS()` from the package)
5. Add `src/app/styleguide/page.tsx` (renders the viewer)
6. Import generated CSS in `globals.css`

### 3.3 Customizing the Theme

**Minimum viable theme** — 3 files + color modes:

```yaml
# style-guide.meta.yaml
name: "CodeFresh"
slug: "codefresh"
title: "CodeFresh — Style Guide"
description: "Eval-driven AI development platform."
```

```yaml
# style-guide.vars.yaml
vars:
  groups:
    - name: Theme Seeds
      vars:
        white: "#ffffff"
        black: "#000000"
        red: "#7C3AED"          # your primary accent
        blue: "#0047ab"
        yellow: "#f5c518"
        success: "#22c55e"
        warning: "#eab308"
        error: "#ef4444"
        info: "#3b82f6"
        font-sans: "'Geist', -apple-system, sans-serif"
        font-mono: "'Geist Mono', 'Menlo', monospace"
        radius: "6px"
```

```yaml
# branding.yaml
name: "CodeFresh"
logo-text: "CODEFRESH"
font-url: "https://fonts.googleapis.com/css2?family=..."
intent: "Eval-driven development platform for AI builders."
perception: "Competent, fast, trustworthy."
audience: "AI engineers who ship production models."
tone: "Direct, technical, never condescending."
keywords: [eval, ship, iterate, precise, fast]
```

```yaml
# style-guide.color-modes.yaml
color-modes:
  light:
    surface: "var(--white)"
    surface-alt: "var(--gray-50)"
    text: "var(--black)"
    text-secondary: "var(--gray-700)"
    text-muted: "var(--gray-500)"
    border: "var(--gray-200)"
    border-strong: "var(--gray-300)"
  dark:
    surface: "#1a1a1a"
    surface-alt: "#252525"
    text: "#e8e8e8"
    text-secondary: "var(--gray-400)"
    text-muted: "var(--gray-500)"
    border: "#333333"
    border-strong: "var(--gray-600)"
```

Everything else inherits from the base theme. Add facet files only to override.

### 3.4 Regenerate and Preview

```bash
npm run regen    # or: ./regen.sh
npm run dev      # → http://localhost:3000/styleguide
```

**Never run `npx next build` in a running dev environment** — use `tsc --noEmit` for type checking.

---

## 4. Multiple Design Directions

For projects exploring multiple visual directions (like codefre.sh with 4 directions), create a separate theme per direction.

### 4.1 Design Directory Layout

```
projects/{domain}/design/
  README.md                            # Comparison table + decision framework
  direction-a-{name}.md              # Full markdown style guide for direction A
  direction-a-{name}.html            # Optional rendered preview
  direction-b-{name}.md
  direction-c-{name}.md
  logo.svg
  theme/
    theme-{domain}-{direction-a}/
    theme-{domain}-{direction-b}/
    theme-{domain}-{direction-c}/
```

### 4.2 Naming Convention

Theme directories follow: `theme-{project}-{direction-name}`

Examples from codefre.sh:
- `theme-codefresh-minimal` (Direction A: Minimal Tech 100%)
- `theme-codefresh-editorial` (Direction B: MT 80% + Editorial 20%)
- `theme-codefresh-brutalist` (Direction C: Neo-Brutalist)
- `theme-codefresh-forge` (Direction D: Forge)

### 4.3 Design README Template

The design README should include (see `projects/codefre.sh/design/README.md` as reference):

1. **At-a-glance comparison table** — columns per direction, rows for: name, style system, primary font, accent color, border radius, motion, risk level
2. **Decision framework** — flowchart or decision tree for choosing between directions
3. **Mixing guidance** — which directions can be combined, how
4. **What's not covered** — explicit scope boundaries
5. **Next steps** — what to do after selection

### 4.4 Preview All Directions

```bash
./serve-project.sh {domain}
# Theme picker shows all theme-* directories — compare side by side
```

---

## 5. Reference Implementation: codefre.sh

codefre.sh demonstrates the recommended setup pattern. Key aspects:

### What codefre.sh Does Well

| Aspect | Implementation |
|---|---|
| **Design exploration** | 4 design directions as separate markdown files with comparison table |
| **Decision framework** | Flowchart in README for choosing between directions |
| **Complete vars.yaml** | All component-level overrides (cards, buttons, HUI controls, toggles) |
| **Color modes** | Distinct light and dark modes with semantic token mapping |
| **Full facet coverage** | All 17 YAML facet files populated (not just the required 4) |
| **Font loading** | Google Fonts URL in branding.yaml, matching font-sans/font-mono in vars |
| **Project-local hosting** | Themes in `app/frontend/src/config/` for integrated dev experience |

### codefre.sh File Inventory

| File | Status | Key Content |
|---|---|---|
| `style-guide.meta.yaml` | Placeholder | Needs project name/slug |
| `branding.yaml` | Placeholder | Needs brand identity, logo, intro hero |
| `style-guide.vars.yaml` | **Customized** | Space Grotesk + IBM Plex Mono, full gray ramp, 17 var groups |
| `style-guide.color-modes.yaml` | **Customized** | Light: white ground, cool gray. Dark: warm charcoal, soft contrast |
| `style-guide.color-palette.yaml` | Customized | Brand reds, blues, yellows + semantic colors |
| `style-guide.css-snippets.yaml` | Customized | Custom component CSS |
| `style-guide.scoped-vars.yaml` | Customized | Selector-level overrides for dark mode |
| `style-guide.semantic-classes.yaml` | Customized | Danger/success/warning/info classes |
| `style-guide.typography.yaml` | Customized | Space Grotesk + IBM Plex Mono declarations |
| `style-guide.spacing.yaml` | Customized | 8px base unit, 12-col grid |
| `style-guide.page-layouts.yaml` | Customized | Standard + article layouts |
| `style-guide.shell-layouts.yaml` | Customized | Navbar + sidebar + footer shells |
| `style-guide.globals.yaml` | Customized | Base element resets |
| `style-guide.page-sections.yaml` | Customized | Viewer section ordering |
| `style-guide.design-sections.yaml` | Customized | Design principle rows |
| `style-guide.glyphs.yaml` | Customized | Unicode glyph browser entries |
| `style-guide.semantic-groups.yaml` | Customized | Semantic class groupings |

### Lessons from codefre.sh

1. **Start with vars.yaml** — the cascade derives everything from seeds, so this is the highest-leverage file
2. **Populate all facet files** — even optional ones. The base theme defaults are generic; project-specific values make the style guide useful
3. **Color modes are not optional** — every production theme needs real light and dark modes
4. **Design directions as markdown first** — write full style guides as markdown, then extract to YAML (see [engine-styleguide.md](engine-styleguide.md) §5)
5. **Component overrides matter** — codefre.sh defines 17 var groups including HUI controls, toggles, and cards. Without these, components use generic base theme styling

---

## 6. Complete Setup Checklist

### Prerequisites

- [ ] Node 22+ and npm installed
- [ ] `.npmrc` configured for Verdaccio (`npm.noizu.com`)
- [ ] Engine submodule initialized (Workflow A) or starter extracted (Workflow B)
- [ ] Engine dependencies installed (`npm install` in engine/app or project/web)

### Required Files (Minimum Viable Theme)

- [ ] `style-guide.meta.yaml` — name, slug, title, description
- [ ] `style-guide.vars.yaml` — at minimum: white, black, one accent, font-sans, radius
- [ ] `branding.yaml` — name, logo-text, font-url
- [ ] `style-guide.color-modes.yaml` — light and dark modes with semantic tokens

### Validation

- [ ] Slug in meta.yaml matches directory suffix (`theme-foo/` → `slug: foo`)
- [ ] All hex values are valid 6-digit with `#` prefix
- [ ] Font families in vars.yaml match those loaded via branding.yaml `font-url`
- [ ] Semantic colors (success/warning/error/info) are defined
- [ ] `npm run regen` completes without errors
- [ ] `/styleguide` renders with correct colors, fonts, and components
- [ ] Dark mode toggle works and produces distinct light/dark rendering
- [ ] Theme appears in the theme picker (if multiple themes exist)

### Production Completeness

- [ ] All 17 YAML facet files populated (not just the required 4)
- [ ] Brand identity fields filled in branding.yaml (intent, perception, audience, tone, keywords)
- [ ] Intro hero configured with project-specific title, subtitle, color bar, meta cards
- [ ] Logo HTML in branding.yaml renders correctly
- [ ] Custom CSS snippets added for project-specific components
- [ ] Semantic classes configured for project states (danger, success, warning, info)
- [ ] Page layouts defined for project content types (standard, article, dashboard, etc.)
- [ ] Shell layouts defined for project navigation patterns

---

## 7. YAML Facet Reference (Quick)

All files live in the theme directory (`theme-{slug}/`). For full schema details, see [engine-styleguide.md](engine-styleguide.md) §6 and engine `docs/arch/yaml-configuration.md`.

| File | Top-Level Key | Purpose | Required? |
|---|---|---|---|
| `style-guide.meta.yaml` | `name`, `slug`, `title`, `description` | Theme identity | **Yes** |
| `style-guide.vars.yaml` | `vars.groups[]` | CSS custom properties (seed values → cascade) | **Yes** |
| `branding.yaml` | (standalone) | Brand identity, logo, intro hero | **Yes** |
| `style-guide.color-modes.yaml` | `color-modes.light`, `color-modes.dark` | Semantic surface/text/border overrides per mode | **Yes** |
| `style-guide.color-palette.yaml` | `color-palette[]` | Color groups for the palette viewer | No |
| `style-guide.typography.yaml` | `typography[]`, `typography-classes[]` | Font declarations and type scale | No |
| `style-guide.spacing.yaml` | `spacing-contexts` | Grid, container, rhythm settings | No |
| `style-guide.page-layouts.yaml` | `page-layouts[]` | Content width presets with chrome | No |
| `style-guide.shell-layouts.yaml` | `shell-layouts[]` | Page shell wireframes (navbar/sidebar/footer) | No |
| `style-guide.css-snippets.yaml` | `css-snippets[]` | Custom CSS rules (accumulated with base) | No |
| `style-guide.scoped-vars.yaml` | `scoped-vars[]` | Selector-scoped vars (accumulated with base) | No |
| `style-guide.semantic-classes.yaml` | `semantic-classes[]` | Contextual modifier classes (danger, success, etc.) | No |
| `style-guide.semantic-groups.yaml` | `semantic-groups[]` | Groupings for semantic classes | No |
| `style-guide.globals.yaml` | `globals` | Raw CSS injected last (resets, base elements) | No |
| `style-guide.glyphs.yaml` | `glyph-language` | Unicode glyph browser entries | No |
| `style-guide.design-sections.yaml` | `design-sections` | Design principle rows for the viewer | No |
| `style-guide.page-sections.yaml` | `page-sections[]` | Controls which sections appear in the viewer | No |

### Merge Behavior

Most files **replace** the base theme's equivalent when present. These 5 keys **accumulate** (entries from both theme and base are merged):

- `css-snippets`
- `jsx-snippets`
- `scoped-vars`
- `css-load`
- `jsx-load`

---

## 8. Common Pitfalls

| Problem | Cause | Fix |
|---|---|---|
| Theme not appearing in picker | Directory doesn't start with `theme-` or missing `style-guide.meta.yaml` | Rename directory, add meta.yaml |
| CSS not scoped correctly | Slug mismatch between meta.yaml and directory name | Ensure `theme-foo/` has `slug: foo` |
| Fonts not loading | `font-url` in branding.yaml doesn't match font families in vars.yaml | Verify Google Fonts URL includes all declared weights |
| Dark mode looks identical to light | Color modes not defined or both set to same values | Populate `style-guide.color-modes.yaml` with distinct light/dark values |
| Components look generic | Only seed vars defined, no component overrides | Add component-level vars (card-\*, btn-\*, etc.) to vars.yaml |
| `serve-project.sh` fails | No `design/theme/` directory or no `theme-*` subdirs | Create the expected directory structure |
| CSS snippets not scoped | Snippet body missing `html[data-design-theme="slug"]` prefix | Snippets are emitted verbatim — you must self-scope |
| `npm run regen` fails | npm not configured for Verdaccio registry | Ensure `.npmrc` points to `npm.noizu.com` for `@noizu` scope |

---

## 9. Recommended Order of Operations

For a new project in the incubator:

```
1. Select style system
   └── SKILL.md Style Selector table → choose pure or mixed (80/20)

2. Write design direction(s) as markdown
   └── process/style-guide-construction.md → full markdown style guide(s)
   └── Save to projects/{domain}/design/direction-{x}-{name}.md

3. Write design README
   └── Comparison table + decision framework (see codefre.sh/design/README.md)

4. Extract YAML from selected direction
   └── engine-styleguide.md §5-6 → section-to-YAML mapping

5. Create theme directory
   └── Workflow A: projects/{domain}/design/theme/theme-{slug}/
   └── Workflow B: projects/{domain}/app/frontend/src/config/theme-{slug}/

6. Populate required files first
   └── meta.yaml → vars.yaml → branding.yaml → color-modes.yaml

7. Regenerate and preview
   └── Workflow A: ./serve-project.sh {domain}
   └── Workflow B: npm run regen && npm run dev

8. Iterate on optional facets
   └── typography, spacing, snippets, semantic classes, etc.

9. Validate
   └── §6 checklist above
```

---

## Related Documents

- [engine-styleguide.md](engine-styleguide.md) — YAML extraction from markdown, full schema templates, component reference
- [style-guide-construction.md](../process/style-guide-construction.md) — Building the markdown style guide
- [project-scaffold.md](project-scaffold.md) — Full-stack project scaffolding (includes theme setup)
- Engine docs: `styleguide-engine/app/docs/guides/creating-themes.md` — Theme creation walkthrough
- Engine docs: `styleguide-engine/app/docs/arch/yaml-configuration.md` — Full YAML schema reference
- Engine docs: `styleguide-engine/app/docs/reference/cascade.md` — Seed-to-token cascade
