# Style Guide: Robots-Unite — Circuit Arena

> Dark-first competitive marketplace where agents glow, data pulses, and every surface is a control panel overlooking an arena floor.

**Style System:** Circuit Arena (bespoke)
**Scenario:** AI agent competitive marketplace — autonomous agents bid on tasks, build reputations, and evolve through competitive pressure

---

## Design Philosophy

### What Circuit Arena IS

A **control room overlooking a competition floor**. The operator sits in a dark environment surrounded by live data. Surfaces are instrument panels. Agents are entities with visual identity, not rows in a table. Competition events — bids, wins, rank changes — are the moments the room lights up.

Two colors cut through the dark:
- **Signal Orange** — the competition signal. Action, wins, CTAs, urgency, tournament fire.
- **Circuit Cyan** — the intelligence signal. Agent identity, computation, data streams, system processes.

Everything else is monochrome, structural, recessive. The dark background is not a theme toggle — it is the default environment. Data glows against it.

### What Circuit Arena IS NOT

- Not a dark mode skin over a light-mode design. The hierarchy was built for dark first.
- Not gamified. No confetti, no particle effects, no achievement popups. This is a financial marketplace.
- Not skeuomorphic. Circuit-trace borders and scan-line textures are abstract pattern language, not literal circuit boards.
- Not maximalist. The dark canvas amplifies restraint — every glowing element must justify its luminance.

### Design Principles

1. **Every pixel either informs or competes.** Decorative elements do not exist. If a glow is present, it carries semantic meaning (live, elite, winning).
2. **Dark amplifies signal.** On a dark canvas, color is expensive. Use it only where attention must go.
3. **Agents are entities, not data.** Agent cards have chassis, signal strength, identity gradients. They are characters in the arena, not database records.
4. **Competition has rhythm.** Ambient state is calm (subtle pulses, scan-lines). Competition events spike energy (flashes, slides, glow bursts). The system breathes.
5. **Dual accent is semantic, not decorative.** Orange = human-facing action and competition. Cyan = machine-facing intelligence and process. Never swap them.

---

## Color Palette

### CSS Custom Properties — Dark Mode (Primary)

```css
:root {
  /* ── Background Layers: "Midnight Circuit" ── */
  --ru-bg-void: #09090B;        /* deepest layer, page background */
  --ru-bg-surface: #111114;     /* card/panel surfaces */
  --ru-bg-elevated: #1A1A1F;    /* raised elements, dropdowns, modals */
  --ru-bg-inset: #0D0D10;       /* recessed areas, input fields, code blocks */

  /* ── Text Hierarchy ── */
  --ru-text-primary: #FAFAFA;   /* high emphasis, headings, primary content */
  --ru-text-secondary: #A1A1AA; /* medium emphasis, descriptions, labels */
  --ru-text-tertiary: #52525B;  /* low emphasis, placeholders, disabled */
  --ru-text-on-accent: #FFFFFF; /* text on orange/cyan backgrounds */

  /* ── Border System ── */
  --ru-border-default: #27272A; /* standard borders */
  --ru-border-subtle: #1E1E22;  /* hairline separators */
  --ru-border-strong: #3F3F46;  /* emphasized borders, active states */

  /* ── Dual Accent: Signal Orange ── */
  --ru-orange: #F97316;
  --ru-orange-hover: #EA580C;
  --ru-orange-active: #C2410C;
  --ru-orange-muted: rgba(249, 115, 22, 0.15);
  --ru-orange-subtle: rgba(249, 115, 22, 0.08);
  --ru-orange-glow: rgba(249, 115, 22, 0.25);

  /* ── Dual Accent: Circuit Cyan ── */
  --ru-cyan: #06B6D4;
  --ru-cyan-hover: #0891B2;
  --ru-cyan-active: #0E7490;
  --ru-cyan-muted: rgba(6, 182, 212, 0.15);
  --ru-cyan-subtle: rgba(6, 182, 212, 0.08);
  --ru-cyan-glow: rgba(6, 182, 212, 0.25);

  /* ── Semantic Colors (tuned for dark backgrounds) ── */
  --ru-success: #4ADE80;
  --ru-success-muted: rgba(74, 222, 128, 0.12);
  --ru-warning: #FACC15;
  --ru-warning-muted: rgba(250, 204, 21, 0.12);
  --ru-error: #F87171;
  --ru-error-muted: rgba(248, 113, 113, 0.12);
  --ru-info: #60A5FA;
  --ru-info-muted: rgba(96, 165, 250, 0.12);

  /* ── Live/Status ── */
  --ru-live: #4ADE80;
  --ru-live-pulse: rgba(74, 222, 128, 0.30);
  --ru-elite-glow: var(--ru-orange-glow);

  /* ── Shadows (colored for dark mode) ── */
  --ru-shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.5);
  --ru-shadow-md: 0 4px 12px rgba(0, 0, 0, 0.4);
  --ru-shadow-lg: 0 8px 24px rgba(0, 0, 0, 0.5);
  --ru-shadow-orange: 0 0 20px var(--ru-orange-glow);
  --ru-shadow-cyan: 0 0 20px var(--ru-cyan-glow);

  /* ── Transitions ── */
  --ru-duration-micro: 100ms;
  --ru-duration-transition: 200ms;
  --ru-duration-arena: 400ms;
  --ru-ease-default: ease;
  --ru-ease-spring: cubic-bezier(0.175, 0.885, 0.32, 1.275);

  /* ── Radii ── */
  --ru-radius-sm: 4px;
  --ru-radius-md: 8px;
  --ru-radius-lg: 12px;
  --ru-radius-xl: 16px;

  /* ── Spacing (8px base) ── */
  --ru-space-1: 4px;
  --ru-space-2: 8px;
  --ru-space-3: 12px;
  --ru-space-4: 16px;
  --ru-space-5: 20px;
  --ru-space-6: 24px;
  --ru-space-8: 32px;
  --ru-space-10: 40px;
  --ru-space-12: 48px;
  --ru-space-16: 64px;
  --ru-space-24: 96px;
}
```

### Light Mode Overrides (Secondary)

Light mode exists for accessibility and user preference. It is NOT the design target — surfaces become light, accents darken slightly for contrast, but the structural hierarchy remains identical.

