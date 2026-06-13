# Variable Cascade

The engine uses a 4-pass builder to resolve CSS custom properties. A skill sets ~12 seed values; `resolveDefaults()` computes everything else.

## Architecture

```
resolveDefaults(yamlVars) {
  Pass 1: base = buildBaseTokens(yamlVars)      // seeds → computed tokens
  Pass 2: { ...base, ...LEVEL_2 }               // layer foundations
  Pass 3: { ...withFoundations, ...LEVEL_3 }     // layer component properties
  Pass 4: { ...withComponents, ...yamlVars }     // YAML overrides win
}
```

Resolution happens at config-load time in TypeScript — not CSS fallback chains. The browser sees single-level `var()` references, easy to trace in DevTools.

## Pass 1: Base token builder

`buildBaseTokens()` reads seed values from the YAML and computes derived tokens.

### Spacing scale from `unit`

| Seed | Default | Computed tokens |
|------|---------|----------------|
| `unit` | `8px` | `space-half`, `space-quarter`, `space-1` through `space-160`, `col-gap`, mid-point spacings |

The full multiplier set: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 16, 18, 20, 25, 30, 32, 35, 37, 48, 52, 60, 64, 80, 90, 96, 108, 112, 128, 144, 150, 160.

Mid-points: `space-0-mid` (unit/2), `space-quarter` (unit/4), `space-1-mid` (unit*1.5), `space-2-mid`, `space-4-mid`, `space-5-mid`, `space-7-mid`, `space-32-mid`, `space-37-mid`, `space-52-mid`.

```
unit: 10px
  → space-half: 5px
  → space-quarter: 2.5px
  → space-1: 10px
  → space-2: 20px
  → space-3: 30px
  → ...
  → space-16: 160px
  → col-gap: 20px
```

Change `unit` to `10px` and the entire spacing system rescales.

### Border size tokens (absolute)

Not derived from `unit`. Always:

```
size-border-thin: 1px
size-border-medium: 1.5px
size-border-thick: 2px
size-border-heavy: 3px
size-border-extra-heavy: 4px
size-border-accent: 5px
```

### Component size tokens from `unit`

```
size-lg: unit * 2.5
size-md-sm: unit * 1.75
size-2xs: unit * 1.25
size-space-1-mid: unit * 1.5
size-space-2: unit * 2
size-space-2-qtr: unit * 2.25
```

### Font size scale from `font-size-base`

| Seed | Default | Computed tokens |
|------|---------|----------------|
| `font-size-base` | `16px` | `font-size-xs` through `font-size-display` via ratio multipliers |

Ratios relative to base:

| Token | Ratio | At 16px base |
|-------|-------|-------------|
| `font-size-xs` | 0.6875 | 11px |
| `font-size-sm` | 0.8125 | 13px |
| `font-size-md` | 1.0 | 16px |
| `font-size-lg` | 1.25 | 20px |
| `font-size-xl` | 1.5 | 24px |
| `font-size-2xl` | 2.0 | 32px |
| `font-size-3xl` | 2.5 | 40px |
| `font-size-display` | 3.5 | 56px |

Also computes `size-xs`, `size-sm`, `size-md`, `size-xl` from the same ratios for non-typographic use.

### Font stacks

| Seed | Default |
|------|---------|
| `font-sans` | `'Space Grotesk', -apple-system, sans-serif` |
| `font-mono` | `'IBM Plex Mono', 'Menlo', monospace` |

### Gray ramp from `white` / `black`

Interpolates between `white` and `black` to produce `off-white` and `gray-50` through `gray-900`:

| Token | Interpolation | Default |
|-------|---------------|---------|
| `off-white` | 2% toward black | #fafafa |
| `gray-50` | 4% | #f5f5f5 |
| `gray-100` | 7% | #eeeeee |
| `gray-200` | 12% | #e0e0e0 |
| `gray-300` | 26% | #bdbdbd |
| `gray-400` | 38% | #9e9e9e |
| `gray-500` | 54% | #757575 |
| `gray-600` | 62% | #616161 |
| `gray-700` | 74% | #424242 |
| `gray-800` | 87% | #212121 |
| `gray-900` | 93% | #121212 |

Set `white: "#1a1a2e"` and `black: "#e8e8f0"` for a dark theme — the entire gray ramp inverts automatically.

### Slate ramp

