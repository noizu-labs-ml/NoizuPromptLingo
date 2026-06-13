# Style Guide: CodeFresh — Direction C: Neo-Brutalist

> Raw, high-contrast testing interface. Not another dashboard.

**Style System:** Bold Expressive (Neo-Brutalist sub-style)
**Source Spec:** bold-expressive.md
**Scenario:** AI agent behavioral testing platform — positioning as challenger brand against polished observability tools

---

## Scenario

Every AI observability tool looks the same: dark mode, blue accent, Inter font, soft borders. Arize, LangSmith, Braintrust, AgentOps — they all share the Minimal Tech aesthetic. They also all do the *wrong thing* (observability, not behavioral testing). CodeFresh does a fundamentally different thing, and it should *look* fundamentally different.

Neo-Brutalist CodeFresh leans into the **"code is the design"** philosophy. Thick borders instead of soft shadows. Monospace as the primary font, not just for code blocks. High-contrast black-on-white *and* white-on-black sections. Exposed structure. The visual language says: **"This is a power tool for people who read terminal output. We didn't hire a brand agency. We hired an engineer."**

This is the highest-risk, highest-differentiation direction. It trades polish for memorability. It will polarize — developers who love it will *really* love it. Those who don't will think it's ugly. That's the point.

**Warning:** Neo-Brutalist requires excellent execution to avoid looking broken. Every unconventional choice must be intentional and consistent. The line between "deliberately raw" and "lazy design" is narrow.

**Reference energy:** deck.graphics (structural brutalism), hfrfrw.com (experimental), basic.agency (creative studio energy)

---

## Color Palette

```css
:root {
  /* Primary surface — dark foundation */
  --bg-primary: #0D0D0D;
  --bg-surface: #1A1A1A;

  /* Inverted surface — for contrast sections */
  --bg-inverted: #F5F5F0;
  --text-on-inverted: #0D0D0D;

  /* Text on dark */
  --text-primary: #F5F5F0;
  --text-secondary: #8A8A8A;
  --text-tertiary: #555555;

  /* Borders — THICK, visible, structural */
  --border-heavy: #F5F5F0;
  --border-medium: #555555;
  --border-subtle: #2A2A2A;

  /* Accent — Electric Yellow (alarm/attention) */
  --accent: #DCFF00;
  --accent-on-dark: #DCFF00;
  --accent-on-light: #8B9900;

  /* Eval Results — same semantic colors, higher saturation */
  --eval-pass: #00FF66;
  --eval-pass-bg: rgba(0, 255, 102, 0.08);
  --eval-warn: #FFD600;
  --eval-warn-bg: rgba(255, 214, 0, 0.08);
  --eval-fail: #FF3333;
  --eval-fail-bg: rgba(255, 51, 51, 0.08);
  --eval-freeball: #FF6600;
  --eval-freeball-bg: rgba(255, 102, 0, 0.08);
}
```

```
+------------------------------------------+
|  CODEFRESH PALETTE — Direction C          |
+------------------------------------------+
|                                           |
|  ██████  #0D0D0D  Primary BG             |
|  ██████  #1A1A1A  Surface                |
|  ██████  #F5F5F0  Inverted / Border      |
|                                           |
|  ██████  #F5F5F0  Text Primary           |
|  ██████  #8A8A8A  Text Secondary         |
|                                           |
|  ██████  #DCFF00  Accent (Electric Lime) |
|                                           |
|  ██████  #00FF66  Pass (Neon Green)      |
|  ██████  #FFD600  Warn (Neon Amber)      |
|  ██████  #FF3333  Fail (Neon Red)        |
|  ██████  #FF6600  Freeball (Neon Orange) |
|                                           |
+------------------------------------------+
```

**Usage rules:**
- Dark mode primary, with **inverted (light) sections** used intentionally for contrast breaks
- Eval result colors are brighter/more neon than Direction A — they need to punch through the heavier visual treatment
- Accent (electric lime) is used for: primary actions, active states, the "RUN" button, and the CodeFresh logo mark
- `--border-heavy` (white on dark) is a structural element — 2-3px borders define panels and cards
- Full-bleed inverted sections break up long pages (e.g., the persona library could be white-on-dark)