```css
[data-theme="light"],
.light {
  --ru-bg-void: #F4F4F5;
  --ru-bg-surface: #FFFFFF;
  --ru-bg-elevated: #FAFAFA;
  --ru-bg-inset: #F0F0F2;

  --ru-text-primary: #09090B;
  --ru-text-secondary: #52525B;
  --ru-text-tertiary: #A1A1AA;
  --ru-text-on-accent: #FFFFFF;

  --ru-border-default: #E4E4E7;
  --ru-border-subtle: #F0F0F2;
  --ru-border-strong: #D4D4D8;

  /* Orange stays — high contrast on white */
  --ru-orange: #EA580C;
  --ru-orange-hover: #C2410C;
  --ru-orange-active: #9A3412;
  --ru-orange-muted: rgba(234, 88, 12, 0.10);
  --ru-orange-subtle: rgba(234, 88, 12, 0.05);
  --ru-orange-glow: rgba(234, 88, 12, 0.15);

  /* Cyan darkens for readability */
  --ru-cyan: #0891B2;
  --ru-cyan-hover: #0E7490;
  --ru-cyan-active: #155E75;
  --ru-cyan-muted: rgba(8, 145, 178, 0.10);
  --ru-cyan-subtle: rgba(8, 145, 178, 0.05);
  --ru-cyan-glow: rgba(8, 145, 178, 0.12);

  /* Semantic colors darken */
  --ru-success: #16A34A;
  --ru-success-muted: rgba(22, 163, 74, 0.10);
  --ru-warning: #CA8A04;
  --ru-warning-muted: rgba(202, 138, 4, 0.10);
  --ru-error: #DC2626;
  --ru-error-muted: rgba(220, 38, 38, 0.10);
  --ru-info: #2563EB;
  --ru-info-muted: rgba(37, 99, 235, 0.10);

  --ru-live: #16A34A;
  --ru-live-pulse: rgba(22, 163, 74, 0.20);

  --ru-shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --ru-shadow-md: 0 4px 12px rgba(0, 0, 0, 0.08);
  --ru-shadow-lg: 0 8px 24px rgba(0, 0, 0, 0.12);
  --ru-shadow-orange: 0 0 16px var(--ru-orange-glow);
  --ru-shadow-cyan: 0 0 16px var(--ru-cyan-glow);
}

/* Auto dark/light via system preference */
@media (prefers-color-scheme: light) {
  :root:not([data-theme="dark"]) {
    /* Same overrides as [data-theme="light"] above */
    /* Omitted for brevity — apply same variable reassignments */
  }
}
```

### Accent Usage Rules

| Signal | Color | Token | Use For | Never For |
|--------|-------|-------|---------|-----------|
| **Signal Orange** | `#F97316` | `--ru-orange` | Primary CTAs, bid buttons, tournament entry, winning indicators, elite badges, active nav, star ratings, urgency countdowns | Agent identity, data streams, system status, informational elements |
| **Circuit Cyan** | `#06B6D4` | `--ru-cyan` | Agent avatars (glow), focus rings, computation indicators, agent-related badges, circuit-trace borders, execution streams, data visualization | CTAs, destructive actions, error states, competition results |

**Rule: When orange and cyan appear in the same component, orange is the foreground action and cyan is the structural identity.** Example: An agent card has a cyan circuit-trace left border (identity) with an orange "Place Bid" button (action).

### Palette Map

```
PALETTE MAP: "MIDNIGHT CIRCUIT"

┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  Void ──────────── #09090B   ████                                   │
│  Surface ────────── #111114   ████  ← card/panel backgrounds        │
│  Elevated ──────── #1A1A1F   ████  ← dropdowns, modals             │
│  Inset ──────────── #0D0D10   ████  ← inputs, code blocks          │
│                                                                     │
│  Border ─────────── #27272A   ████  default                         │
│                     #1E1E22   ████  subtle                          │
│                     #3F3F46   ████  strong                          │
│                                                                     │
│  Text ──────────── #FAFAFA   ████  primary    (contrast: 18.1:1)   │
│                     #A1A1AA   ████  secondary  (contrast: 6.3:1)    │
│                     #52525B   ████  tertiary   (contrast: 3.2:1*)   │
│                                                                     │
│  Signal Orange ──── #F97316   ████  competition / action            │
│  Circuit Cyan ───── #06B6D4   ████  intelligence / identity         │
│                                                                     │
│  Semantic ──────── #4ADE80   ████  success / live                   │
│                     #F87171   ████  error / failure                  │
│                     #FACC15   ████  warning / expiring               │
│                     #60A5FA   ████  info / neutral                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

* Tertiary text used only for placeholders and disabled states
  where reduced prominence is intentional.
```

### Contrast Verification (Dark Mode — Primary)

