# Style Guide: AI Fighter — Neural Neon

> Dark, electric, and competitive. A game interface where neural pathways glow and every battle feels like watching intelligence evolve.

**Style System:** Bold Expressive 80% + Minimal Tech 20%
**Source Specs:** bold-expressive.md + minimal-tech.md
**Scenario:** Mobile game UI for training and battling AI-powered fighters

---

## Scenario

**AI Fighter** is a mobile game where players build neural-net powered fighters through a visual graph editor, train them in simulated gyms, and compete in async PvP arenas. The interface has two distinct modes: **spectacle** (battles, replays, home screen, seasonal events) and **precision** (graph editor, training analytics, stats).

The Bold Expressive foundation delivers the energy a competitive game demands — neon accents on black, dramatic type, glowing particle motifs, screen-shake moments. Players should feel like they're inside a machine, watching synapses fire.

The Minimal Tech accent provides the structural discipline the graph editor and training analytics need. When a player is wiring perception nodes to action nodes, they need clean lines, readable labels, and systematic spacing — not chaos. MT contributes **functional component styling** (inputs, data tables, node labels), **monospace data readouts**, and **systematic grid spacing** within the editor and stats screens.

**Brand personality:** Electric. Competitive. Intelligent. Visceral.

---

## Color Palette

```css
:root {
  /* 80% — Bold Expressive foundation: dark void */
  --bg-primary: #0A0A0F;
  --bg-surface: #12121A;
  --bg-elevated: #1A1A26;

  --text-primary: #E8E8F0;
  --text-secondary: #8888A0;
  --text-tertiary: #55556A;

  /* 20% — Minimal Tech structural tokens */
  --border-default: #2A2A3A;
  --border-subtle: #1E1E2E;
  --focus-ring: rgba(0, 255, 170, 0.25);

  /* Bold Expressive accents — "Neural Neon" */
  --accent-primary: #00FFAA;         /* Electric mint — synapses, wins, primary CTA */
  --accent-primary-rgb: 0, 255, 170;
  --accent-danger: #FF3366;          /* Hot pink — damage, losses, destructive actions */
  --accent-danger-rgb: 255, 51, 102;
  --accent-info: #3366FF;            /* Electric blue — defense, utility, info */
  --accent-info-rgb: 51, 102, 255;
  --accent-reward: #FFAA00;          /* Amber — currency, rank, rewards */
  --accent-reward-rgb: 255, 170, 0;

  /* Semantic (minimal tech contribution — systematic) */
  --success: #00FFAA;
  --warning: #FFAA00;
  --error: #FF3366;
  --info: #3366FF;

  /* Accent muted variants (for backgrounds, badges) */
  --accent-primary-muted: rgba(0, 255, 170, 0.10);
  --accent-danger-muted: rgba(255, 51, 102, 0.10);
  --accent-info-muted: rgba(51, 102, 255, 0.10);
  --accent-reward-muted: rgba(255, 170, 0, 0.10);
}
```

```
┌──────────────────────────────────────────────┐
│  NEURAL NEON PALETTE                         │
├──────────────────────────────────────────────┤
│                                              │
│  ██████  #0A0A0F   Void black (bg)           │
│  ██████  #12121A   Surface                   │
│  ██████  #1A1A26   Elevated                  │
│                                              │
│  ██████  #E8E8F0   Primary text              │
│  ██████  #8888A0   Secondary text            │
│                                              │
│  ██████  #00FFAA   Synapse mint (primary)    │
│  ██████  #FF3366   Damage pink (danger)      │
│  ██████  #3366FF   Shield blue (info)        │
│  ██████  #FFAA00   Reward amber (currency)   │
│                                              │
│  Four neon accents on near-black.            │
│  Each accent maps to a game concept.         │
│  MT provides border + focus tokens.          │
│                                              │
└──────────────────────────────────────────────┘
```

