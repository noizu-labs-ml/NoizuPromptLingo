# Token Reference

Complete listing of CSS custom properties produced by `resolveDefaults()` in `src/lib/css-gen/defaults.ts`. Open this when you want to know "what token controls X and how do I override it."

Override any token in your theme YAML:

```yaml
vars:
  unit: "10px"            # rescales all spacing
  card-padding: "20px"    # overrides just one component token
```

YAML overrides always win (Pass 4). See [cascade.md](cascade.md) for precedence rules.

---

## Seeds

The ~12 input tokens a theme author sets. Everything else derives from these.

| Seed | Default | Controls |
|------|---------|----------|
| `unit` | `8px` | All `space-*` tokens, `col-gap`, component size tokens, and via `var()` chains: every spatial measurement in the system |
| `font-size-base` | `16px` | All `font-size-*` tokens, `size-xs`/`size-sm`/`size-md`/`size-xl` |
| `white` | `#ffffff` | Light end of gray ramp interpolation |
| `black` | `#000000` | Dark end of gray ramp interpolation |
| `font-sans` | `'Space Grotesk', -apple-system, sans-serif` | Primary font stack, body text, buttons |
| `font-mono` | `'IBM Plex Mono', 'Menlo', monospace` | Code font, micro-label system |
| `radius` | `2px` | Default border-radius for most components |
| `line-height-base` | `1.5` | Base line height alias |
| `brand-red` (or `red`) | `#e20613` | Card accent, showcase accent, code numbers |
| `brand-blue` (or `blue`) | `#0047ab` | Focus rings, checked controls, field focus, tab selected |
| `brand-yellow` (or `yellow`) | `#f5c518` | Available for theme use (no default component bindings) |
| `success` | `#1a8a3f` | Success alerts, toasts, progress, terminal prompt |
| `warning` | `#c27a00` | Warning alerts, toasts |
| `error` | `#c41a1a` | Error alerts, toasts, terminal errors |
| `info` | `#0047ab` | Info alerts, toasts |

---

## Pass 1: Base Tokens

Computed from seeds at config-load time. The browser sees flat values, not `calc()` chains.

### Spacing scale from `unit`

Formula: `unit * N` for each multiplier.

| Token | Multiplier | At `8px` unit | At `10px` unit |
|-------|-----------|--------------|----------------|
| `space-half` | 0.5 | `4px` | `5px` |
| `space-quarter` | 0.25 | `2px` | `2.5px` |
| `space-1` | 1 | `8px` | `10px` |
| `space-2` | 2 | `16px` | `20px` |
| `space-3` | 3 | `24px` | `30px` |
| `space-4` | 4 | `32px` | `40px` |
| `space-5` | 5 | `40px` | `50px` |
| `space-6` | 6 | `48px` | `60px` |
| `space-7` | 7 | `56px` | `70px` |
| `space-8` | 8 | `64px` | `80px` |
| `space-9` | 9 | `72px` | `90px` |
| `space-10` | 10 | `80px` | `100px` |
| `space-11` | 11 | `88px` | `110px` |
| `space-12` | 12 | `96px` | `120px` |
| `space-15` | 15 | `120px` | `150px` |
| `space-16` | 16 | `128px` | `160px` |
| `space-18` | 18 | `144px` | `180px` |
| `space-20` | 20 | `160px` | `200px` |
| `space-25` | 25 | `200px` | `250px` |
| `space-30` | 30 | `240px` | `300px` |
| `space-32` | 32 | `256px` | `320px` |
| `space-35` | 35 | `280px` | `350px` |
| `space-37` | 37 | `296px` | `370px` |
| `space-48` | 48 | `384px` | `480px` |
| `space-52` | 52 | `416px` | `520px` |
| `space-60` | 60 | `480px` | `600px` |
| `space-64` | 64 | `512px` | `640px` |
| `space-80` | 80 | `640px` | `800px` |
| `space-90` | 90 | `720px` | `900px` |
| `space-96` | 96 | `768px` | `960px` |
| `space-108` | 108 | `864px` | `1080px` |
| `space-112` | 112 | `896px` | `1120px` |
| `space-128` | 128 | `1024px` | `1280px` |
| `space-144` | 144 | `1152px` | `1440px` |
| `space-150` | 150 | `1200px` | `1500px` |
| `space-160` | 160 | `1280px` | `1600px` |
| `col-gap` | 2 | `16px` | `20px` |