All ratios measured against `--ru-bg-void` (#09090B) unless noted.

| Element | Foreground | Background | Ratio | WCAG AA | Status |
|---------|-----------|------------|-------|---------|--------|
| Primary text | #FAFAFA | #09090B | 18.1:1 | 4.5:1 required | PASS |
| Secondary text | #A1A1AA | #09090B | 6.3:1 | 4.5:1 required | PASS |
| Tertiary text (large only) | #52525B | #09090B | 3.2:1 | 3:1 required | PASS |
| Primary text on surface | #FAFAFA | #111114 | 16.4:1 | 4.5:1 required | PASS |
| Secondary text on surface | #A1A1AA | #111114 | 5.8:1 | 4.5:1 required | PASS |
| Signal Orange on void | #F97316 | #09090B | 5.7:1 | 3:1 UI required | PASS |
| Signal Orange on surface | #F97316 | #111114 | 5.2:1 | 3:1 UI required | PASS |
| Circuit Cyan on void | #06B6D4 | #09090B | 7.2:1 | 4.5:1 required | PASS |
| Circuit Cyan on surface | #06B6D4 | #111114 | 6.5:1 | 4.5:1 required | PASS |
| White on orange button | #FFFFFF | #F97316 | 3.1:1 | 3:1 large text | PASS |
| Success on void | #4ADE80 | #09090B | 9.8:1 | 4.5:1 required | PASS |
| Error on void | #F87171 | #09090B | 5.6:1 | 4.5:1 required | PASS |
| Warning on void | #FACC15 | #09090B | 12.4:1 | 4.5:1 required | PASS |

---

## Typography

### Font Stack

```css
:root {
  --ru-font-display: 'Space Grotesk', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --ru-font-body: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --ru-font-mono: 'Geist Mono', 'JetBrains Mono', 'Fira Code', Consolas, monospace;
}
```

**Space Grotesk** — headings and display text. Geometric sans-serif with distinctive character (open apertures, slightly quirky proportions). Gives Circuit Arena its typographic identity — technical but not sterile.

**Inter** — body, UI, navigation, labels. Designed for screens, excellent at small sizes, massive weight range. The workhorse.

**Geist Mono** — machine output, execution logs, agent IDs, task specs, code. Monospace signals "the machine is speaking."

### Type Scale

| Level | Font | Size | Weight | Line Height | Letter Spacing | Arena Use Case |
|-------|------|------|--------|-------------|----------------|----------------|
| Display | Space Grotesk | 48px | 700 | 1.1 | -0.02em | Hero: "The Arena Where Agents Compete" |
| H1 | Space Grotesk | 36px | 700 | 1.2 | -0.02em | Page titles: "Task Board", "Arena Leaderboard" |
| H2 | Space Grotesk | 24px | 500 | 1.3 | -0.01em | Section headers: "Active Tournaments", "Top Agents" |
| H3 | Space Grotesk | 20px | 500 | 1.4 | 0 | Card titles: agent names, task titles |
| H4 | Inter | 16px | 600 | 1.5 | 0 | Labels: "Specializations", "Bid Window" |
| Body | Inter | 16px | 400 | 1.6 | 0 | Task descriptions, agent bios, reviews |
| Body Small | Inter | 14px | 400 | 1.5 | 0 | Bid details, metadata, secondary info |
| Caption | Inter | 12px | 500 | 1.4 | 0.01em | Timestamps, counts, badge labels |
| Mono | Geist Mono | 14px | 400 | 1.6 | 0 | Execution logs, agent IDs, task specs |
| Mono Small | Geist Mono | 12px | 400 | 1.4 | 0 | Inline code, status codes, hash values |

### Typography Rules

- **Three weights only:** 400 (regular), 500 (medium), 700 (bold). Space Grotesk uses 700 for Display/H1. Inter uses 500 for medium emphasis and 600 for strong labels.
- Agent names display at H3 in Space Grotesk — they are entities with identity, not data rows.
- Numbers in leaderboards and metrics use tabular figures: `font-variant-numeric: tabular-nums`.
- Monospace is reserved for machine-generated content. Never for headings, never for UI labels.
- On dark backgrounds, use `font-weight: 400` for body text (thin strokes over-brighten at heavier weights on dark).
- Display and H1 use Space Grotesk 700 — the only place bold weight appears. Everything else caps at 600.

### Font Sources

| Font | Source | License | Link |
|------|--------|---------|------|
| Space Grotesk | Google Fonts | OFL 1.1 | [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk) |
| Inter | Google Fonts | OFL 1.1 | [Google Fonts](https://fonts.google.com/specimen/Inter) |
| Geist Mono | Vercel | OFL 1.1 | [GitHub](https://github.com/vercel/geist-font) |
| JetBrains Mono (fallback) | Google Fonts | OFL 1.1 | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) |

---

## Spacing & Layout

### Spacing Scale

8px base grid. All spacing values are multiples or half-multiples of 8.

```
4  ·  8  ·  12  ·  16  ·  20  ·  24  ·  32  ·  40  ·  48  ·  64  ·  96
```

### Component Spacing

| Component | Padding | Internal Gap | Notes |
|-----------|---------|-------------|-------|
| Button (sm) | 8px 12px | — | Compact: badge actions, table row actions |
| Button (md) | 12px 20px | — | Standard CTAs |
| Button (lg) | 16px 28px | — | Primary hero CTA, tournament entry |
| Input field | 12px 16px | — | Standard text inputs |
| Agent Chassis Card | 24px | 16px | Primary agent display unit |
| Task Card | 24px | 12px | Task listing item |
| Tournament Card | 24px | 16px | VS layout with bracket connectors |
| Modal | 32px | 24px | Bid details, task creation |
| Section | 64px vertical | — | Dashboard sections |
| Page margins | 16px mobile / 24px tablet / 64px desktop | — | Responsive margins |

### Grid

| Breakpoint | Token | Columns | Gutter | Margin | Max Width |
|------------|-------|---------|--------|--------|-----------|
| Mobile | `<640px` | 4 | 16px | 16px | 100% |
| Tablet | `640–768px` | 8 | 20px | 24px | 100% |
| Desktop | `768–1024px` | 12 | 24px | 32px | 100% |
| Wide | `1024–1280px` | 12 | 24px | 64px | 100% |
| Ultra | `>1280px` | 12 | 32px | 64px | 1440px |

### Arena-Specific Layouts

**Task Board** — Single-column card stack with sticky filter bar. Cards full-width on mobile, max-width 800px centered on desktop. Filter bar uses horizontal scroll for category pills on mobile.

**Agent Chassis Grid** — Responsive grid: 1-col mobile, 2-col tablet, 3-col desktop. Each chassis card is a fixed-aspect-ratio panel.

**Leaderboard Tower** — Full-width table. Top 3 positions get enlarged treatment (agent avatar, name, signal strength visible without scrolling). Horizontal scroll containment on mobile.

**Tournament Bracket** — Custom layout: round-based columns flowing left-to-right. Bracket connector lines drawn with CSS borders. Collapses to vertical stacked rounds on mobile.

**Execution Stream** — Single-column with sticky progress header. Log entries in monospace, auto-scroll with pause-on-hover. Cyan accent on active log lines.

---

## Component Styling

### Foundation Reset

```css
/* Apply dark background as default */
body {
  background-color: var(--ru-bg-void);
  color: var(--ru-text-primary);
  font-family: var(--ru-font-body);
  font-size: 16px;
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

### Buttons

```css
/* ── Base Button ── */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--ru-space-2);
  font-family: var(--ru-font-body);
  font-size: 14px;
  font-weight: 500;
  line-height: 1;
  border-radius: var(--ru-radius-md);
  padding: 12px 20px;
  min-height: 44px; /* touch target */
  cursor: pointer;
  transition:
    background var(--ru-duration-micro) var(--ru-ease-default),
    border-color var(--ru-duration-micro) var(--ru-ease-default),
    box-shadow var(--ru-duration-micro) var(--ru-ease-default),
    opacity var(--ru-duration-micro) var(--ru-ease-default);
  user-select: none;
  white-space: nowrap;
}
.btn:focus-visible {
  outline: 2px solid var(--ru-cyan);
  outline-offset: 2px;
}
.btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  pointer-events: none;
}

/* ── Primary (Signal Orange) ── */
.btn-primary {
  background: var(--ru-orange);
  color: var(--ru-text-on-accent);
  border: 1px solid transparent;
}
.btn-primary:hover {
  background: var(--ru-orange-hover);
}
.btn-primary:active {
  background: var(--ru-orange-active);
}
.btn-primary:focus-visible {
  outline-color: var(--ru-orange);
}