---

## Typography

**Font stack:**
```css
/* Primary — Monospace is the hero */
--font-mono: 'Space Mono', 'JetBrains Mono', 'Courier New', monospace;

/* Secondary — Grotesque for UI labels and navigation */
--font-sans: 'Space Grotesk', 'Inter', sans-serif;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| Display | Mono | clamp(48px, 8vw, 96px) | 700 | 0.95 | Hero headline, "CODEFRE.SH" |
| H1 | Mono | 32px | 700 | 1.1 | Page titles, ALL CAPS |
| H2 | Mono | 24px | 700 | 1.15 | Section headers |
| H3 | Sans | 18px | 700 | 1.3 | Card headers, labels |
| Body | Mono | 14px | 400 | 1.7 | Default text |
| Body Small | Mono | 12px | 400 | 1.6 | Metadata |
| Caption | Sans | 11px | 500 | 1.4 | Overlines, uppercase labels |
| Code | Mono | 14px | 400 | 1.5 | No distinction — body IS code |

**Typography notes:**
- **Monospace is the default**, not the exception. This is the core Neo-Brutalist move. Everything reads like a terminal. The sans-serif (Space Grotesk) is reserved for compact UI labels, nav items, and captions where mono would be too wide.
- Headlines are UPPERCASE with tight line-height (0.95-1.1) and heavy weight (700)
- Letter-spacing on headlines: -0.02em (letters crowd each other intentionally)
- Body text at 14px mono with 1.7 line-height — wider leading compensates for monospace's density

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Space Mono | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Space+Mono) |
| Space Grotesk | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk) |

---

## Spacing & Layout

**Spacing scale:** 4, 8, 16, 24, 32, 48, 64, 96, 128px

Note: wider jumps than Minimal Tech. Neo-Brutalist uses **extremes** — tight content blocks separated by generous gaps.

**Grid:**

| Breakpoint | Columns | Gutter | Margin | Max Width |
|------------|---------|--------|--------|-----------|
| Mobile (<768px) | 4 | 8px | 16px | 100% |
| Tablet (768-1024px) | 6 | 16px | 24px | 100% |
| Desktop (1024-1440px) | 12 | 16px | 32px | 100% |
| Wide (>1440px) | 12 | 16px | 48px | 1400px |

**Layout pattern:** Full-width header + content area. No persistent sidebar — navigation lives in a fullscreen overlay triggered by a hamburger/menu button (even on desktop). The main workspace gets 100% width.

```
+==================================================================+
||  CODEFRE.SH                           [SCRIPTS] [RUNS] [■ MENU]||
+==================================================================+
|                                                                    |
|  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  |
|  ┃                                                              ┃  |
|  ┃  GRAPH EDITOR                                                ┃  |
|  ┃  (full width — no sidebar stealing space)                    ┃  |
|  ┃                                                              ┃  |
|  ┃  ┏━━━━━━━━━━━━━┓         ┏━━━━━━━━━━━━━┓                    ┃  |
|  ┃  ┃ NODE 1      ┃━━━━━━━━▶┃ NODE 2      ┃                    ┃  |
|  ┃  ┃ 2px border  ┃         ┃ 2px border  ┃                    ┃  |
|  ┃  ┗━━━━━━━━━━━━━┛         ┗━━━━━━━━━━━━━┛                    ┃  |
|  ┃                                                              ┃  |
|  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  |
|                                                                    |
|  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  |
|  ┃  NODE DETAIL (expands below, not as sidebar)                 ┃  |
|  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  |
|                                                                    |
+====================================================================+
```

---

## Component Styling

### Buttons

```css
/* Primary — THE button */
.btn-primary {
  background: var(--accent);
  color: #0D0D0D;
  padding: 12px 24px;
  border: 2px solid var(--accent);
  font-family: var(--font-mono);
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  transition: background 100ms ease, color 100ms ease;
}
.btn-primary:hover {
  background: transparent;
  color: var(--accent);
}
.btn-primary:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 4px;
}

/* Secondary — outlined */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  padding: 12px 24px;
  border: 2px solid var(--border-heavy);
  font-family: var(--font-mono);
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  transition: background 100ms ease, color 100ms ease;
}
.btn-secondary:hover {
  background: var(--text-primary);
  color: var(--bg-primary);
}

