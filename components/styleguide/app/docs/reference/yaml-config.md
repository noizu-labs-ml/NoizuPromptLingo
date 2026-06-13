# YAML Config Reference

Config files live in `src/config/theme-*/` directories (e.g. `theme-cyberpunk/`, `theme-sumi-e/`). Each theme directory contains `style-guide.*.yaml` files that are globbed alphabetically and merged with `Object.assign` — later files override earlier top-level keys. Themes inherit from a base theme; the `overrides` file selects which variant files to load per section.

Snippet files (`css-snippets`, `jsx-snippets`) are **accumulated** across all matching files rather than replaced — this allows multiple files to contribute snippets to the same target section.

## File inventory

| File | Key(s) | Purpose |
|------|--------|---------|
| `style-guide.meta.yaml` | `name`, `slug`, `title`, `description` | Theme identity |
| `style-guide.vars.yaml` | `vars.groups[]` | CSS custom properties |
| `style-guide.scoped-vars.yaml` | `scoped-vars`, `scoped-vars-defaults` | Selector-scoped CSS custom properties with section contexts |
| `style-guide.color-modes.yaml` | `color-modes` | Light/dark token maps |
| `style-guide.semantic-groups.yaml` | `semantic-groups[]` | Category labels for semantic classes |
| `style-guide.semantic-classes.yaml` | `semantic-classes[]` | Contextual modifiers (`.danger`, `.info`, etc.) |
| `style-guide.page-layouts.yaml` | `page-layouts[]` | Layout templates with chrome and scoped vars |
| `style-guide.shell-layouts.yaml` | `shell-layouts[]` | App shell definitions (navbar, sidebar, footer) |
| `style-guide.typography.yaml` | `typography[]`, `typography-classes[]` | Font family metadata, weight availability, and named type styles |
| `style-guide.color-palette.yaml` | `color-palette[]` | Named color groups for documentation |
| `style-guide.globals.yaml` | `globals`, `toast` | Raw CSS string (resets, base styles) and toast config |
| `style-guide.spacing.yaml` | `spacing-contexts` | Grid, page container, section rhythm |
| `style-guide.glyphs.yaml` | `glyph-language` | Unicode glyph/icon principles |
| `style-guide.design-sections.yaml` | `design-sections[]` | Component design patterns |
| `style-guide.css-snippets.yaml` | `css-snippets[]`, `css-snippets-defaults` | Injected CSS blocks (accumulated across files) |
| `style-guide.jsx-snippets.yaml` | `jsx-snippets[]`, `jsx-snippets-defaults` | Injected JSX/React components (accumulated across files) |
| `style-guide.overrides.yaml` | `overrides` | Variant file selection per section |
| `branding.yaml` | (standalone, not merged) | Brand personality |

Any yaml file may also contain `css-load` and `jsx-load` keys for loading external CSS/JSX files into the pipeline.

## File schemas

### style-guide.meta.yaml

```yaml
name: style-guide          # Internal identifier
slug: style-guide           # Used in data-design-theme attribute
title: Style Guide          # Display title
description: "..."          # Subtitle / tagline
```

### style-guide.vars.yaml

CSS custom properties organized into named groups. Each var becomes `--{name}: {value};` in the output.

```yaml
vars:
  groups:
    - name: Surfaces
      vars:
        white: "#ffffff"
        black: "#000000"
        gray-50: "#f5f5f5"
        # ...

    - name: Typography
      vars:
        font-sans: "'Space Grotesk', -apple-system, sans-serif"
        font-size-base: "16px"
        # ...

    - name: Cards
      vars:
        card-padding: "var(--space-3)"    # references another var
        card-background: "var(--white)"
        # ...
```

**Var reference syntax:** Values can reference other vars using standard CSS syntax: `"var(--space-3)"`. The resolver passes these through verbatim — the browser resolves the chain at runtime.

**Var groups in the current theme:**