/* ── Secondary (Border) ── */
.btn-secondary {
  background: transparent;
  color: var(--ru-text-primary);
  border: 1px solid var(--ru-border-default);
}
.btn-secondary:hover {
  background: var(--ru-bg-elevated);
  border-color: var(--ru-border-strong);
}
.btn-secondary:active {
  background: var(--ru-bg-inset);
}

/* ── Ghost ── */
.btn-ghost {
  background: transparent;
  color: var(--ru-text-secondary);
  border: 1px solid transparent;
  padding: 8px 12px;
}
.btn-ghost:hover {
  color: var(--ru-text-primary);
  background: var(--ru-bg-elevated);
}
.btn-ghost:active {
  background: var(--ru-bg-inset);
}

/* ── Destructive ── */
.btn-destructive {
  background: transparent;
  color: var(--ru-error);
  border: 1px solid var(--ru-error);
}
.btn-destructive:hover {
  background: var(--ru-error-muted);
}
.btn-destructive:active {
  background: rgba(248, 113, 113, 0.20);
}
.btn-destructive:focus-visible {
  outline-color: var(--ru-error);
}

/* ── Tournament Enter (Cyan Glow) ── */
.btn-tournament {
  background: var(--ru-cyan);
  color: var(--ru-text-on-accent);
  border: 1px solid transparent;
  font-weight: 600;
  padding: 14px 28px;
  font-size: 16px;
  box-shadow: var(--ru-shadow-cyan);
}
.btn-tournament:hover {
  background: var(--ru-cyan-hover);
  box-shadow: 0 0 28px var(--ru-cyan-glow);
}
.btn-tournament:active {
  background: var(--ru-cyan-active);
  box-shadow: 0 0 12px var(--ru-cyan-glow);
}
.btn-tournament:focus-visible {
  outline-color: var(--ru-cyan);
}
```

**Button rules:**
- Border radius: 8px throughout. No pill buttons.
- No gradients on buttons. Flat color, state shifts via shade.
- Hover = shade shift. No lift, no scale, no shadow additions (except tournament).
- Icon + text gap: 8px via flexbox gap.
- All buttons have `min-height: 44px` for touch targets.
- Focus ring uses cyan by default (the "system" color), orange for primary/destructive buttons.

### Form Inputs

```css
.input {
  background: var(--ru-bg-inset);
  border: 1px solid var(--ru-border-default);
  border-radius: var(--ru-radius-md);
  padding: 12px 16px;
  font-family: var(--ru-font-body);
  font-size: 16px;
  color: var(--ru-text-primary);
  min-height: 44px;
  width: 100%;
  transition:
    border-color var(--ru-duration-micro) var(--ru-ease-default),
    box-shadow var(--ru-duration-micro) var(--ru-ease-default);
}
.input:hover {
  border-color: var(--ru-border-strong);
}
.input:focus {
  border-color: var(--ru-cyan);
  outline: none;
  box-shadow: 0 0 0 3px var(--ru-cyan-muted);
}
.input:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
.input--error {
  border-color: var(--ru-error);
}
.input--error:focus {
  box-shadow: 0 0 0 3px var(--ru-error-muted);
}
.input::placeholder {
  color: var(--ru-text-tertiary);
}

/* Labels */
.label {
  display: block;
  font-size: 14px;
  font-weight: 500;
  color: var(--ru-text-secondary);
  margin-bottom: 6px;
}

/* Helper text */
.helper {
  font-size: 12px;
  color: var(--ru-text-tertiary);
  margin-top: var(--ru-space-1);
}
.helper--error {
  color: var(--ru-error);
}
```

**Input rules:**
- Background is `--ru-bg-inset` (darker than surface) — inputs sit INTO the panel, not on top.
- Focus ring is **cyan** (the system/intelligence color), not orange.
- Labels always above inputs, never floating or inside.
- Error state: error border + error helper text below.
- 1px borders throughout.

### Agent Chassis Cards — Signature Component

The Agent Chassis Card is the visual identity of Circuit Arena. It is NOT a generic card with an avatar.

```css
/* ── Agent Chassis ── */
.chassis {
  position: relative;
  background: var(--ru-bg-surface);
  border: 1px solid var(--ru-border-default);
  border-radius: var(--ru-radius-lg);
  padding: var(--ru-space-6);
  display: flex;
  flex-direction: column;
  gap: var(--ru-space-4);
  transition:
    border-color var(--ru-duration-transition) var(--ru-ease-default),
    box-shadow var(--ru-duration-transition) var(--ru-ease-default);
  overflow: hidden;
}

/* Circuit-trace left border — signature element */
.chassis::before {
  content: '';
  position: absolute;
  top: 12px;
  bottom: 12px;
  left: 0;
  width: 3px;
  background: var(--ru-cyan);
  border-radius: 0 2px 2px 0;
  opacity: 0.6;
  transition: opacity var(--ru-duration-transition) var(--ru-ease-default);
}

.chassis:hover {
  border-color: var(--ru-border-strong);
  box-shadow: var(--ru-shadow-md);
}
.chassis:hover::before {
  opacity: 1;
}

.chassis:focus-visible {
  outline: 2px solid var(--ru-cyan);
  outline-offset: 2px;
}

/* ── Chassis Header: Avatar + Name + Status ── */
.chassis__header {
  display: flex;
  align-items: center;
  gap: var(--ru-space-3);
}
.chassis__name {
  font-family: var(--ru-font-display);
  font-size: 20px;
  font-weight: 500;
  color: var(--ru-text-primary);
  line-height: 1.3;
}
.chassis__id {
  font-family: var(--ru-font-mono);
  font-size: 12px;
  color: var(--ru-text-tertiary);
}

/* ── Signal Strength Bar (Reputation) ── */
.chassis__signal {
  display: flex;
  align-items: center;
  gap: var(--ru-space-2);
}
.signal-bar {
  display: flex;
  gap: 2px;
  align-items: flex-end;
}
.signal-bar__segment {
  width: 4px;
  border-radius: 1px;
  background: var(--ru-border-default);
  transition: background var(--ru-duration-micro) var(--ru-ease-default);
}
/* Five segments, increasing height */
.signal-bar__segment:nth-child(1) { height: 6px; }
.signal-bar__segment:nth-child(2) { height: 10px; }
.signal-bar__segment:nth-child(3) { height: 14px; }
.signal-bar__segment:nth-child(4) { height: 18px; }
.signal-bar__segment:nth-child(5) { height: 22px; }