/* Ghost — text only, underline */
.btn-ghost {
  background: none;
  border: none;
  color: var(--text-secondary);
  font-family: var(--font-mono);
  font-size: 13px;
  text-decoration: underline;
  text-decoration-thickness: 2px;
  text-underline-offset: 4px;
  transition: color 100ms ease;
}
.btn-ghost:hover { color: var(--text-primary); }
```

### Graph Nodes

```css
/* Base node — heavy borders, no radius */
.graph-node {
  background: var(--bg-surface);
  border: 2px solid var(--border-medium);
  border-radius: 0;
  padding: 16px;
  min-width: 220px;
  max-width: 340px;
  font-family: var(--font-mono);
  font-size: 12px;
  transition: border-color 100ms ease;
}
.graph-node:hover { border-color: var(--border-heavy); }
.graph-node--selected {
  border-color: var(--accent);
  border-width: 3px;
}

/* Eval states — bright borders + subtle bg */
.graph-node--pass { border-color: var(--eval-pass); background: var(--eval-pass-bg); }
.graph-node--warn { border-color: var(--eval-warn); background: var(--eval-warn-bg); }
.graph-node--fail { border-color: var(--eval-fail); background: var(--eval-fail-bg); }
.graph-node--freeball {
  border-color: var(--eval-freeball);
  background: var(--eval-freeball-bg);
  border-style: dashed;
  border-width: 3px;
}

/* Graph edges */
.graph-edge {
  stroke: var(--border-medium);
  stroke-width: 2;
}
.graph-edge--freeball {
  stroke: var(--eval-freeball);
  stroke-dasharray: 8 4;
}
```

### Score Badges

```css
.score-badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 8px;
  border: 2px solid currentColor;
  border-radius: 0;
  font-family: var(--font-mono);
  font-size: 12px;
  font-weight: 700;
}
.score-badge--pass { color: var(--eval-pass); }
.score-badge--warn { color: var(--eval-warn); }
.score-badge--fail { color: var(--eval-fail); }
```

### Cards

```css
.card {
  background: var(--bg-surface);
  border: 2px solid var(--border-medium);
  border-radius: 0;
  padding: 24px;
}
.card:hover {
  border-color: var(--border-heavy);
}

/* Featured card — inverted */
.card--inverted {
  background: var(--bg-inverted);
  color: var(--text-on-inverted);
  border: 2px solid var(--text-on-inverted);
}
```

### Form Inputs

```css
.input {
  background: transparent;
  color: var(--text-primary);
  padding: 12px 16px;
  border: 2px solid var(--border-medium);
  border-radius: 0;
  font-family: var(--font-mono);
  font-size: 14px;
  transition: border-color 100ms ease;
}
.input:focus {
  border-color: var(--accent);
  outline: none;
}
.input--error { border-color: var(--eval-fail); }
.input::placeholder {
  color: var(--text-tertiary);
  font-style: italic;
}
```

### Navigation

```css
/* Header bar */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 32px;
  border-bottom: 2px solid var(--border-heavy);
  background: var(--bg-primary);
}

/* Logo — display mono */
.logo {
  font-family: var(--font-mono);
  font-size: 24px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: -0.02em;
}
.logo .dot { color: var(--accent); }

/* Nav links in header */
.nav-link {
  font-family: var(--font-sans);
  font-size: 13px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-secondary);
  transition: color 100ms ease;
}
.nav-link:hover { color: var(--text-primary); }
.nav-link--active { color: var(--accent); }

