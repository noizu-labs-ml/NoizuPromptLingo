# MCP Host — Style Direction

> Unified design system for the MCP Host platform and its three product surfaces.

**Status:** draft
**Last updated:** 2026-05-12

---

## Style Selection

**Primary:** Nocturne (80%) — dark-native, luminosity-driven hierarchy
**Accent:** Minimal Tech (20%) — geometric precision, monochrome restraint

### Rationale

MCP Host is a developer-facing security platform. The audience lives in dark terminals and IDEs. Nocturne provides the immersive dark canvas that signals "this is a professional instrument, not a consumer toy." The Minimal Tech accent brings clean geometric structure and SaaS credibility — preventing Nocturne from sliding into gaming aesthetics.

The security-first positioning benefits enormously from dark backgrounds: audit logs, policy dashboards, and trust scores read as serious on dark canvas. Bright-on-dark data visualization creates natural focus hierarchy.

---

## Platform Color System

### Dark Canvas (shared across all surfaces)

| Token | Hex | Usage |
|-------|-----|-------|
| `--void` | `#09090B` | Page background, deepest layer |
| `--canvas` | `#0C0C10` | Primary background |
| `--canvas-alt` | `#111118` | Alternating section background |
| `--surface` | `#18181F` | Card backgrounds, elevated elements |
| `--surface-raised` | `#23232E` | Modals, dropdowns, popovers |
| `--surface-overlay` | `#262636` | Highest elevation surfaces |

### Borders

| Token | Hex | Usage |
|-------|-----|-------|
| `--border-mist` | `#2A2A3A` | Subtle dividers, card borders |
| `--border-fog` | `#3A3A4F` | Interactive element borders, focus rings |

### Text Hierarchy (luminosity-driven)

| Token | Hex | Usage |
|-------|-----|-------|
| `--text-dim` | `#5C5C72` | Disabled, placeholder, metadata |
| `--text-secondary` | `#8888A0` | Body text, descriptions |
| `--text-primary` | `#CDCDE0` | Headlines, labels, navigation |
| `--text-bright` | `#EDEDF4` | Emphasized text, active states |
| `--text-max` | `#FFFFFF` | Sparingly — hero headlines, critical alerts |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `--success` | `#4ADE80` | Health checks passing, deploy success |
| `--warning` | `#FACC15` | Policy warnings, deprecation notices |
| `--error` | `#F87171` | Auth failures, policy denials, errors |
| `--info` | `#60A5FA` | Informational states, links |

### Platform Glow: Phosphor Blue

The platform's primary accent. Blue signals trust, authority, and technical competence — aligned with the security-first brand promise.

| Token | Hex | Usage |
|-------|-----|-------|
| `--glow` | `#3B82F6` | Primary CTA, active nav, focus indicators |
| `--glow-dim` | `#3B82F620` | Subtle background tints, hover states |
| `--glow-mid` | `#3B82F640` | Inner halo on buttons, active borders |
| `--glow-bright` | `#3B82F680` | Outer bloom on primary actions |

### Sub-Product Accent Colors

Each surface gets a secondary accent used sparingly alongside the platform blue — for product-specific iconography, badges, and section markers only.

| Surface | Accent | Hex | Signal |
|---------|--------|-----|--------|
| **JustMCP.it** | Plasma Cyan | `#06B6D4` | Speed, immediacy, "just works" |
| **MCP Jumpstart** | Aurora Green | `#10B981` | Growth, building, scaffolding |
| **SafeMCP** | Spectral Violet | `#8B5CF6` | Security, authority, depth |

Usage rule: sub-product accent appears only in that surface's logo variant, category badges, and section headers. All interactive elements (buttons, links, focus rings) use platform Phosphor Blue for consistency.

---

## Typography

### Font Stack

| Role | Font | Fallback |
|------|------|----------|
| **Display/Headings** | Geist | Inter, system-ui |
| **Body** | Geist | Inter, system-ui |
| **Monospace** | JetBrains Mono | Berkeley Mono, Fira Code, monospace |

### Type Scale

| Token | Size | Weight | Letter-spacing | Usage |
|-------|------|--------|----------------|-------|
| `--display` | 48px | 500 | -0.02em | Hero headlines |
| `--h1` | 36px | 500 | -0.015em | Page titles |
| `--h2` | 24px | 500 | -0.01em | Section headings |
| `--h3` | 20px | 500 | 0 | Subsection headings |
| `--body` | 16px | 400 | +0.01em | Body text |
| `--body-sm` | 14px | 400 | +0.01em | Secondary body, captions |
| `--caption` | 12px | 400 | +0.02em | Metadata, timestamps |
| `--mono` | 14px | 400 | 0 | Code blocks, tool names, API keys |

### Weight Rules

- Only two weights: 400 (regular) and 500 (medium)
- No bold (600+) — Nocturne uses luminosity for emphasis, not weight
- Reduce weight one step from light-mode equivalents
- Body text uses `--text-secondary`, never `--text-max`

---

## Spacing System

### Base Unit: 8px

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight inline spacing |
| `--space-2` | 8px | Icon-to-label gaps |
| `--space-3` | 12px | Form field gaps |
| `--space-4` | 16px | Component internal padding |
| `--space-6` | 24px | Card padding, list gaps |
| `--space-8` | 32px | Section internal padding |
| `--space-12` | 48px | Between major components |
| `--space-16` | 64px | Section vertical spacing |
| `--space-24` | 96px | Hero/section breaks |