Hardcoded Tailwind slate values as defaults (`slate-50` through `slate-950`). Each is individually overridable via seed. Not interpolated — uses fixed hex values unless the YAML provides replacements.

### Primary color variants

Each primary generates `color-mix()` variants against `var(--surface)`:

| Primary | Light % | Mid % |
|---------|---------|-------|
| `brand-red` (seed: `brand-red` or `red`) | 12% | 20% |
| `brand-blue` (seed: `brand-blue` or `blue`) | 12% | 20% |
| `brand-yellow` (seed: `brand-yellow` or `yellow`) | 18% | 35% |

```
brand-red: "#e20613"
  → brand-red-light: color-mix(in srgb, #e20613 12%, var(--surface))
  → brand-red-mid: color-mix(in srgb, #e20613 20%, var(--surface))
```

### Semantic color tints

Each semantic color generates a `-tint` variant at 12% mix with surface:

```
success: "#1a8a3f"  → success-tint: color-mix(in srgb, #1a8a3f 12%, var(--surface))
warning: "#c27a00"  → warning-tint: color-mix(in srgb, #c27a00 12%, var(--surface))
error:   "#c41a1a"  → error-tint: color-mix(in srgb, #c41a1a 12%, var(--surface))
info:    "#0047ab"  → info-tint: color-mix(in srgb, #0047ab 12%, var(--surface))
```

### Base aliases

Always computed (reference other tokens via `var()`):

```
base-font-family: var(--font-sans)
base-font-color: var(--text)
base-background: var(--surface)
base-line-height: var(--line-height-base)
base-font-size: var(--font-size-base)
```

## Pass 2: Component foundations (LEVEL_2)

Static map of ~80 shared patterns that reference Pass 1 tokens via `var()`. Changes to Pass 1 cascade automatically at runtime.

### Micro label
`micro-label-font-family` (font-mono), `micro-label-font-size` (font-size-xs), `micro-label-font-weight` (font-weight-bold), `micro-label-letter-spacing` (letter-spacing-wider), `micro-label-text-transform` (uppercase), `micro-label-color` (gray-500).

### Typography
Font weights: `font-weight-normal` (400), `font-weight-medium` (500), `font-weight-semibold` (600), `font-weight-bold` (700). Line heights: `line-height-tight` (1.3), `line-height-normal` (1.5), `line-height-relaxed` (1.6), `line-height-heading` (1.2), `line-height-compact` (1). Letter spacing: `letter-spacing-tight` (-0.02em), `letter-spacing-snug` (-0.01em), `letter-spacing-wide` (0.05em), `letter-spacing-wider` (0.08em), `letter-spacing-label` (0.06em), `letter-spacing-widest` (0.1em). Extra small font: `font-size-2xs` (10px).

### Transitions
`transition-fast` (0.1s), `transition-base` (0.15s), `transition-medium` (0.22s), `transition-slow` (0.3s).

### Borders & radius
`border-thin` (size-border-thin), `border-thick` (size-border-thick), `border-heavy` (size-border-heavy), `border-control` (size-border-medium), `border-accent` (size-border-accent), `accent-width` (space-1). Radius: `radius-none` (0%), `radius-sm` (5%), `radius-md` (space-1-mid), `radius-lg` (25%), `radius-xl`/`radius-circle` (50%).

### Shadows & elevation
`shadow-sm`, `shadow-inset`, `shadow-elevation`, `shadow-overlay`, `shadow-toast`, `shadow-control`, `shadow-thumb`, `shadow-panel`, `shadow-dialog`, `shadow-floating`. Overlays: `overlay-highlight`, `overlay-shadow`, `overlay-backdrop`.

### Z-indices
`z-chrome` (300), `z-panel` (200), `z-overlay` (100), `z-dialog` (101), `z-floating` (90), `z-dropdown` (50).

### Opacity scale
`opacity-muted` (0.45), `opacity-subtle` (0.55), `opacity-soft` (0.75), `opacity-disabled` (0.4), `opacity-faint` (0.3).

### Small component sizes
`size-dot` (6px), `size-icon-sm` (18px), `size-action` (28px).

### Semantic layout aliases
`control-height` (space-5), `navbar-height` (space-7), `dropdown-max-height` (space-25), `popover-min-width` (space-25), `sidebar-width` (space-30), `url-bar-max-width` (space-30), `aside-width` (space-32-mid), `card-min-width` (space-35), `dialog-width` (space-52-mid), `prose-max-width` (space-60).