/* Fullscreen menu overlay */
.menu-overlay {
  position: fixed;
  inset: 0;
  background: var(--bg-primary);
  display: grid;
  place-items: center;
  z-index: 100;
}
.menu-overlay .menu-item {
  font-family: var(--font-mono);
  font-size: clamp(32px, 6vw, 64px);
  font-weight: 700;
  text-transform: uppercase;
  color: var(--text-secondary);
  transition: color 150ms ease;
}
.menu-overlay .menu-item:hover {
  color: var(--accent);
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Button hover | Background/color swap | 100ms | ease |
| Input focus | Border color snap | 100ms | ease |
| Nav link hover | Color shift | 100ms | ease |
| Menu overlay open | Fade in | 200ms | ease |
| Graph node hover | Border color | 100ms | ease |
| Eval result load | Hard cut (no fade — results snap in) | 0ms | none |
| Card hover | Border color shift | 100ms | ease |
| Page transition | Hard cut | 0ms | none |

**Motion philosophy:** Abrupt, not smooth. Things appear or they don't. No easing curves, no staggered fades, no sliding panels. The only animated elements are hover states (100ms) and the menu overlay (200ms fade). Everything else is instant.

This is intentional: brutalist motion signals confidence. "The data is here. We're not performing for you."

Exception: `prefers-reduced-motion` is still respected — though there's less to reduce.

---

## Asset Guidelines

**Photography:** None. Raw screenshots and terminal output are acceptable as "imagery."

**Iconography:** Minimal. Prefer text labels over icons. When icons are necessary: Phosphor icons at 20px, bold weight. Or unicode characters (→, ✓, ✗, ⚠) as a brutalist shortcut.

**Data visualization:** Charts use thick strokes (2-3px), no fills, no gradients. Axes visible with labels in mono. Grid lines visible at full opacity (not subtle). Charts feel like they could be rendered in a terminal.

**Illustration:** None. If an empty state needs visual content, use ASCII art:

```
  ┌─────────────────────────────┐
  │                             │
  │    NO SCRIPTS YET           │
  │                             │
  │    $ codefresh new          │
  │                             │
  └─────────────────────────────┘
```

**Logo direction:** "CODEFRE.SH" in Space Mono at 700 weight, uppercase. The period is rendered in `--accent` (electric lime). Can be displayed at extreme sizes (full-viewport on marketing site).

---

## Accessibility Considerations

Neo-Brutalist inherently conflicts with some accessibility patterns. Required accommodations:

- [ ] All text meets WCAG AA contrast (neon-on-dark and dark-on-light both pass)
- [ ] Keyboard navigation works everywhere (focus indicators: 2px accent outlines)
- [ ] Skip navigation link for screen readers
- [ ] Fullscreen menu is keyboard-navigable
- [ ] No auto-playing animations
- [ ] `prefers-reduced-motion` respected
- [ ] Inverted sections maintain contrast ratios

**Contrast verification (critical):**

| Combination | Ratio | Status |
|---|---|---|
| #F5F5F0 on #0D0D0D | 17.4:1 | Pass AAA |
| #0D0D0D on #F5F5F0 | 17.4:1 | Pass AAA |
| #8A8A8A on #0D0D0D | 5.1:1 | Pass AA |
| #DCFF00 on #0D0D0D | 12.8:1 | Pass AAA |
| #00FF66 on #0D0D0D | 10.2:1 | Pass AAA |
| #FFD600 on #0D0D0D | 12.3:1 | Pass AAA |
| #FF3333 on #0D0D0D | 4.7:1 | Pass AA (large text) |

**Note:** `--eval-fail` (#FF3333) on dark bg is borderline for small text. Use at 14px+ or pair with a pass-fail icon for redundant encoding.

---

## Implementation Checklist

- [ ] Monospace (Space Mono) is the primary font — not a code-only fallback
- [ ] Sans (Space Grotesk) only for compact UI labels and nav
- [ ] No border-radius anywhere (all 0)
- [ ] Border width 2px minimum on containers and inputs
- [ ] Electric lime accent on dark, adjusted for light sections
- [ ] Fullscreen menu overlay instead of persistent sidebar
- [ ] Inverted (light) sections used for intentional contrast breaks
- [ ] ALL CAPS on H1 and H2 levels
- [ ] Hard-cut transitions (no sliding/fading page transitions)
- [ ] Charts use thick strokes, visible grid, terminal aesthetic
- [ ] Every unconventional choice documented with stated purpose
- [ ] Keyboard navigation functional across all surfaces
- [ ] WCAG AA contrast on all text
- [ ] --eval-fail (#FF3333) used at 14px+ or with redundant icon

---

*Derived from: bold-expressive.md (Neo-Brutalist sub-style)*