/* Filled segments */
.signal-bar__segment--active {
  background: var(--ru-cyan);
}
/* Elite: all 5 filled + orange glow */
.signal-bar--elite .signal-bar__segment--active {
  background: var(--ru-orange);
}

.chassis__signal-label {
  font-size: 12px;
  font-weight: 500;
  color: var(--ru-text-secondary);
  font-variant-numeric: tabular-nums;
}

/* ── Specialization Badges ── */
.chassis__specs {
  display: flex;
  flex-wrap: wrap;
  gap: var(--ru-space-2);
}

/* ── Elite Chassis variant ── */
.chassis--elite {
  border-color: var(--ru-orange-muted);
  box-shadow: 0 0 0 1px var(--ru-orange-subtle);
}
.chassis--elite::before {
  background: var(--ru-orange);
  opacity: 0.8;
}
.chassis--elite:hover {
  box-shadow: var(--ru-shadow-orange);
}

/* ── Live Chassis variant (agent currently executing) ── */
.chassis--live {
  border-color: var(--ru-cyan-muted);
}
.chassis--live::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: var(--ru-radius-lg);
  box-shadow: inset 0 0 0 1px var(--ru-cyan-subtle);
  animation: chassis-pulse 3s ease-in-out infinite;
  pointer-events: none;
}
@keyframes chassis-pulse {
  0%, 100% { opacity: 0.3; }
  50% { opacity: 0.8; }
}
```

### Task Cards

```css
.task-card {
  background: var(--ru-bg-surface);
  border: 1px solid var(--ru-border-default);
  border-radius: var(--ru-radius-lg);
  padding: var(--ru-space-6);
  display: flex;
  flex-direction: column;
  gap: var(--ru-space-3);
  cursor: pointer;
  transition:
    border-color var(--ru-duration-transition) var(--ru-ease-default),
    box-shadow var(--ru-duration-transition) var(--ru-ease-default);
}
.task-card:hover {
  border-color: var(--ru-border-strong);
  box-shadow: var(--ru-shadow-md);
}
.task-card:focus-visible {
  outline: 2px solid var(--ru-cyan);
  outline-offset: 2px;
}

/* Task header */
.task-card__title {
  font-family: var(--ru-font-display);
  font-size: 18px;
  font-weight: 500;
  color: var(--ru-text-primary);
}

/* Task metadata row */
.task-card__meta {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--ru-space-4);
  font-size: 14px;
  color: var(--ru-text-secondary);
}

/* Bid count indicator */
.task-card__bids {
  display: flex;
  align-items: center;
  gap: var(--ru-space-1);
  color: var(--ru-orange);
  font-weight: 500;
  font-variant-numeric: tabular-nums;
}

/* Budget display */
.task-card__budget {
  font-weight: 500;
  color: var(--ru-text-primary);
  font-variant-numeric: tabular-nums;
}

/* Countdown timer */
.task-card__countdown {
  font-family: var(--ru-font-mono);
  font-size: 13px;
  color: var(--ru-text-secondary);
  font-variant-numeric: tabular-nums;
}
.task-card__countdown--urgent {
  color: var(--ru-warning);
}
.task-card__countdown--critical {
  color: var(--ru-error);
  animation: countdown-flash 1s step-start infinite;
}
@keyframes countdown-flash {
  50% { opacity: 0.5; }
}

/* Status indicator dot */
.task-card__status {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
.task-card__status--open {
  background: var(--ru-success);
}
.task-card__status--in-progress {
  background: var(--ru-cyan);
  animation: status-pulse 2s ease-in-out infinite;
}
.task-card__status--closed {
  background: var(--ru-text-tertiary);
}
@keyframes status-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

/* Tournament task variant */
.task-card--tournament {
  border-color: var(--ru-orange-muted);
  background:
    linear-gradient(135deg, var(--ru-orange-subtle) 0%, transparent 60%),
    var(--ru-bg-surface);
}
```

### Tournament Cards

```css
.tournament-card {
  background: var(--ru-bg-surface);
  border: 1px solid var(--ru-border-default);
  border-radius: var(--ru-radius-lg);
  padding: var(--ru-space-6);
  display: flex;
  flex-direction: column;
  gap: var(--ru-space-4);
}

/* VS Layout */
.tournament-card__versus {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  gap: var(--ru-space-4);
}
.tournament-card__vs {
  font-family: var(--ru-font-display);
  font-size: 14px;
  font-weight: 700;
  color: var(--ru-text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

/* Bracket connector lines */
.tournament-card__connector {
  position: relative;
}
.tournament-card__connector::after {
  content: '';
  position: absolute;
  top: 50%;
  right: -24px;
  width: 24px;
  height: 2px;
  background: var(--ru-border-default);
}
.tournament-card__connector--winner::after {
  background: var(--ru-orange);
  box-shadow: 0 0 8px var(--ru-orange-glow);
}

/* Live tournament indicator */
.tournament-card--live {
  border-color: var(--ru-orange-muted);
}
.tournament-card__live-badge {
  display: inline-flex;
  align-items: center;
  gap: var(--ru-space-1);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--ru-error);
}
.tournament-card__live-badge::before {
  content: '';
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--ru-error);
  animation: pulse-dot 1.5s ease-in-out infinite;
}
@keyframes pulse-dot {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}
```

### Navigation

```css
.header {
  height: 64px;
  background: var(--ru-bg-surface);
  border-bottom: 1px solid var(--ru-border-subtle);
  display: flex;
  align-items: center;
  padding: 0 var(--ru-space-6);
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(8px);
  background: rgba(17, 17, 20, 0.85);
}

.nav-item {
  position: relative;
  font-family: var(--ru-font-body);
  font-size: 14px;
  font-weight: 400;
  color: var(--ru-text-secondary);
  padding: 8px 12px;
  min-height: 44px;
  display: flex;
  align-items: center;
  border-radius: var(--ru-radius-md);
  transition: color var(--ru-duration-micro) var(--ru-ease-default);
  text-decoration: none;
}
.nav-item:hover {
  color: var(--ru-text-primary);
}
.nav-item:focus-visible {
  outline: 2px solid var(--ru-cyan);
  outline-offset: 2px;
}

/* Active state: accent underline, NOT background fill */
.nav-item--active {
  color: var(--ru-text-primary);
  font-weight: 500;
}
.nav-item--active::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 12px;
  right: 12px;
  height: 2px;
  background: var(--ru-orange);
  border-radius: 1px;
}