| Group | Count | Examples |
|-------|-------|---------|
| Surfaces | 13 | `--white`, `--gray-50` through `--gray-900`, `--black` |
| Primaries | 9 | `--red`, `--blue`, `--yellow` + light/mid variants |
| Semantic | 8 | `--success`, `--warning`, `--error`, `--info` + `-bg` |
| Typography | 12 | `--font-sans`, `--font-mono`, `--font-size-xs` through `--font-size-display` |
| Grid & Spacing | 14 | `--unit`, `--space-half` through `--space-16`, `--radius`, `--col-gap` |
| Base | 5 | `--base-font-family`, `--base-font-color` (reference other vars) |
| Cards | ~37 | `--card-padding`, `--card-background`, `--card-title-font-size` |
| Buttons | ~29 | `--btn-font-size`, `--btn-padding-y`, `--btn-outline-color` |
| Tokens | ~22 | `--token-card-padding`, `--token-row-font-size` |
| Toggle | 5 | `--toggle-icon-size`, `--toggle-icon-color` |
| HUI (7 groups) | ~120 | Focus, Controls, Triggers, Panels, Tabs, Disclosure, Fields, Dialog, Showcase |

### style-guide.scoped-vars.yaml

Selector-scoped CSS custom properties. Unlike `vars` which output into the theme root, scoped vars are emitted under specific CSS selectors. Each var can have a single value or per-section values for different selector contexts.

```yaml
scoped-vars-defaults:          # optional file-level defaults
  prefix: "theme"

scoped-vars:
  prefix: "theme"              # prefix for generated var names (--{prefix}-{name})
  sections:                    # named CSS selector contexts
    standard:
      selector: 'html[data-design-theme="style-guide"]'
      prefix: "theme"          # optional per-section prefix override
    dark:
      selector: 'html[data-design-theme="style-guide"].dark'

  vars:                        # array of variable entries
    - name: surface
      value:                   # section-specific values (array form)
        - section: standard
          value: "var(--white)"
        - section: dark
          value: "var(--slate-800)"

    - name: content-container-type
      value: "inline-size"     # simple string form (same across all sections)
      selector: ".content"     # optional standalone selector override
      selector-body: "container-type: var(--content-container-type)"  # extra CSS in the selector block
```

**Value forms:**
- **String** — same value emitted into all sections
- **Array of `{ section, value }`** — different value per named section

### style-guide.color-modes.yaml

Token maps for light and dark modes. Each key in a mode maps a semantic token name to a concrete var reference or value.

```yaml
color-modes:
  light:
    surface: "var(--white)"
    text: "var(--black)"
  dark:
    surface: "var(--slate-800)"
    text: "var(--gray-100)"
```

### style-guide.semantic-groups.yaml

Category labels referenced by `semantic-classes` entries via the `group` field.

```yaml
semantic-groups:
  - name: States
    description: "Feedback and status indicators"
  - name: Actions
    description: "Interactive intent classes"
```

### style-guide.semantic-classes.yaml

Defines contextual modifier classes that apply to cards, buttons, and text.

```yaml
semantic-classes:
  - name: danger
    class: danger
    group: States           # references a semantic-group
    title: Danger
    description: "Destructive actions, errors, critical states"
    accent-style: bottom-bar  # bottom-bar | left-border | outer-shadow | inner-glow | ...
    vars:
      accent: "#c41a1a"
      background: "rgba(196, 26, 26, 0.06)"
      color: "#c41a1a"
      # optional text overrides:
      font-family: "..."
      font-weight: "..."
```

**accent-style options:** `bottom-bar`, `bottom-bar-glow`, `left-border`, `left-dashed`, `outer-shadow`, `inner-shadow`, `outer-glow`, `inner-glow`, `none`

### style-guide.page-layouts.yaml

```yaml
page-layouts:
  - name: standard
    title: Standard
    description: "Max-width centered content column"
    selector: ".layout-standard"
    vars:
      max-width: "1280px"
      padding-x: "var(--space-5)"
    chrome:
      navbar: { height: "56px", background: "var(--black)", color: "var(--white)" }
      sidebar: { width: "240px", background: "var(--gray-100)" }
```

### style-guide.shell-layouts.yaml

```yaml
shell-layouts:
  - name: landing
    title: Landing Page
    description: "Full-width, no sidebar"
    chrome:
      navbar: { height: "64px", background: "var(--black)", color: "var(--white)" }
      footer: { height: "32px", background: "var(--gray-50)", color: "var(--gray-500)" }
    zones:
      - { label: "Hero", background: "var(--gray-900)", color: "var(--white)", ratio: 3 }
      - { label: "Content", ratio: 5 }
      - { label: "CTA", background: "var(--gray-50)", ratio: 2 }
```