#### Mid-point spacings

| Token | Formula | At `8px` unit |
|-------|---------|--------------|
| `space-0-mid` | `unit / 2` | `4px` |
| `space-1-mid` | `unit * 1.5` | `12px` |
| `space-2-mid` | `unit * 2.5` | `20px` |
| `space-4-mid` | `unit * 4.5` | `36px` |
| `space-5-mid` | `unit * 5.5` | `44px` |
| `space-7-mid` | `unit * 7.5` | `60px` |
| `space-32-mid` | `unit * 32.5` | `260px` |
| `space-37-mid` | `unit * 37.5` | `300px` |
| `space-52-mid` | `unit * 52.5` | `420px` |

### Border size tokens (absolute)

Not derived from `unit`. Fixed values unless overridden.

| Token | Value |
|-------|-------|
| `size-border-thin` | `1px` |
| `size-border-medium` | `1.5px` |
| `size-border-thick` | `2px` |
| `size-border-heavy` | `3px` |
| `size-border-extra-heavy` | `4px` |
| `size-border-accent` | `5px` |

### Component size tokens from `unit`

| Token | Formula | At `8px` unit |
|-------|---------|--------------|
| `size-lg` | `unit * 2.5` | `20px` |
| `size-md-sm` | `unit * 1.75` | `14px` |
| `size-2xs` | `unit * 1.25` | `10px` |
| `size-space-1-mid` | `unit * 1.5` | `12px` |
| `size-space-2` | `unit * 2` | `16px` |
| `size-space-2-qtr` | `unit * 2.25` | `18px` |

### Font size scale from `font-size-base`

Formula: `font-size-base * ratio`.

| Token | Ratio | At `16px` base |
|-------|-------|---------------|
| `font-size-xs` | 0.6875 | `11px` |
| `font-size-sm` | 0.8125 | `13px` |
| `font-size-md` | 1.0 | `16px` |
| `font-size-lg` | 1.25 | `20px` |
| `font-size-xl` | 1.5 | `24px` |
| `font-size-2xl` | 2.0 | `32px` |
| `font-size-3xl` | 2.5 | `40px` |
| `font-size-display` | 3.5 | `56px` |

Font-derived size tokens (for non-typographic use):

| Token | Ratio | At `16px` base |
|-------|-------|---------------|
| `size-xs` | 0.6875 | `11px` |
| `size-sm` | 0.8125 | `13px` |
| `size-md` | 1.0 | `16px` |
| `size-xl` | 1.5 | `24px` |

### Gray ramp from `white` / `black`

Interpolated between `white` and `black`. Set `white: "#1a1a2e"` and `black: "#e8e8f0"` for a dark theme — the ramp inverts automatically.