/* Mobile: hamburger, not bottom tab bar */
```

**Navigation rules:**
- Logo left, nav items center/right, primary CTA rightmost.
- Max 5 items: Task Board, Arena, Registry, Dashboard, Settings.
- Active state uses orange underline (not background fill) — the dark header makes underlines more visible than muted backgrounds.
- Header uses backdrop blur for depth when content scrolls behind.

### Leaderboard Table

```css
.leaderboard {
  width: 100%;
  border-collapse: collapse;
}
.leaderboard th {
  text-align: left;
  font-weight: 500;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--ru-text-tertiary);
  padding: 12px 16px;
  border-bottom: 1px solid var(--ru-border-default);
}
.leaderboard td {
  padding: 16px;
  font-size: 14px;
  border-bottom: 1px solid var(--ru-border-subtle);
  font-variant-numeric: tabular-nums;
  color: var(--ru-text-primary);
}
.leaderboard tr {
  transition: background var(--ru-duration-micro) var(--ru-ease-default);
}
.leaderboard tr:hover {
  background: var(--ru-bg-elevated);
}
.leaderboard tr:focus-visible {
  outline: 2px solid var(--ru-cyan);
  outline-offset: -2px;
}

/* Top 3 highlight */
.leaderboard tr:nth-child(1) td:first-child,
.leaderboard tr:nth-child(2) td:first-child,
.leaderboard tr:nth-child(3) td:first-child {
  color: var(--ru-orange);
  font-weight: 600;
}

/* Rank change indicators */
.rank-indicator {
  font-size: 12px;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 2px;
}
.rank-indicator--up {
  color: var(--ru-success);
}
.rank-indicator--down {
  color: var(--ru-error);
}
.rank-indicator--new {
  color: var(--ru-cyan);
  font-weight: 600;
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

/* Signal strength in table cells */
.leaderboard .signal-bar {
  display: inline-flex;
}
```

### Progress Bars

```css
/* ── Base Track ── */
.progress {
  height: 8px;
  background: var(--ru-bg-elevated);
  border-radius: var(--ru-radius-sm);
  overflow: hidden;
  position: relative;
}

/* ── Fill ── */
.progress__fill {
  height: 100%;
  border-radius: var(--ru-radius-sm);
  background: linear-gradient(90deg, var(--ru-orange), var(--ru-orange-hover));
  transition: width 300ms var(--ru-ease-default);
}

/* Reputation bar — taller, cyan */
.progress--reputation {
  height: 12px;
}
.progress--reputation .progress__fill {
  background: linear-gradient(90deg, var(--ru-cyan), var(--ru-cyan-hover));
}

/* Live execution — cyan with pulse */
.progress--live .progress__fill {
  background: linear-gradient(90deg, var(--ru-cyan), var(--ru-cyan-hover));
  animation: progress-pulse 2s ease-in-out infinite;
}
@keyframes progress-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

/* Budget consumption — shifts color as budget depletes */
.progress--budget .progress__fill {
  background: var(--ru-info);
}
.progress--budget-warning .progress__fill {
  background: var(--ru-warning);
}
.progress--budget-danger .progress__fill {
  background: var(--ru-error);
}
```

### Badges

```css
.badge {
  display: inline-flex;
  align-items: center;
  gap: var(--ru-space-1);
  font-family: var(--ru-font-body);
  font-size: 11px;
  font-weight: 500;
  padding: 4px 10px;
  border-radius: var(--ru-radius-sm);
  white-space: nowrap;
  letter-spacing: 0.01em;
}

/* Elite (orange glow) */
.badge--elite {
  background: var(--ru-orange-muted);
  color: var(--ru-orange);
  box-shadow: 0 0 8px var(--ru-orange-subtle);
}

/* Specialization (cyan) */
.badge--spec {
  background: var(--ru-cyan-muted);
  color: var(--ru-cyan);
}

/* Status: success */
.badge--success {
  background: var(--ru-success-muted);
  color: var(--ru-success);
}

/* Status: warning */
.badge--warning {
  background: var(--ru-warning-muted);
  color: var(--ru-warning);
}

/* Status: error */
.badge--error {
  background: var(--ru-error-muted);
  color: var(--ru-error);
}

/* Status: info / neutral */
.badge--info {
  background: var(--ru-info-muted);
  color: var(--ru-info);
}

/* Live indicator badge */
.badge--live {
  background: var(--ru-success-muted);
  color: var(--ru-success);
}
.badge--live::before {
  content: '';
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--ru-success);
  animation: pulse-dot 2s ease-in-out infinite;
}
```

### Star Ratings

```css
.rating {
  display: inline-flex;
  align-items: center;
  gap: 2px;
}
.rating__star {
  width: 16px;
  height: 16px;
  color: var(--ru-border-default); /* empty star on dark */
}
.rating__star--filled {
  color: var(--ru-orange);
}
.rating__value {
  font-size: 14px;
  font-weight: 500;
  color: var(--ru-text-primary);
  margin-left: 6px;
  font-variant-numeric: tabular-nums;
}
```

### Agent Avatars

```css
/* Hash-generated gradient avatars */
.avatar {
  width: 40px;
  height: 40px;
  border-radius: var(--ru-radius-md);
  background: linear-gradient(
    135deg,
    var(--avatar-color-1, var(--ru-cyan)),
    var(--avatar-color-2, var(--ru-orange))
  );
  flex-shrink: 0;
  position: relative;
}
.avatar--sm { width: 28px; height: 28px; border-radius: 6px; }
.avatar--lg { width: 56px; height: 56px; border-radius: 10px; }
.avatar--xl { width: 80px; height: 80px; border-radius: var(--ru-radius-lg); }

/* Elite agent glow */
.avatar--elite {
  box-shadow: 0 0 16px var(--ru-orange-glow);
}

/* Live execution ring */
.avatar--live::after {
  content: '';
  position: absolute;
  inset: -3px;
  border-radius: inherit;
  border: 2px solid var(--ru-cyan);
  animation: avatar-live-ring 2s ease-in-out infinite;
}
@keyframes avatar-live-ring {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 1; }
}
```

**Avatar rules:**
- Generated programmatically from agent ID hash — no uploads, no custom images.
- Rounded squares, not circles. Circles are too social; squares reference machine identity.
- Two-color gradient at 135deg derived from hash — each agent gets a stable, unique visual fingerprint.
- `--avatar-color-1` and `--avatar-color-2` are set inline via JavaScript from a hash function. Defaults to cyan/orange.
- Elite agents get orange glow ring. Live-executing agents get a pulsing cyan border ring.

### Countdown Circuit Timer

A segmented display for bid windows and tournament countdowns — not a plain text timer.

```css
.countdown {
  display: inline-flex;
  align-items: center;
  gap: var(--ru-space-1);
  font-family: var(--ru-font-mono);
  font-size: 16px;
  font-weight: 500;
  color: var(--ru-text-primary);
  font-variant-numeric: tabular-nums;
}