### style-guide.typography.yaml

Contains both font family metadata and named typography classes.

```yaml
typography:
  - var: font-sans
    name: Space Grotesk
    description: "Primary typeface for headings and body"
    usage: "Headlines, body copy, UI labels"
    weights: [400, 600, 700]

  - var: font-mono
    name: IBM Plex Mono
    description: "Code, data, labels"
    usage: "Code blocks, token names, technical labels"
    weights: [400, 500, 700]

typography-classes:
  - name: Display
    class: typography-display
    font-family: "var(--font-sans)"
    font-size: "var(--font-size-display)"
    font-weight: "700"
    line-height: "1.05"
    letter-spacing: "-0.03em"
    text-transform: uppercase    # optional
    color: "var(--text)"         # optional
    sample: "Preview text"       # optional — shown in the style guide preview
    usage: "Hero headlines"      # optional — usage guidance
```

**typography-classes fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `name` | yes | Display name |
| `class` | yes | CSS class name |
| `font-family` | yes | Font family value or var reference |
| `font-size` | yes | Font size value or var reference |
| `font-weight` | yes | Weight value |
| `line-height` | yes | Line height |
| `letter-spacing` | no | Letter spacing |
| `text-transform` | no | CSS text-transform value |
| `color` | no | Text color override |
| `sample` | no | Preview text for the style guide |
| `usage` | no | Usage guidance note |

### style-guide.color-palette.yaml

```yaml
color-palette:
  - group: Surfaces
    description: "Neutral grays for backgrounds, borders, and text"
    colors:
      - { name: White, value: "#ffffff" }
      - { name: Off-white, value: "#fafafa" }
      # ...
    notes:
      - { swatch: "#e20613", label: "Red", text: "Primary accent — Bauhaus-inspired" }
```

### style-guide.spacing.yaml

```yaml
spacing-contexts:
  grid:
    columns: 12
    gutter-token: col-gap
    margin-token: space-5
  page-container:
    max-width: "1280px"
    padding-x-token: space-5
    padding-y-token: space-4
  section-spacing:
    - { role: "Major section gap", token: space-8 }
    - { role: "Subsection gap", token: space-6 }
    - { role: "Component gap", token: space-3 }
    - { role: "Element gap", token: space-2 }
```

### style-guide.glyphs.yaml

```yaml
glyph-language:
  description: "Unicode glyphs are the primary symbol language..."
  principles:
    - rule: "Function over decoration"
      detail: "Every glyph must serve a navigational or status purpose."
    # ...
  sections:
    - name: ui
      title: UI Glyphs
      description: "Structural and navigational symbols"
    - name: typography
      title: Typographic Glyphs
      description: "Text-level symbols and punctuation"
```

### style-guide.design-sections.yaml

```yaml
design-sections:
  - name: navigation
    title: Navigation
    icon: "→"
    description: "Wayfinding patterns"
    components:
      - name: navbar
        title: Top Navigation Bar
        principle: "Always visible, never competing with content"
        approach: "Fixed header, compact height, keyboard-navigable"
        rationale: "Users need constant orientation..."
```

### style-guide.globals.yaml

Raw CSS string injected after all generated CSS. Used for resets and base element styles. Also contains toast notification configuration.

```yaml
globals: |
  *, *::before, *::after {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }
  body {
    font-family: var(--base-font-family);
    font-size: var(--base-font-size);
    color: var(--base-font-color);
    background: var(--base-background);
    line-height: var(--base-line-height);
  }

toast:
  position: top-right       # top-left | top-right | top-center | bottom-left | bottom-right | bottom-center
  duration: 8000
  gap: 16
  expand: true
  visible-toasts: 4
```

### style-guide.css-snippets.yaml

Verbatim CSS blocks injected into specific style guide sections. Snippets are **accumulated** across all yaml files that define them — they are not replaced by later files. Dependencies are resolved via topological sort before injection.

```yaml
css-snippets-defaults:         # optional file-level defaults applied to all entries
  target-section: cards

css-snippets:
  - slug: card-glow            # REQUIRED — unique identifier
    name: Card Glow Effect     # optional display name
    title: "Glow variant"      # optional
    description: "Adds glow effect to cards"  # optional
    target-section: cards      # which section to inject into (overrides defaults)
    dependencies: [base-card]  # slugs that must come first (topological sort)
    body: |                    # REQUIRED — verbatim CSS
      .card.glow { box-shadow: 0 0 20px ...; }
```