### Dividers
`hr-height` (border-thin), `hr-thick` (border-thick), `hr-heavy` (border-heavy), `on-semantic-color` (var(--white)).

## Pass 3: Component properties (LEVEL_3)

~500 component-specific vars that reference Pass 1/2 via `var()`. Organized by system:

| System | Prefix | Approx count | Example |
|--------|--------|-------------|---------|
| Cards | `card-*`, `table-*` | ~45 | `card-padding: var(--space-3)` |
| Tokens | `token-*` | ~27 | `token-card-padding: var(--space-3)` |
| Buttons | `btn-*` | ~22 | `btn-padding-y: var(--space-1)` |
| Toggle | `toggle-*`, `collapse-*` | ~7 | `toggle-icon-size: var(--font-size-2xs)` |
| Indicators | `badge-*`, `alert-*`, `toast-*`, `progress-*`, `status-dot-*`, `tag-*` | ~35 | `badge-radius: var(--radius-md)` |
| Forms | `field-*`, `control-*`, `switch-*`, `radio-*`, `fieldset-*` | ~40 | `field-height: var(--hui-field-height)` |
| Shells | `shell-*`, `screen-*` | ~55 | `shell-navbar-height: var(--navbar-height)` |
| Sections | `sg-*` | ~30 | `sg-description-max-width: var(--prose-max-width)` |
| Branding | `branding-*` | ~25 | `branding-name-font-size: var(--space-2-mid)` |
| Dividers | `hr-*` | 2 | `hr-overline-length: var(--space-6)` |
| HUI: Focus | `hui-focus-*` | 2 | `hui-focus-ring-width: var(--border-heavy)` |
| HUI: Controls | `hui-control-*`, `hui-switch-*`, `hui-radio-*`, `hui-checkbox-*` | ~30 | `hui-switch-track-on-bg: var(--brand-blue)` |
| HUI: Triggers | `hui-trigger-*` | ~10 | `hui-trigger-font-size: var(--font-size-sm)` |
| HUI: Panels | `hui-panel-*`, `hui-popover-*`, `hui-menu-*`, `hui-combo-*` | ~25 | `hui-panel-shadow: var(--shadow-panel)` |
| HUI: Tabs | `hui-tab-*` | ~15 | `hui-tab-indicator-width: var(--border-thick)` |
| HUI: Disclosure | `hui-disclosure-*` | ~15 | `hui-disclosure-font-size: var(--font-size-sm)` |
| HUI: Fields | `hui-field-*`, `hui-label-*`, `hui-description-*`, `hui-textarea-*` | ~20 | `hui-field-height: var(--control-height)` |
| HUI: Dialog | `hui-dialog-*` | ~12 | `hui-dialog-max-width: var(--dialog-width)` |
| HUI: Showcase | `hui-showcase-*` | ~15 | `hui-showcase-accent: var(--brand-red)` |
| Code | `code-*` | ~10 | `code-bg: var(--gray-900)` |
| Terminal | `terminal-*` | ~10 | `terminal-bg: var(--gray-900)` |

## Pass 4: YAML overrides

Any var explicitly defined in the YAML always wins — it overwrites computed, foundation, and component defaults. This means you can:

1. Set `unit: "10px"` → computed spacing rescales → all `var(--space-*)` references update
2. But also set `space-3: "20px"` → overrides just that one step in the computed scale
3. Or set `card-padding: "20px"` → overrides the component default without touching the spacing scale

## Override precedence

```
buildBaseTokens(seeds)     ← lowest priority (computed from ~12 seeds)
  ↓ overridden by
LEVEL_2 (foundations)      ← static var() refs
  ↓ overridden by
LEVEL_3 (component props)  ← static var() refs
  ↓ overridden by
YAML vars                  ← highest priority (author's explicit choices)
```

## What seeds control what

Practical reference for theme authors. Each seed value cascades into the systems listed.

### `unit` (default: `8px`)
- All `space-*` tokens (spacing scale)
- `col-gap` (unit * 2)
- `size-lg`, `size-md-sm`, `size-2xs`, `size-space-*` (component sizes)
- Via `var()` chains: card padding, button padding, shell heights, field heights, panel spacing, grid gaps, diagram dimensions — essentially every spatial measurement in every component.