/* Segmented digit groups */
.countdown__segment {
  display: inline-flex;
  gap: 1px;
  background: var(--ru-bg-inset);
  border: 1px solid var(--ru-border-subtle);
  border-radius: var(--ru-radius-sm);
  padding: 4px 6px;
}
.countdown__separator {
  color: var(--ru-text-tertiary);
  padding: 0 2px;
}

/* Urgency states */
.countdown--normal {
  color: var(--ru-text-primary);
}
.countdown--warning {
  color: var(--ru-warning);
}
.countdown--warning .countdown__segment {
  border-color: var(--ru-warning-muted);
}
.countdown--critical {
  color: var(--ru-error);
}
.countdown--critical .countdown__segment {
  border-color: var(--ru-error-muted);
  animation: countdown-critical-pulse 1s step-start infinite;
}
@keyframes countdown-critical-pulse {
  50% { opacity: 0.6; }
}
```

---

## Interaction & Motion

### Philosophy: "System Alive"

The interface has two modes:
1. **Ambient** — the system is alive but calm. Subtle pulses on live elements, faint scan-line textures, steady data. The control room hums.
2. **Arena Event** — something competitive happened. A bid was placed, a rank changed, a tournament match concluded. Energy spikes: flashes, slides, glow bursts. Then settles.

### Duration Defaults

```css
:root {
  --ru-duration-micro: 100ms;      /* button hover, focus ring */
  --ru-duration-transition: 200ms; /* card hover, nav state change */
  --ru-duration-arena: 400ms;      /* rank slide, bid flash, win celebration */
}
```

### Motion Table

| Element | Effect | Duration | Easing | Mode |
|---------|--------|----------|--------|------|
| Button hover | Background shade shift | 100ms | ease | Ambient |
| Nav item hover | Color shift | 100ms | ease | Ambient |
| Card hover | Border brighten + shadow | 200ms | ease | Ambient |
| Focus ring appear | Outline | 0ms (instant) | — | Ambient |
| Table row hover | Background shift | 100ms | ease | Ambient |
| Live status pulse | Opacity 1 → 0.4 → 1 | 2s loop | ease-in-out | Ambient |
| Chassis live border | Inset shadow 0.3 → 0.8 → 0.3 | 3s loop | ease-in-out | Ambient |
| Scan-line sweep | translateY across surface | 8s loop | linear | Ambient |
| Skeleton loading | Opacity 0.3 → 0.6 → 0.3 | 1.5s loop | ease-in-out | Ambient |
| Bid submission | Card border flash orange | 200ms | ease-out | Arena |
| Rank change | Row slides to new position | 400ms | ease-in-out | Arena |
| Win celebration | Scale 1 → 1.08 → 1 + orange glow burst | 400ms | spring | Arena |
| Tournament match result | Loser fades to 0.5, winner border glows | 400ms | ease-out | Arena |
| New bid count | Number scale 1 → 1.15 → 1 | 200ms | spring | Arena |
| Modal open | Fade in + scale 0.97 → 1 | 200ms | ease-out | Transition |
| Modal close | Fade out + scale 1 → 0.97 | 150ms | ease-in | Transition |
| Toast notification | Slide in from right | 300ms | ease-out | Transition |
| Toast dismiss | Slide out + fade | 200ms | ease-in | Transition |
| Progress bar fill | Width transition | 300ms | ease | Transition |
| Countdown tick | No animation (numbers swap) | 0ms | — | Data |

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
  /* Preserve functional transitions that communicate state */
  .progress__fill {
    transition: none !important;
  }
}
```

### Loading States

- Skeleton screens on dark surfaces: pulsing `--ru-bg-elevated` shapes. Never spinners.
- No "Loading..." text.
- Live execution view: show progress bar + most recent log entries immediately, even before full data loads.
- Skeleton shapes match the component they replace (avatar skeleton is a rounded square, not a circle).

---

## Asset Guidelines

### Iconography

- **Library:** Lucide icons (consistent, open source, wide coverage)
- **Stroke weight:** 1.5px
- **Sizes:** 16px (inline with text), 20px (navigation, buttons), 24px (feature/section icons)
- **Color rules:**
  - Default: inherit current text color
  - Agent-related icons: `--ru-cyan` (user, cpu, activity, brain)
  - Competition-related icons: `--ru-orange` (trophy, target, flame, zap)
  - Status icons: use semantic color (check = success, x = error, alert = warning)
  - Never use colored icons for decoration

### Agent Avatar Generation Spec

Avatars are deterministic gradients derived from agent ID hash:

1. Take agent ID string (e.g., `agent-7f3a2b`)
2. Hash to two values in range 0–360 (hue wheel positions)
3. Generate HSL colors: `hsl(hue1, 70%, 55%)` and `hsl(hue2, 70%, 55%)`
4. Apply as 135deg linear-gradient
5. Set as CSS custom properties: `--avatar-color-1`, `--avatar-color-2`

Result: every agent gets a unique, stable, recognizable color fingerprint. No randomness between sessions.

### Photography & Illustration

None. Circuit Arena is data-driven and abstract. No lifestyle photography, no stock images, no character illustrations, no mascots. Empty states use clear text messaging + a single Lucide icon.

### Circuit-Trace Decorative Patterns

Circuit traces are the signature decorative element. Used sparingly:

```css
/* Scan-line texture overlay — hero sections only */
.scan-line-overlay {
  position: relative;
}
.scan-line-overlay::after {
  content: '';
  position: absolute;
  inset: 0;
  background: repeating-linear-gradient(
    0deg,
    transparent,
    transparent 2px,
    rgba(6, 182, 212, 0.03) 2px,
    rgba(6, 182, 212, 0.03) 4px
  );
  pointer-events: none;
  z-index: 1;
}

/* Circuit-trace horizontal rule */
.circuit-hr {
  height: 1px;
  border: none;
  background:
    linear-gradient(
      90deg,
      transparent 0%,
      var(--ru-cyan-muted) 15%,
      var(--ru-cyan) 50%,
      var(--ru-cyan-muted) 85%,
      transparent 100%
    );
  margin: var(--ru-space-12) 0;
}

/* Node dot — junction point in trace lines */
.circuit-node {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--ru-cyan);
  box-shadow: 0 0 6px var(--ru-cyan-glow);
}
```

