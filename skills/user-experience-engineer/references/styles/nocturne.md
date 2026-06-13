# Nocturne Style Specification

> Dark-native design that treats darkness as a first-class material, not an inversion. Hierarchy through luminosity, feedback through glow, color as emitted light. For interfaces that live in the dark and own it.

## Quick Reference

- **Also known as:** Dark-native, luminosity-first, ambient UI, glow design
- **Signal:** Immersion, atmosphere, focus, expertise, calm intensity
- **Best for:** Media/entertainment, Gaming interfaces, Music platforms, Monitoring/observability dashboards, Creative tools (DAWs, video editors, 3D), Astronomy/space, Nightlife/events, Data visualization, Streaming, Narrative experiences
- **Key characteristics:** Dark canvas is the default (not a toggle), Luminosity hierarchy replaces weight hierarchy, Glow-based interaction feedback, Color is always emitted light (never reflected surface), Depth through light falloff not shadow, Ambient motion (slow, continuous, atmospheric), Sound-responsive design patterns
- **Avoid when:** Product is document-heavy (long-form reading), Users primarily work in bright environments, Brand needs to feel corporate or institutional, Primary audience skews 65+, Print compatibility is required

## Table of Contents

- [1. Positioning](#1-positioning)
- [2. Design Philosophy](#2-design-philosophy)
- [3. Color System](#3-color-system)
- [4. Typography](#4-typography)
- [5. Spacing System](#5-spacing-system)
- [6. Component Styling](#6-component-styling)
- [7. Interaction Patterns](#7-interaction-patterns)
- [8. Atmospheric Effects](#8-atmospheric-effects)
- [9. Data Visualization](#9-data-visualization)
- [10. Accessibility Considerations](#10-accessibility-considerations)
- [11. Do's and Don'ts](#11-dos-and-donts)
- [12. Reference Sites](#12-reference-sites)
- [13. Implementation Checklist](#13-implementation-checklist)

---

## 1. Positioning

### 1.1 What This Style Signals

- **Immersion**: "Step into the experience"
- **Expertise**: "This is a professional instrument, not a toy"
- **Focus**: "Nothing distracts from what matters"
- **Atmosphere**: "The environment itself communicates"
- **Calm intensity**: "Serious without being sterile"

### 1.2 Best Use Cases

- Music production and audio tools (DAWs, mixers, DJ software)
- Video/photo editing and creative suites
- Gaming interfaces and companion apps
- Media streaming platforms
- Monitoring and observability dashboards (ops, infrastructure)
- Data visualization and analytics (especially real-time)
- Astronomy, space, and scientific visualization
- Nightlife, events, and venue platforms
- Narrative and immersive storytelling experiences
- Trading and financial terminals (after-hours aesthetic)
- Home automation and IoT dashboards

### 1.3 Avoid When

- Product is primarily text/document focused (use Editorial)
- Users work outdoors or in bright sunlit environments
- Brand identity requires a light, airy, or institutional feel
- Primary audience expects conventional business interfaces
- Product needs to print well or export to PDF
- Regulatory requirements mandate high-brightness displays

### 1.4 How Nocturne Differs From "Dark Mode"

This is not a color inversion. Standard dark mode takes a light-first design and flips it. Nocturne is **designed in darkness from the start**:

| Dark Mode (inverted light) | Nocturne (dark-native) |
|---|---|
| White text on dark background | Luminosity gradient creates hierarchy |
| Same component shapes, darker | Components glow, breathe, emit |
| Shadows become lighter | Shadows disappear; light falloff creates depth |
| Same interaction feedback, different colors | Glow-based feedback; light is the signal |
| Dark is a setting | Dark is the material |
| Toggle between light/dark | No light mode (or light is the alternative) |

---

## 2. Design Philosophy

### 2.1 The Luminosity Principle

In light-native design, hierarchy is created by **weight** — bold vs. regular, dark vs. light, solid vs. outline. In Nocturne, hierarchy is created by **luminosity** — brighter elements are more important.

```
LUMINOSITY HIERARCHY

  ████████████  ← Maximum luminosity: primary actions, active states
  ▓▓▓▓▓▓▓▓▓▓▓▓  ← High luminosity: headings, focused content
  ▒▒▒▒▒▒▒▒▒▒▒▒  ← Medium luminosity: body content, secondary actions
  ░░░░░░░░░░░░  ← Low luminosity: labels, metadata, borders
  ············  ← Near-zero: disabled states, deep background texture
  [  void  ]   ← True dark: the canvas itself (absence)
```

### 2.2 Light as Material

In the physical world, dark environments reveal light sources. Nocturne uses this physics:

- **Glow** replaces shadow as the primary depth cue
- **Light falloff** (inverse-square fading) creates natural hierarchy
- **Bloom** (subtle light bleed) creates warmth and atmosphere
- **Emission** — elements don't reflect light, they emit it

### 2.3 The Three Laws

1. **Darkness is not absence — it is canvas.** The dark areas are as designed as the light ones. Negative space in Nocturne is negative *light*.
2. **Brightness is currency — spend it wisely.** Every bright element costs attention. A single glowing CTA in a dark field is more powerful than any bold button on white.
3. **Motion is breath, not decoration.** Subtle ambient motion (glow pulses, color drifts) gives the interface a living quality without being distracting.

---

## 3. Color System

### 3.1 Palette Structure

```
┌─────────────────────────────────────────────────────────────┐
│  NOCTURNE PALETTE STRUCTURE                                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Void ─────────────── #09090B                (true black)    │
│  Canvas ───────────── #0C0C10 or #111118     (near-black)    │
│  Surface ──────────── #18181F or #1C1C26     (elevated)      │
│  Surface Raised ───── #23232E or #262636     (cards/modals)  │
│                                                              │
│  Mist ─────────────── #2A2A3A                (subtle border) │
│  Fog ──────────────── #3A3A4F                (stronger sep.) │
│                                                              │
│  Text Dim ─────────── #5C5C72                (metadata)      │
│  Text Secondary ───── #8888A0                (body text)     │
│  Text Primary ─────── #CDCDE0                (headings)      │
│  Text Bright ──────── #EDEDF4                (emphasis)      │
│  Text Max ─────────── #FFFFFF                (active/focus)   │
│                                                              │
│  Glow ─────────────── ONE primary glow color (see options)   │
│  Glow Ambient ─────── Glow color at 5-15% opacity           │
│  Glow Halo ────────── Glow color at 20-40% opacity, blurred │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Glow Color Options

Choose ONE primary glow for the interface. This is the soul of the palette — it tints everything:

| Color | Hex | Glow Hex (bright) | Signal | Best For |
|-------|-----|-------------------|--------|----------|
| Phosphor Blue | `#3B82F6` | `#60A5FA` | Precision, monitoring | Dashboards, ops tools, data viz |
| Ember Orange | `#F97316` | `#FB923C` | Warmth, energy | Music, social, entertainment |
| Spectral Violet | `#8B5CF6` | `#A78BFA` | Mystery, creativity | Creative tools, narrative, gaming |
| Plasma Cyan | `#06B6D4` | `#22D3EE` | Technology, clarity | Dev tools, terminals, sci-fi |
| Aurora Green | `#10B981` | `#34D399` | Growth, health, nature | Sustainability, monitoring, trading |
| Neon Rose | `#EC4899` | `#F472B6` | Boldness, nightlife | Music, events, fashion, streaming |

**Advanced:** Two-glow systems (primary + secondary) are permitted for data-heavy interfaces where categorical color distinction matters. Keep the second glow color analogous (within 60° on the color wheel) or complementary.

### 3.3 The Glow Stack

Every interactive or important element has a **glow stack** — layers of the glow color at decreasing opacity:

```css
/* Glow stack for a primary button */
.btn-primary {
  background: var(--glow);
  color: var(--void);
  box-shadow:
    0 0 1px  var(--glow),              /* crisp edge        */
    0 0 8px  color-mix(in srgb, var(--glow) 40%, transparent),  /* inner halo  */
    0 0 24px color-mix(in srgb, var(--glow) 15%, transparent);  /* outer bloom  */
}

/* Glow stack for focus ring */
.focusable:focus-visible {
  outline: 2px solid var(--glow);
  outline-offset: 2px;
  box-shadow:
    0 0 12px color-mix(in srgb, var(--glow) 30%, transparent);
}
```

### 3.4 Semantic Colors

Semantic colors in Nocturne are **always bright** — they're light sources against the dark canvas:

| Purpose | Color | Glow Treatment |
|---------|-------|----------------|
| Success | `#4ADE80` | Soft green glow |
| Warning | `#FACC15` | Warm amber glow |
| Error | `#F87171` | Pulsing red glow |
| Info | `#60A5FA` | Steady blue glow |

Error states pulse gently (1.5s cycle) to draw attention without flashing.

### 3.5 Color Usage Rules

- **Canvas should be 85%+ of visual field** — the dark IS the design
- Glow color appears on: primary CTAs, active states, focused elements, key data points, progress indicators
- **Never use glow color for large fills** — it destroys the luminosity budget. Max glow-filled area: button-sized
- Text hierarchy is created by opacity/brightness steps, not color variety
- Borders use `--mist` (barely visible) or `--fog` (clear separation) — never bright
- **Avoid pure white (#FFFFFF) for backgrounds or fills** — it's blinding. Reserve for text-max and active indicators only
- Surface elevation is shown by brightness stepping: canvas → surface → surface-raised (each step ~+8% brightness)

---

## 4. Typography

### 4.1 Font Selection

**Primary recommendation:** Inter, Geist, or Untitled Sans

Nocturne typography is lighter than conventional dark-mode text. On dark backgrounds, light text appears heavier due to irradiation illusion (light blooms into surrounding dark pixels). Compensate:

**Mandatory adjustments for dark canvas:**
- Reduce font-weight by one step vs. what you'd use on white (use 400 where you'd use 500, use 300 where you'd use 400)
- Increase letter-spacing slightly (+0.01em for body, +0.02em for captions)
- Use `--text-secondary` (#8888A0) for body text, NOT `--text-bright` — save brightness for hierarchy

**Acceptable alternatives:**
- Instrument Sans (slightly warm)
- DM Sans (geometric, clean)
- Plus Jakarta Sans (modern, rounded)
- IBM Plex Sans (technical, no-nonsense)
- Space Grotesk (distinctive but restrained)

**Monospace (for data/code):**
- JetBrains Mono, Berkeley Mono, or Iosevka
- Mono fonts should match the glow color for syntax highlighting primary tokens

**Avoid:**
- Thin/hairline weights below 16px (invisible on dark backgrounds)
- Heavy/black weights for body (irradiation makes them look bolder than intended)
- Serif fonts (their fine strokes disappear against dark canvas; exception: display use only)

### 4.2 Type Scale

Base: 16px

| Level | Size | Weight | Line Height | Color | Use |
|-------|------|--------|-------------|-------|-----|
| Display | 48-72px | 300-400 | 1.05 | `--text-bright` | Hero headlines, splash |
| H1 | 36px | 400 | 1.15 | `--text-primary` | Page titles |
| H2 | 24px | 500 | 1.25 | `--text-primary` | Section headers |
| H3 | 20px | 500 | 1.3 | `--text-primary` | Subsections |
| H4 | 16px | 500 | 1.4 | `--text-secondary` | Card titles, labels |
| Body | 16px | 400 | 1.65 | `--text-secondary` | Primary content |
| Body Small | 14px | 400 | 1.55 | `--text-dim` | Secondary content |
| Caption | 12px | 400 | 1.4 | `--text-dim` | Metadata, timestamps |
| Code | 14px | 400 (mono) | 1.5 | `--glow` at 80% | Code snippets |

### 4.3 Typography Rules

- Display headlines use **light weights (300-400)** — the dark canvas provides the contrast; the type doesn't need to shout
- Body text is `--text-secondary`, NOT full white — this is critical. Full-brightness body text causes eye fatigue on dark backgrounds
- Headlines step up to `--text-primary` or `--text-bright` for hierarchy
- Active/focused text can reach `--text-max` (#FFFFFF) temporarily
- Letter-spacing: `+0.01em` for body, `+0.02em` for captions, `-0.02em` for display
- **Never use text-shadow for readability** — if you need shadow for legibility, the contrast is wrong

---

## 5. Spacing System

### 5.1 Base Unit

8px base, same scale as Minimal Tech — but applied differently:

```
4px   - Micro (glow padding, indicator gaps)
8px   - XS (icon-to-label, tight groups)
12px  - SM (input padding, badge padding)
16px  - MD (standard component spacing)
24px  - LG (card padding, section gaps)
32px  - XL (between component groups)
48px  - 2XL (major section divisions)
64px  - 3XL (page section spacing)
96px  - 4XL (hero/splash spacing)
```

### 5.2 Nocturne-Specific Spacing Rules

- **More generous than light-native design.** Dark interfaces need more breathing room — dense dark layouts feel oppressive. Add ~25% more vertical spacing than you would in a light design.
- **Card padding: 24-32px** (not 16px like Minimal Tech) — content needs room to breathe in the dark
- **Section spacing: 64-96px vertical** — let the dark canvas show between sections
- **Glow elements need clearance.** A glowing button needs at least 16px clear space so its halo doesn't collide with adjacent elements

### 5.3 Component Spacing

| Component | Padding | Gap | Notes |
|-----------|---------|-----|-------|
| Button (sm) | 8px 16px | -- | Extra horizontal for glow clearance |
| Button (md) | 12px 20px | -- | |
| Button (lg) | 16px 28px | -- | |
| Input field | 14px 16px | -- | Slightly taller than light-native |
| Card | 28px | 20px internal | Generous; dark cards need air |
| Modal | 36px | 24px internal | |
| Section | 80px vertical | -- | 25% more than Minimal Tech |
| Page margins | 24px (mobile) / 80px+ (desktop) | -- | |

### 5.4 Grid System

```
Mobile:     4 columns, 16px gutters, 16px margins
Tablet:     8 columns, 24px gutters, 32px margins
Desktop:    12 columns, 28px gutters, 80px margins
Wide:       12 columns, 32px gutters, max-width 1400px centered
```

Max-width is slightly wider than Minimal Tech (1400 vs 1280) because dark backgrounds handle width better — the eye doesn't get lost on a dark field the way it does on wide white.

---

## 6. Component Styling

### 6.1 Buttons

```css
/* Primary — glowing */
.btn-primary {
  background: var(--glow);
  color: var(--void);
  border: none;
  border-radius: 8px;
  font-weight: 500;
  box-shadow:
    0 0 1px var(--glow),
    0 0 12px color-mix(in srgb, var(--glow) 30%, transparent);
  transition: box-shadow 0.2s ease-out, transform 0.15s ease-out;
}
.btn-primary:hover {
  box-shadow:
    0 0 1px var(--glow),
    0 0 20px color-mix(in srgb, var(--glow) 45%, transparent);
  transform: translateY(-1px);
}

/* Secondary — outlined with subtle glow */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  border: 1px solid var(--fog);
  border-radius: 8px;
  transition: border-color 0.2s, box-shadow 0.2s;
}
.btn-secondary:hover {
  border-color: var(--glow);
  box-shadow: 0 0 8px color-mix(in srgb, var(--glow) 15%, transparent);
}

/* Ghost — text only, glow on hover */
.btn-ghost {
  background: transparent;
  color: var(--text-dim);
  border: none;
}
.btn-ghost:hover {
  color: var(--glow);
  text-shadow: 0 0 12px color-mix(in srgb, var(--glow) 30%, transparent);
}

/* Destructive — red glow */
.btn-destructive {
  background: var(--error);
  color: var(--void);
  border: none;
  border-radius: 8px;
  box-shadow: 0 0 12px color-mix(in srgb, var(--error) 30%, transparent);
}
```

**Button Rules:**
- Primary buttons glow — they're the brightest element in their context
- Only one primary button per viewport section
- Hover intensifies the glow (never dims it)
- Border radius: 8px (slightly softer than Minimal Tech to diffuse glow naturally)
- No gradients on buttons — solid fill with glow stack
- Disabled buttons lose ALL glow: flat `--surface-raised` background, `--text-dim` text

### 6.2 Form Inputs

```css
.input {
  background: var(--surface);
  border: 1px solid var(--mist);
  border-radius: 8px;
  padding: 14px 16px;
  font-size: 16px;
  color: var(--text-primary);
  transition: border-color 0.2s, box-shadow 0.2s;
}
.input:hover {
  border-color: var(--fog);
}
.input:focus {
  border-color: var(--glow);
  outline: none;
  box-shadow:
    0 0 0 3px color-mix(in srgb, var(--glow) 10%, transparent),
    0 0 12px color-mix(in srgb, var(--glow) 8%, transparent);
}
.input::placeholder {
  color: var(--text-dim);
}
.input-error {
  border-color: var(--error);
  box-shadow: 0 0 8px color-mix(in srgb, var(--error) 15%, transparent);
}
```

**Input Rules:**
- Inputs sit on `--surface` (one step above canvas) — they're recessed, like physical controls
- Focus state: glow ring + subtle bloom
- Error state: red border with red glow (pulsing optional)
- Labels above inputs in `--text-secondary`, never inside
- Helper text in `--text-dim`, error text in `--error`
- Disabled inputs: `--canvas` background, `--text-dim` text, no border

### 6.3 Cards

```css
/* Standard card — raised surface */
.card {
  background: var(--surface-raised);
  border: 1px solid var(--mist);
  border-radius: 12px;
  padding: 28px;
  transition: border-color 0.25s, box-shadow 0.25s;
}

/* Hover glow (for clickable cards) */
.card-interactive:hover {
  border-color: color-mix(in srgb, var(--glow) 40%, var(--mist));
  box-shadow: 0 0 24px color-mix(in srgb, var(--glow) 8%, transparent);
}

/* Featured card — ambient glow background */
.card-featured {
  background:
    radial-gradient(
      ellipse at top,
      color-mix(in srgb, var(--glow) 8%, var(--surface-raised)),
      var(--surface-raised) 70%
    );
  border: 1px solid color-mix(in srgb, var(--glow) 20%, var(--mist));
}
```

**Card Rules:**
- Cards are `--surface-raised` — one brightness step above the canvas
- Never use bright backgrounds on cards — they should be barely distinguishable from canvas
- Clickable cards glow on hover (border + bloom)
- Featured/highlighted cards get a subtle radial gradient tinted with the glow color
- Border radius: 12px (slightly more rounded; sharp corners cut into the dark harshly)
- No drop shadows — use glow for elevation instead

### 6.4 Navigation

**Top Bar:**
```css
.navbar {
  background: color-mix(in srgb, var(--canvas) 80%, transparent);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--mist);
  height: 64px;
}
.nav-item {
  color: var(--text-dim);
  transition: color 0.15s;
}
.nav-item:hover {
  color: var(--text-primary);
}
.nav-item.active {
  color: var(--glow);
  text-shadow: 0 0 8px color-mix(in srgb, var(--glow) 25%, transparent);
}
```

**Navigation Rules:**
- Navbar uses `backdrop-filter: blur()` over transparent dark — content scrolls underneath
- Active nav items glow with the primary glow color
- Inactive items are dim; hover brightens them
- Mobile: slide-out panel from left/right with darkened backdrop, not fullscreen takeover
- Sidebar (if used): collapsible, 260px expanded, with glow indicator on active item

### 6.5 Tables

```css
.table th {
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-dim);
  padding: 12px 16px;
  border-bottom: 1px solid var(--fog);
}
.table td {
  padding: 16px;
  color: var(--text-secondary);
  border-bottom: 1px solid var(--mist);
}
.table tr:hover {
  background: var(--surface);
}
/* Highlight row */
.table tr.highlighted {
  background: color-mix(in srgb, var(--glow) 5%, var(--surface));
  border-left: 2px solid var(--glow);
}
```

---

## 7. Interaction Patterns

### 7.1 Animation Principles

- **Duration:** 200ms for micro-interactions, 350ms for transitions, 800ms-2s for ambient effects
- **Easing:** `cubic-bezier(0.25, 0.46, 0.45, 0.94)` for entrances (decelerating), `ease-out` for hover responses
- **Properties:** Prefer `opacity`, `transform`, `box-shadow`, and `filter` (GPU accelerated)
- **Ambient motion:** Slow, continuous, subtle. Glow pulses at 3-5s cycles. Color temperature drifts imperceptibly over minutes.

### 7.2 The Glow Response

Every interactive element follows the **glow response** pattern:

```
Resting → Hover → Active → Complete
  dim    → glow  → bright → flash + fade
```

| State | Visual Treatment | Duration |
|-------|-----------------|----------|
| Resting | Element at base luminosity | — |
| Hover | Glow halo appears around element | 200ms ease-out |
| Focus | Glow ring + bloom (accessibility) | 150ms |
| Active/Press | Brightness peaks, glow intensifies | 100ms |
| Complete | Brief flash, then settle to new state | 300ms |

### 7.3 Loading States

- **Skeleton screens** with a slow luminosity sweep (left-to-right shimmer in `--mist` → `--fog` → `--mist`)
- **Progress indicators** use the glow color as a filling bar with trailing bloom
- **Spinners:** Avoid. Use a pulsing glow dot or a breathing ring instead
- **Empty states:** Dim icon + dim text centered in the dark. The emptiness IS the communication

### 7.4 Feedback Patterns

- **Toast notifications:** Bottom-center, dark surface with colored left-border (success/error/warning glow), auto-dismiss 4s
- **Form validation:** Inline below field. Error text in `--error` with subtle glow
- **Success:** Brief green glow pulse on the triggering element
- **Alerts:** Glow border on the container (not background color change — that's too bright)

---

## 8. Atmospheric Effects

This section is unique to Nocturne. These effects create the living, breathing quality that distinguishes dark-native from dark-mode.

### 8.1 Ambient Glow

A subtle, always-present glow that gives the canvas life:

```css
/* Ambient glow behind primary content area */
.ambient-glow {
  position: fixed;
  width: 600px;
  height: 600px;
  border-radius: 50%;
  background: radial-gradient(
    circle,
    color-mix(in srgb, var(--glow) 4%, transparent),
    transparent 70%
  );
  pointer-events: none;
  z-index: 0;
  animation: drift 20s ease-in-out infinite alternate;
}

@keyframes drift {
  0% { transform: translate(-10%, -5%); }
  100% { transform: translate(10%, 5%); }
}

@media (prefers-reduced-motion: reduce) {
  .ambient-glow { animation: none; }
}
```

### 8.2 Cursor Proximity Glow

Elements subtly brighten as the cursor approaches, even before hover:

```css
/* Applied via JS: element tracks cursor distance */
/* 0 = cursor on element, 1 = cursor far away */
.proximity-glow {
  --proximity: 1;
  border-color: color-mix(
    in srgb,
    var(--glow) calc((1 - var(--proximity)) * 30%),
    var(--mist)
  );
}
```

Use sparingly. Best on cards in a grid or navigation items. Must have `prefers-reduced-motion` fallback (disable proximity effect, rely on standard `:hover`).

### 8.3 Depth Layers

Nocturne uses three depth layers, distinguished by brightness and blur:

```
┌────────────────────────────────────────────────────┐
│  Layer 3: FOREGROUND (modals, popovers, toasts)    │
│  Brightness: +16% from canvas                      │
│  Has: backdrop-filter blur, glow edges              │
├────────────────────────────────────────────────────┤
│  Layer 2: CONTENT (cards, widgets, controls)        │
│  Brightness: +8% from canvas                        │
│  Has: subtle border, optional glow on interact      │
├────────────────────────────────────────────────────┤
│  Layer 1: CANVAS (background, negative space)       │
│  Brightness: baseline (darkest)                     │
│  Has: ambient glow, texture (optional)              │
└────────────────────────────────────────────────────┘
```

**No shadows.** Depth is communicated by brightness stepping and backdrop blur, not by casting shadows downward. Shadows make no physical sense in a dark environment — there's nothing to cast them.

### 8.4 Temporal Awareness (Optional)

For products that benefit from time-of-day sensitivity, the glow color temperature can shift imperceptibly:

| Time | Glow Temperature | Reasoning |
|------|-----------------|-----------|
| 6am-12pm | Slightly cooler (+5% blue) | Morning alertness |
| 12pm-6pm | Neutral (baseline) | Midday standard |
| 6pm-12am | Slightly warmer (+5% orange) | Evening wind-down |
| 12am-6am | Baseline, reduced bloom | Late night; minimize eye strain |

Implement via CSS custom property update on a timer. The shift should be **imperceptible in the moment** — users should never notice a transition.

---

## 9. Data Visualization

Nocturne excels at data visualization. Dark canvases make colored data sing.

### 9.1 Chart Styling

```css
.chart {
  background: transparent; /* charts sit on canvas, no container */
}
.chart-grid-line {
  stroke: var(--mist);
  stroke-width: 0.5;
}
.chart-axis-label {
  fill: var(--text-dim);
  font-size: 11px;
}
.chart-data-primary {
  stroke: var(--glow);
  fill: none;
  stroke-width: 2;
  filter: drop-shadow(0 0 4px color-mix(in srgb, var(--glow) 40%, transparent));
}
```

**Chart Rules:**
- Data lines/bars use the glow color with a `drop-shadow` glow
- Secondary data series use `--text-dim` or a desaturated variant of glow
- Grid lines: nearly invisible (`--mist` at 50% opacity)
- No chart backgrounds or borders — data floats on the canvas
- Tooltips: `--surface-raised` with glow-colored left border

### 9.2 Metric Cards

```
┌──────────────────────────────────────┐
│  MONTHLY ACTIVE USERS                 │  ← Caption, --text-dim
│  1,234,567                            │  ← Display size, --text-bright
│  ● ↑ 12.3%                           │  ← Body small, --success with glow
│  ━━━━━━━━━━━━━━━━░░░░░░              │  ← Spark line in --glow
└──────────────────────────────────────┘
```

### 9.3 Real-Time Data

For live dashboards and monitoring:

- New data points animate in with a brief glow flash
- Threshold breaches pulse the metric in the relevant semantic color
- Stale data fades to lower luminosity automatically
- Use `--glow` for "healthy/normal" and semantic colors for anomalies

---

## 10. Accessibility Considerations

Dark-native design has unique accessibility challenges. Address all of them:

### 10.1 Contrast Requirements

WCAG 2.2 AA still applies. Verify these critical pairs:

| Foreground | Background | Min Ratio |
|------------|------------|-----------|
| `--text-secondary` (#8888A0) | `--canvas` (#0C0C10) | 4.5:1 ✓ (5.2:1) |
| `--text-primary` (#CDCDE0) | `--canvas` (#0C0C10) | 4.5:1 ✓ (11.4:1) |
| `--text-primary` (#CDCDE0) | `--surface` (#18181F) | 4.5:1 ✓ (9.1:1) |
| `--text-dim` (#5C5C72) | `--canvas` (#0C0C10) | 3:1 (for large text/UI) ✓ (3.4:1) |
| `--glow` (varies) | `--void` (#09090B) | 3:1 minimum for UI ✓ |

**Critical:** `--text-dim` (#5C5C72) on `--canvas` only passes 3:1 — acceptable for large text (18px+) and UI components, but NOT for body-size informational text. Use `--text-secondary` minimum for anything the user needs to read.

### 10.2 Glow and Motion

- ALL ambient motion (glow drift, proximity effects, temporal shifts) must respect `prefers-reduced-motion`
- Glow halos are decorative enhancement — remove them under reduced motion, keep solid borders
- Error pulsing: reduce to static glow under reduced motion
- The interface must be fully usable with zero animation

### 10.3 Focus Indicators

Focus indicators are MORE important in Nocturne because subtle borders disappear on dark backgrounds:

```css
:focus-visible {
  outline: 2px solid var(--glow);
  outline-offset: 2px;
  box-shadow: 0 0 8px color-mix(in srgb, var(--glow) 25%, transparent);
}

@media (prefers-reduced-motion: reduce) {
  :focus-visible {
    box-shadow: none; /* keep solid outline, remove glow */
  }
}
```

### 10.4 Screen Readers

- Glow states must have ARIA equivalents (e.g., `aria-current` for glowing nav items)
- Ambient effects are `aria-hidden="true"`
- Proximity glow is purely decorative; no information conveyed by cursor distance
- Live data updates use `aria-live` regions appropriately

### 10.5 Light Mode Alternative

If the product serves users who may need a light environment:

- Provide a "Daylight" mode as an **alternative theme**, not an inversion
- The daylight mode should be a separate design pass — NOT just flipping Nocturne colors
- Consider using Minimal Tech spec as the foundation for the light alternative
- Include a toggle that persists preference

---

## 11. Do's and Don'ts

### Do's

- Treat the dark canvas as the primary design element
- Use luminosity (brightness) to create hierarchy — brighter = more important
- Apply glow effects to interactive elements for feedback
- Give content generous spacing — dark layouts need more room to breathe
- Use the glow color consistently as the single accent
- Verify contrast ratios carefully (dark-on-dark failures are easy to miss)
- Respect `prefers-reduced-motion` for all ambient effects
- Use `backdrop-filter: blur()` for depth layering
- Make data visualization the star — dark canvases are perfect for it
- Test on OLED screens (true blacks) and LCD screens (backlight bleed) — they render very differently

### Don'ts

- Invert a light design and call it Nocturne
- Use pure white (#FFFFFF) for body text (use `--text-secondary`)
- Apply glow to everything — brightness is currency, spend wisely
- Create large areas of bright color (cards, backgrounds, panels)
- Use drop shadows for depth — use brightness stepping and blur
- Ignore the irradiation illusion (light text looks heavier on dark)
- Add texture/noise "to fill the dark" — trust the void
- Use thin hairline fonts below 16px — they vanish on dark backgrounds
- Mix warm and cool glow colors without intent (pick one temperature)
- Forget that some users work in brightly lit offices — provide a light alternative for critical workflows

---

## 12. Reference Sites

Study these for dark-native execution:

| Site | Notable Elements |
|------|------------------|
| linear.app (dark mode) | Glow interactions, depth layers, data density |
| figma.com (dark UI) | Canvas-as-material, luminosity hierarchy |
| ableton.com/live | Audio interface: dark-native, glow meters |
| github.com/features/copilot | Ambient glow, gradient atmosphere |
| spotify.com/design | Color on dark, data viz, media focus |
| Apple TV app | Dark-native media browser, luminosity |
| Teenage Engineering (OP-1 field) | Hardware-inspired dark UI, glow indicators |
| fl-studio.com | DAW dark-native, meter glow, depth layers |

---

## 13. Implementation Checklist

Before shipping, verify:

- [ ] Canvas color is near-black (not gray, not pure black)
- [ ] Luminosity hierarchy established: 5+ brightness steps from dim to bright
- [ ] Single glow color used consistently throughout
- [ ] Glow stack applied to primary CTA (crisp edge + inner halo + outer bloom)
- [ ] Body text uses `--text-secondary`, NOT white
- [ ] Font weight reduced by one step from light-native equivalent
- [ ] Card/component spacing is 25% more generous than light-native equivalent
- [ ] Depth via brightness stepping, NOT shadows
- [ ] All contrast ratios pass WCAG 2.2 AA
- [ ] Focus indicators clearly visible (glow ring + solid outline)
- [ ] All ambient motion respects `prefers-reduced-motion`
- [ ] Tested on OLED and LCD screens
- [ ] Glow elements have 16px minimum clearance from neighbors
- [ ] No large areas of bright fill (max bright area: button-sized)
- [ ] Error states use semantic glow, not just color change
- [ ] Light/daylight alternative available if users need it

---

*Version: 0.1.0*
*Last updated: 2026-03-14*