**css-snippets fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `slug` | yes | Unique identifier across all snippet files |
| `body` | yes | Verbatim CSS string |
| `target-section` | no | Section to inject into (can come from defaults) |
| `name` | no | Display name |
| `title` | no | Title text |
| `description` | no | Description text |
| `dependencies` | no | Array of slugs that must be emitted first |

### style-guide.jsx-snippets.yaml

React/JSX component blocks injected into specific style guide sections. Like CSS snippets, these are **accumulated** across files, not replaced. Dependencies are topologically sorted.

```yaml
jsx-snippets-defaults:         # optional file-level defaults
  target-section: demo
  imports: ["import { useState } from 'react';"]

jsx-snippets:
  - slug: counter-demo         # REQUIRED — unique identifier
    name: Counter Demo         # optional display name
    target-section: demo       # which section to inject into
    imports:                   # import statements prepended to output
      - "import { useState } from 'react';"
    dependencies: [demo-imports]  # slugs that must come first
    body: |                    # REQUIRED — verbatim JSX/TSX
      export function CounterDemo() { ... }
```

**jsx-snippets fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `slug` | yes | Unique identifier across all snippet files |
| `body` | yes | Verbatim JSX/TSX string |
| `target-section` | no | Section to inject into (can come from defaults) |
| `name` | no | Display name |
| `imports` | no | Array of import statements (merged with defaults) |
| `dependencies` | no | Array of slugs that must be emitted first |

### style-guide.overrides.yaml

Selects variant files per config section. When a section has an override value, the loader reads `style-guide.{section}.{variant}.yaml` instead of the base `style-guide.{section}.yaml`. A `null` value means "use the base file."

```yaml
overrides:
  color-palette: user    # loads style-guide.color-palette.user.yaml
  vars: null             # null = use base file
```

### css-load / jsx-load (any yaml file)

Any yaml config file can include `css-load` and/or `jsx-load` keys to pull in external CSS or JSX files from the theme directory. These are loaded into the pipeline alongside snippets.

```yaml
css-load:
  - path: "./custom.css"        # relative to theme directory
    target-section: cards        # which section receives the content
    force: false                 # optional — force reload even if cached

jsx-load:
  - path: "./custom.tsx"
    target-section: demo
```

### branding.yaml

Standalone file (not merged with style-guide files). Loaded by `branding-loader.ts`.

```yaml
name: noizu.ink
logo-text: NOIZU.INK
intent: "Cyberpunk design system for digital products"
perception: "Technical precision meets creative edge"
audience: "Developers and designers building modern interfaces"
tone: "Confident, minimal, precise"
keywords:
  - design-system
  - cyberpunk
  - bauhaus
  - monospace
```

## When to use scoped-vars vs color-modes

| Question | color-modes | scoped-vars |
|----------|-------------|-------------|
| What does it scope? | Light/dark token maps only | Any CSS selector |
| Where do vars land? | `:root` and `.dark` | Arbitrary selectors you define |
| Token naming? | Bare names (`surface`, `text`) | Prefixed names (`--{prefix}-{name}`) |
| Per-layout overrides? | No | Yes (e.g., different padding for article vs dashboard) |
| Selector-body injection? | No | Yes (`container-type`, etc.) |
| Complexity | Low | High |

**color-modes** is the simple path. Define `light:` and `dark:` maps of semantic tokens to values. The engine emits them into `:root` and `.dark` automatically. Use this when you just need light/dark switching for standard semantic tokens.

**scoped-vars** is the advanced path. Each entry targets an arbitrary CSS selector and can carry per-section value overrides, custom prefixes, and `selector-body` injection. Use this when you need per-section, per-layout, or per-component token overrides that go beyond light/dark.

**Do they conflict?** They coexist. `color-modes` handles the light/dark toggle; `scoped-vars` handles everything else. If both set the same token, CSS specificity determines the winner — `scoped-vars` selectors are typically more specific than `:root`/`.dark`. Best practice: use `color-modes` for light/dark, `scoped-vars` for layout-specific overrides.