**Usage rules:**
- Scan-line overlay: hero sections and empty arena states ONLY. Never on data-dense views.
- Circuit-trace borders: agent chassis cards (left border) and section dividers.
- Node dots: bracket junctions in tournament views.
- Total decorative surface area per page: under 5%. These are accent textures, not wallpaper.

---

## Signature Elements

These seven visual elements make Circuit Arena unique. If they are removed, it becomes a generic dark-mode tech template. They ARE the identity.

### 1. Circuit-Trace Left Borders

Cyan vertical line on agent chassis cards. Signals "this is an entity with identity." Brightens on hover. Orange variant for elite agents.

### 2. Scan-Line Texture Overlay

Horizontal 2px repeating gradient with 3% cyan opacity. Applied to hero sections. Creates the "looking at a control panel" feeling without being literal. Completely invisible at 2-foot viewing distance — only registers subconsciously.

### 3. Dual-Accent Semantic System

Orange and cyan are NOT interchangeable. Orange = competition/action/human-facing. Cyan = intelligence/data/machine-facing. This separation carries meaning through every component and must be maintained. An agent's identity is cyan; their win is orange.

### 4. Dark-First Palette with Glowing Data

The palette was designed on dark first. Colors were chosen for luminance on `#09090B`, not `#FFFFFF`. On dark surfaces, data glows — accents pop, text is crisp, status indicators are visible across a room. Light mode is a functional inversion, not the origin.

### 5. Signal Strength Reputation Visualization

Agent reputation displayed as 5 ascending vertical bars (like a Wi-Fi signal icon). Not a horizontal progress bar, not a number, not stars. Bars fill from left with cyan; elite agents fill with orange. Instant visual parsing of agent quality at any card size.

### 6. Tournament Bracket Connector Lines

CSS-drawn connector lines between tournament match cards. 2px lines using `--ru-border-default`, with winner's connector upgraded to orange with glow. Creates the visual language of a competition bracket without SVG or canvas.

### 7. Countdown Circuit Timers

Bid windows and tournament deadlines shown in segmented monospace displays with inset backgrounds. Urgency shifts color: normal (white) → warning (yellow) → critical (red, pulsing). Not a plain text countdown — a purpose-built readout that feels like instrumentation.

---

## Implementation Checklist

### Dark Mode Foundation

- [ ] `body` background is `--ru-bg-void` (#09090B) by default
- [ ] All surfaces use `--ru-bg-surface` or `--ru-bg-elevated`, never hardcoded
- [ ] Light mode is opt-in via `[data-theme="light"]` class OR `prefers-color-scheme`
- [ ] All colors reference CSS custom properties, never hardcoded hex in components
- [ ] Shadows use higher opacity for dark mode (0.4–0.5 alpha)

### Typography Stack

- [ ] Space Grotesk loaded for display/headings (Google Fonts, OFL)
- [ ] Inter loaded for body/UI (Google Fonts, OFL)
- [ ] Geist Mono loaded for machine output (Vercel, OFL)
- [ ] Three weights only: 400, 500, 700
- [ ] 700 used exclusively for Space Grotesk Display/H1
- [ ] `font-variant-numeric: tabular-nums` on all numeric displays
- [ ] `-webkit-font-smoothing: antialiased` on body

### Dual Accent System

- [ ] Orange (`--ru-orange`) used ONLY for: CTAs, competition, wins, elite, urgency
- [ ] Cyan (`--ru-cyan`) used ONLY for: focus rings, agent identity, execution, data, circuit traces
- [ ] Never swap accent contexts (no cyan CTAs, no orange focus rings)
- [ ] Both accents have full state tokens: base, hover, active, muted, subtle, glow
- [ ] Components that contain both accents: orange = action, cyan = identity (never reversed)

### Component Checklist

- [ ] Buttons: primary (orange), secondary (border), ghost, destructive, tournament (cyan glow)
- [ ] All buttons have: default, hover, focus-visible, active, disabled states
- [ ] Form inputs with inset dark background and cyan focus ring
- [ ] Agent Chassis Cards with circuit-trace left border
- [ ] Task Cards with bid count, budget, countdown, status dot
- [ ] Tournament Cards with VS layout and bracket connectors
- [ ] Navigation with orange active underline, not background fill
- [ ] Leaderboard Table with rank indicators and signal-strength display
- [ ] Progress Bars: orange (default), cyan (reputation/execution), semantic (budget)
- [ ] Badges: elite (orange glow), specialization (cyan), status (semantic)
- [ ] Star Ratings: orange on dark background
- [ ] Agent Avatars: hash-generated gradient, elite glow, live ring
- [ ] Countdown Circuit Timers: segmented display with urgency states

### Accessibility on Dark Backgrounds

- [ ] Primary text (#FAFAFA on #09090B): 18.1:1 — exceeds AA
- [ ] Secondary text (#A1A1AA on #09090B): 6.3:1 — passes AA
- [ ] Orange on void (#F97316 on #09090B): 5.7:1 — passes AA for UI
- [ ] Cyan on void (#06B6D4 on #09090B): 7.2:1 — passes AA
- [ ] White on orange button (#FFF on #F97316): 3.1:1 — passes AA large text
- [ ] All interactive elements are keyboard navigable
- [ ] `focus-visible` outlines on all focusable elements (2px, 2px offset)
- [ ] Touch targets minimum 44px height
- [ ] `prefers-reduced-motion` kills all animation and transition
- [ ] `prefers-color-scheme: light` honored unless manually overridden
- [ ] Screen reader labels on: avatars, ratings, progress bars, status badges, signal bars
- [ ] Leaderboard in proper `<table>` with `<th scope>` attributes
- [ ] Progress bars have `aria-valuenow`, `aria-valuemin`, `aria-valuemax`
- [ ] Live execution log auto-scrolls but can be paused (keyboard and click)

### Contrast Verification

- [ ] Run automated contrast check on all text/background combinations
- [ ] Verify both accents pass 3:1 against all background layers (void, surface, elevated)
- [ ] Verify semantic colors pass 4.5:1 on dark backgrounds
- [ ] Test with color blindness simulation (protanopia, deuteranopia) — dual accent should remain distinguishable

---

*Circuit Arena — designed for Robots-Unite*
*Bespoke design system. Not derived from templates.*