### Layout Grid

- Max width: **1400px** (Nocturne standard — wider than Minimal Tech's 1280px)
- Columns: 12 at desktop, 24px gutters
- Card padding: 28px (25% more generous than light-native)
- Glow elements: 16px minimum clearance from adjacent elements

---

## Component Styling

### Buttons

```
Primary:    --surface-raised bg + --glow border + glow stack (crisp edge → inner halo → outer bloom)
Secondary:  --surface bg + --border-fog border + no glow
Ghost:      transparent bg + --text-secondary text → --text-bright on hover
Destructive: --surface bg + --error border + error glow on hover
```

- Border radius: 6px (Minimal Tech influence)
- No drop shadows — ever
- Hover: opacity shift + border glow intensify, 100-150ms
- Active: glow contracts inward, 50ms

### Cards

- Background: `--surface-raised`
- Border: 1px `--border-mist`
- Border radius: 8px
- Padding: 28px
- No shadows — depth via brightness stepping only
- Hover (if interactive): border shifts to `--border-fog`, 150ms

### Inputs

- Background: `--surface` (recessed below card surface)
- Border: 1px `--border-mist` → `--glow` on focus
- Border radius: 6px
- Padding: 12px 16px
- Placeholder: `--text-dim`
- Focus: glow ring (2px `--glow-mid`)

### Navigation

- Background: `--canvas` with `backdrop-filter: blur(12px)` + 80% opacity
- Active item: `--text-bright` + `--glow` underline or left-border
- Inactive: `--text-secondary`
- Logo lockup always full brightness

### Data Tables (audit logs, registry, policies)

- Header row: `--surface` bg, `--text-primary`, 500 weight
- Body rows: alternating `--canvas` / `--canvas-alt`
- Row hover: `--surface` bg, 100ms
- Status badges: semantic color bg at 15% opacity + full color text

### Code Blocks

- Background: `--void` (deepest layer — code is recessed)
- Border: 1px `--border-mist`
- Font: JetBrains Mono 14px
- Syntax highlighting: muted palette (avoid neon — this isn't a code editor)

---

## Motion

| Pattern | Duration | Easing |
|---------|----------|--------|
| Micro-interaction | 50-100ms | ease-out |
| Hover state | 100-150ms | ease-in-out |
| Panel transition | 200-300ms | ease-out |
| Page transition | 300-400ms | ease-in-out |
| Glow pulse (status) | 2000ms | ease-in-out, infinite |

- All motion respects `prefers-reduced-motion`
- Glow animations: subtle pulse on active status indicators only
- No decorative motion — motion communicates state changes
- Skeleton loaders over spinners (Minimal Tech influence)

---

## Brand Identity

### Platform Mark: MCP Host

The platform mark is a **geometric logomark** — a stylized shield form built from the letters "M", "C", "P" arranged to suggest both security (shield silhouette) and connectivity (interlocking nodes).

Construction principles:
- Built on 24x24 grid
- Maximum 2 colors (Phosphor Blue + white)
- Must read as monochrome silhouette at 16px
- Shield form without being a literal shield — abstract, geometric, modern

### Sub-Product Wordmarks

Each sub-product uses the platform logomark (at reduced size) alongside its domain name set in Geist Medium:

| Surface | Lockup | Accent Treatment |
|---------|--------|-----------------|
| **JustMCP.it** | [mark] + "JustMCP" in Geist 500 + ".it" in Plasma Cyan | Cyan dot on the "i" |
| **MCP Jumpstart** | [mark] + "MCP Jumpstart" in Geist 500 | Green arrow glyph after "Jumpstart" |
| **SafeMCP** | [mark] + "SafeMCP" in Geist 500 | Violet lock icon before "Safe" |

### Voice & Tone

| Attribute | Expression |
|-----------|-----------|
| **Authoritative** | "Your MCP endpoints, secured by default." not "We try to keep things safe!" |
| **Technical** | Use precise terminology: "dual-principal authorization", not "double security" |
| **Confident** | State capabilities directly: "Deploys in 90 seconds." not "We aim for fast deploys." |
| **Concise** | Headlines ≤ 8 words. Body sentences ≤ 25 words. |

---

## Accessibility Commitments

- All text meets WCAG 2.2 AA contrast on dark backgrounds (4.5:1 body, 3:1 UI)
- Glow effects are decorative — never the only indicator of state
- Focus indicators visible at 3:1 contrast against adjacent colors
- All interactive elements have ≥ 44x44px touch targets
- Test on both OLED (true black) and LCD (backlit dark gray)
- `prefers-reduced-motion` disables all glow animations and transitions

---

## Anti-Patterns (Don'ts)

- White body text — use `--text-secondary` for body, `--text-primary` for headings
- Glow on everything — reserve glow for primary CTA and active states only
- Drop shadows — depth comes from brightness stepping in Nocturne
- Hairline fonts below 16px — illegible on dark backgrounds
- Large bright fills — dark canvas should dominate; bright areas are small and intentional
- Multiple accent colors on one screen — platform blue only for interactions
- Inverting a light theme to get dark mode — Nocturne is designed dark-first
- Border-radius above 12px — sharp geometry signals precision
- Gradients on UI elements — flat fills only
- Decorative illustrations or mascots — let the interface be the product
