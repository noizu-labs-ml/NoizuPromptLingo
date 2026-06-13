# YAML Configuration Reference

Authoritative reference for the YAML config schema, snippet system, file-loading mechanism, and the loader's merge behavior. For the generation pipeline that consumes this config, see [generation.md](generation.md). For config loading and override resolution, see [config-pipeline.md](config-pipeline.md).

## Config Files

Each theme has its own directory under `app/src/config/theme-{name}/` containing facet files following the convention `style-guide.{facet}.yaml`. Non-base themes inherit missing facets from the base theme (default: `theme-style-guide`). The loader globs them alphabetically and merges with `Object.assign` — later files override earlier top-level keys, with exceptions noted below.

| File | Top-level key | Schema section |
|------|---------------|----------------|
| `style-guide.meta.yaml` | `name`, `slug`, `title`, `description` | [Meta](#meta) |
| `style-guide.vars.yaml` | `vars` | [Vars](#vars) |
| `style-guide.scoped-vars.yaml` | `scoped-vars` | [Scoped Vars](#scoped-vars) |
| `style-guide.semantic-groups.yaml` | `semantic-groups` | [Semantic Groups](#semantic-groups) |
| `style-guide.semantic-classes.yaml` | `semantic-classes` | [Semantic Classes](#semantic-classes) |
| `style-guide.page-layouts.yaml` | `page-layouts` | [Page Layouts](#page-layouts) |
| `style-guide.shell-layouts.yaml` | `shell-layouts` | [Shell Layouts](#shell-layouts) |
| `style-guide.typography.yaml` | `typography` | [Typography](#typography) |
| `style-guide.color-palette.yaml` | `color-palette` | [Color Palette](#color-palette) |
| `style-guide.color-modes.yaml` | `color-modes` | [Color Modes](#color-modes) |
| `style-guide.spacing.yaml` | `spacing-contexts` | [Spacing](#spacing) |
| `style-guide.glyphs.yaml` | `glyph-language` | [Glyphs](#glyphs) |
| `style-guide.design-sections.yaml` | `design-sections` | [Design Sections](#design-sections) |
| `style-guide.page-sections.yaml` | `page-sections` | [Page Sections](#page-sections) |
| `style-guide.css-snippets.yaml` | `css-snippets` | [CSS Snippets](#css-snippets) |
| `style-guide.jsx-snippets.yaml` | `jsx-snippets` | [JSX Snippets](#jsx-snippets) |
| `style-guide.globals.yaml` | `globals` | [Globals](#globals) |
| `branding.yaml` | (standalone) | [Branding](#branding) |

## Merge Behavior

Most top-level keys use simple `Object.assign` — last file wins. Six keys receive **special array-merge handling** where values from all files are concatenated rather than replaced:

| Mergeable key | Defaults key | Purpose |
|---------------|-------------|---------|
| `css-snippets` | `css-snippets-defaults` | CSS snippet definitions |
| `jsx-snippets` | `jsx-snippets-defaults` | JSX snippet definitions |
| `scoped-vars` | `scoped-vars-defaults` | Scoped CSS custom properties |
| `css-load` | — | External CSS file inclusions |
| `jsx-load` | — | External JSX file inclusions |

This means snippets, scoped-vars, and loads can be **spread across multiple YAML files** and the loader will collect them all. Non-mergeable keys (like `vars`, `semantic-classes`, etc.) must live in a single file — a second file would overwrite the first.

### Defaults

The `*-defaults` keys provide fallback values that are applied to any snippet in that file missing the field:

```yaml
# Any file can declare defaults for its snippets
css-snippets-defaults:
  target-section: cards        # Applied to snippets without a target-section

css-snippets:
  - slug: my-snippet
    body: |                     # target-section defaults to "cards"
      .foo { color: red; }
```

```yaml
jsx-snippets-defaults:
  target-section: demo
  imports: ["react"]           # Reserved — import collation NYI

jsx-snippets:
  - slug: my-component
    body: |                     # target-section defaults to "demo"
      export function Foo() { return <div />; }
```

---

## CSS Snippets

Inline CSS rules defined in YAML and injected into the generated stylesheet. Snippets appear in the cascade **after** all built-in generators (utilities, layout) but **before** `globals`.

**Source:** `lib/css-gen/css-snippets.ts` — `generateCssSnippetsCSS()`

### Schema

```yaml
css-snippets:
  - slug: string              # Required — unique identifier, used for dependency refs
    name: string              # Optional — display name
    title: string             # Optional — short label (appears in CSS comment header)
    description: string       # Optional — longer description (wrapped in CSS comment)
    target-section: string    # Optional — groups snippets in output (default: "ungrouped")
    dependencies: [string]    # Optional — slugs that must appear before this snippet
    body: |                   # Required — raw CSS, emitted verbatim
      .selector { ... }
```

### Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `slug` | yes | string | Unique ID. Referenced by other snippets' `dependencies`. |
| `name` | no | string | Human-readable name, shown in the style guide UI. |
| `title` | no | string | Short label. Used in the generated CSS comment header. |
| `description` | no | string | Longer explanation. Word-wrapped into a CSS block comment. |
| `target-section` | no | string | Groups snippets in the output. Snippets with the same target-section are sorted together. Defaults to `"ungrouped"`. Can be inherited from `css-snippets-defaults`. |
| `dependencies` | no | string[] | List of slugs. The topological sort ensures all dependencies emit before this snippet. |
| `body` | yes | string | Raw CSS. Use YAML block scalar (`\|`) for multi-line. Emitted verbatim — no processing, no prefixing. You can reference any `var(--*)` defined by earlier generators. |

### Example

```yaml
css-snippets:
  - slug: card-glow
    name: Card Glow Effect
    title: "Glow variant"
    description: "Adds a colored glow shadow to cards. Apply with .card.glow alongside a semantic class."
    target-section: cards
    body: |
      .card.glow {
        box-shadow: 0 0 20px color-mix(in srgb, var(--brand-blue) 40%, transparent);
        transition: box-shadow var(--transition-slow) ease;
      }
      .card.glow:hover {
        box-shadow: 0 0 32px color-mix(in srgb, var(--brand-blue) 60%, transparent);
      }
```

### Generated Output

Each target-section group gets a comment header, then snippets in topological order, each with its own doc comment:

```css
/* ── cards ── */
/**
 * cards: Glow variant
 *
 * Adds a colored glow shadow to cards. Apply with .card.glow alongside
 * a semantic class.
 */
.card.glow {
  box-shadow: 0 0 20px color-mix(in srgb, var(--brand-blue) 40%, transparent);
  ...
}
```

### Cascade Position

CSS snippets are the **19th of 21** generators in the pipeline:

```
vars → scoped-vars → branding → sections → tokens → swatches →
spacing → cards → buttons → semantic → typography → indicators →
forms → dividers → shells → hui → utilities → layout →
css-snippets → code-terminal → globals
```

This means snippets can override any built-in rule (cards, buttons, etc.) since they appear later. Only `code-terminal` and `globals` follow.

---

## JSX Snippets

React component code defined in YAML and assembled into generated `.tsx` files.

**Source:** `lib/jsx-gen/index.ts` — `generateJsxFiles()`
**Output:** `components/generated/{target-section}.tsx`

### Schema

```yaml
jsx-snippets:
  - slug: string              # Required — unique identifier, used for dependency refs
    name: string              # Optional — display name
    title: string             # Optional — short label
    description: string       # Optional — longer description
    target-section: string    # Required — determines output filename
    imports: [string]         # Optional — reserved for future import collation (NYI)
    dependencies: [string]    # Optional — slugs that must appear before this snippet
    body: |                   # Required — raw TSX code, emitted verbatim
      export function Foo() { ... }
```

### Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `slug` | yes | string | Unique ID. Referenced by other snippets' `dependencies`. |
| `name` | no | string | Human-readable name. |
| `title` | no | string | Short label. Used in the generated comment header. |
| `description` | no | string | Longer explanation. Emitted as `//` comment lines. |
| `target-section` | yes | string | **Determines the output file.** All snippets with `target-section: demo` are assembled into `components/generated/demo.tsx`. Can be inherited from `jsx-snippets-defaults`. |
| `imports` | no | string[] | Reserved. Import collation is not yet implemented. Use a manual import snippet with `dependencies` instead (see pattern below). |
| `dependencies` | no | string[] | List of slugs. Ensures dependency snippets appear first in the file. |
| `body` | yes | string | Raw TSX code. Use YAML block scalar (`\|`). Emitted verbatim. |

### Import Pattern (Current Workaround)

Since `imports` collation is NYI, use a dedicated import snippet as a dependency:

```yaml
jsx-snippets:
  - slug: demo-imports
    name: Demo Imports
    title: "Shared imports"
    target-section: demo
    body: |
      import { useState } from "react";

  - slug: counter-demo
    name: Counter Demo
    target-section: demo
    dependencies: [demo-imports]      # Ensures imports appear first
    body: |
      export function CounterDemo() {
        const [count, setCount] = useState(0);
        return (
          <button className="btn btn-sm" onClick={() => setCount((c) => c + 1)}>
            Count: {count}
          </button>
        );
      }
```

### Generated Output

Each target-section produces one file at `components/generated/{section}.tsx`:

```tsx
// Auto-generated from YAML jsx-snippets — do not edit manually
"use client";

// @demo-imports
// Demo Imports: Shared imports
import { useState } from "react";

// @counter-demo
// Counter Demo: Simple counter
// A basic counter component to verify JSX snippet generation works.
// depends: demo-imports
export function CounterDemo() {
  const [count, setCount] = useState(0);
  return (
    <button className="btn btn-sm" onClick={() => setCount((c) => c + 1)}>
      Count: {count}
    </button>
  );
}
```

Files are **only written when content changes** to avoid unnecessary HMR/rebuilds.

---

## File Loaders (css-load / jsx-load)

For larger blocks of CSS or JSX that are unwieldy in YAML, you can point to external files.

### CSS Load

```yaml
css-load:
  - path: "custom/animations.css"    # Relative to theme-style-guide/
    target-section: animations        # Section label in output
    force: false                      # Optional — required to target built-in sections
```

### JSX Load

```yaml
jsx-load:
  - path: "custom/chart-widget.tsx"  # Relative to theme-style-guide/
    target-section: widgets           # Determines output filename
```

### Built-in Section Conflict Detection

CSS loads that target a built-in section name are **rejected by default**. Set `force: true` to override:

```
vars, scoped-vars, branding, sections, tokens, swatches, spacing,
cards, buttons, semantic, typography, indicators, forms, dividers,
shells, hui, utilities, layout, globals
```

JSX loads do not have this restriction — they merge into any target-section.

---

## Topological Sort

Both CSS and JSX snippet generators use `lib/topo-sort.ts` to order snippets within each target-section group.

**Algorithm:** Depth-first traversal with cycle detection.

| Behavior | Detail |
|----------|--------|
| No dependencies | Emitted first, in original YAML order |
| With dependencies | Emitted after all named dependencies |
| Missing dependency slug | Silently ignored (the dependency simply doesn't exist to visit) |
| Circular dependency | Warning logged, cycle-involved snippets appended in original order |

The sort is **per target-section** — dependencies across different target-sections have no effect (they live in separate output files/sections).

---

## Snippet Rendering in the Style Guide

`components/SnippetShowcase.tsx` renders snippets in the interactive style guide:

| Snippet type | Rendering |
|-------------|-----------|
| CSS snippets | Live preview (CSS injected, sample element rendered) + syntax-highlighted source |
| JSX snippets | Dynamic import of generated component + source view |

CSS snippets are auto-detected as card variants if the body matches `.card.*` selectors and rendered with a card preview. JSX snippets that export a named function are rendered live; import-only snippets are shown as code.

Both types support search filtering via `data-search-*` attributes on their name, title, and description.

---

## Other Facet Schemas (Summary)

These facets are documented in detail in `app/docs/yaml-config.md`. Brief reference here for completeness.

### Meta

```yaml
name: style-guide          # Internal identifier
slug: style-guide           # Used in data-design-theme attribute
title: Style Guide          # Display title
description: "..."          # Subtitle
```

### Vars

CSS custom properties in named groups. Each var becomes `--{name}: {value};` in `:root`.

```yaml
vars:
  groups:
    - name: Surfaces
      vars:
        white: "#ffffff"
        gray-50: "#f5f5f5"
```

Values can reference other vars: `"var(--space-3)"` — the browser resolves the chain at runtime.

### Scoped Vars

Selector-scoped CSS custom properties with support for sectioned values (light/dark, standard/compact) and custom `selector-body` rules.

```yaml
scoped-vars:
  prefix: "theme"
  sections:
    standard:
      selector: "html[data-design-theme]"
    dark:
      selector: "html[data-design-theme].dark"
  vars:
    - name: content-position
      value:
        - section: standard
          value: "relative"
        - section: dark
          value: "relative"
      selector: ".content"
      selector-body: "position: var(--content-position)"
```

Uses array-merge like snippets — can be spread across multiple files.

### Semantic Classes

Contextual modifier classes with accent styles and scoped vars.

```yaml
semantic-classes:
  - name: danger
    class: danger
    group: States
    accent-style: bottom-bar    # bottom-bar | left-border | outer-shadow | inner-glow | ...
    vars:
      accent: "#c41a1a"
      background: "rgba(196, 26, 26, 0.06)"
```

### Page Layouts

```yaml
page-layouts:
  - name: standard
    selector: ".layout-standard"
    vars:
      max-width: "1280px"
    chrome:
      navbar: { height: "56px", background: "var(--black)" }
```

### Shell Layouts

```yaml
shell-layouts:
  - name: landing
    chrome:
      navbar: { height: "64px" }
      footer: { height: "32px" }
    zones:
      - { label: "Hero", background: "var(--gray-900)", ratio: 3 }
```

### Typography

```yaml
typography:
  - var: font-sans
    name: Space Grotesk
    weights: [400, 600, 700]
```

### Color Palette

```yaml
color-palette:
  - group: Surfaces
    colors:
      - { name: White, value: "#ffffff" }
    notes:
      - { swatch: "#e20613", label: "Red", text: "Primary accent" }
```

### Spacing

```yaml
spacing-contexts:
  grid: { columns: 12, gutter-token: col-gap }
  page-container: { max-width: "1280px", padding-x-token: space-5 }
  section-spacing:
    - { role: "Major section gap", token: space-8 }
```

### Globals

Raw CSS string injected **last** in the cascade. Used for resets and base element styles.

```yaml
globals: |
  *, *::before, *::after { box-sizing: border-box; }
```

### Branding

Standalone file (not merged). Loaded separately by `branding-loader.ts`.

```yaml
name: noizu.ink
logo-text: NOIZU.INK
intent: "Cyberpunk design system for digital products"
tone: "Confident, minimal, precise"
```
