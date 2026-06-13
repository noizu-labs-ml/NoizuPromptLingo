# Style Guide: Noizu Labs — noizu.com

> Dark-mode-first minimal tech aesthetic with gold accent, glassmorphism surfaces, and scroll-driven motion design.

**Style System:** Minimal Tech (dark) with Nocturne influence — 80% Minimal Tech / 20% Nocturne
**Scenario:** Personal brand site for fractional CTO / principal engineer consulting practice

---

## 00 — Header & Brand Identity

### Design Philosophy

**What this IS:**
- Dark, confident, technically sophisticated
- Restrained — gold accent used surgically, never gratuitously
- Motion as communication — parallax and scroll reveals that demonstrate technical craft
- Glass surfaces that create depth without visual clutter

**What this IS NOT:**
- Colorful, playful, or casual
- Decoration-heavy or illustration-driven
- Light mode (dark is the only mode)
- Flashy or attention-seeking — confidence is quiet

### Design Principles (ranked)

1. **Depth through subtlety** — Glassmorphism, parallax layers, and gold glow create dimension without heavy-handed 3D or shadows
2. **Gold is earned** — The brand accent appears only where it matters: CTAs, active states, section labels, gradient text on hero headlines
3. **Motion tells the story** — Scroll-triggered reveals, staggered fades, and parallax backgrounds reward engagement
4. **Technical credibility** — Monospace accents, clean grids, and precise spacing signal engineering quality
5. **Content over chrome** — Every decorative element (glass borders, glow effects) serves to frame content, never compete with it

### Brand Identity

| Attribute | Value |
|-----------|-------|
| **Intent** | Position Keith Brings as a senior technical leader |
| **Perception** | Confident, precise, modern, premium |
| **Audience** | CTOs, VPs of Engineering, startup founders seeking fractional leadership |
| **Tone** | Professional but not corporate; technically fluent; direct |
| **Keywords** | Performance, scale, leadership, architecture, reliability |

### Logo

