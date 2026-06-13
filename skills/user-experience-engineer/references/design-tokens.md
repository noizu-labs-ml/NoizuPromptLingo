# Design Tokens

> Canonical token naming convention and cascade model for the design system. Defines categories, naming patterns, semantic vs primitive tokens, and how tokens map to the YAML theme system. This reference is independent of the engine implementation.

---

## Table of Contents

1. [What Tokens Are](#what-tokens-are)
2. [Token Layers](#token-layers)
3. [Naming Convention](#naming-convention)
4. [Token Categories](#token-categories)
   - [Color](#color)
   - [Typography](#typography)
   - [Spacing](#spacing)
   - [Elevation](#elevation)
   - [Motion](#motion)
   - [Border](#border)
   - [Opacity](#opacity)
5. [The Cascade Model](#the-cascade-model)
6. [YAML Theme Mapping](#yaml-theme-mapping)
7. [Token Resolution Order](#token-resolution-order)
8. [Creating New Tokens](#creating-new-tokens)
9. [Anti-Patterns](#anti-patterns)

---

## What Tokens Are

Design tokens are the atomic values of a design system — named constants that represent design decisions. They're the single source of truth for colors, spacing, typography, and every other visual property.

**Tokens are NOT:**
- CSS variables (tokens are abstract; CSS variables are one implementation)
- Colors (color is one category of tokens)
- A theme (tokens compose into themes, but they aren't themes)

**Tokens ARE:**
- Named design decisions (`color-primary` = "we decided our primary color is X")
- Platform-agnostic (same token → CSS variable, iOS constant, Android resource)
- Hierarchical (primitive → semantic → component)

---

## Token Layers

Tokens exist at three abstraction layers. Each layer references the one below it.

```
COMPONENT TOKENS       (most specific)
  "What does this specific UI element look like?"
  Example: --btn-primary-bg, --card-border-radius

        ↓ references ↓

SEMANTIC TOKENS        (intent-based)
  "What does this design decision mean?"
  Example: --color-action, --spacing-section, --text-heading

        ↓ references ↓

PRIMITIVE TOKENS       (raw values)
  "What are the raw palette values?"
  Example: --blue-500, --space-6, --font-size-lg
```

### Why Three Layers

**Primitive tokens** define the design vocabulary — the complete set of available values. Changing a primitive changes every semantic token that references it.

**Semantic tokens** assign meaning. `--color-action` points to `--blue-500` in one theme and `--green-600` in another. Same meaning, different value.

**Component tokens** handle exceptions. When a specific component needs to deviate from the semantic convention, it gets its own token. Component tokens should be rare — if you have more component tokens than semantic tokens, your design system has a problem.

### Layer Distribution (Target)

| Layer | Expected Count | Percentage |
|-------|---------------|------------|
| Primitive | 80-120 | ~40% |
| Semantic | 100-150 | ~50% |
| Component | 20-40 | ~10% |

---

## Naming Convention

### Pattern

```
--{category}-{property}-{variant}-{state}
```

| Segment | Required | Examples |
|---------|----------|---------|
| `category` | Yes | `color`, `space`, `font`, `radius`, `shadow`, `motion`, `opacity` |
| `property` | Yes | `bg`, `text`, `border`, `size`, `weight`, `duration`, `gap` |
| `variant` | Optional | `primary`, `secondary`, `subtle`, `muted`, `inverse`, `surface` |
| `state` | Optional | `hover`, `active`, `disabled`, `focus`, `error` |

### Examples

**Primitive tokens:**
```
--color-blue-50          # lightest blue
--color-blue-500         # mid blue
--color-blue-900         # darkest blue
--space-1                # 4px
--space-4                # 16px
--space-8                # 32px
--font-size-sm           # 14px
--font-size-base         # 16px
--font-size-lg           # 18px
--radius-sm              # 4px
--radius-md              # 8px
```

**Semantic tokens:**
```
--color-bg-primary       # page background
--color-bg-surface       # card/component background
--color-bg-surface-raised # elevated surface
--color-bg-inverse       # inverse background (e.g., dark on light theme)
--color-text-primary     # main text
--color-text-secondary   # subdued text
--color-text-muted       # metadata, hints
--color-text-inverse     # text on inverse background
--color-action           # primary interactive color
--color-action-hover     # primary interactive hover
--color-border-default   # standard border
--color-border-subtle    # barely visible border
--color-status-success   # success state
--color-status-error     # error state
--color-status-warning   # warning state
--color-status-info      # info state
--space-section          # space between major sections
--space-component        # space between components
--space-element          # space between elements within a component
--font-heading           # heading font family
--font-body              # body font family
--font-mono              # monospace font family
```

**Component tokens:**
```
--btn-primary-bg         # primary button background
--btn-primary-text       # primary button text
--btn-radius             # button border radius
--card-bg                # card background
--card-padding           # card internal padding
--card-radius            # card border radius
--input-bg               # input field background
--input-border           # input field border
--input-border-focus     # input border on focus
--nav-bg                 # navigation background
--nav-height             # navigation bar height
```

### Naming Rules

1. **Use kebab-case.** Always. `--color-bg-primary`, not `--colorBgPrimary`.
2. **Category comes first.** This groups tokens logically when listed alphabetically.
3. **Semantic names describe purpose, not value.** `--color-action` not `--color-blue`.
4. **Primitive names describe the value.** `--color-blue-500` IS a description of the value.
5. **States append at the end.** `--color-action-hover`, not `--color-hover-action`.
6. **Keep it readable.** If a token name is longer than 35 characters, simplify it.
7. **No numbers in semantic names.** `--space-section` not `--space-section-1`. Variants use descriptors: `--space-section-tight`, `--space-section-loose`.

---

## Token Categories

### Color

The most complex category. Organized in three sub-groups:

**Primitive palette** (scale-based):
```
--color-{hue}-{shade}

Hues:    gray, blue, green, red, yellow, orange, purple, pink, cyan
Shades:  50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950

Example: --color-gray-100, --color-blue-500, --color-red-700
```

**Semantic colors** (intent-based):
```
Background:
  --color-bg-primary         # page/app background
  --color-bg-secondary       # alternate section background
  --color-bg-surface         # card, component background
  --color-bg-surface-raised  # modal, popover, elevated elements
  --color-bg-inverse         # dark bg on light theme (or vice versa)
  --color-bg-overlay         # backdrop behind modals (with opacity)

Text:
  --color-text-primary       # headings, important text
  --color-text-secondary     # body text
  --color-text-muted         # metadata, captions, hints
  --color-text-inverse       # text on inverse backgrounds
  --color-text-link          # hyperlinks
  --color-text-link-hover    # hyperlink hover state

Interactive:
  --color-action             # primary action color (buttons, links, active states)
  --color-action-hover       # hover state
  --color-action-active      # active/pressed state
  --color-action-subtle      # subtle action background (tag, badge)

Border:
  --color-border-default     # standard component borders
  --color-border-subtle      # nearly invisible borders
  --color-border-strong      # emphasis borders

Status:
  --color-status-success     # success (green)
  --color-status-success-bg  # success background tint
  --color-status-error       # error (red)
  --color-status-error-bg    # error background tint
  --color-status-warning     # warning (yellow/amber)
  --color-status-warning-bg  # warning background tint
  --color-status-info        # info (blue)
  --color-status-info-bg     # info background tint
```

### Typography

```
Font family:
  --font-heading             # heading stack
  --font-body                # body text stack
  --font-mono                # code/monospace stack

Font size (scale):
  --font-size-xs             # 12px
  --font-size-sm             # 14px
  --font-size-base           # 16px
  --font-size-md             # 18px
  --font-size-lg             # 20px
  --font-size-xl             # 24px
  --font-size-2xl            # 30px
  --font-size-3xl            # 36px
  --font-size-4xl            # 48px
  --font-size-5xl            # 60px
  --font-size-display        # 72px+

Font weight:
  --font-weight-light        # 300
  --font-weight-regular      # 400
  --font-weight-medium       # 500
  --font-weight-semibold     # 600
  --font-weight-bold         # 700

Line height:
  --line-height-tight        # 1.15 (headings)
  --line-height-normal       # 1.5 (UI text)
  --line-height-relaxed      # 1.65 (body copy)
  --line-height-loose        # 1.8 (long-form)

Letter spacing:
  --letter-spacing-tight     # -0.02em (display)
  --letter-spacing-normal    # 0em (body)
  --letter-spacing-wide      # 0.02em (captions, uppercase)
  --letter-spacing-wider     # 0.08em (all-caps labels)
```

### Spacing

8px-based scale. Every spacing value is a multiple of 4px.

```
--space-0                    # 0px
--space-px                   # 1px (for borders and hairlines only)
--space-0.5                  # 2px
--space-1                    # 4px
--space-1.5                  # 6px
--space-2                    # 8px
--space-3                    # 12px
--space-4                    # 16px
--space-5                    # 20px
--space-6                    # 24px
--space-8                    # 32px
--space-10                   # 40px
--space-12                   # 48px
--space-16                   # 64px
--space-20                   # 80px
--space-24                   # 96px

Semantic spacing:
--space-element              # within components (--space-2 or --space-3)
--space-component            # between components (--space-4 or --space-6)
--space-section              # between sections (--space-12 or --space-16)
--space-page                 # page margins (--space-6 to --space-20, responsive)
```

### Elevation

Depth/shadow tokens. Light themes use shadows; dark themes use brightness stepping.

```
Light theme:
  --shadow-xs                # 0 1px 2px rgba(0,0,0,0.05)
  --shadow-sm                # 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)
  --shadow-md                # 0 4px 6px rgba(0,0,0,0.1), 0 2px 4px rgba(0,0,0,0.06)
  --shadow-lg                # 0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)
  --shadow-xl                # 0 20px 25px rgba(0,0,0,0.1), 0 10px 10px rgba(0,0,0,0.04)

Dark/Nocturne theme:
  --elevation-base           # canvas brightness (0%)
  --elevation-raised         # +8% brightness
  --elevation-overlay        # +16% brightness + backdrop-blur
  --elevation-glow           # glow stack (see Nocturne style spec)

Semantic:
  --elevation-surface        # card, widget (shadow-sm or elevation-raised)
  --elevation-dropdown       # menus, popovers (shadow-lg or elevation-overlay)
  --elevation-modal          # modals, dialogs (shadow-xl or elevation-overlay)
```

### Motion

```
Duration:
  --duration-instant         # 0ms (no animation)
  --duration-fast            # 100ms (micro-interactions)
  --duration-normal          # 200ms (standard transitions)
  --duration-slow            # 350ms (page transitions, complex animations)
  --duration-deliberate      # 500ms (emphasis animations)

Easing:
  --ease-default             # cubic-bezier(0.25, 0.1, 0.25, 1)
  --ease-in                  # cubic-bezier(0.42, 0, 1, 1)
  --ease-out                 # cubic-bezier(0, 0, 0.58, 1)
  --ease-in-out              # cubic-bezier(0.42, 0, 0.58, 1)
  --ease-spring              # cubic-bezier(0.34, 1.56, 0.64, 1)  (overshoot)

Semantic:
  --motion-hover             # --duration-fast --ease-out
  --motion-enter             # --duration-normal --ease-out
  --motion-exit              # --duration-fast --ease-in
  --motion-page              # --duration-slow --ease-in-out
```

### Border

```
Width:
  --border-width-thin        # 1px
  --border-width-default     # 1px (aliased for clarity)
  --border-width-thick       # 2px
  --border-width-heavy       # 3px

Radius:
  --radius-none              # 0px
  --radius-sm                # 4px
  --radius-md                # 8px
  --radius-lg                # 12px
  --radius-xl                # 16px
  --radius-2xl               # 24px
  --radius-full              # 9999px (pill/circle)

Semantic:
  --radius-button            # --radius-md
  --radius-card              # --radius-lg
  --radius-input             # --radius-md
  --radius-badge             # --radius-full
```

### Opacity

```
--opacity-0                  # 0 (invisible)
--opacity-5                  # 0.05
--opacity-10                 # 0.1
--opacity-20                 # 0.2
--opacity-30                 # 0.3
--opacity-50                 # 0.5
--opacity-70                 # 0.7
--opacity-80                 # 0.8
--opacity-90                 # 0.9
--opacity-100                # 1 (fully opaque)

Semantic:
  --opacity-disabled         # --opacity-50
  --opacity-overlay          # --opacity-70
  --opacity-subtle           # --opacity-10
```

---

## The Cascade Model

The design system uses a 4-pass defaults cascade to generate ~300 CSS custom properties from as few as 12 seed values in YAML.

### How It Works

```
Pass 1: SEED VALUES (from YAML)
  User provides 12-20 core values:
    primary color, font family, base spacing, etc.
    ↓

Pass 2: PRIMITIVE GENERATION
  Engine generates full primitive scales:
    primary color → 11-shade palette (50-950)
    base spacing → 15-step scale
    font size → 12-step scale
    ↓

Pass 3: SEMANTIC MAPPING
  Engine maps primitives to semantic tokens:
    --color-action = --color-primary-500
    --color-bg-primary = --color-gray-50  (light) or --color-gray-950 (dark)
    --space-section = --space-16
    ↓

Pass 4: COMPONENT DEFAULTS
  Engine sets component tokens from semantic tokens:
    --btn-primary-bg = --color-action
    --card-bg = --color-bg-surface
    --card-padding = --space-6
```

### Override at Any Level

The cascade is overridable. YAML theme files can set values at any layer:

- **Override a primitive:** Change `--color-blue-500` and everything referencing it changes
- **Override a semantic:** Change `--color-action` to break the link to the primitive
- **Override a component:** Change `--btn-primary-bg` to break the link to the semantic

**Specificity rule:** More specific overrides win. Component > Semantic > Primitive > Engine default.

---

## YAML Theme Mapping

### How Tokens Map to YAML Files

Each YAML config file in a theme corresponds to a token category:

| YAML File | Token Category | Key Tokens Set |
|-----------|---------------|---------------|
| `meta.yaml` | Theme metadata | Theme name, version, description |
| `vars.yaml` | Seed/primitive values | Primary color, neutral palette, font stacks |
| `branding.yaml` | Brand tokens | Logo, brand colors, brand voice |
| `color-palette.yaml` | Color primitives + semantics | Full palette, semantic color mapping |
| `color-modes.yaml` | Light/dark mode overrides | Per-mode color reassignment |
| `typography.yaml` | Typography tokens | Font sizes, weights, line heights, stacks |
| `spacing.yaml` | Spacing tokens | Base unit, scale, semantic spacing |
| `globals.yaml` | Global semantic tokens | Border radius, shadow, transition defaults |
| `semantic-classes.yaml` | Component tokens | Button, card, input, badge defaults |
| `semantic-groups.yaml` | Composite patterns | Form group, nav group spacing |
| `scoped-vars.yaml` | Context-specific overrides | Per-section token overrides |
| `page-layouts.yaml` | Layout tokens | Grid, max-width, margin, padding |
| `page-sections.yaml` | Section tokens | Hero, feature, CTA section styling |
| `shell-layouts.yaml` | Shell tokens | Header, footer, sidebar dimensions |
| `css-snippets.yaml` | Raw CSS overrides | Escape hatch for custom properties |
| `glyphs.yaml` | Icon/glyph tokens | Icon library, icon sizing |
| `design-sections.yaml` | Styleguide showcase config | Which sections to show in /styleguide |

### Minimum Viable Theme

A theme needs only 3 files to produce a complete design system:

```yaml
# meta.yaml
name: "My Theme"
version: "1.0.0"

# vars.yaml
color-primary: "#3B82F6"
color-neutral: "#6B7280"
font-family-heading: "Inter, sans-serif"
font-family-body: "Inter, sans-serif"

# branding.yaml
name: "My Brand"
tagline: "A brief description"
```

Everything else cascades from defaults. The engine generates all primitives, semantics, and component tokens automatically.

---

## Token Resolution Order

When the engine encounters a token reference, it resolves in this order:

```
1. Component token override (in YAML)     → if defined, use it
2. Semantic token override (in YAML)       → if defined, use it
3. Primitive token override (in YAML)      → if defined, use it
4. Engine-computed semantic (from cascade)  → if generated, use it
5. Engine-computed primitive (from seeds)   → if generated, use it
6. Engine hard-coded default               → last resort
```

**In practice:** Most themes only set seeds (level 5) and maybe a few semantic overrides (level 2). The engine handles everything in between.

---

## Creating New Tokens

### When to Create a New Token

Create a new token when:
- A value is used in 3+ places
- The value represents a design decision (not a one-off)
- You need to theme/vary the value across modes or brands
- A component deviates from semantic defaults and the deviation is intentional

### Where to Place It

| Token Type | Where | Example |
|---|---|---|
| New primitive | `vars.yaml` or `color-palette.yaml` | A new brand color |
| New semantic | `globals.yaml` or `semantic-classes.yaml` | A new intent (e.g., `--color-accent`) |
| New component | `semantic-classes.yaml` | A specific component override |
| New layout | `page-layouts.yaml` | A new layout pattern's dimensions |

### Naming Checklist

Before naming a new token:
- [ ] Does a token for this purpose already exist? (Don't duplicate)
- [ ] Does the name describe purpose (semantic) or value (primitive)?
- [ ] Does it follow the `--{category}-{property}-{variant}-{state}` pattern?
- [ ] Is it less than 35 characters?
- [ ] Would another designer understand what it controls from the name alone?

---

## Anti-Patterns

| Anti-Pattern | Why It's Bad | Do This Instead |
|---|---|---|
| **Using raw values in components** (`color: #3B82F6`) | Unthemeable, maintenance nightmare | Reference a semantic token |
| **Too many component tokens** (50+) | System is too specific, loses flexibility | Push decisions up to semantic layer |
| **Semantic names with values** (`--color-blue-action`) | Breaks when you theme to a green brand | `--color-action` (no color name) |
| **Skipping semantic layer** (primitive → component directly) | Theming requires changing every component | Always use semantic intermediary |
| **One-off tokens** (used in exactly one place) | Token proliferation, no system benefit | Use the semantic token or inline the value |
| **Inconsistent naming** (`--btn-bg` + `--card-background`) | Unpredictable, hard to discover | Pick `bg` or `background` and use it everywhere |
| **Magic numbers** (`--space-7: 28px`) | Breaks the scale | Stick to the defined scale (4px increments) |
| **Overriding tokens in CSS** (not YAML) | Bypasses the cascade, invisible to the engine | Override in YAML theme files |

---

*For style-specific token application, see the style specifications: [minimal-tech.md](styles/minimal-tech.md), [nocturne.md](styles/nocturne.md), etc. For the engine integration guide, see [outputs/engine-styleguide.md](outputs/engine-styleguide.md).*

---

*Version: 0.1.0*