### `font-size-base` (default: `16px`)
- All `font-size-*` tokens (type scale)
- `size-xs`, `size-sm`, `size-md`, `size-xl` (non-typographic size tokens)
- Via `var()` chains: card titles, button labels, field text, badge text, micro-label sizes, shell nav text, branding text.

### `white` and `black` (defaults: `#ffffff`, `#000000`)
- `off-white`, `gray-50` through `gray-900` (full gray ramp via interpolation)
- Via `var()` chains: text colors (`gray-400`/`gray-500`/`gray-600`/`gray-700` used extensively), micro-label color, toggle/tab/chevron colors, combo placeholder colors, card tag colors.

### `font-sans` and `font-mono`
- `base-font-family` (via var)
- `font-mono` → micro-label system → field labels, section headings, badges, tags, token cards, branding keywords, table headers.
- `font-sans` → button text, shell nav text, all body text.

### `brand-red`, `brand-blue`, `brand-yellow` (or bare `red`, `blue`, `yellow`)
- `brand-*-light` and `brand-*-mid` variants (color-mix with surface)
- `brand-red` → card accent color, showcase accent, code number color.
- `brand-blue` → control checked color, focus ring, hui switch on-bg, field focus border, tab selected border, radio option active, code keyword.
- `brand-yellow` → (available for theme use, no default component bindings).

### `success`, `warning`, `error`, `info`
- `*-tint` variants (12% mix with surface)
- Toast backgrounds and text colors per variant.
- Progress, alert, and status-dot systems reference these.

### `radius` (default: `2px`)
- Base border-radius for most components.
- Navbar links, shell actions, screen frames, tags, spacing bars, branding logo, sg section numbers.
- Note: `radius-md` through `radius-circle` are separate foundation tokens in LEVEL_2.

### `line-height-base` (default: `1.5`)
- `base-line-height` alias.
- Not used to derive other line heights — `line-height-tight`, `line-height-normal`, etc. are independent LEVEL_2 values.

## Dark / Light Mode

The semantic color layer sits on top of the cascade. Absolute tokens (`--white`, `--black`, `--gray-*`, `--slate-*`) stay constant in both modes. Semantic tokens flip based on the `.dark` class on `<html>`:

### Semantic tokens

| Token | Light | Dark | Purpose |
|-------|-------|------|---------|
| `--surface` | `var(--white)` | `var(--slate-900)` | Page/card/panel backgrounds |
| `--surface-alt` | `var(--slate-50)` | `var(--slate-800)` | Inset areas, headers, hover states |
| `--surface-inverse` | `var(--slate-900)` | `var(--slate-200)` | Inverted containers (navbar, toast) |
| `--text` | `var(--black)` | `var(--slate-100)` | Primary text, strong borders |
| `--text-secondary` | `var(--gray-600)` | `var(--slate-300)` | Body text, descriptions |
| `--text-muted` | `var(--gray-400)` | `var(--slate-400)` | Placeholders, disabled |
| `--text-inverse` | `var(--white)` | `var(--slate-900)` | Text on inverse surfaces |
| `--border` | `var(--slate-200)` | `var(--slate-700)` | Default borders |
| `--border-strong` | `var(--slate-300)` | `var(--slate-600)` | Emphasized borders |
| `--shadow-color` | `rgba(0,0,0,0.1)` | `rgba(0,0,0,0.4)` | Box shadows |

### How it works

Defined in `style-guide.color-modes.yaml`. The CSS generator (`vars.ts`) emits two blocks:

```css
html[data-design-theme="style-guide"] {
  --surface: var(--white);
  --text: var(--black);
  /* ... light defaults ... */
}
html[data-design-theme="style-guide"].dark {
  --surface: var(--slate-900);
  --text: var(--slate-100);
  /* ... dark overrides ... */
}
```

Component defaults reference semantic tokens (`--card-background: var(--surface)`) so they flip automatically. Primary color variants use `color-mix(... var(--surface))` so tints adapt to the current surface color in both modes.

### Slate vs Gray

- **Gray** (`--gray-50` through `--gray-900`): Pure neutral grays, interpolated from `--white`/`--black`. Used for text colors and intentionally neutral elements.
- **Slate** (`--slate-50` through `--slate-950`): Blue-tinted neutrals, hardcoded Tailwind defaults. Used for surfaces and backgrounds — gives dark mode depth and warmth.