- **Logomark:** Circular gold (#ffca02) background with white serif "N" cutout
- **Logotype:** "noizu" in Inter semibold + "Labs" suffix in gold-400
- **Clear space:** Minimum 1x logomark diameter on all sides
- **Minimum size:** 24px height for logomark, 120px width for full logo
- **Dark backgrounds only** — no light-mode variant currently defined

---

## 01 — Design Tokens

```css
:root {
  /* ── Surfaces ── */
  --bg-primary: #09090b;          /* zinc-950 */
  --bg-surface: rgba(255, 255, 255, 0.03);  /* glass base */
  --bg-surface-hover: rgba(255, 255, 255, 0.06);
  --bg-elevated: rgba(255, 255, 255, 0.05);

  /* ── Text ── */
  --text-primary: #f4f4f5;        /* zinc-100 */
  --text-secondary: #d4d4d8;      /* zinc-300 */
  --text-tertiary: #a1a1aa;       /* zinc-400 */
  --text-muted: #71717a;          /* zinc-500 */
  --text-inverse: #09090b;        /* zinc-950 — text on gold buttons */

  /* ── Brand / Accent ── */
  --gold-50: #fffbeb;
  --gold-100: #fff3c4;
  --gold-200: #fce588;
  --gold-300: #fad24b;
  --gold-400: #ffca02;            /* PRIMARY — logo color */
  --gold-500: #f0b400;
  --gold-600: #cc8a00;
  --gold-700: #a16207;
  --gold-800: #854d0e;
  --gold-900: #713f12;
  --gold-950: #422006;
  --amber-400: #fbbf24;
  --amber-500: #f59e0b;

  /* ── Borders ── */
  --border-subtle: rgba(255, 255, 255, 0.06);
  --border-hover: rgba(255, 202, 2, 0.1);   /* gold tint on hover */
  --border-active: rgba(255, 202, 2, 0.3);

  /* ── Semantic ── */
  --success: #4ade80;
  --warning: #facc15;
  --error: #f87171;
  --info: #60a5fa;

  /* ── Shadows / Glow ── */
  --glow-gold: 0 0 80px -20px rgba(255, 202, 2, 0.12);
  --glow-gold-strong: 0 0 120px -20px rgba(255, 202, 2, 0.2);
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.4);
  --shadow-lg: 0 8px 30px rgba(0, 0, 0, 0.5);

  /* ── Spacing (8px base) ── */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;
  --space-10: 40px;
  --space-12: 48px;
  --space-16: 64px;
  --space-20: 80px;
  --space-24: 96px;
  --space-28: 112px;

  /* ── Radii ── */
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-2xl: 24px;

  /* ── Transitions ── */
  --duration-fast: 150ms;
  --duration-normal: 300ms;
  --duration-slow: 500ms;
  --duration-reveal: 600ms;
  --ease-out: cubic-bezier(0.0, 0.0, 0.2, 1);
  --ease-in: cubic-bezier(0.4, 0.0, 1, 1);
  --ease-in-out: cubic-bezier(0.4, 0.0, 0.2, 1);

  /* ── Typography ── */
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', 'Monaco', monospace;

  /* ── Selection ── */
  --selection-bg: rgba(255, 202, 2, 0.3);
  --selection-text: #ffffff;

  /* ── Glass ── */
  --glass-bg: rgba(255, 255, 255, 0.03);
  --glass-border: rgba(255, 255, 255, 0.06);
  --glass-blur: 24px;
}
```

---

## 02 — Color Palette

### Primary Palette

| Name | Hex | Use |
|------|-----|-----|
| **Background** | `#09090b` (zinc-950) | Page background — 85%+ of visual field |
| **Gold 400** | `#ffca02` | Primary accent: CTAs, section labels, logo, active states |
| **Gold 300** | `#fad24b` | Hover state for gold elements, gradient midpoint |
| **Amber 400** | `#fbbf24` | Gradient endpoint for `.gradient-text` |
| **White** | `#ffffff` | Headings, emphasis text |
| **Zinc 100** | `#f4f4f5` | Body text |
| **Zinc 300** | `#d4d4d8` | Secondary body text, descriptions |
| **Zinc 400** | `#a1a1aa` | Tertiary text, metadata |

### Surface Colors

| Name | Value | Use |
|------|-------|-----|
| **Glass base** | `white/3%` | Card backgrounds, navbar |
| **Glass hover** | `white/6%` | Hover state for glass surfaces |
| **Glass border** | `white/6%` | Subtle borders on glass elements |
| **Gold border** | `gold-400/10%` | Border hover accent |

### Contrast Verification

| Foreground | Background | Ratio | WCAG AA |
|------------|------------|-------|---------|
| zinc-100 (#f4f4f5) | zinc-950 (#09090b) | 18.1:1 | Pass |
| zinc-300 (#d4d4d8) | zinc-950 (#09090b) | 12.6:1 | Pass |
| zinc-400 (#a1a1aa) | zinc-950 (#09090b) | 7.4:1 | Pass |
| gold-400 (#ffca02) | zinc-950 (#09090b) | 11.8:1 | Pass |
| zinc-950 (#09090b) | gold-400 (#ffca02) | 11.8:1 | Pass (button text) |

### Usage Rules

- Background (zinc-950) dominates — 85%+ of visual field
- Gold-400 is reserved for: primary CTAs, section labels, `.gradient-text`, logo accent, active nav states, tag borders
- Never use gold as a large-area background
- Glass surfaces create depth hierarchy without competing with content
- The gradient-text effect (gold-400 → gold-300 → amber-400) is reserved for hero headlines only

---

## 03 — Typography

### Font Stack

```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', 'Monaco', monospace;
```

### Type Scale

| Level | Size | Weight | Line Height | Letter Spacing | Use |
|-------|------|--------|-------------|----------------|-----|
| Display | 72px (7xl) | 700 | 1.1 | -0.02em | Hero headline (mobile: 48px/5xl) |
| H1 | 36-48px (4xl) | 700 | 1.2 | -0.01em | Page titles |
| H2 | 30-36px (3xl-4xl) | 700 | 1.2 | 0 | Section headings |
| H3 | 18px (lg) | 600 | 1.4 | 0 | Card titles, subsections |
| H4 | 16px (base) | 600 | 1.5 | 0 | Sub-subsections |
| Section Label | 14px (sm) | 500 | 1.5 | 0.05em | Uppercase gold labels above sections |
| Body | 16px (base) | 400 | 1.6 | 0 | Primary content |
| Body Large | 20-24px (xl-2xl) | 400 | 1.6 | 0 | Hero subtitle |
| Body Small | 14-15px (sm) | 400 | 1.5-1.6 | 0 | Card descriptions, testimonials |
| Caption | 12px (xs) | 400 | 1.4 | 0 | Metadata, timestamps |
| Code | 14px (sm) | 400 (mono) | 1.5 | 0 | Code snippets, technical content |
| Tag | 12px (xs) | 400 | 1 | 0 | Pill tags on cards |

### Font Sources

| Font | Source | License | Link |
|------|--------|---------|------|
| Inter | Google Fonts | OFL | fonts.google.com/specimen/Inter |
| JetBrains Mono | Google Fonts | OFL | fonts.google.com/specimen/JetBrains+Mono |

### Typography Rules

- Only weights used: 400 (regular), 500 (medium), 600 (semibold), 700 (bold)
- Bold (700) only on headings — never on body text
- Section labels: uppercase, tracking-wider, gold-400, font-medium
- `-webkit-font-smoothing: antialiased` globally for crisp rendering on dark backgrounds
- Gradient text (`.gradient-text`) uses `bg-clip-text` and is reserved for hero keywords

---

## 04 — Spacing & Layout

### Spacing Scale (8px base)

```
4px   (space-1)  — Icon padding, tight groups
8px   (space-2)  — Related inline elements
12px  (space-3)  — Input padding, small gaps
16px  (space-4)  — Standard gap, grid gutters
24px  (space-6)  — Card padding, component spacing
32px  (space-8)  — Between component groups
48px  (space-12) — Section internal padding
64px  (space-16) — Between major sections (mobile)
80px  (space-20) — Section vertical padding (py-20)
112px (space-28) — Section vertical padding desktop (sm:py-28)
```

### Component Spacing

| Component | Padding | Gap | Notes |
|-----------|---------|-----|-------|
| Navbar | px-6, h-16 | gap-1 (nav links) | Fixed, glass, rounded-2xl |
| Section | py-20 / sm:py-28 | — | Consistent vertical rhythm |
| Container | px-6 / lg:px-8 | — | max-w-7xl (1280px) centered |
| Card (glass) | p-6 (24px) | — | rounded-2xl |
| Button (primary) | px-6 py-3 | — | rounded-xl |
| Button (nav) | px-4 py-2 | — | rounded-lg |
| Tag pill | px-2.5 py-1 | — | rounded-full |
| Service icon box | w-10 h-10 | — | rounded-xl |
| CTA section | px-8 py-16 / sm:px-16 sm:py-24 | — | rounded-3xl, glass + glow |

### Grid System

| Breakpoint | Columns | Gutter | Container Padding | Max Width |
|------------|---------|--------|-------------------|-----------|
| Default (mobile) | 1 | 16px (gap-4) | 24px (px-6) | 100% |
| md (768px) | 2 | 16px | 24px | 100% |
| lg (1024px) | 3-4 | 16px | 32px (lg:px-8) | 1280px |

### Layout Patterns

- **Services grid:** 1 col → 2 col (md) → 4 col (lg)
- **Featured projects:** 1 col → 2 col (md)
- **Testimonials:** 1 col → 2 col (md) → 3 col (lg)
- **Hero:** Single column, max-w-3xl, left-aligned
- **CTA section:** Centered text, glass + glow wrapper, rounded-3xl

---

## 05 — Buttons

### Primary Button

```css
.btn-primary {
  padding: 12px 24px;             /* px-6 py-3 */
  background: var(--gold-400);    /* #ffca02 */
  color: var(--text-inverse);     /* zinc-950 */
  font-size: 14px;                /* text-sm */
  font-weight: 500;               /* font-medium */
  border-radius: var(--radius-lg); /* rounded-xl */
  border: none;
  transition: background-color var(--duration-fast);
}
.btn-primary:hover {
  background: var(--gold-300);    /* #fad24b */
}
```

### Secondary Button (Glass)

```css
.btn-secondary {
  padding: 12px 24px;
  background: var(--glass-bg);
  color: #ffffff;
  font-size: 14px;
  font-weight: 500;
  border-radius: var(--radius-lg);
  border: 1px solid var(--glass-border);
  backdrop-filter: blur(var(--glass-blur));
  transition: all var(--duration-normal);
}
.btn-secondary:hover {
  background: var(--bg-surface-hover);
  border-color: var(--border-hover);
}
```

### Ghost Button (Nav)

```css
.btn-ghost {
  padding: 8px 16px;             /* px-4 py-2 */
  background: transparent;
  color: var(--text-secondary);   /* zinc-300 */
  font-size: 14px;
  border: none;
  border-radius: var(--radius-md); /* rounded-lg */
  transition: color var(--duration-fast), background-color var(--duration-fast);
}
.btn-ghost:hover {
  color: #ffffff;
  background: rgba(255, 255, 255, 0.05);
}
```

### Button Usage Rules

- Primary (gold) for main CTAs only — max 1-2 per viewport
- Secondary (glass) for supporting actions
- Ghost for navigation and tertiary actions
- No shadows on buttons
- No gradient backgrounds on buttons
- Icon + text spacing: 8px (gap-2)
- Sizes: sm (px-4 py-2), md (px-6 py-3), lg (px-8 py-4)

---

## 06 — Input Fields

### Text Input

```css
.input {
  background: transparent;
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-md);
  padding: 12px 16px;
  font-size: 16px;
  color: var(--text-primary);
  transition: border-color var(--duration-fast);
}
.input:focus {
  border-color: var(--gold-400);
  outline: none;
  box-shadow: 0 0 0 3px rgba(255, 202, 2, 0.1);
}
.input::placeholder {
  color: var(--text-muted);
}
.input.error {
  border-color: var(--error);
}
```

### Input Rules

- Labels above inputs, zinc-300, text-sm, font-medium
- Helper text below in text-xs, zinc-400
- Error text in text-xs, error color
- Focus ring: gold-400 border + gold/10% shadow
- Consistent 6px border-radius with buttons

---

## 07 — Navigation

### Fixed Navbar (Glass)

- **Position:** Fixed top, full width, z-50
- **Container:** max-w-7xl centered, mt-2 offset
- **Surface:** Glass (white/3% bg, white/6% border, backdrop-blur-xl)
- **Shape:** rounded-2xl, h-16, px-6
- **Logo:** Left — logomark (32px) + "noizu" text + "Labs" gold suffix
- **Desktop nav:** Right — ghost links (max 6 items) + primary CTA button
- **Mobile nav:** Hamburger toggle → dropdown glass panel with AnimatePresence
- **Mobile menu animation:** fade + slide-up (-10px), Framer Motion

### Navigation States

| State | Style |
|-------|-------|
| Default | text-zinc-300 |
| Hover | text-white, bg-white/5% |
| Active/Current | text-white (or gold-400 for emphasis) |
| CTA | bg-gold-400, text-zinc-950, font-medium |

---

## 08 — Status Indicators

| State | Color | Use |
|-------|-------|-----|
| Success | `#4ade80` (green-400) | Completed actions |
| Warning | `#facc15` (yellow-400) | Caution states |
| Error | `#f87171` (red-400) | Failed actions, validation |
| Info | `#60a5fa` (blue-400) | Informational notices |
| Active/Online | `var(--gold-400)` | Active items, online status |

---

## 09 — Cards

### Glass Card

```css
.card {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-xl);   /* rounded-2xl = 16px */
  padding: var(--space-6);           /* 24px */
  backdrop-filter: blur(var(--glass-blur));
}
```

### Interactive Card (Project/Link Cards)

```css
.card-interactive {
  /* extends .card */
  transition: background-color var(--duration-normal),
              border-color var(--duration-normal);
}
.card-interactive:hover {
  background: var(--bg-surface-hover);
  border-color: var(--border-hover);
}
.card-interactive:hover .card-title {
  color: var(--gold-400);
}
.card-interactive:hover .card-icon {
  color: var(--gold-400);
}
```

### CTA Card (Glow)

```css
.card-cta {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-2xl);  /* rounded-3xl */
  backdrop-filter: blur(var(--glass-blur));
  box-shadow: var(--glow-gold);
  text-align: center;
}
```

### Testimonial Card

- Glass background, rounded-2xl
- Quote icon: w-8 h-8, gold-500/30% opacity
- Body text: 15px, zinc-300, relaxed line-height
- Attribution: border-t white/6%, name in white semibold, title in zinc-400 xs

### Card Grid Behavior

| Context | Mobile | Tablet (md) | Desktop (lg) |
|---------|--------|-------------|---------------|
| Services | 1 col | 2 col | 4 col |
| Projects | 1 col | 2 col | 2 col |
| Testimonials | 1 col | 2 col | 3 col |
| Gap | 16px | 16px | 16px |

---

## 10 — Core Component Reference

### Tag / Pill

```css
.tag {
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 9999px;          /* rounded-full */
  background: rgba(240, 180, 0, 0.1);   /* gold-500/10 */
  color: var(--gold-400);
  border: 1px solid rgba(240, 180, 0, 0.2); /* gold-500/20 */
}
```

### Section Label

```css
.section-label {
  font-size: 14px;
  font-weight: 500;
  color: var(--gold-400);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 8px;
}
```

### Icon Container

```css
.icon-box {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-lg);
  background: rgba(204, 138, 0, 0.1);   /* gold-600/10 */
  border: 1px solid rgba(240, 180, 0, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--gold-400);
}
```

### Gradient Text

```css
.gradient-text {
  background: linear-gradient(to right, var(--gold-400), var(--gold-300), var(--amber-400));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
```

### Glass Utility

```css
.glass {
  background: rgba(255, 255, 255, 0.03);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255, 255, 255, 0.06);
}
```

---

## 11 — Project Components

### Service Card

- Glass card with icon-box (gold), title (white, semibold), bullet list (zinc-300/80, gold dots)
- No hover effect (non-interactive)
- Full height within grid

### Project Card (Interactive)

- Glass card with hover → gold title + gold arrow icon
- Title row: title left, external-link arrow right
- Description: text-sm, zinc-300
- Tags row: flex-wrap pill tags
- Full card is an anchor (`<a>`) with `group` hover behavior

### Testimonial Card

- Glass card, flex column, full height
- Quote SVG icon (w-8, gold-500/30)
- Feedback text (15px, zinc-300, relaxed, flex-1 to push attribution down)
- Attribution: border-t divider, name (white, semibold, sm), title (zinc-400, xs)

### Contact CTA Block

- Glass + glow (gold box-shadow), rounded-3xl
- Centered content: heading, description, two buttons (primary + secondary w/ GitHub icon)
- Extra generous padding: py-16/24, px-8/16

---

## 12 — Screens

### Home Page (Primary Screen)

**Sections in order:**

1. **Hero** — Large heading with `.gradient-text` keywords, subtitle, two CTAs. `pt-32 sm:pt-44` to clear fixed navbar. FadeIn on viewport entry.

2. **Featured Projects** — Section label (gold, uppercase) + heading + "View all" link. 2-col grid of interactive project cards. FadeInStagger with 100ms delay between items.

3. **Services** — Section label + heading + description. 4-col grid of service cards. FadeInStagger.

4. **Testimonials** — Centered section label + heading. 3-col grid of testimonial cards. FadeInStagger.

5. **Contact CTA** — Glass + glow card, centered heading + description + two buttons.

**Stock art:** None needed — this is a text/content-driven site. The visual interest comes from glass surfaces, gold accents, and motion.

### Projects Page (Secondary Screen)

- Categorized project listing with tag filtering
- Same card pattern as featured projects
- Grid layout: 1 → 2 → 3 columns

### Empty/Error State

- Centered message on zinc-950 background
- Icon or illustration in zinc-600
- Heading in white, description in zinc-400
- Single primary CTA to navigate back

---

## Interaction & Motion

### Animation Components (Framer Motion)

| Component | Effect | Duration | Easing | Trigger |
|-----------|--------|----------|--------|---------|
| `FadeIn` | opacity 0→1, y 20→0 | 500ms | easeOut | Viewport entry (once, -50px margin) |
| `FadeInStagger` | Container for staggered children | — | — | Viewport entry (once) |
| `FadeInItem` | opacity 0→1, y 20→0 | 500ms | easeOut | Parent stagger (100ms delay) |
| `ParallaxSection` | Background y: -8% → 8% | Scroll-driven | Linear | Continuous scroll |
| `FloatingOrb` | Scale 0.85→1.05→0.9 + y offset | Scroll-driven | Linear | Continuous scroll |
| `GradientCard` | Radial gradient spotlight sweep R→L | Scroll-driven | Linear | Viewport presence |
| `GradientBanner` | Wide radial gradient sweep R→L | Scroll-driven | Linear | Viewport presence |

### CSS Animations

| Animation | Duration | Easing | Use |
|-----------|----------|--------|-----|
| `fade-in` | 600ms | ease-out | Initial element reveals |
| `slide-up` | 600ms | ease-out | Staggered content entry (opacity + translateY) |

### Hover Interactions

| Element | Effect | Duration |
|---------|--------|----------|
| Primary button | bg gold-400 → gold-300 | 150ms |
| Glass card | bg white/3% → white/6%, border → gold/10% | 300ms |
| Nav link | text zinc-300 → white, bg → white/5% | 150ms |
| Project card title | text white → gold-400 | 150ms |
| External link icon | text zinc-600 → gold-400 | 150ms |
| Logo | scale transition | 300ms |

### Scroll Effects (Extended — New Features)

#### Parallax Layers
- **Hero background:** Subtle gradient orb moving at 0.3x scroll speed
- **Section backgrounds:** ParallaxSection with ±8% y-offset
- **Floating elements:** Scale + position shift tied to scroll progress

#### Scroll-Snap Sections (New)
```css
.snap-container {
  scroll-snap-type: y mandatory;
  overflow-y: scroll;
  height: 100vh;
}
.snap-section {
  scroll-snap-align: start;
  min-height: 100vh;
}
```
- Use for full-screen showcase sections (portfolio pieces, case studies)
- Each section snaps into place as user scrolls

#### Sticky Section Headers (New)
```css
.sticky-header {
  position: sticky;
  top: 80px;            /* below navbar */
  z-index: 10;
  background: rgba(9, 9, 11, 0.8);
  backdrop-filter: blur(12px);
}
```

#### Scroll-Triggered Number Counter (New)
- Metrics/stats animate from 0 to value when entering viewport
- Duration: 1.5-2s, easeOut curve
- Use for: years of experience, projects completed, team members mentored

#### Horizontal Scroll Gallery (New)
```css
.horizontal-scroll {
  display: flex;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  gap: 16px;
  padding: 16px;
  scrollbar-width: none;
}
.horizontal-scroll > * {
  scroll-snap-align: start;
  flex-shrink: 0;
}
```

### Page Transitions (New)
- Cross-fade between pages: 300ms opacity transition
- Content slides up 20px on entry
- Use Next.js layout transitions or Framer Motion `AnimatePresence`

### `prefers-reduced-motion` Handling

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

All Framer Motion components should check `useReducedMotion()` and disable transforms when true.

---

## Asset Guidelines

### Photography Style

Not currently used. If added:
- **Hero backgrounds:** Abstract, dark, high-contrast. "Dark abstract technology background with subtle gold light traces, shallow depth of field, 16:9"
- **Team/About:** "Professional headshot, dark background, warm side lighting, shallow DOF, 1:1 square crop"
- **Case studies:** "Overhead view of laptop showing dashboard UI, dark desk, warm ambient lighting, 3:2"

### Iconography

- **Style:** Outline (Heroicons 24x24, strokeWidth 1.5)
- **Color:** `currentColor` inherited from parent
- **Sizes:** w-5 h-5 (inline), w-6 h-6 (card icons), w-8 h-8 (decorative)
- **Source:** Heroicons (heroicons.com) — MIT license
- **Custom SVGs:** GitHub logo, quote mark — inline

### Gradient Effects

| Effect | Gradient | Use |
|--------|----------|-----|
| `.gradient-text` | `to right: gold-400 → gold-300 → amber-400` | Hero keywords only |
| `GradientCard` spotlight | Radial: `rgba(234,120,30,0.22)` → `rgba(255,202,2,0.06)` | Featured sections |
| `GradientBanner` | Radial: `rgba(234,120,30,0.30)` → `rgba(255,170,2,0.12)` | Section backgrounds |
| Selection | `gold-400/30%` background, white text | Global text selection |
| Glow | `0 0 80px -20px rgba(255,202,2,0.12)` | CTA card halo |

---

## Mixing Notes (Minimal Tech 80% + Nocturne 20%)

The site is primarily Minimal Tech (single typeface, restrained palette, technical credibility) with these Nocturne-influenced elements:

1. **Dark-only mode** — No light mode. The zinc-950 background creates the immersive, focused atmosphere characteristic of Nocturne.

2. **Glassmorphism surfaces** — The `backdrop-blur-xl` glass effect with ultra-subtle borders adds the layered depth and atmospheric quality of Nocturne, beyond what standard Minimal Tech specifies.

3. **Gold glow effects** — The `box-shadow: 0 0 80px` glow on CTA cards and the gradient spotlight sweeps bring a Nocturne-style ambient luminance. Standard Minimal Tech would avoid glow entirely.

4. **Scroll-driven gradient animations** — The `GradientCard` and `GradientBanner` components with their sweeping warm spotlights add atmospheric depth that's more Nocturne than Minimal Tech.

**What was considered and rejected:**
- Multiple accent colors (conflicts with single-accent Minimal Tech rule)
- Sound or haptic feedback (outside scope)
- Raster-based interactive elements (prefer SVG/D3 for resolution independence and scroll-driven control)

---

## Interactive Element Technology Preference

**Prefer SVG/D3.js** over raster images or canvas for all interactive and animated elements:

| Use Case | Technology | Rationale |
|----------|-----------|-----------|
| Parallax background layers | **Raster photos** (WebP) | Photos need raster; apply CSS filters for color grading |
| Circuit traces, node networks | **Inline SVG** | Resolution-independent, stroke-dashoffset draw-on, Framer Motion compatible |
| Architecture diagrams | **SVG + D3.js** | Dynamic layout, zoom/pan, scroll-driven state transitions |
| Constellation patterns | **Inline SVG** | Lightweight, animatable per-element, no canvas overhead |
| Data visualizations | **D3.js** | Scroll-driven transitions, responsive, accessible |
| Particle effects | **SVG or D3.js** | Prefer over canvas for <100 particles; better compositing with DOM |
| Interactive node graphs | **D3.js force layout** | Physics-based positioning, drag interaction, gold-themed |
| Blueprint grid lines | **SVG pattern** | Tileable, crisp at any zoom, animatable |
| Scroll progress bar | **SVG rect** or CSS | Simple, GPU-accelerated |
| Logo animations | **Inline SVG + CSS** | Path animation, morph transitions |

**Why SVG/D3 over Canvas:**
- Composites naturally with DOM layers (backdrop-blur, z-indexing)
- Each element is individually addressable for Framer Motion animation
- Resolution-independent (retina-safe without 2x assets)
- Accessible (elements can have ARIA labels, are in the DOM)
- Smaller payload than equivalent raster images
- CSS transitions/filters apply directly

**When to use raster photos:**
- Photographic backgrounds (fiber optics, circuit boards, workspace shots)
- Texture overlays (noise, paper grain)
- Complex photographic content that can't be reproduced in vector

**D3.js integration with Next.js:**
```typescript
// Use D3 for layout/math, React for rendering
import * as d3 from 'd3';

function NetworkGraph({ nodes, links }) {
  const simulation = d3.forceSimulation(nodes)
    .force("link", d3.forceLink(links).distance(100))
    .force("charge", d3.forceManyBody().strength(-200))
    .force("center", d3.forceCenter(width / 2, height / 2));

  // Render with React SVG elements, not D3 DOM manipulation
  return (
    <svg viewBox={`0 0 ${width} ${height}`}>
      {links.map(link => (
        <line key={link.id}
          x1={link.source.x} y1={link.source.y}
          x2={link.target.x} y2={link.target.y}
          stroke="rgba(255,202,2,0.08)" strokeWidth="1" />
      ))}
      {nodes.map(node => (
        <circle key={node.id}
          cx={node.x} cy={node.y} r={node.r}
          fill="rgba(255,202,2,0.12)" />
      ))}
    </svg>
  );
}
```

---

## Extended Features — New Interactive Elements

### 1. Magnetic Cursor Effect (Buttons)

Primary CTA buttons subtly attract toward the cursor when within 50px proximity.

```typescript
// Framer Motion magnetic effect
const magneticRef = useRef<HTMLButtonElement>(null);

const handleMouseMove = (e: MouseEvent) => {
  const btn = magneticRef.current;
  if (!btn) return;
  const rect = btn.getBoundingClientRect();
  const x = e.clientX - rect.left - rect.width / 2;
  const y = e.clientY - rect.top - rect.height / 2;
  btn.style.transform = `translate(${x * 0.15}px, ${y * 0.15}px)`;
};

const handleMouseLeave = () => {
  magneticRef.current!.style.transform = 'translate(0, 0)';
};
```

- **Strength:** 0.15 (subtle pull, not jarring)
- **Reset:** Smooth transition back on mouse leave
- **Reduced motion:** Disabled entirely

### 2. Text Reveal Animation (Headlines)

Section headings reveal word-by-word or character-by-character on scroll entry.

```typescript
// Split text into words, animate each with staggered delay
const words = text.split(' ');
// Each word: opacity 0→1, y 20→0, stagger 50ms
```

- **Trigger:** Viewport entry (once)
- **Stagger:** 50ms per word
- **Duration:** 400ms per word
- **Reduced motion:** Instant reveal, no transform

### 3. Tilt/3D Card Effect

Project cards tilt subtly toward cursor position on hover, creating a 3D depth effect.

```css
.card-tilt {
  transform-style: preserve-3d;
  perspective: 1000px;
  transition: transform 300ms ease-out;
}
/* JS sets: rotateX(Ydeg) rotateY(Xdeg) based on cursor position */
/* Max tilt: ±5 degrees */
```

- **Max tilt:** 5 degrees (subtle, not nauseating)
- **Shine overlay:** Subtle light reflection follows cursor
- **Reduced motion:** No tilt, standard hover only

### 4. Scroll Progress Indicator

Thin gold progress bar at the top of the viewport showing scroll position.

```css
.scroll-progress {
  position: fixed;
  top: 0;
  left: 0;
  height: 2px;
  background: var(--gold-400);
  z-index: 100;
  transform-origin: left;
  /* width set by JS: scrollY / (docHeight - viewportHeight) * 100% */
}
```

### 5. Typed Text Effect (Hero)

Hero subtitle types out character by character on first load.

- **Speed:** 30ms per character
- **Start delay:** 800ms (after hero title has faded in)
- **Cursor:** Blinking gold pipe character
- **Reduced motion:** Full text visible immediately, no typing

### 6. Particle/Node Background (Hero Only)

Subtle interconnected nodes floating behind the hero section.

- **Node count:** 30-50 (performance-safe)
- **Node color:** gold-400 at 10-20% opacity
- **Line color:** gold-400 at 5% opacity
- **Connection distance:** 150px
- **Animation:** Slow drift, 0.2-0.5px/frame
- **Mouse interaction:** Nodes gently repel from cursor
- **Canvas size:** Hero section bounds only (not full page)
- **Reduced motion:** Static node positions, no animation

### 7. Smooth Section Transitions

Sections fade and slide as they enter the viewport, with alternating directions.

```typescript
// Odd sections: slide from left
// Even sections: slide from right
const direction = index % 2 === 0 ? -30 : 30;
// x: direction → 0, opacity: 0 → 1
```

### 8. Image/Card Hover Parallax

On glass cards, the background gradient shifts based on mouse position within the card, creating a dynamic light source effect.

```typescript
const handleMouseMove = (e: React.MouseEvent) => {
  const rect = e.currentTarget.getBoundingClientRect();
  const x = ((e.clientX - rect.left) / rect.width) * 100;
  const y = ((e.clientY - rect.top) / rect.height) * 100;
  e.currentTarget.style.setProperty('--mouse-x', `${x}%`);
  e.currentTarget.style.setProperty('--mouse-y', `${y}%`);
};
```

```css
.card-hover-light::before {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(
    circle at var(--mouse-x, 50%) var(--mouse-y, 50%),
    rgba(255, 202, 2, 0.06) 0%,
    transparent 60%
  );
  pointer-events: none;
  opacity: 0;
  transition: opacity 300ms;
}
.card-hover-light:hover::before {
  opacity: 1;
}
```

---

## SVG Parallax System

Multi-layer SVG illustrations that move at different scroll speeds to create depth. Each layer is an inline SVG positioned absolutely within a section container, animated via Framer Motion `useTransform`.

### Layer Architecture

```
┌─────────────────────────────────────────────────────┐
│  PARALLAX LAYER STACK (back to front)                │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Layer 0 — Background gradient      speed: 0x        │
│  Layer 1 — Deep SVG elements        speed: 0.15x     │
│  Layer 2 — Mid SVG elements         speed: 0.3x      │
│  Layer 3 — Near SVG elements        speed: 0.5x      │
│  Layer 4 — Content (text, cards)    speed: 1x         │
│  Layer 5 — Foreground SVG overlay   speed: 1.2x       │
│                                                      │
│  speed = translateY multiplier relative to scroll     │
└─────────────────────────────────────────────────────┘
```

### Hero Section — Circuit Network SVG

Five-layer parallax scene behind the hero headline. Abstract circuit/node patterns in gold on dark.

```typescript
// Hero parallax layers
function HeroParallax() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  });

  // Each layer moves at a different rate
  const y1 = useTransform(scrollYProgress, [0, 1], ["0%", "15%"]);   // deep/slow
  const y2 = useTransform(scrollYProgress, [0, 1], ["0%", "30%"]);   // mid
  const y3 = useTransform(scrollYProgress, [0, 1], ["0%", "50%"]);   // near
  const opacity = useTransform(scrollYProgress, [0, 0.8], [1, 0]);   // fade out

  return (
    <div ref={ref} className="absolute inset-0 overflow-hidden">
      {/* Layer 1: Deep grid lines */}
      <motion.div style={{ y: y1, opacity }} className="absolute inset-0">
        <HeroGridSVG />
      </motion.div>
      {/* Layer 2: Mid circuit traces */}
      <motion.div style={{ y: y2, opacity }} className="absolute inset-0">
        <HeroCircuitSVG />
      </motion.div>
      {/* Layer 3: Near floating nodes */}
      <motion.div style={{ y: y3, opacity }} className="absolute inset-0">
        <HeroNodesSVG />
      </motion.div>
    </div>
  );
}
```

#### Layer 1 — Deep Grid (speed: 0.15x)

```svg
<!-- Faint perspective grid lines receding into distance -->
<svg viewBox="0 0 1440 800" fill="none" xmlns="http://www.w3.org/2000/svg"
     class="w-full h-full" preserveAspectRatio="xMidYMid slice">
  <!-- Horizontal grid lines, fading with depth -->
  <line x1="0" y1="200" x2="1440" y2="200" stroke="rgba(255,202,2,0.03)" stroke-width="1"/>
  <line x1="0" y1="400" x2="1440" y2="400" stroke="rgba(255,202,2,0.05)" stroke-width="1"/>
  <line x1="0" y1="600" x2="1440" y2="600" stroke="rgba(255,202,2,0.04)" stroke-width="1"/>
  <!-- Vertical grid lines -->
  <line x1="360" y1="0" x2="360" y2="800" stroke="rgba(255,202,2,0.02)" stroke-width="1"/>
  <line x1="720" y1="0" x2="720" y2="800" stroke="rgba(255,202,2,0.03)" stroke-width="1"/>
  <line x1="1080" y1="0" x2="1080" y2="800" stroke="rgba(255,202,2,0.02)" stroke-width="1"/>
  <!-- Intersection dots -->
  <circle cx="720" cy="400" r="3" fill="rgba(255,202,2,0.08)"/>
  <circle cx="360" cy="200" r="2" fill="rgba(255,202,2,0.05)"/>
  <circle cx="1080" cy="600" r="2" fill="rgba(255,202,2,0.05)"/>
</svg>
```

**Style rules:** stroke-only, gold at 2-5% opacity, no fills except node dots at 5-8%

#### Layer 2 — Circuit Traces (speed: 0.3x)

```svg
<!-- Abstract circuit board traces connecting key points -->
<svg viewBox="0 0 1440 800" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Right-angle circuit paths -->
  <path d="M200 100 L200 300 L500 300 L500 500"
        stroke="rgba(255,202,2,0.06)" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M800 150 L800 350 L1100 350 L1100 450 L1250 450"
        stroke="rgba(255,202,2,0.08)" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Connection nodes at endpoints -->
  <circle cx="500" cy="500" r="4" fill="rgba(255,202,2,0.1)"/>
  <circle cx="1250" cy="450" r="4" fill="rgba(255,202,2,0.1)"/>
  <!-- Small component rectangles along traces -->
  <rect x="195" y="195" width="10" height="6" rx="1" fill="rgba(255,202,2,0.06)"/>
  <rect x="795" y="245" width="10" height="6" rx="1" fill="rgba(255,202,2,0.06)"/>
</svg>
```

**Style rules:** right-angle paths (circuit-board aesthetic), stroke 1-2px, gold at 6-10% opacity, rounded caps

#### Layer 3 — Floating Nodes (speed: 0.5x)

```svg
<!-- Prominent nodes with connection lines, closest to viewer -->
<svg viewBox="0 0 1440 800" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Node cluster — upper right -->
  <circle cx="950" cy="180" r="6" fill="rgba(255,202,2,0.15)"/>
  <circle cx="1050" cy="220" r="4" fill="rgba(255,202,2,0.12)"/>
  <circle cx="1000" cy="280" r="5" fill="rgba(255,202,2,0.1)"/>
  <line x1="950" y1="180" x2="1050" y2="220" stroke="rgba(255,202,2,0.08)" stroke-width="1"/>
  <line x1="1050" y1="220" x2="1000" y2="280" stroke="rgba(255,202,2,0.06)" stroke-width="1"/>

  <!-- Node cluster — lower left -->
  <circle cx="300" cy="550" r="5" fill="rgba(255,202,2,0.12)"/>
  <circle cx="200" cy="600" r="3" fill="rgba(255,202,2,0.08)"/>
  <line x1="300" y1="550" x2="200" y2="600" stroke="rgba(255,202,2,0.06)" stroke-width="1"/>

  <!-- Pulsing ring on primary node (CSS animation) -->
  <circle cx="950" cy="180" r="12" stroke="rgba(255,202,2,0.1)" stroke-width="1" fill="none">
    <animate attributeName="r" values="12;20;12" dur="4s" repeatCount="indefinite"/>
    <animate attributeName="opacity" values="0.1;0;0.1" dur="4s" repeatCount="indefinite"/>
  </circle>
</svg>
```

**Style rules:** filled circles 3-8px, gold at 8-15% opacity, connecting lines at 6-8%, optional pulse animation on 1-2 key nodes

### Services Section — Topology Map SVG

Abstract network topology behind the services grid.

```svg
<svg viewBox="0 0 1440 600" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Hub nodes representing service areas -->
  <circle cx="360" cy="150" r="40" stroke="rgba(255,202,2,0.04)" stroke-width="1" fill="none"/>
  <circle cx="720" cy="300" r="50" stroke="rgba(255,202,2,0.05)" stroke-width="1" fill="none"/>
  <circle cx="1080" cy="200" r="35" stroke="rgba(255,202,2,0.04)" stroke-width="1" fill="none"/>

  <!-- Connection arcs between hubs -->
  <path d="M400 150 Q550 100 720 300" stroke="rgba(255,202,2,0.03)" stroke-width="1" fill="none"/>
  <path d="M770 300 Q900 250 1080 200" stroke="rgba(255,202,2,0.03)" stroke-width="1" fill="none"/>

  <!-- Small satellite nodes -->
  <circle cx="300" cy="100" r="3" fill="rgba(255,202,2,0.06)"/>
  <circle cx="420" cy="200" r="2" fill="rgba(255,202,2,0.05)"/>
  <circle cx="780" cy="350" r="3" fill="rgba(255,202,2,0.06)"/>
</svg>
```

**Parallax:** Single layer at 0.2x scroll speed, fades to 0 opacity as section scrolls out

### Testimonials Section — Constellation SVG

Sparse star-field / constellation pattern behind testimonials.

```svg
<svg viewBox="0 0 1440 500" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Stars — small dots scattered -->
  <circle cx="150" cy="80" r="1.5" fill="rgba(255,202,2,0.08)"/>
  <circle cx="430" cy="120" r="1" fill="rgba(255,202,2,0.06)"/>
  <circle cx="780" cy="60" r="2" fill="rgba(255,202,2,0.1)"/>
  <circle cx="1100" cy="140" r="1.5" fill="rgba(255,202,2,0.07)"/>
  <circle cx="1300" cy="90" r="1" fill="rgba(255,202,2,0.05)"/>
  <circle cx="250" cy="350" r="1" fill="rgba(255,202,2,0.06)"/>
  <circle cx="650" cy="420" r="1.5" fill="rgba(255,202,2,0.08)"/>
  <circle cx="900" cy="380" r="1" fill="rgba(255,202,2,0.05)"/>
  <circle cx="1200" cy="400" r="2" fill="rgba(255,202,2,0.09)"/>

  <!-- Constellation lines connecting a few stars -->
  <line x1="150" y1="80" x2="430" y2="120" stroke="rgba(255,202,2,0.03)" stroke-width="0.5"/>
  <line x1="430" y1="120" x2="780" y2="60" stroke="rgba(255,202,2,0.03)" stroke-width="0.5"/>
  <line x1="1100" y1="140" x2="1300" y2="90" stroke="rgba(255,202,2,0.03)" stroke-width="0.5"/>
</svg>
```

**Parallax:** 0.1x scroll speed (nearly static — stars don't rush)

### SVG Design Rules

| Rule | Value |
|------|-------|
| Color palette | Gold (#ffca02) only — vary opacity, never hue |
| Max opacity for fills | 15% (layer 3, closest nodes) |
| Max opacity for strokes | 10% (layer 3) |
| Stroke width | 0.5-2px depending on layer depth |
| Fill shapes | Circles only (nodes, dots, stars) |
| Stroke shapes | Lines, paths, circles (traces, connections, rings) |
| ViewBox | Match section width (1440 standard) |
| PreserveAspectRatio | `xMidYMid slice` (cover, don't stretch) |
| Reduced motion | Hide animated elements, show static SVGs |
| Mobile | Scale down to 2-3 key elements, reduce density |

### Framer Motion Parallax Component (SVG-aware)

```typescript
interface SVGParallaxLayerProps {
  children: React.ReactNode;
  speed: number;        // 0 = static, 1 = matches scroll
  fadeOut?: boolean;     // fade to 0 as section exits
  className?: string;
}

export function SVGParallaxLayer({
  children, speed, fadeOut = true, className = ""
}: SVGParallaxLayerProps) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  const y = useTransform(scrollYProgress, [0, 1], [`${-speed * 15}%`, `${speed * 15}%`]);
  const opacity = fadeOut
    ? useTransform(scrollYProgress, [0, 0.2, 0.8, 1], [0, 1, 1, 0])
    : useTransform(scrollYProgress, [0, 0.2], [0, 1]);

  return (
    <motion.div
      ref={ref}
      style={{ y, opacity }}
      className={`absolute inset-0 pointer-events-none ${className}`}
    >
      {children}
    </motion.div>
  );
}
```

---

## Image Parallax System

Background images with parallax scrolling. Images are positioned `absolute` within a section, oversized to allow vertical travel, and translated on scroll.

### Parallax Image Types

#### 1. Full-Bleed Background Parallax

The classic Ken Burns/parallax effect — a large background image moves slower than content.

```typescript
export function ParallaxImage({
  src, alt, speed = 0.3, className = ""
}: {
  src: string;
  alt: string;
  speed?: number;       // 0.2-0.5 recommended
  className?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });

  const y = useTransform(scrollYProgress, [0, 1], [`${-speed * 30}%`, `${speed * 30}%`]);

  return (
    <div ref={ref} className={`relative overflow-hidden ${className}`}>
      <motion.div style={{ y }} className="absolute inset-0 -inset-y-[20%]">
        <img
          src={src}
          alt={alt}
          className="w-full h-full object-cover"
          loading="lazy"
        />
        {/* Dark overlay for text readability */}
        <div className="absolute inset-0 bg-zinc-950/70" />
      </motion.div>
    </div>
  );
}
```

**Key details:**
- Image is 140% height (`-inset-y-[20%]`) to allow 20% travel in each direction
- Dark overlay at 60-80% opacity for text contrast
- Speed 0.2-0.5 (subtle — avoid seasickness)
- `object-cover` prevents distortion
- `loading="lazy"` for performance

#### 2. Offset Image Cards (Side Parallax)

Two images at different depths flanking content, moving at different rates.

```typescript
function SplitParallax() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref, offset: ["start end", "end start"],
  });

  const yLeft  = useTransform(scrollYProgress, [0, 1], ["20%", "-10%"]);
  const yRight = useTransform(scrollYProgress, [0, 1], ["-10%", "20%"]);

  return (
    <div ref={ref} className="relative grid grid-cols-3 gap-8 py-20">
      <motion.div style={{ y: yLeft }} className="relative rounded-2xl overflow-hidden h-[400px]">
        <img src="/images/..." alt="..." className="object-cover w-full h-full" />
        <div className="absolute inset-0 bg-zinc-950/40" />
      </motion.div>

      <div className="flex items-center px-8">
        {/* Center content — moves at normal scroll speed */}
        <div>
          <h2>Section Title</h2>
          <p>Description text...</p>
        </div>
      </div>

      <motion.div style={{ y: yRight }} className="relative rounded-2xl overflow-hidden h-[400px]">
        <img src="/images/..." alt="..." className="object-cover w-full h-full" />
        <div className="absolute inset-0 bg-zinc-950/40" />
      </motion.div>
    </div>
  );
}
```

#### 3. Reveal-on-Scroll Image Strip

Images inside a horizontal strip that slides in from the right as the section enters viewport.

```typescript
function ImageStrip() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref, offset: ["start end", "end start"],
  });

  const x = useTransform(scrollYProgress, [0, 1], ["20%", "-20%"]);

  return (
    <div ref={ref} className="overflow-hidden py-20">
      <motion.div style={{ x }} className="flex gap-4">
        {images.map((img) => (
          <div key={img.src} className="flex-shrink-0 w-[400px] h-[280px] rounded-xl overflow-hidden">
            <img src={img.src} alt={img.alt} className="object-cover w-full h-full" />
          </div>
        ))}
      </motion.div>
    </div>
  );
}
```

#### 4. Depth Stack (Layered Images + SVG)

Multiple images at different z-depths with SVG decorations between them.

```
┌─────────────────────────────────────────────┐
│  z-0  Background gradient (static)          │
│  z-1  Blurred large photo (speed: 0.15x)    │
│  z-2  SVG circuit traces (speed: 0.25x)     │
│  z-3  Medium photo, offset left (0.35x)     │
│  z-4  SVG node dots (speed: 0.4x)           │
│  z-5  Small photo, offset right (0.5x)      │
│  z-6  Content text (speed: 1x)              │
│  z-7  SVG foreground particles (1.1x)       │
└─────────────────────────────────────────────┘
```

```css
.depth-stack {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
}
.depth-layer {
  position: absolute;
  inset: 0;
  pointer-events: none;
}
.depth-layer img {
  object-fit: cover;
  border-radius: var(--radius-xl);
}
/* Blurred background image */
.depth-layer-bg img {
  filter: blur(20px) brightness(0.4);
  transform: scale(1.1); /* prevent blur edge bleed */
}
```

### Image Treatment Rules

| Rule | Value |
|------|-------|
| Dark overlay | Always 50-80% zinc-950 over photos |
| Blur (background images) | 0-20px depending on depth |
| Border radius | rounded-xl (12px) for inset images, 0 for full-bleed |
| Aspect ratios | 16:9 (landscape), 3:2 (editorial), 1:1 (thumbnails) |
| Max travel distance | 20% of image height (avoid excessive motion) |
| Loading | `loading="lazy"` on all below-fold images |
| Fallback (no JS) | Images show at center position, no parallax |
| Reduced motion | `transform: none`, static positioning |
| Color correction | Desaturate 20-40% and shift shadows toward warm gold tint |
| Overlay gradient | `linear-gradient(to top, zinc-950 0%, transparent 40%)` for bottom fade |

### Image Color Treatment (CSS Filter)

All photographs should be color-graded to match the gold/warm palette:

```css
.parallax-image {
  filter: saturate(0.7) sepia(0.15) brightness(0.6);
}
.parallax-image:hover {
  filter: saturate(0.85) sepia(0.1) brightness(0.7);
  transition: filter 600ms ease-out;
}
```

This desaturates, adds warm sepia tint, and darkens — matching the zinc-950 + gold aesthetic.

---

## Stock Art & Cinematic Scroll Sequences

This section defines every image asset needed for the site, organized as **cinematic scroll sequences** — Apple-style multi-layered scroll-driven animations where images, SVGs, and text choreograph together as the user scrolls. Each sequence is a self-contained section that tells a visual story.

The approach: instead of static background images, every section becomes a **scroll-driven scene** where multiple layers (photos, SVGs, gradients, text) transform independently as `scrollYProgress` moves from 0 to 1. Think Apple's MacBook opening as you scroll, but adapted for a consulting practice.

---

### Scroll Sequence Architecture

Each sequence uses Framer Motion's `useScroll` + `useTransform` to map scroll position (0→1) to visual properties. The page is structured as a series of these sequences, each pinned for a scroll distance proportional to its complexity.

```
┌──────────────────────────────────────────────────────────────┐
│  SCROLL SEQUENCE ANATOMY                                      │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Container: sticky, height: 100vh, overflow: hidden           │
│  Scroll distance: 200-400vh (user scrolls 2-4x viewport)     │
│                                                               │
│  Layers (back → front):                                       │
│    BG gradient    — static or slow drift                      │
│    Photo layer(s) — scale, position, opacity, blur, clip      │
│    SVG layer(s)   — draw-on, position, opacity                │
│    Overlay        — gradient masks, vignettes                 │
│    Text layer(s)  — fade, slide, swap content                 │
│    UI elements    — cards, buttons appear at end               │
│                                                               │
│  scrollYProgress: 0.0 ─────────────────────────────── 1.0     │
│                   │         │         │         │              │
│                   Scene 1   Scene 2   Scene 3   Final state    │
│                   (intro)   (build)   (reveal)  (interactive)  │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

```typescript
// Scroll sequence container pattern
function ScrollSequence({ children, scrollHeight = "300vh" }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  return (
    <div ref={containerRef} style={{ height: scrollHeight }}>
      <div className="sticky top-0 h-screen overflow-hidden">
        {/* Layers receive scrollYProgress as prop */}
        {React.Children.map(children, child =>
          React.cloneElement(child, { progress: scrollYProgress })
        )}
      </div>
    </div>
  );
}
```

---

### Sequence 1: Hero — "The Signal" (above fold → first scroll)

**Concept:** The screen begins dark and empty. As the user scrolls, golden light traces emerge from darkness like a signal being received — circuit paths draw themselves, nodes pulse to life, and the headline materializes from the glow. The effect communicates: *something powerful is waking up*.

**Scroll distance:** 300vh (3x viewport — user scrolls 2 full screens to complete)

**Timeline:**

| Scroll % | Scene | What Happens |
|-----------|-------|--------------|
| 0-10% | Darkness | Pure zinc-950. Single faint gold dot pulses center-screen. |
| 10-25% | Signal emerges | Dot expands into a radial glow. First circuit traces begin drawing (SVG stroke-dashoffset animation). Deep photo layer fades in at 5% opacity, heavily blurred. |
| 25-45% | Network forms | Circuit traces complete. Nodes appear at intersections (scale 0→1). Connection lines draw between nodes. Photo layer sharpens slightly (blur 20px→10px), opacity rises to 15%. |
| 45-60% | Headline reveal | "Leadership in" fades in word-by-word from bottom. Background photo reaches full parallax position, 25% opacity. SVG nodes settle into final positions. |
| 60-75% | Gradient text | "performance" and "scale" reveal with gradient-text effect, each word lighting up like a filament. Gold glow intensifies behind text. |
| 75-90% | Subtitle + CTAs | Subtitle types in. CTA buttons slide up with stagger. Full hero composition is visible. |
| 90-100% | Settle | Parallax layers settle into ambient drift mode. Sequence releases scroll — next section begins entering from bottom. |

**Image assets needed:**

| Layer | Asset | Source / Description |
|-------|-------|---------------------|
| **Deep photo (z-1)** | `screen-overlay-fiber-optics.png` | **Available** in `design/`. Golden fiber optic burst on pure black — radiating golden strands with bokeh endpoints. |
| | | **Treatment:** blur 20px→8px over scroll, opacity 5%→25%, saturate(0.5) sepia(0.2) brightness(0.4). Center the burst in upper-right quadrant for asymmetric composition. |
| **Mid photo (z-2)** | `screen-overlay-circuit-traces.png` | **Available** in `design/`. Macro circuit board with golden copper traces on dark PCB, warm directional lighting, shallow DOF. |
| | | **Treatment:** clip-path reveals from center outward (circle 0%→100%), opacity 0%→20%, desaturated. Already perfectly color-matched. |
| **Particle overlay (z-4)** | `screen-overlay-gold-particles.png` | **Available** in `design/`. Sparse gold particles and dust motes on black, varying sizes, some with motion blur trails. |
| | | **Treatment:** Screen blend mode, opacity 0%→40% over scroll, moves upward at 0.5x scroll speed. |
| **SVG layer (z-3)** | Inline SVG / D3.js | Circuit network drawn with SVG `<path>` elements. Use stroke-dashoffset for draw-on animation driven by scroll. **Prefer SVG over raster** for this layer — resolution-independent, individually animatable nodes. See [Hero Circuit Network SVG](#hero-section--circuit-network-svg) above. |

**SVG draw-on technique:**

```typescript
// Animate SVG path drawing based on scroll
function DrawOnPath({ d, progress, startAt, endAt }) {
  const pathRef = useRef<SVGPathElement>(null);
  const [pathLength, setPathLength] = useState(0);

  useEffect(() => {
    if (pathRef.current) setPathLength(pathRef.current.getTotalLength());
  }, []);

  const dashOffset = useTransform(
    progress,
    [startAt, endAt],
    [pathLength, 0]
  );

  return (
    <motion.path
      ref={pathRef}
      d={d}
      stroke="rgba(255,202,2,0.12)"
      strokeWidth="1.5"
      fill="none"
      strokeLinecap="round"
      style={{
        strokeDasharray: pathLength,
        strokeDashoffset: dashOffset,
      }}
    />
  );
}
```

---

### Sequence 2: Featured Projects — "The Workshop" (scroll-pinned showcase)

**Concept:** A developer's workspace materializes — a laptop opens from closed to 90°, its screen illuminates with project screenshots, and project cards emerge from the screen like holograms. Similar to Apple's MacBook reveal but with a software engineering context.

**Scroll distance:** 400vh (each of 6 projects gets attention)

**Timeline:**

| Scroll % | Scene | What Happens |
|-----------|-------|--------------|
| 0-15% | Laptop appears | Dark laptop outline fades in, centered. Perspective view from above at ~30°. |
| 15-35% | Laptop opens | Lid rotates from 0° (closed) to ~130° (open). Screen is dark initially. Keyboard area catches faint gold light reflection. |
| 35-50% | Screen lights up | Screen emits warm gold glow (radial gradient expanding). First project screenshot fades onto screen. Ambient glow illuminates the surrounding area. |
| 50-90% | Project carousel | Screen content transitions between project screenshots (crossfade, 6-7% scroll per project). Project card floats up beside the laptop with details. Each swap: old card slides left + fades, new card slides up + fades in. |
| 90-100% | Dissolve to grid | Laptop scales down and fades. Projects settle into the standard 2-column card grid. Transition to interactive mode. |

**Image assets needed:**

| Layer | Asset | Prompt / Description |
|-------|-------|---------------------|
| **Laptop body** | `laptop-frame.png` | **AI:** "Modern laptop computer, matte dark gray finish, thin bezels, seen from above at 30 degree angle, lid partially open, on pure black background, no reflections, product photography style, transparent background PNG, 16:9" |
| | | **Alt approach:** Build entirely in SVG/CSS for resolution independence (preferred) |
| **Screen content — GenAI** | `project-genai.webp` | **AI:** "Dark mode code editor showing Elixir code, syntax highlighting with gold/amber/white colors on zinc-950 background, clean monospace font, showing function definitions for AI inference client, 16:9 laptop screen aspect, UI screenshot style" |
| **Screen content — NPL** | `project-npl.webp` | **AI:** "Dark mode markdown document with structured prompt notation, gold headings, code blocks with amber syntax, tree-like indentation showing prompt hierarchy, minimal clean interface, 16:9" |
| **Screen content — Intellect** | `screen-intellect.png` | **Available** in `design/`. Multi-agent hierarchical architecture diagram — system supervisor → research/analysis/communication agents → worker nodes. Gold connection lines, status indicators, dark dashboard. **Rebuild as interactive D3.js/SVG** for the live site — see `design/screen-intellect.html`. |
| **Screen content — Rule Engine** | `project-rules.webp` | **AI:** "Dark mode interface showing rule engine configuration, decision tree with gold connecting lines, condition-action pairs in card layout, minimal enterprise UI, 16:9" |
| **Keyboard reflection** | SVG gradient | `radial-gradient(ellipse at 50% 20%, rgba(255,202,2,0.06) 0%, transparent 60%)` — mimics screen glow on keyboard |
| **Ambient glow** | CSS gradient | `radial-gradient(ellipse at 50% 50%, rgba(255,202,2,0.08) 0%, transparent 50%)` — expands as screen "turns on" |

**CSS laptop technique (SVG/CSS preferred over photo):**

```css
.laptop {
  perspective: 1200px;
  transform-style: preserve-3d;
}
.laptop-lid {
  transform-origin: bottom center;
  /* rotateX animated from 90deg (closed) to -10deg (open) via scroll */
  backface-visibility: hidden;
}
.laptop-screen {
  background: #000;
  border-radius: 8px;
  overflow: hidden;
  /* Screen content fades in after lid opens past 60deg */
}
.laptop-base {
  background: linear-gradient(to bottom, #1a1a1e, #111114);
  border-radius: 0 0 12px 12px;
}
```

---

### Sequence 3: Services — "The Architecture Blueprint"

**Concept:** An architectural blueprint unrolls/draws itself. The "paper" is dark with gold lines (like a luxury technical drawing). Service categories appear as labeled nodes on the blueprint, connected by flowing gold lines. Each service card "pops out" of its blueprint position as the user scrolls to it.

**Scroll distance:** 350vh

**Timeline:**

| Scroll % | Scene | What Happens |
|-----------|-------|--------------|
| 0-20% | Blueprint base | Dark textured paper background fades in. Subtle grid lines draw on (like graph paper but dark). |
| 20-50% | Architecture draws | Main structure lines draw themselves — a central hub with radiating connections to 8 positions (one per service). Gold lines animate via stroke-dashoffset. |
| 50-85% | Service nodes pop | Each service node animates in sequence (stagger): icon scales up, title fades in, brief description appears. Currently active node glows brighter. Connection line to hub pulses. |
| 85-100% | Grid formation | Blueprint fades to 10% opacity background. Service cards animate from their blueprint positions into the standard 4-column grid layout. |

**Image assets needed:**

| Layer | Asset | Prompt / Description |
|-------|-------|---------------------|
| **Blueprint texture** | `blueprint-dark.webp` | **Stock:** "dark blueprint paper texture, technical drawing, subtle grid lines" |
| | | **AI:** "Dark navy-black technical blueprint paper texture, very subtle grid lines in dark gold, aged paper feel but dark, matte finish, seamless tileable, 1:1, 4K texture" |
| | | **Treatment:** Tint to zinc-950 + gold, 8-15% opacity, tileable background |
| **Architecture diagram** | Inline SVG | Full SVG with 8 radial connection paths from center hub. All paths use stroke-dashoffset for draw-on animation. Gold at 8-15% opacity. |
| **Service icons** | Existing Heroicons | Current SVG icons, animated scale(0)→scale(1) with slight bounce easing |

---

### Sequence 4: Testimonials — "Constellations of Trust"

**Concept:** Stars appear one by one in a dark sky. Each star is a testimonial — when it lights up, it reveals the quote. Constellation lines draw between related testimonials. The effect: a universe of trust signals connecting across the dark.

**Scroll distance:** 250vh

**Timeline:**

| Scroll % | Scene | What Happens |
|-----------|-------|--------------|
| 0-15% | Night sky | Deep space photo fades in at low opacity (5-10%). Subtle nebula warmth in one corner. |
| 15-70% | Stars light up | Each testimonial appears as a bright point (scale + glow animation). Card fades in near the star with quote text. Staggered — each testimonial gets ~8% of scroll. Constellation lines draw between sequential stars. |
| 70-85% | Full constellation | All stars visible. Lines connecting them form a complete pattern. Brief pause to appreciate. |
| 85-100% | Grid settle | Star positions animate to standard 3-column grid positions. Background dims. Cards are now interactive. |

**Image assets needed:**

| Layer | Asset | Prompt / Description |
|-------|-------|---------------------|
| **Deep space** | `space-deep.webp` | **Stock:** "deep space nebula, dark, subtle warm tones, stars, astronomy" |
| | | **AI:** "Deep space photograph, predominantly black with very subtle warm amber nebula glow in upper right quadrant, scattered pinpoint stars, Hubble telescope style but muted and dark, warm color palette, 16:9, cinematic" |
| | | **Treatment:** brightness(0.15) saturate(0.5) sepia(0.3), overlay zinc-950/80 |
| **Star glow** | CSS + SVG | Each "star" is a `<circle>` with animated `r` (2→6→4) and a radial-gradient CSS glow behind the card |
| **Constellation lines** | Inline SVG | `<line>` elements with stroke-dashoffset draw-on, gold at 5% opacity |

---

### Sequence 5: Contact CTA — "The Beacon"

**Concept:** From the constellation field, a single bright light grows — a beacon calling for connection. The gold glow expands to illuminate the CTA card, which rises from darkness. Particles drift inward toward the card (converging instead of scattering), implying: *all paths lead here*.

**Scroll distance:** 200vh

**Timeline:**

| Scroll % | Scene | What Happens |
|-----------|-------|--------------|
| 0-20% | Fade from previous | Constellation dims. A single bright gold point appears center-screen. |
| 20-50% | Beacon grows | Point expands into warm radial glow (scale 1→40). Ambient particles begin drifting inward from edges. |
| 50-75% | CTA reveals | Glass card fades in within the glow. Heading text reveals. Glow settles behind card as box-shadow. |
| 75-100% | Interactive | Buttons appear. Particles reach their final positions around the card. Card is now fully interactive with hover states. |

**Image assets needed:**

| Layer | Asset | Prompt / Description |
|-------|-------|---------------------|
| **Particle field** | `cta-particles.webp` | **Stock:** "gold light particles converging, dark background, radial motion blur" |
| | | **AI:** "Golden light particles streaming inward toward center point on black background, radial motion blur on each particle suggesting movement toward center, warm amber tones, ethereal atmosphere, particles vary from sharp dots to soft bokeh, 16:9, cinematic" |
| | | **Treatment:** opacity 0%→30%, scale 1.5→1 (converging effect), screen blend |
| **Light leak** | `cta-glow.webp` | **Stock:** "warm gold light flare, center, black background, cinematic" |
| | | **AI:** "Single bright warm golden light source at dead center of black background, volumetric light rays spreading outward in all directions, lens flare, anamorphic quality, pure gold color, no other colors, 16:9, cinematic" |
| | | **Treatment:** scale 0→1 via scroll, opacity 0%→60%, behind the glass CTA card |

---

### Sequence 6: About/Bio — "The Architect at Work" (future page)

**Concept:** A workspace comes into focus from blur. The camera (scroll) moves through the depth of field — from the blurred foreground (coffee cup, plant) through the midground (keyboard, hands) to the background (screens with code). Each depth plane sharpens as it enters focus and blurs as the camera "passes" it.

**Scroll distance:** 300vh

**Timeline:**

| Scroll % | Scene | What Happens |
|-----------|-------|--------------|
| 0-20% | Foreground focus | Foreground objects sharp (coffee cup, desk edge). Everything behind is heavily blurred. Warm lamp glow. |
| 20-50% | Mid focus | Foreground blurs out. Keyboard and hands come into focus. Code on screen becomes legible. Typing animation (subtle CSS). |
| 50-80% | Screen focus | Hands blur. Screen content becomes the focus. Dashboard/code is clearly visible. Gold UI elements highlighted. |
| 80-100% | Pull back | Everything resolves into a full scene. Bio text overlays on the left. Photo settles into final position on right. |

**Image assets needed:**

| Layer | Asset | Prompt / Description |
|-------|-------|---------------------|
| **Foreground** | `workspace-fg.webp` | **Stock:** "coffee cup edge of frame, dark desk, out of focus background, warm lighting" |
| | | **AI:** "Close-up of ceramic coffee mug on dark wooden desk, right third of frame, rest of frame shows heavily blurred workspace with warm amber monitor glow in background, shallow DOF f/1.4, warm tones, moody developer workspace, 16:9" |
| | | **Treatment:** This image is sharp at scroll 0%, blurs to 30px by scroll 30% |
| **Midground** | `workspace-mid.webp` | **Stock:** "developer hands on mechanical keyboard, dark desk, monitor glow, warm" |
| | | **AI:** "Developer's hands on backlit mechanical keyboard, dark desk environment, warm amber glow from dual monitors above, slight motion blur on fingertips suggesting typing, shallow DOF, 16:9, moody editorial photography" |
| | | **Treatment:** Starts blurred (20px), sharpens at scroll 30-50%, blurs again by scroll 70% |
| **Background** | `workspace-bg.webp` | **Stock:** "dual monitors showing code, dark room, developer workspace from behind" |
| | | **AI:** "Over-shoulder view of two ultrawide monitors displaying dark mode code editor and system dashboard with gold accent colors, dark room lit only by screen glow, Elixir code visible, warm color temperature, 16:9, cinematic" |
| | | **Treatment:** Starts at blur(30px), sharpens at scroll 60-80%, final state is subtle blur(2px) |
| **Foreground objects** | `workspace-items.png` | **AI:** "Small desk objects on pure black background, transparent PNG: mechanical pencil, sticky notes, USB cable, small succulent plant, items scattered naturally, warm lighting, product photography, overhead view" |
| | | **Treatment:** Separate PNG layer with transparency, parallax at 1.3x (faster than scroll) for foreground depth |

---

### Per-Section Background Parallax Images

For sections that don't use full cinematic sequences but still need parallax depth:

#### Simple Section Backgrounds

| Section | Layer | Asset | Prompt | Speed | Opacity |
|---------|-------|-------|--------|-------|---------|
| Any section divider | Deep | `bg-grid-perspective.webp` | "Perspective grid on dark background, golden lines receding to vanishing point, minimal, technical" | 0.15x | 4-6% |
| | | | **AI:** "One-point perspective grid, thin golden lines on pure black, lines converging to center vanishing point, technical drawing aesthetic, minimal and clean, 16:9" | | |
| Any section divider | Mid | `bg-bokeh-warm.webp` | "Abstract warm bokeh circles, dark background, gold and amber" | 0.3x | 8-12% |
| | | | **AI:** "Large soft bokeh circles, warm gold and amber tones, floating on black background, varying sizes from 50px to 200px, some overlapping, dreamy out-of-focus, 16:9" | | |
| Tech detail | Close | `bg-code-texture.webp` | "Code on dark screen, blurred, warm syntax highlighting" | 0.5x | 5-10% |
| | | | **AI:** "Blurred code editor content, dark background, warm gold and amber syntax highlighting colors, text illegible but structured, developer aesthetic, 16:9, gaussian blur 8px" | | |

#### Texture Overlays (Static, No Parallax)

| Asset | Prompt | Opacity | Blend Mode |
|-------|--------|---------|------------|
| `noise-warm.png` | "Film grain noise texture, warm tint, seamless tileable, 512x512" | 3-5% | overlay |
| `scanlines.png` | "Horizontal scanline texture, 1px lines, 4px spacing, seamless, dark" | 2-3% | overlay |
| `vignette.webp` | "Dark vignette overlay, transparent center, dark edges, radial gradient" | 20-40% | multiply |

---

### AI Image Generation Master Prompts

For consistent results across all assets, prefix every AI prompt with this **style primer**:

```
STYLE: Dark technical photography, warm gold/amber color palette on
near-black backgrounds (#09090b). Cinematic lighting, shallow depth
of field, moody atmosphere. No blues, no greens, no cool tones.
Warm amber is the only accent color. Matte finish, editorial quality.
16:9 unless specified otherwise. 8K detail.
```

**Midjourney-specific suffix:**
```
--ar 16:9 --style raw --s 250 --c 10 --no blue green cool neon bright white background
```

**DALL-E-specific notes:**
- Add "photorealistic, shot on Sony A7III with 85mm f/1.4 lens" for photo assets
- Add "clean vector illustration, single stroke weight" for SVG-source assets

**Stable Diffusion (SDXL) negative prompt:**
```
blue, green, cool tones, neon, bright, white background, cartoon,
illustration, text, watermark, oversaturated, HDR, high key
```

---

### Image Color Grading Pipeline

Every photo asset goes through this pipeline before use:

```
Source image
  ↓
Step 1: Desaturate (saturation × 0.6-0.7)
  ↓
Step 2: Warm shift (sepia 10-20%)
  ↓
Step 3: Darken (brightness × 0.4-0.6)
  ↓
Step 4: Contrast boost (contrast × 1.1-1.2)
  ↓
Step 5: Add zinc-950 overlay (50-80% opacity depending on use)
  ↓
Step 6: Optional: add bottom gradient (zinc-950 → transparent, 40% height)
  ↓
Ready for use
```

```css
/* One-line CSS filter equivalent */
.parallax-image {
  filter: saturate(0.65) sepia(0.15) brightness(0.5) contrast(1.15);
}
```

```bash
# ImageMagick batch processing
convert input.jpg \
  -modulate 100,65 \          # saturation to 65%
  -fill '#1a1000' -colorize 15% \  # warm sepia tint
  -brightness-contrast -50x15 \    # darken + slight contrast
  -resize 1920x1080^ \        # resize for web
  -gravity center -extent 1920x1080 \  # crop to exact
  -quality 82 \
  output.webp
```

### Image Performance Budget

| Image Type | Max Size | Format | Loading | Notes |
|------------|----------|--------|---------|-------|
| Hero deep layer | 200KB | WebP (AVIF fallback) | Eager | Above fold, priority fetch |
| Hero mid layer | 150KB | WebP | Eager | Above fold |
| Hero particles | 100KB | WebP | Eager | Screen blend, needs alpha |
| Section background | 150KB | WebP | Lazy | IntersectionObserver |
| Project screenshot | 80KB | WebP | Lazy | Inside scroll sequence |
| Workspace photos | 120KB each | WebP | Lazy | 3 depth layers |
| Texture overlay | 20KB | PNG | Lazy | Tileable, small source |
| SVG illustration | 15KB | Inline SVG | In bundle | Gzip to ~4KB |
| Thumbnail | 30KB | WebP | Lazy | Card images |

**Total hero section budget:** ~450KB (3 photo layers + SVGs)
**Total page budget:** ~1.5MB images (all sections combined)

```html
<!-- Responsive image with art direction -->
<picture>
  <source srcset="/images/hero-deep.avif" type="image/avif">
  <source srcset="/images/hero-deep.webp" type="image/webp">
  <img src="/images/hero-deep.jpg" alt="Abstract fiber optic network"
       loading="eager" decoding="async" fetchpriority="high"
       width="1920" height="1080">
</picture>
```

### Next.js Image Component Pattern

```typescript
import Image from 'next/image';

// For parallax images — use fill mode with object-cover
<div className="relative h-[600px] overflow-hidden">
  <motion.div style={{ y }} className="absolute inset-0 -inset-y-[20%]">
    <Image
      src="/images/hero-deep.webp"
      alt="Abstract fiber optic network"
      fill
      sizes="100vw"
      className="object-cover"
      style={{ filter: 'saturate(0.65) sepia(0.15) brightness(0.5) contrast(1.15)' }}
      priority  // above fold only
    />
    <div className="absolute inset-0 bg-zinc-950/70" />
  </motion.div>
</div>
```

Note: For static export (`output: "export"`), use `unoptimized: true` in next.config or use standard `<img>` tags.

---

## Implementation Checklist

- [x] Single sans-serif typeface (Inter) + monospace accent (JetBrains Mono)
- [x] Gold (#ffca02) as sole accent color
- [x] Dark mode only (zinc-950 background)
- [x] Glass surfaces with backdrop-blur
- [x] Consistent 8px spacing scale
- [x] Scroll-triggered fade/stagger animations
- [x] Parallax background components
- [x] Responsive grid (1→2→3-4 columns)
- [x] Mobile navigation with animation
- [x] Contrast ratios pass WCAG AA
- [ ] `prefers-reduced-motion` handling for all Framer Motion components
- [ ] Magnetic cursor effect on primary CTAs
- [ ] Text reveal animation on section headings
- [ ] 3D tilt effect on project cards
- [ ] Scroll progress indicator
- [ ] Typed text effect on hero subtitle
- [ ] Particle/node hero background
- [ ] Smooth alternating section transitions
- [ ] Mouse-tracking card light effect
- [ ] Scroll-snap for full-page sections (case studies)
- [ ] Sticky section headers
- [ ] Horizontal scroll gallery
- [ ] Number counter animation for stats
- [ ] Page transition animations
- [ ] SVG parallax layers — hero circuit network (3 layers)
- [ ] SVG parallax layers — services topology map
- [ ] SVG parallax layers — testimonials constellation
- [ ] SVGParallaxLayer reusable component
- [ ] Full-bleed background image parallax with dark overlay
- [ ] Offset image cards (side parallax)
- [ ] Horizontal reveal image strip
- [ ] Depth stack (layered images + SVG)
- [ ] Image color treatment filter (desaturate + sepia + darken)
- [ ] Stock art sourced and color-corrected for all sections
- [ ] WebP/AVIF image formats with `<picture>` fallbacks
- [ ] Image performance budget enforced (<200KB hero, <150KB section)
- [ ] Cinematic Sequence 1: Hero "The Signal" — draw-on circuit SVGs + photo layers
- [ ] Cinematic Sequence 2: Projects "The Workshop" — laptop open + screen carousel
- [ ] Cinematic Sequence 3: Services "The Blueprint" — architecture draw-on + node pop
- [ ] Cinematic Sequence 4: Testimonials "Constellations" — star-field + quote reveal
- [ ] Cinematic Sequence 5: CTA "The Beacon" — converging particles + glow expand
- [ ] Cinematic Sequence 6: About "The Architect" — rack focus depth of field (future)
- [ ] ScrollSequence container component (sticky + scroll distance)
- [ ] DrawOnPath SVG component (stroke-dashoffset via scroll)
- [ ] Image color grading pipeline (ImageMagick or CSS filter)
- [ ] Texture overlays (noise, scanlines, vignette)

---

*Derived from: Minimal Tech + Nocturne (80/20)*
*Current implementation: Next.js 14, Tailwind CSS 3.4, Framer Motion 11*