| Token | Interpolation % | Default (white=#fff, black=#000) |
|-------|----------------|----------------------------------|
| `off-white` | 2% | `#fafafa` |
| `gray-50` | 4% | `#f5f5f5` |
| `gray-100` | 7% | `#eeeeee` |
| `gray-200` | 12% | `#e0e0e0` |
| `gray-300` | 26% | `#bdbdbd` |
| `gray-400` | 38% | `#9e9e9e` |
| `gray-500` | 54% | `#757575` |
| `gray-600` | 62% | `#616161` |
| `gray-700` | 74% | `#424242` |
| `gray-800` | 87% | `#212121` |
| `gray-900` | 93% | `#121212` |

### Slate ramp

Hardcoded Tailwind slate values. Not interpolated — individually overridable.

| Token | Default |
|-------|---------|
| `slate-50` | `#f8fafc` |
| `slate-100` | `#f1f5f9` |
| `slate-200` | `#e2e8f0` |
| `slate-300` | `#cbd5e1` |
| `slate-400` | `#94a3b8` |
| `slate-500` | `#64748b` |
| `slate-600` | `#475569` |
| `slate-700` | `#334155` |
| `slate-800` | `#1e293b` |
| `slate-900` | `#0f172a` |
| `slate-950` | `#020617` |

### Primary color variants

Each primary generates `color-mix()` variants against `var(--surface)`.

| Token | Formula |
|-------|---------|
| `brand-red-light` | `color-mix(in srgb, {brand-red} 12%, var(--surface))` |
| `brand-red-mid` | `color-mix(in srgb, {brand-red} 20%, var(--surface))` |
| `brand-blue-light` | `color-mix(in srgb, {brand-blue} 12%, var(--surface))` |
| `brand-blue-mid` | `color-mix(in srgb, {brand-blue} 20%, var(--surface))` |
| `brand-yellow-light` | `color-mix(in srgb, {brand-yellow} 18%, var(--surface))` |
| `brand-yellow-mid` | `color-mix(in srgb, {brand-yellow} 35%, var(--surface))` |

### Semantic color tints

Each semantic color generates a `-tint` at 12% mix with surface.

| Token | Formula |
|-------|---------|
| `success-tint` | `color-mix(in srgb, {success} 12%, var(--surface))` |
| `warning-tint` | `color-mix(in srgb, {warning} 12%, var(--surface))` |
| `error-tint` | `color-mix(in srgb, {error} 12%, var(--surface))` |
| `info-tint` | `color-mix(in srgb, {info} 12%, var(--surface))` |

### Base aliases

Always computed. Reference other tokens via `var()`.

| Token | Value |
|-------|-------|
| `base-font-family` | `var(--font-sans)` |
| `base-font-color` | `var(--text)` |
| `base-background` | `var(--surface)` |
| `base-line-height` | `var(--line-height-base)` |
| `base-font-size` | `var(--font-size-base)` |

---

## Pass 2: Foundations

Static `var()` references to Pass 1 tokens. Changes to Pass 1 cascade automatically.

### Micro label system

| Token | Default |
|-------|---------|
| `micro-label-font-family` | `var(--font-mono)` |
| `micro-label-font-size` | `var(--font-size-xs)` |
| `micro-label-font-weight` | `var(--font-weight-bold)` |
| `micro-label-letter-spacing` | `var(--letter-spacing-wider)` |
| `micro-label-text-transform` | `uppercase` |
| `micro-label-color` | `var(--gray-500)` |

### Typography

| Token | Default |
|-------|---------|
| `font-weight-normal` | `400` |
| `font-weight-medium` | `500` |
| `font-weight-semibold` | `600` |
| `font-weight-bold` | `700` |
| `line-height-tight` | `1.3` |
| `line-height-normal` | `1.5` |
| `line-height-relaxed` | `1.6` |
| `line-height-heading` | `1.2` |
| `line-height-compact` | `1` |
| `letter-spacing-tight` | `-0.02em` |
| `letter-spacing-snug` | `-0.01em` |
| `letter-spacing-wide` | `0.05em` |
| `letter-spacing-wider` | `0.08em` |
| `letter-spacing-label` | `0.06em` |
| `letter-spacing-widest` | `0.1em` |
| `font-size-2xs` | `10px` |

### Transitions

| Token | Default |
|-------|---------|
| `transition-fast` | `0.1s` |
| `transition-base` | `0.15s` |
| `transition-medium` | `0.22s` |
| `transition-slow` | `0.3s` |

### Borders and radius

| Token | Default | Derives from |
|-------|---------|-------------|
| `border-thin` | `var(--size-border-thin)` | Pass 1 |
| `border-thick` | `var(--size-border-thick)` | Pass 1 |
| `border-heavy` | `var(--size-border-heavy)` | Pass 1 |
| `border-control` | `var(--size-border-medium)` | Pass 1 |
| `border-accent` | `var(--size-border-accent)` | Pass 1 |
| `accent-width` | `var(--space-1)` | `unit` |
| `radius-none` | `0%` | static |
| `radius-sm` | `5%` | static |
| `radius-md` | `var(--space-1-mid)` | `unit` |
| `radius-lg` | `25%` | static |
| `radius-xl` | `50%` | static |
| `radius-circle` | `50%` | static |

### Dividers

| Token | Default |
|-------|---------|
| `hr-height` | `var(--border-thin)` |
| `hr-thick` | `var(--border-thick)` |
| `hr-heavy` | `var(--border-heavy)` |
| `on-semantic-color` | `var(--white)` |

### Shadows and elevation

| Token | Default |
|-------|---------|
| `shadow-sm` | `0 space-quarter border-heavy rgba(0,0,0,0.25)` |
| `shadow-inset` | `inset 0 space-quarter space-half rgba(0,0,0,0.06)` |
| `shadow-elevation` | `0 space-1 space-3 shadow-color, 0 space-half space-2 shadow-color` |
| `shadow-overlay` | `0 space-1 space-4 rgba(0,0,0,0.18), ...` |
| `shadow-toast` | `0 space-half space-1 rgba(0,0,0,0.35)` |
| `shadow-control` | `inset 0 size-border-thin border-heavy rgba(0,0,0,0.04)` |
| `shadow-thumb` | `0 size-border-thin size-border-extra-heavy rgba(0,0,0,0.18), ...` |
| `shadow-panel` | `0 space-1 space-4 shadow-color, ...` |
| `shadow-dialog` | `0 space-3 space-8 rgba(0,0,0,0.18), ...` |
| `shadow-floating` | `0 space-half space-3 rgba(0,0,0,0.12), ...` |

### Overlays

| Token | Default |
|-------|---------|
| `overlay-highlight` | `rgba(255,255,255,0.22)` |
| `overlay-shadow` | `rgba(0,0,0,0.18)` |
| `overlay-backdrop` | `rgba(0,0,0,0.4)` |

### Z-indices

| Token | Default |
|-------|---------|
| `z-chrome` | `300` |
| `z-panel` | `200` |
| `z-overlay` | `100` |
| `z-dialog` | `101` |
| `z-floating` | `90` |
| `z-dropdown` | `50` |

### Opacity scale

| Token | Default |
|-------|---------|
| `opacity-muted` | `0.45` |
| `opacity-subtle` | `0.55` |
| `opacity-soft` | `0.75` |
| `opacity-disabled` | `0.4` |
| `opacity-faint` | `0.3` |

### Small component sizes

| Token | Default |
|-------|---------|
| `size-dot` | `6px` |
| `size-icon-sm` | `18px` |
| `size-action` | `28px` |

### Semantic layout aliases

| Token | Default | Purpose |
|-------|---------|---------|
| `control-height` | `var(--space-5)` | Input/button height |
| `navbar-height` | `var(--space-7)` | Top navigation bar |
| `dropdown-max-height` | `var(--space-25)` | Menu/combo max scroll |
| `popover-min-width` | `var(--space-25)` | Popover minimum |
| `sidebar-width` | `var(--space-30)` | Left sidebar |
| `url-bar-max-width` | `var(--space-30)` | Browser chrome URL bar |
| `aside-width` | `var(--space-32-mid)` | Right aside panel |
| `card-min-width` | `var(--space-35)` | Card grid breakpoint |
| `dialog-width` | `var(--space-52-mid)` | Modal dialog |
| `prose-max-width` | `var(--space-60)` | Text content max-width |

---

## Pass 3: Component Properties

Per-component tokens referencing Pass 1/2 via `var()`. Grouped by system prefix.

### Cards (`card-*`, `table-*`)

| Token | Default | Purpose |
|-------|---------|---------|
| `card-grid-gap` | `var(--space-2)` | Gap between cards |
| `card-grid-min-width` | `var(--card-min-width)` | Auto-fit minimum |
| `card-padding` | `var(--space-3)` | Inner padding |
| `card-border-width` | `var(--border-thin)` | Border thickness |
| `card-border-style` | `solid` | |
| `card-border-color` | `var(--text)` | |
| `card-border` | shorthand | Composed from width/style/color |
| `card-border-width-accent` | `var(--accent-width)` | Accent stripe thickness |
| `card-accent-side` | `top` | Which edge gets the accent |
| `card-accent-color` | `var(--brand-red)` | Accent stripe color |
| `card-transition` | `var(--transition-base)` | Hover transition |
| `card-background` | `var(--surface)` | Default bg |
| `card-header-background` | `var(--surface)` | |
| `card-header-color` | `var(--text-secondary)` | |
| `card-footer-background` | `var(--surface-alt)` | |
| `card-footer-color` | `var(--text-secondary)` | |
| `card-hover-background` | `var(--surface-alt)` | |
| `card-filled-background` | `var(--black)` | Filled variant bg |
| `card-filled-color` | `var(--text-inverse)` | |
| `card-filled-hover-background` | `var(--gray-900)` | |
| `card-title-font-size` | `var(--font-size-md)` | |
| `card-title-font-weight` | `var(--font-weight-bold)` | |
| `card-title-letter-spacing` | `var(--letter-spacing-tight)` | |
| `card-title-margin-bottom` | `var(--space-1)` | |
| `card-title-line-height` | `var(--line-height-heading)` | |
| `card-body-*` | font-size sm, color text-secondary, line-height relaxed | Body text styling |
| `card-body-filled-color` | `var(--text-muted)` | |
| `card-tag-*` | font-mono, font-size-2xs, surface-alt bg | Tag pills on cards |
| `card-rounded-radius` | `var(--radius-md)` | Rounded variant |
| `card-drop-shadow` | `var(--shadow-elevation)` | Shadow variant |
| `card-separator-*` | border-thin, border color | Internal dividers |
| `card-footer-font-size` | `var(--font-size-sm)` | |
| `table-cell-padding` | `var(--space-2) var(--space-1)` | |
| `table-header-*` | micro-label system | Table header styling |

### Tokens (`token-*`)

Style guide token display cards. ~27 tokens.

| Token | Default | Purpose |
|-------|---------|---------|
| `token-grid-min-width` | `var(--space-37-mid)` | Grid auto-fit minimum |
| `token-grid-gap` | `var(--space-2)` | Grid gap |
| `token-card-*` | surface bg, border, space-3 padding | Card container |
| `token-card-title-*` | micro-label system | Card headings |
| `token-row-*` | font-mono, font-size-xs | Individual token rows |
| `token-name-color` | `var(--gray-500)` | Token name text |
| `token-value-color` | `var(--base-font-color)` | Token value text |
| `token-preview-*` | Various sizes | Color/space/radius previews |

### Buttons (`btn-*`)

| Token | Default | Purpose |
|-------|---------|---------|
| `btn-font-family` | `var(--font-sans)` | |
| `btn-font-weight` | `var(--font-weight-semibold)` | |
| `btn-font-size` | `var(--font-size-sm)` | |
| `btn-line-height` | `var(--line-height-compact)` | |
| `btn-letter-spacing` | `var(--letter-spacing-snug)` | |
| `btn-padding-y` | `var(--space-1)` | |
| `btn-padding-x` | `var(--space-2)` | |
| `btn-border-width` | `var(--border-thin)` | |
| `btn-border-color` | `var(--border-strong)` | |
| `btn-background` | `var(--surface-alt)` | |
| `btn-color` | `var(--text)` | |
| `btn-hover-background` | `var(--border)` | |
| `btn-transition` | `var(--transition-base)` | |
| `btn-rounded-radius` | `var(--radius-md)` | |
| `btn-drop-shadow` | `var(--shadow-elevation)` | |
| `btn-sm-*` | Smaller padding/font | Small variant |
| `btn-lg-*` | Larger padding/font | Large variant |
| `btn-xl-*` | Largest padding/font | Extra-large variant |
| `btn-outline-*` | transparent bg, text color | Outline variant |
| `btn-active-offset` | `var(--border-thin)` | Press effect |
| `btn-overlay-highlight` | `var(--overlay-highlight)` | Hover overlay |
| `btn-overlay-shadow` | `var(--overlay-shadow)` | Active overlay |

### Toggle (`toggle-*`, `collapse-*`)

| Token | Default |
|-------|---------|
| `toggle-icon-collapsed` | `'\25B6'` (right triangle) |
| `toggle-icon-expanded` | `'\25BC'` (down triangle) |
| `toggle-icon-size` | `var(--font-size-2xs)` |
| `toggle-icon-color` | `var(--gray-400)` |
| `toggle-transition` | `var(--transition-base) ease` |
| `collapse-section-height` | `var(--space-16)` |
| `collapse-subsection-height` | `var(--space-8)` |

### Indicators (`badge-*`, `alert-*`, `toast-*`, `progress-*`, `status-dot-*`, `tag-*`)

**Badges** (~9 tokens): padding `space-half space-1`, radius-md, font-size-xs, font-mono, semibold. Count variant has `size-icon-sm` min-width/height.

**Alerts** (~6 tokens): border-heavy left accent, gap space-half, title semibold sm, body sm with normal line-height.

**Toasts** (~17 tokens): gap space-2, padding space-3, font-size-sm. Per-variant backgrounds use `{status}-tint` and colors use `{status}` directly. Max-width prose-max-width, border-accent width, shadow-toast.

**Progress** (~5 tokens): height space-1, radius-none, transition on width. Small (`space-half`) and large (`radius-md`) height variants.

**Status dots** (~3 tokens): dot size space-1, row gap size-dot, font-size-sm labels.

**Tags** (~6 tokens): padding `space-half space-1`, radius from seed `radius`, font-size-xs, font-mono, medium weight, border-thin.

### Forms (`field-*`, `control-*`, `switch-*`, `radio-*`, `fieldset-*`)

**Fields** (~20 tokens): Height, padding, font-size, bg, border, and focus styling all delegate to `hui-field-*` tokens (see HUI Fields below). Additional tokens for textarea, select, validation bar, label (micro-label system), hints, and char count.

**Controls** (~6 tokens): size space-2, border-control width, border-strong color, brand-blue checked, shadow-inset.

**Switches** (~12 tokens): width space-4-mid, height size-lg, thumb size-md-sm. Track radius radius-md, transition on background. Thumb has calculated position and shadow-sm.

**Radios** (~5 tokens): size space-2, border-control width, inner shadow `inset 0 0 0 size-border-extra-heavy brand-blue`.

**Fieldsets** (~3 tokens): legend padding size-dot, margin border-thick, border-thin.

### Shells (`shell-*`, `screen-*`)

**Navbar** (~16 tokens): height from `navbar-height`, z-chrome, font-size-sm. Links have opacity-soft, radius from seed, semibold when active. Actions are size-action squares. Dismiss button is xs font.

**Sidebar** (~13 tokens): width from `sidebar-width`, z-panel. Section headings use micro-label. Items have space-1 gap, sm font, semibold when active. Glyphs are size-icon-sm.

**Aside** (~10 tokens): width from `aside-width`, z-panel. Section headings xs font with wide spacing. Rows sm font with thin borders. Meta has subtle opacity.

**Footer** (~5 tokens): height space-4, z-chrome, xs font, dot indicators with faint opacity.

**Screen frame** (~12 tokens): radius space-1, shadow-overlay, border-thin. Titlebar with macOS-style dots (hardcoded colors: `#ff5f56`, `#ffbd2e`, `#27c93f`). URL bar with half-space padding and radius.

### Sections (`sg-*`)

Style guide layout tokens. ~30 tokens covering:

- `sg-border`: `border-thin solid border`
- `sg-screen-*`: url max-width, body min-height, retro shadow
- `sg-section-number-*`: number badges with surface-alt bg, radius, micro-label spacing
- `sg-section-title-*`: font-size-lg, tight spacing, inherits font-family
- `sg-section-desc-*`: font-mono, text-muted
- `sg-type-specimen-*`: transparent bg, bottom-border-only, mono name font
- `sg-principle-label-width`: `var(--space-9)`
- `sg-description-max-width`: `var(--prose-max-width)`
- `sg-hairline`: `var(--border-thick)`
- `sg-bar-*`, `sg-spacing-*`, `sg-diagram-*`: Demo component styling for spacing/layout sections

### Branding (`branding-*`)

~25 tokens for brand identity cards:

- `branding-grid-width`: card-min-width
- `branding-border`: inherits card-border
- `branding-logo-*`: surface-alt bg, space-20 max-width, space-15 max-height, radius from seed
- `branding-placeholder-*`: dashed border for missing logos
- `branding-name-*`: space-2-mid font-size, bold, tight spacing
- `branding-field-*`: micro-label labels, sm font values, text-secondary
- `branding-keyword-*`: micro-label system, border-thin pills, space-half gap

### Dividers (`hr-*`)

| Token | Default |
|-------|---------|
| `hr-glow-blur` | `0.3px` |
| `hr-overline-length` | `var(--space-6)` |

### HUI: Focus (`hui-focus-*`)

| Token | Default |
|-------|---------|
| `hui-focus-ring-color` | `color-mix(in srgb, var(--brand-blue) 25%, transparent)` |
| `hui-focus-ring-width` | `var(--border-heavy)` |

### HUI: Controls (`hui-control-*`, `hui-switch-*`, `hui-radio-*`, `hui-checkbox-*`)

~30 tokens. Pattern: `hui-{component}-{property}`.

- `hui-control-color`: brand-blue. `hui-control-bg`: surface. `hui-control-border`: border-strong. `hui-control-size`: size-lg.
- `hui-checkbox-radius`: border-heavy
- `hui-switch-track-*`: width space-5-mid, height space-3, radius-md, off-bg gray-300, on-bg brand-blue
- `hui-switch-thumb-*`: size-space-2-qtr, white bg, radius-circle, border-heavy inset, shadow-thumb
- `hui-radio-option-*`: size-dot padding, border and brand-blue active border, 8% blue tint active bg
- `hui-radio-dot-*`: size-space-2, circle radius, calculated inner size

### HUI: Triggers (`hui-trigger-*`)

~10 tokens for dropdown/combo trigger buttons. Padding space-1 / space-1-mid, font-size-sm, medium weight, surface bg, border colors, size-dot gap.

### HUI: Panels (`hui-panel-*`, `hui-popover-*`, `hui-menu-*`, `hui-combo-*`)

~25 tokens for overlay panels.

- `hui-panel-bg`: surface. `hui-panel-border`: border. `hui-panel-shadow`: shadow-panel. `hui-panel-z-index`: z-dropdown.
- `hui-panel-item-*`: space-1 padding-y, sm font, surface-alt active bg, fast transition, semibold when selected, opacity-disabled when disabled
- `hui-panel-sep-*`: border-thin height, space-half margin
- `hui-panel-max-height`: dropdown-max-height
- `hui-popover-padding`: space-3. `hui-popover-min-width`: popover-min-width.
- `hui-menu-min-width`: space-20
- `hui-combo-*`: icon-area space-4-mid, placeholder gray-400, button gray-500

### HUI: Tabs (`hui-tab-*`)

~15 tokens.

- Padding: font-size-2xs / size-space-2
- Font: sm, medium weight, semibold when selected
- Colors: gray-400 default, gray-700 hover, text when selected
- `hui-tab-border-selected`: text. `hui-tab-list-border`: border.
- `hui-tab-indicator-width`: border-thick. Offset: `-1 * border-thin`.

### HUI: Disclosure (`hui-disclosure-*`)

~15 tokens for accordion/collapsible sections.

- Bg surface-alt, border, sm font, medium weight
- Panel: surface bg, text-secondary, relaxed line-height
- Chevron: size-md-sm, gray-400, cubic-bezier transition

### HUI: Fields (`hui-field-*`, `hui-label-*`, `hui-description-*`, `hui-textarea-*`)

~20 tokens. These are the "source of truth" that `field-*` tokens delegate to.

- `hui-field-height`: control-height. `hui-field-padding-x`: size-space-1-mid. `hui-field-font-size`: font-size-sm.
- `hui-field-bg`: surface. `hui-field-border`: border. `hui-field-border-hover`: border-strong. `hui-field-focus-border`: brand-blue.
- `hui-field-shadow`: shadow-control. `hui-field-border-width`: border-thin.
- `hui-field-icon-area`: space-4. Chevron: gray-400, size-dot, size-border-medium border.
- `hui-label-*`: font-size-xs, semibold, letter-spacing-label, text-muted
- `hui-description-*`: font-size-xs, text-muted
- `hui-textarea-resize`: none

### HUI: Dialog (`hui-dialog-*`)

~12 tokens.

- `hui-dialog-backdrop`: overlay-backdrop. `hui-dialog-bg`: surface. `hui-dialog-shadow`: shadow-dialog.
- `hui-dialog-padding`: space-4. `hui-dialog-max-width`: dialog-width.
- `hui-dialog-backdrop-z-index`: z-overlay. `hui-dialog-z-index`: z-dialog.
- Title: bold, text color. Body: text-secondary, relaxed line-height.

### HUI: Showcase (`hui-showcase-*`)

~15 tokens for component demo grids.

- `hui-showcase-accent`: brand-red. `hui-showcase-bg`: surface-alt. `hui-showcase-border`: border-strong.
- Cell: surface bg, border, space-3 padding, 140px min-height
- Labels: text-muted, font-size-2xs, bold, letter-spacing-wider
- Grid gap: border-thin. Accent width: border-heavy.

### Code (`code-*`)

| Token | Default | Purpose |
|-------|---------|---------|
| `code-bg` | `var(--gray-900)` | Block background |
| `code-text` | `var(--gray-100)` | Default text |
| `code-border` | `var(--gray-700)` | Block border |
| `code-keyword` | `var(--brand-blue)` | Language keywords |
| `code-string` | `var(--success)` | String literals |
| `code-comment` | `var(--gray-500)` | Comments |
| `code-function` | `var(--amber)` | Function names |
| `code-number` | `var(--brand-red)` | Numeric literals |
| `code-line-number` | `var(--gray-600)` | Gutter numbers |

### Terminal (`terminal-*`)

| Token | Default | Purpose |
|-------|---------|---------|
| `terminal-bg` | `var(--gray-900)` | Background |
| `terminal-text` | `var(--gray-100)` | Default text |
| `terminal-border` | `var(--gray-700)` | Border |
| `terminal-title-bar-bg` | `var(--gray-800)` | Title bar |
| `terminal-prompt` | `var(--success)` | Prompt character |
| `terminal-command` | `var(--gray-100)` | User input |
| `terminal-output` | `var(--gray-400)` | Command output |
| `terminal-success` | `var(--success)` | Success messages |
| `terminal-error` | `var(--error)` | Error messages |
| `terminal-warning` | `var(--warning)` | Warning messages |

---

## Semantic Color Tokens (Color Modes)

Defined in `style-guide.color-modes.yaml`, not in `defaults.ts`. Flip automatically with `.dark` class on `<html>`.

| Token | Light | Dark |
|-------|-------|------|
| `surface` | `var(--white)` | `var(--slate-900)` |
| `surface-alt` | `var(--slate-50)` | `var(--slate-800)` |
| `surface-inverse` | `var(--slate-900)` | `var(--slate-200)` |
| `text` | `var(--black)` | `var(--slate-100)` |
| `text-secondary` | `var(--gray-600)` | `var(--slate-300)` |
| `text-muted` | `var(--gray-400)` | `var(--slate-400)` |
| `text-inverse` | `var(--white)` | `var(--slate-900)` |
| `border` | `var(--slate-200)` | `var(--slate-700)` |
| `border-strong` | `var(--slate-300)` | `var(--slate-600)` |
| `shadow-color` | `rgba(0,0,0,0.1)` | `rgba(0,0,0,0.4)` |

**Gray vs Slate**: Gray tokens are pure neutrals interpolated from white/black (used for text). Slate tokens are blue-tinted Tailwind defaults (used for surfaces). In dark mode, semantic tokens swap to slate values for depth.