**Usage rules:**
- Dark mode only. No light mode variant.
- **Synapse mint** (`--accent-primary`): primary CTAs, win states, active graph connections, synapse glow, navigation active state
- **Damage pink** (`--accent-danger`): damage numbers, loss states, destructive actions (delete fighter), health depletion
- **Shield blue** (`--accent-info`): defense stats, utility nodes, informational toasts, secondary buttons
- **Reward amber** (`--accent-reward`): currency displays, rank badges, XP gains, seasonal banners
- Muted variants (`*-muted`) for backgrounds behind badges, tags, and graph node fills
- **MT contribution:** `--border-default` and `--focus-ring` provide consistent structural lines and accessible focus indicators across all interactive elements

**Contrast ratios (against `--bg-primary: #0A0A0F`):**
- `--text-primary` (#E8E8F0): **16.4:1** — exceeds AAA
- `--text-secondary` (#8888A0): **6.8:1** — exceeds AA
- `--accent-primary` (#00FFAA): **13.2:1** — exceeds AAA
- `--accent-danger` (#FF3366): **5.4:1** — meets AA for large text/UI
- `--accent-info` (#3366FF): **4.1:1** — meets AA for large text/UI
- `--accent-reward` (#FFAA00): **9.6:1** — exceeds AAA

---

## Typography

**Font stack:**
```css
/* 80% — Bold Expressive: display type */
--font-display: 'Space Grotesk', 'Arial Black', sans-serif;

/* Body: clean, readable at small mobile sizes */
--font-body: 'DM Sans', 'Inter', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;

/* 20% — Minimal Tech: functional data text */
--font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| Hero | Display | 64-80px | 700 | 0.9 | Season titles, "AI FIGHTER" wordmark |
| H1 | Display | 48px | 700 | 0.95 | Screen titles ("ARENA", "FIGHTER STUDIO") |
| H2 | Display | 32px | 700 | 1.05 | Section headings, fighter names |
| H3 | Display | 24px | 600 | 1.1 | Card titles, subsection headings |
| Body Large | Body | 18px | 400 | 1.6 | Intro text, descriptions |
| Body | Body | 16px | 400 | 1.6 | Primary UI text |
| Body Small | Body | 14px | 400 | 1.5 | Secondary labels |
| **Stat Value** | **Mono** | **16px** | **500** | **1.2** | **Numbers: ELO, win rate, confidence %** |
| **Node Label** | **Mono** | **13px** | **400** | **1.3** | **Graph node labels, parameter names** |
| **Metadata** | **Mono** | **12px** | **400** | **1.4** | **Timestamps, IDs, generation counters** |
| Caption | Mono | 11px | 400 | 1.3 | Fine print, version numbers |

**Typography notes:**
- Display type is ALWAYS uppercase and tight-tracked (`letter-spacing: -0.02em` to `-0.04em`). This is the game's visual signature.
- Body type uses sentence case. Never all-caps for body text — it must contrast with display.
- **The 20% MT element:** Monospace for all numerical data, graph labels, and metadata. Stat values in JetBrains Mono feel "computed" and "precise" — reinforcing the neural-net theme. Display type for headings, mono for data, body for everything else. Three-tier hierarchy that maps to game concepts: **spectacle → data → explanation**.

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Space Grotesk | Google Fonts | OFL | [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk) |
| DM Sans | Google Fonts | OFL | [Google Fonts](https://fonts.google.com/specimen/DM+Sans) |
| JetBrains Mono | Google Fonts / GitHub | OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) \| [GitHub](https://github.com/JetBrains/JetBrainsMono) |

*All fonts are free and open-source. No paid alternatives needed.*

---

## Spacing & Layout

### Base Unit

8px base, following Minimal Tech's systematic scale:

```
4px   — Micro (inline gaps, icon-to-label)
8px   — XS (tight component padding)
12px  — SM (list item gaps)
16px  — MD (standard padding)
24px  — LG (section inner padding)
32px  — XL (card padding, section gaps)
48px  — 2XL (between major sections)
64px  — 3XL (screen-level padding)
96px  — 4XL (hero/splash spacing)
```

### Grid Specification

| Breakpoint | Columns | Gutter | Margin | Max Width | Notes |
|------------|---------|--------|--------|-----------|-------|
| Mobile (< 480px) | 4 | 12px | 16px | 100% | Phone portrait |
| Tablet (480-768px) | 6 | 16px | 24px | 100% | Phone landscape / small tablet |
| Desktop (768px+) | 12 | 20px | 32px | 1200px | Tablet landscape / desktop |

### Layout Split: Spectacle vs Precision

**Bold Expressive (80%)** — Home screen, arena, battle replay, season banners:
- Full-bleed imagery, overlapping elements, asymmetric compositions
- No strict grid adherence — compositional, dramatic
- Large negative space between hero elements

**Minimal Tech (20%)** — Graph editor, training gym analytics, stat tables:
- Strict 8px grid with systematic margins
- Single-column or sidebar+main layout
- Predictable spacing between elements

```css
/* Spectacle screen (home, arena) */
.screen-spectacle {
  padding: 0; /* Full bleed */
  overflow: hidden;
}

/* Precision screen (editor, stats) */
.screen-precision {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px 16px;
}
.screen-precision > * + * {
  margin-top: 16px;
}
```

### Border Radius

```css
--radius-none: 0;
--radius-sm: 4px;       /* MT: inputs, small tags */
--radius-md: 8px;       /* Cards, panels */
--radius-lg: 12px;      /* Large cards, modals */
--radius-xl: 16px;      /* Bento tiles, featured cards */
--radius-full: 9999px;  /* Pill buttons, badges, avatars */
```

---

## Component Styling

### Buttons

```css
/* Primary CTA — neon mint */
.btn-primary {
  background: var(--accent-primary);
  color: var(--bg-primary);
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 14px 28px;
  border: none;
  border-radius: var(--radius-full);
  cursor: pointer;
  transition: transform 100ms ease, box-shadow 200ms ease;
}
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 0 24px rgba(var(--accent-primary-rgb), 0.4);
}
.btn-primary:active {
  transform: translateY(0) scale(0.97);
}
.btn-primary:focus-visible {
  outline: 2px solid var(--accent-primary);
  outline-offset: 3px;
}
.btn-primary:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

/* Secondary — outline with neon glow on hover */
.btn-secondary {
  background: transparent;
  color: var(--accent-info);
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  padding: 12px 24px;
  border: 1px solid var(--accent-info);
  border-radius: var(--radius-full);
  cursor: pointer;
  transition: all 150ms ease;
}
.btn-secondary:hover {
  background: rgba(var(--accent-info-rgb), 0.12);
  box-shadow: 0 0 16px rgba(var(--accent-info-rgb), 0.2);
}

/* Ghost — minimal text button */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  font-family: var(--font-mono);
  font-size: 13px;
  font-weight: 400;
  padding: 8px 16px;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: color 150ms ease, background 150ms ease;
}
.btn-ghost:hover {
  color: var(--text-primary);
  background: var(--bg-elevated);
}

/* Danger — destructive actions */
.btn-danger {
  background: transparent;
  color: var(--accent-danger);
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  padding: 12px 24px;
  border: 1px solid var(--accent-danger);
  border-radius: var(--radius-full);
  cursor: pointer;
  transition: all 150ms ease;
}
.btn-danger:hover {
  background: rgba(var(--accent-danger-rgb), 0.12);
  box-shadow: 0 0 16px rgba(var(--accent-danger-rgb), 0.2);
}
```

### Form Inputs (20% Minimal Tech)

```css
.input {
  background: var(--bg-surface);
  color: var(--text-primary);
  font-family: var(--font-mono);
  font-size: 14px;
  padding: 12px 16px;
  border: 1px solid var(--border-default);
  border-radius: var(--radius-sm);
  width: 100%;
  transition: border-color 150ms ease, box-shadow 150ms ease;
}
.input:focus {
  border-color: var(--accent-primary);
  box-shadow: 0 0 0 3px var(--focus-ring);
  outline: none;
}
.input::placeholder {
  color: var(--text-tertiary);
}
.input--error {
  border-color: var(--accent-danger);
  box-shadow: 0 0 0 3px rgba(var(--accent-danger-rgb), 0.15);
}
.input:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
```

### Cards

```css
/* Standard card — dark glass surface */
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  padding: 24px;
  transition: border-color 200ms ease, box-shadow 200ms ease;
}
.card:hover {
  border-color: rgba(var(--accent-primary-rgb), 0.3);
  box-shadow: 0 0 20px rgba(var(--accent-primary-rgb), 0.06);
}

/* Fighter card — featured, with glow */
.card-fighter {
  background: var(--bg-surface);
  border: 1px solid rgba(var(--accent-primary-rgb), 0.2);
  border-radius: var(--radius-xl);
  padding: 32px;
  position: relative;
  overflow: hidden;
}
.card-fighter::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(
    circle at 50% 50%,
    rgba(var(--accent-primary-rgb), 0.06) 0%,
    transparent 50%
  );
  pointer-events: none;
}

/* Bento tile — for home screen quick actions */
.card-bento {
  background: var(--bg-elevated);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-xl);
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  transition: transform 150ms ease, box-shadow 200ms ease;
}
.card-bento:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
}
```

### Navigation — Bottom Tab Bar (Mobile)

```css
.tab-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 64px;
  background: var(--bg-surface);
  border-top: 1px solid var(--border-default);
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding: 0 8px;
  z-index: 100;
}
.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  font-family: var(--font-mono);
  font-size: 10px;
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 8px 12px;
  border-radius: var(--radius-md);
  transition: color 150ms ease;
}
.tab-item--active {
  color: var(--accent-primary);
}
.tab-item--active::after {
  content: '';
  width: 4px;
  height: 4px;
  background: var(--accent-primary);
  border-radius: var(--radius-full);
  box-shadow: 0 0 8px rgba(var(--accent-primary-rgb), 0.6);
}
```

### Game-Specific Components

#### Graph Node

```css
.graph-node {
  background: var(--bg-elevated);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  padding: 10px 14px;
  font-family: var(--font-mono);
  font-size: 13px;
  color: var(--text-primary);
  min-width: 120px;
  cursor: grab;
  transition: border-color 150ms ease, box-shadow 150ms ease;
}
.graph-node:hover {
  border-color: var(--accent-primary);
}
.graph-node--selected {
  border-color: var(--accent-primary);
  box-shadow: 0 0 12px rgba(var(--accent-primary-rgb), 0.2);
}
.graph-node__type {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-tertiary);
  margin-bottom: 4px;
}
.graph-node__value {
  font-size: 12px;
  color: var(--accent-primary);
}
```

#### Health Bar

```css
.health-bar {
  height: 8px;
  background: var(--bg-elevated);
  border-radius: var(--radius-full);
  overflow: hidden;
  position: relative;
}
.health-bar__fill {
  height: 100%;
  border-radius: var(--radius-full);
  transition: width 300ms ease-out;
}
.health-bar__fill--high {
  background: var(--accent-primary);
  box-shadow: 0 0 8px rgba(var(--accent-primary-rgb), 0.4);
}
.health-bar__fill--mid {
  background: var(--accent-reward);
  box-shadow: 0 0 8px rgba(var(--accent-reward-rgb), 0.4);
}
.health-bar__fill--low {
  background: var(--accent-danger);
  box-shadow: 0 0 8px rgba(var(--accent-danger-rgb), 0.4);
}
```

#### Rank Badge

```css
.badge-rank {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 4px 12px;
  border-radius: var(--radius-full);
}
.badge-rank--bronze {
  background: rgba(205, 127, 50, 0.15);
  color: #CD7F32;
  border: 1px solid rgba(205, 127, 50, 0.3);
}
.badge-rank--silver {
  background: rgba(192, 192, 192, 0.15);
  color: #C0C0C0;
  border: 1px solid rgba(192, 192, 192, 0.3);
}
.badge-rank--gold {
  background: var(--accent-reward-muted);
  color: var(--accent-reward);
  border: 1px solid rgba(var(--accent-reward-rgb), 0.3);
}
.badge-rank--diamond {
  background: var(--accent-info-muted);
  color: var(--accent-info);
  border: 1px solid rgba(var(--accent-info-rgb), 0.3);
}
.badge-rank--neural {
  background: var(--accent-primary-muted);
  color: var(--accent-primary);
  border: 1px solid rgba(var(--accent-primary-rgb), 0.3);
  box-shadow: 0 0 12px rgba(var(--accent-primary-rgb), 0.15);
}
```

#### Stat Readout

```css
.stat {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.stat__label {
  font-family: var(--font-mono);
  font-size: 11px;
  font-weight: 400;
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}
.stat__value {
  font-family: var(--font-mono);
  font-size: 24px;
  font-weight: 500;
  color: var(--text-primary);
  line-height: 1;
}
.stat__value--positive { color: var(--accent-primary); }
.stat__value--negative { color: var(--accent-danger); }
.stat__delta {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-tertiary);
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing | Source |
|---------|--------|----------|--------|--------|
| Primary button hover | Lift + neon glow | 200ms | ease | BE |
| Primary button press | Scale down (0.97) | 100ms | ease | BE |
| Card hover | Border glow + subtle lift | 200ms | ease | BE |
| Graph node drag | Pick up shadow | 150ms | ease-out | MT |
| Graph connection | Glowing line draws between nodes | 200ms | ease-out | BE |
| Battle hit | Screen shake (2px, 3 frames) + pink flash | 100ms | step-end | BE |
| Battle win | Mint pulse + particle burst | 800ms | spring | BE |
| Battle loss | Desaturation + static grain | 400ms | ease-in | BE |
| Health bar depletion | Width shrink + color shift | 300ms | ease-out | BE |
| Training generation tick | Fast counter increment | 50ms per gen | linear | MT |
| Nav tab switch | Color fade | 150ms | ease | MT |
| Input focus | Border + shadow ring | 150ms | ease | MT |
| Stat value change | Number morphs (count up/down) | 300ms | ease-out | BE |
| Menu slide | Horizontal translate with depth | 250ms | ease-in-out | BE |

**Motion split:** Spectacle screens (battles, wins, home) use Bold Expressive animation — dramatic, spring-based, scroll-linked, 200-800ms. Precision screens (editor, stats) use Minimal Tech animation — subtle, 150ms ease, predictable.

**Reduced motion:** All animations respect `prefers-reduced-motion: reduce`. Under reduced motion: battle replays use cut transitions instead of shakes; stat counters snap to final value; card hovers change border color without transform.

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Asset Guidelines

**Visual motifs:**
- **Neural pathways** as the core motif — glowing lines connecting nodes. Used in backgrounds, loading screens, transitions, and the graph editor itself.
- **Particle systems** for battle actions — sparks, energy trails, data-stream particles. Colors match the accent palette.
- **Scanline texture** — subtle horizontal lines (1px, 4% opacity) on dark backgrounds. Reinforces the "inside the machine" atmosphere.

**Iconography:**
- Lucide icons, 20px at 1.5px stroke weight
- Neon accent colors on dark backgrounds, `--text-secondary` on surface backgrounds
- Game-specific icons (sword, shield, brain, lightning, graph) may use custom SVGs matching Lucide stroke style

**Illustration:** None — the game's visual identity comes from the fighters, the graph editor, and particle effects. No illustrated mascots or hand-drawn elements.

**Photography:** None — this is a digital-native product. All imagery is rendered (3D fighters, graph visualizations, battle arenas).

**Logo:** "AI FIGHTER" in Space Grotesk 700, uppercase, tracked at `0.08em`. Electric mint on black. The "I" in "AI" can optionally render as a glowing vertical line (neural pathway motif). Minimum clear space: 16px all sides.

---

## Mixing Notes

### Elements Carrying the 20% Minimal Tech Accent (5 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Graph editor UI** | BE's compositional chaos → MT's 8px grid with systematic node spacing | The graph editor is a precision tool. Players are connecting perception nodes to decision nodes — they need clear spatial relationships, not artistic asymmetry. MT's grid ensures nodes align predictably and connections read clearly. |
| **Form inputs** | (BE doesn't define forms) → MT input patterns with mono type, 4px radius, focus rings | The graph editor needs parameter inputs (sliders, number fields, dropdowns for node types). BE has no form language. Importing MT's input styling creates functional, accessible controls that feel "technical" rather than "generic." |
| **Data readouts (stats, training analytics)** | Display type for everything → Mono for all numerical data | A player's win rate, ELO score, confidence percentage, and training generation count must be instantly parseable. JetBrains Mono at fixed width means numbers align in columns, values feel "computed," and the neural-net theme is reinforced through typography alone. |
| **Component transitions** | BE's dramatic 500ms+ → MT's 150ms for all functional interactions | When a player drags a graph node, taps a tab, or focuses an input, they need instant feedback. 150ms feels responsive. The 500ms+ dramatic animations are reserved for spectacle moments (battle hits, wins) where drama is the point. |
| **Navigation tab bar** | BE's hidden/experimental nav → MT's systematic bottom tab bar | Mobile games need thumb-reachable, instantly legible navigation. Hidden nav or experimental patterns would frustrate a player trying to switch between Arena, Studio, and Lab. MT's tab bar with mono labels and accent-colored active state is functional AND fits the aesthetic. |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| MT's muted color palette (replacing neon with single indigo accent) | Four neon accents are load-bearing — each maps to a game concept (mint=synapse, pink=damage, blue=defense, amber=reward). Reducing to one accent would strip the game's color language. |
| MT's conservative type scale (flattening 64px heroes to 36px) | The game needs dramatic headlines. "ARENA" at 48px uppercase feels like a title screen. At 36px sentence case, it feels like a settings page. |
| Rounded corners everywhere (Consumer Playful influence) | 16px radius on everything would soften the aesthetic too much. The game should feel sharp and electric, not friendly and bubbly. Radius is reserved for pills (buttons, badges) and bento tiles. |
| Light mode option | Neon accents on dark backgrounds is the entire visual identity. A light mode would require redesigning every glow, every particle effect, every gradient. Not worth the investment for a game where "inside the machine" is the mood. |

---

## Implementation Checklist

- [ ] Space Grotesk (display, 600-700) + DM Sans (body, 400) + JetBrains Mono (data, 400-500)
- [ ] All four neon accents rendered correctly against `#0A0A0F` background
- [ ] Primary CTA buttons have neon glow on hover (`box-shadow` with accent color)
- [ ] Graph editor uses MT spacing (8px grid, systematic node alignment)
- [ ] All inputs have visible focus rings (`--focus-ring` token)
- [ ] All numerical data (ELO, win rate, confidence %) uses JetBrains Mono
- [ ] Health bars animate width with color transitions (green → amber → red)
- [ ] Rank badges use correct tier colors with muted backgrounds
- [ ] Bottom tab bar: 64px height, mono labels, mint active indicator
- [ ] Spectacle animations: 200-800ms, spring easing, dramatic
- [ ] Precision animations: 150ms ease, subtle, functional
- [ ] `prefers-reduced-motion`: all animations disabled, instant state changes
- [ ] Screen reader: semantic HTML, aria-labels on all game controls, alt text on fighter renders
- [ ] Touch targets: minimum 44px for all interactive elements
- [ ] Dark mode only — no theme toggle
- [ ] Contrast ratios: all text meets WCAG AA minimum

---

*Derived from: bold-expressive.md + minimal-tech.md*
*Project: NOIZUAI-10 — AI Fighter (aifighter.com)*
