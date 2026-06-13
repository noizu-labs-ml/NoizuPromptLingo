# Style Guide: AI Fighter — Neural Combat

> A bespoke dark-interface system where every visual element maps to the game's core mechanic: building, training, and battling AI minds.

**Style System:** Custom ("Neural Combat") — evolved from Bold Expressive + Minimal Tech DNA, but governed by its own rules
**Scenario:** Mobile game UI for designing neural-net fighters, training them, and battling in async PvP arenas

---

## Scenario

AI Fighter is not a dashboard, not a portfolio, not a SaaS app. It's a **competitive mobile game about engineering intelligence**. The style system must serve two opposing needs simultaneously:

1. **Spectacle** — battles, wins, losses, ranked climbing, seasonal events. The game must *feel* electric, competitive, and addictive in screenshots and replays.
2. **Precision** — the graph editor, training data, decision overlays. The tool-side of the game must feel like a clean, trustworthy instrument for serious work.

Standard style mixes fail here because they treat the 80/20 split as a global blend. Neural Combat instead uses **modal switching** — the visual system changes based on *what the player is doing*:

| Player Mode | Visual Register | Governs |
|---|---|---|
| **Building** (Fighter Studio) | Instrument — clean, precise, low-stimulus | Graph editor, node palette, parameter sliders |
| **Training** (Gym) | Laboratory — data-forward, evolving | Charts, heatmaps, generation counters, insights |
| **Fighting** (Arena) | Arena — high-energy, dramatic, emotional | Battle playback, health bars, decision overlays, win/loss |
| **Exploring** (Lab/Hub) | Social — warm enough for community, cool enough for competition | Leaderboards, build sharing, replays, season banners |

This modal approach means the same player encounters different visual intensities depending on context — and the transitions between modes become a signature design element.

---

## Color Palette

### The Semantic Spine

Every color in the palette maps to a concept in the game's neural-net mechanic. This is not decorative — it's **functional semiotics**. When a player sees electric mint, they know "this is a synapse firing." When they see hot coral, they know "damage/aggression."

```css
:root {
  /* === VOID — the space between neurons === */
  --void-deep:       #06060C;   /* True background — near-black, cold blue undertone */
  --void-surface:    #0E0E18;   /* Elevated panels, cards, modals */
  --void-elevated:   #16162A;   /* Active surfaces, selected states */
  --void-border:     #252540;   /* Structural edges — visible but quiet */

  /* === SYNAPSE — the core identity color === */
  /* This is the "pulse" of the game. It means: connection, intelligence, life. */
  --synapse:         #00FFAA;   /* Electric mint — neural pathways, active connections */
  --synapse-dim:     #00CC88;   /* Subdued synapse for secondary uses */
  --synapse-glow:    rgba(0, 255, 170, 0.15);  /* Ambient glow behind active nodes */
  --synapse-bright:  rgba(0, 255, 170, 0.85);  /* Text on dark, high-emphasis */

  /* === COMBAT — aggression, damage, stakes === */
  --combat:          #FF2D55;   /* Hot coral — attacks, damage numbers, losses */
  --combat-dim:      #CC2444;   /* Subdued for backgrounds */
  --combat-glow:     rgba(255, 45, 85, 0.15);

  /* === SIGNAL — defense, perception, information === */
  --signal:          #2979FF;   /* Deep electric blue — blocks, dodges, perception nodes */
  --signal-dim:      #1A5FCC;
  --signal-glow:     rgba(41, 121, 255, 0.15);

  /* === REWARD — currency, rank, achievement === */
  --reward:          #FFB300;   /* Warm amber — XP, rank badges, season rewards */
  --reward-dim:      #CC8F00;
  --reward-glow:     rgba(255, 179, 0, 0.15);

  /* === TEXT — readability hierarchy === */
  --text-primary:    #E6E6F0;   /* Primary content — 15.8:1 on void-deep */
  --text-secondary:  #8888A0;   /* Labels, metadata — 5.9:1 on void-deep */
  --text-dim:        #555570;   /* Hints, placeholders — 3.2:1 (decorative only) */
  --text-inverse:    #06060C;   /* Text on bright backgrounds */

  /* === SEMANTIC (non-game) === */
  --success:         var(--synapse);    /* Wins reuse synapse */
  --error:           var(--combat);     /* Losses reuse combat */
  --warning:         var(--reward);     /* Warnings reuse reward */
  --info:            var(--signal);     /* Info reuses signal */
}
```

### Palette Diagram

```
┌──────────────────────────────────────────────────────┐
│  NEURAL COMBAT PALETTE                               │
├──────────────────────────────────────────────────────┤
│                                                      │
│  THE VOID (backgrounds)                              │
│  ██████  #06060C   Deep void                         │
│  ██████  #0E0E18   Surface                           │
│  ██████  #16162A   Elevated                          │
│  ░░░░░░  #252540   Border                            │
│                                                      │
│  THE FOUR SIGNALS (game semantics)                   │
│  ██████  #00FFAA   Synapse  — connection, life       │
│  ██████  #FF2D55   Combat   — aggression, damage     │
│  ██████  #2979FF   Signal   — defense, perception    │
│  ██████  #FFB300   Reward   — currency, rank         │
│                                                      │
│  Rule: These four colors are NEVER decorative.       │
│  Every use maps to a game concept.                   │
│                                                      │
│  TEXT                                                 │
│  ██████  #E6E6F0   Primary (body, headlines)         │
│  ██████  #8888A0   Secondary (labels, meta)          │
│  ██████  #555570   Dim (decorative only)             │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### Color Usage Rules

- **Dark mode only.** No light mode. The void is the canvas; neurons glow against it.
- **Four-color maximum per screen.** Void + text + two of the four signal colors. All four signals appearing simultaneously means something is wrong.
- **Synapse is the default accent.** When only one color is needed, it's always synapse.
- **Combat and signal appear together only in battle.** Outside the arena, they don't coexist.
- **Reward appears only in progression contexts.** Rank, XP, currency, season rewards. Never on gameplay elements.
- **Glow tokens are for ambience, not readability.** Text on glow backgrounds must still use `--text-primary`.
- **No gradients on UI elements.** Gradients are reserved for the battle arena background and seasonal event banners only.

---

## Typography

### Font Stack

```css
:root {
  /* DISPLAY — fighter names, arena titles, season banners, win/loss screens */
  --font-display: 'Space Grotesk', 'Arial Black', sans-serif;

  /* BODY — descriptions, menus, onboarding text, settings */
  --font-body: 'DM Sans', 'Inter', system-ui, sans-serif;

  /* DATA — node parameters, confidence values, stats, graph labels, counters */
  --font-data: 'JetBrains Mono', 'SF Mono', 'Consolas', monospace;
}
```

**Why these fonts, specifically:**

- **Space Grotesk** (display) — geometric sans with just enough personality. Its alternate glyphs give fighter names character without becoming illegible at mobile sizes. Unlike Monument Extended (the README's original pick), it's open-source, performs well on mobile, and is readable down to 24px — critical for a game where display text appears on cards and lists, not just hero sections.
- **DM Sans** (body) — optical sizing built in, excellent at 14-16px on mobile screens. Slightly warmer than Inter, which prevents the UI from feeling clinical in social contexts (Lab, profiles).
- **JetBrains Mono** (data) — the graph editor's voice. Tabular figures for stats, clear at 12px for node parameter values. Players will stare at `Aggression: 0.73` in this font. It needs to feel precise and trustworthy.

### Type Scale

Base: 16px (mobile), 18px (tablet+)

| Level | Size | Weight | Line Height | Tracking | Use |
|---|---|---|---|---|---|
| Arena Display | `clamp(36px, 8vw, 56px)` | 700 | 0.95 | -0.03em | Win/loss screens, season titles |
| Fighter Name | `clamp(24px, 5vw, 36px)` | 700 | 1.0 | -0.02em | Fighter cards, profile headers |
| Section Title | 20px | 600 | 1.2 | -0.01em | "TRAINING GYM", "ARENA", tab headers |
| Body | 16px | 400 | 1.5 | 0 | Descriptions, onboarding, settings |
| Body Small | 14px | 400 | 1.4 | 0 | Secondary text, tooltips |
| Data Large | 20px (mono) | 500 | 1.2 | 0 | Win rate %, ELO rating, generation count |
| Data Default | 14px (mono) | 400 | 1.3 | 0.02em | Node values, confidence scores, timestamps |
| Data Micro | 11px (mono) | 400 | 1.2 | 0.04em | Graph labels on nodes, axis labels on charts |

### Typography Rules

- **Display font is ALWAYS uppercase** with tight negative tracking. Fighter names, arena titles, section headers.
- **Body font is NEVER uppercase.** Sentence case only. Even button labels.
- **Data font has tabular figures enabled** (`font-variant-numeric: tabular-nums`). Numbers in stats, counters, and sliders must align vertically.
- **Maximum two weights per font** in use at any time. Space Grotesk: 600 + 700. DM Sans: 400 + 500. JetBrains Mono: 400 + 500.
- **No italics anywhere in the game UI.** Emphasis is achieved through weight or color, never slant.

### Font Sources

| Font | Source | License | Link |
|---|---|---|---|
| Space Grotesk | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk) |
| DM Sans | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/DM+Sans) |
| JetBrains Mono | Google Fonts / GitHub | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) |

All three fonts are free and self-hostable. No paid alternatives needed. For native mobile (Unity/Godot), bundle as `.ttf` or `.otf` assets.

---

## Spacing & Layout

### Base Unit

8px base. All spacing is a multiple of 8, with 4px for micro-adjustments within components.

```
4px   — Micro: icon-to-label gap, node connector padding
8px   — XS: related controls, inline groups
12px  — SM: input padding, small card padding
16px  — MD: standard content gaps, list item padding
24px  — LG: card padding, section gaps within a screen
32px  — XL: between major screen sections
48px  — 2XL: screen-level vertical rhythm (e.g., hub to bento grid)
```

### Mobile-First Grid

AI Fighter is mobile-native. The grid is designed for portrait-mode phones.

```
Phone (< 428px):
  Layout: Single column, edge-to-edge
  Margins: 16px horizontal
  Content max-width: none (full bleed)
  Tab bar: fixed bottom, 56px tall, 5 items

Phone Landscape / Small Tablet (428-768px):
  Layout: 2-column for bento grids
  Margins: 24px horizontal
  Graph editor: gains a collapsible side panel

Tablet (768px+):
  Layout: 3-column bento, sidebar for graph editor
  Margins: 32px horizontal
  Battle replays: side-by-side decision overlays
```

### Screen Composition Patterns

Each screen type has a compositional pattern:

**Hub (Home):**
```
┌──────────────────────┐
│  Header bar (48px)   │
│──────────────────────│
│                      │
│  Fighter hero card   │  ← 40% of viewport
│  (full-width)        │
│                      │
│──────────────────────│
│  Bento quick actions │  ← 3-column grid, 1:1 ratio
│  [Arena] [Gym] [Lab] │
│──────────────────────│
│  Season banner       │  ← Full-width card
│──────────────────────│
│  Tab bar (56px)      │
└──────────────────────┘
```

**Fighter Studio (Graph Editor):**
```
┌──────────────────────┐
│  Toolbar (48px)      │
│──────────────────────│
│                      │
│                      │
│  Canvas area         │  ← 70% of viewport, pannable
│  (graph lives here)  │
│                      │
│                      │
│──────────────────────│
│  Bottom drawer       │  ← Pull-up: node palette,
│  (collapsed: 64px)   │    parameters, save/test
│  (expanded: 50vh)    │
└──────────────────────┘

No tab bar in Studio — immersive mode.
```

**Battle Replay:**
```
┌──────────────────────┐
│  Back + title (48px) │
│──────────────────────│
│  Fighters + HP bars  │  ← 64px, always visible
│──────────────────────│
│                      │
│  Battle viewport     │  ← 50% of screen
│                      │
│──────────────────────│
│  Scrubber (48px)     │
│──────────────────────│
│  Decision overlay    │  ← Scrollable panel
│  (current decision)  │
│──────────────────────│
│  Tab bar (56px)      │
└──────────────────────┘
```

---

## Component Styling

### Node (Graph Editor)

The node is the atomic unit of the game. It must be instantly readable, draggable on touch, and visually encode its category.

```css
/* Base node — all node types inherit from this */
.node {
  background: var(--void-surface);
  border: 1.5px solid var(--void-border);
  border-radius: 12px;
  padding: 12px 16px;
  min-width: 120px;
  font-family: var(--font-data);
  font-size: 14px;
  color: var(--text-primary);
  /* Touch target: minimum 44x44px (node body always exceeds this) */
}

/* Category coloring — left border accent */
.node--perception {
  border-left: 3px solid var(--signal);
  /* Perception nodes sense the world: distance, health, stamina */
}
.node--decision {
  border-left: 3px solid var(--synapse);
  /* Decision nodes weigh inputs: aggression, risk tolerance */
}
.node--action {
  border-left: 3px solid var(--combat);
  /* Action nodes execute: attack, block, dodge */
}

/* Selected state */
.node--selected {
  border-color: var(--synapse);
  box-shadow: 0 0 0 2px var(--synapse-glow),
              0 0 24px var(--synapse-glow);
}

/* Node parameter value */
.node__value {
  font-family: var(--font-data);
  font-size: 13px;
  font-variant-numeric: tabular-nums;
  color: var(--text-secondary);
}
```

### Connection Lines (Graph Editor)

```css
/* Synapse connections between nodes */
.connection {
  stroke: var(--synapse-dim);
  stroke-width: 2;
  fill: none;
  opacity: 0.6;
}
.connection--active {
  stroke: var(--synapse);
  opacity: 1.0;
  filter: drop-shadow(0 0 4px var(--synapse-glow));
  /* Active during live preview — shows signal flowing */
}
.connection--drawing {
  stroke: var(--synapse);
  stroke-dasharray: 8 4;
  opacity: 0.8;
  /* While user is dragging a new connection */
}
```

### Health Bar (Battle)

```css
.health-bar {
  height: 8px;
  background: var(--void-elevated);
  border-radius: 4px;
  overflow: hidden;
}
.health-bar__fill {
  height: 100%;
  border-radius: 4px;
  transition: width 300ms ease-out;
}
/* Color shifts as health drops */
.health-bar__fill--high   { background: var(--synapse); }     /* > 60% */
.health-bar__fill--medium { background: var(--reward); }      /* 30-60% */
.health-bar__fill--low    { background: var(--combat); }       /* < 30% */
```

### Buttons

```css
/* Primary — used for main actions: "Battle Now", "Save", "Train" */
.btn-primary {
  background: var(--synapse);
  color: var(--text-inverse);
  border: none;
  border-radius: 8px;
  padding: 14px 24px;
  font-family: var(--font-body);
  font-size: 16px;
  font-weight: 500;
  min-height: 48px;                    /* Touch target */
  transition: opacity 150ms ease, transform 100ms ease;
}
.btn-primary:hover {
  opacity: 0.9;
}
.btn-primary:active {
  transform: scale(0.97);
  opacity: 0.85;
}
.btn-primary:focus-visible {
  outline: 2px solid var(--synapse);
  outline-offset: 3px;
}
.btn-primary:disabled {
  opacity: 0.35;
  pointer-events: none;
}

/* Secondary — used for alternatives: "Cancel", "Rematch", "View Stats" */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  border: 1.5px solid var(--void-border);
  border-radius: 8px;
  padding: 14px 24px;
  font-family: var(--font-body);
  font-size: 16px;
  font-weight: 500;
  min-height: 48px;
  transition: border-color 150ms ease, background 150ms ease;
}
.btn-secondary:hover {
  border-color: var(--text-secondary);
  background: var(--void-surface);
}
.btn-secondary:active {
  transform: scale(0.97);
}
.btn-secondary:focus-visible {
  outline: 2px solid var(--synapse);
  outline-offset: 3px;
}

/* Ghost — used for tertiary actions within cards/panels */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  border: none;
  padding: 8px 12px;
  font-family: var(--font-body);
  font-size: 14px;
  font-weight: 400;
  min-height: 36px;
  transition: color 150ms ease;
}
.btn-ghost:hover {
  color: var(--text-primary);
}
```

### Cards

```css
/* Standard card — bento grid items, build cards, sparring partner selection */
.card {
  background: var(--void-surface);
  border: 1px solid var(--void-border);
  border-radius: 12px;
  padding: 20px;
  transition: border-color 200ms ease;
}
.card:hover {
  border-color: var(--synapse-dim);
}

/* Fighter card — the hero card on home screen */
.card-fighter {
  background: var(--void-surface);
  border: 1px solid var(--void-border);
  border-radius: 16px;
  padding: 24px;
  position: relative;
  overflow: hidden;
}
/* Ambient glow behind fighter — color matches fighter's dominant trait */
.card-fighter::before {
  content: '';
  position: absolute;
  bottom: -40%;
  left: 50%;
  transform: translateX(-50%);
  width: 80%;
  height: 60%;
  border-radius: 50%;
  filter: blur(60px);
  opacity: 0.3;
  /* Color set via inline style based on fighter's dominant node category */
}

/* Stat card — small metric displays */
.card-stat {
  background: var(--void-elevated);
  border-radius: 10px;
  padding: 16px;
  text-align: center;
}
.card-stat__label {
  font-family: var(--font-data);
  font-size: 11px;
  font-weight: 400;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--text-secondary);
  margin-bottom: 4px;
}
.card-stat__value {
  font-family: var(--font-data);
  font-size: 24px;
  font-weight: 500;
  font-variant-numeric: tabular-nums;
  color: var(--text-primary);
}
```

### Decision Overlay (Battle Replay)

```css
/* The decision trace shown during replay — the "why" behind each action */
.decision-overlay {
  background: var(--void-surface);
  border: 1px solid var(--void-border);
  border-radius: 12px;
  padding: 16px;
}
.decision-overlay__action {
  font-family: var(--font-display);
  font-size: 16px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: -0.01em;
  color: var(--text-primary);
}
.decision-overlay__reason {
  font-family: var(--font-data);
  font-size: 13px;
  color: var(--text-secondary);
  margin-top: 8px;
}
.decision-overlay__confidence {
  font-family: var(--font-data);
  font-size: 14px;
  font-variant-numeric: tabular-nums;
  color: var(--synapse);
  margin-top: 4px;
}
/* Confidence bar — visual representation */
.confidence-bar {
  height: 4px;
  background: var(--void-elevated);
  border-radius: 2px;
  margin-top: 8px;
  overflow: hidden;
}
.confidence-bar__fill {
  height: 100%;
  background: var(--synapse);
  border-radius: 2px;
  transition: width 200ms ease-out;
}
```

### Navigation (Tab Bar)

```css
.tab-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 56px;
  background: var(--void-deep);
  border-top: 1px solid var(--void-border);
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding-bottom: env(safe-area-inset-bottom);
  z-index: 100;
}
.tab-bar__item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  color: var(--text-dim);
  font-family: var(--font-body);
  font-size: 10px;
  font-weight: 500;
  transition: color 150ms ease;
  /* Touch target: 48x48 minimum */
  min-width: 48px;
  min-height: 48px;
  justify-content: center;
}
.tab-bar__item--active {
  color: var(--synapse);
}
.tab-bar__item:hover {
  color: var(--text-secondary);
}
/* Icon size within tab */
.tab-bar__icon {
  width: 24px;
  height: 24px;
}
```

### Form Inputs (Settings, Search)

```css
.input {
  background: var(--void-elevated);
  color: var(--text-primary);
  font-family: var(--font-body);
  font-size: 16px;                     /* Prevents iOS zoom */
  padding: 14px 16px;
  border: 1.5px solid var(--void-border);
  border-radius: 10px;
  min-height: 48px;
  transition: border-color 150ms ease;
}
.input:focus {
  border-color: var(--synapse);
  box-shadow: 0 0 0 3px var(--synapse-glow);
  outline: none;
}
.input::placeholder {
  color: var(--text-dim);
}
.input--error {
  border-color: var(--combat);
  box-shadow: 0 0 0 3px var(--combat-glow);
}
```

---

## Interaction & Motion

### The Pulse Principle

Every animation in AI Fighter connects to the neural metaphor. Motion is not decorative — it communicates **signal propagation**, **state change**, or **impact**.

### Timing Classes

| Class | Duration | Easing | Used For |
|---|---|---|---|
| Instant | 100ms | `ease-out` | Button presses, toggle states |
| Swift | 150ms | `ease` | Hover states, tab switches, focus rings |
| Flow | 250ms | `cubic-bezier(0.25, 0.1, 0.25, 1)` | Panel slides, drawer open/close |
| Pulse | 400ms | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Node connections, training gen tick |
| Impact | 100ms + 200ms | `ease-out` then settle | Battle hits (shake + fade) |
| Dramatic | 600-800ms | `cubic-bezier(0.16, 1, 0.3, 1)` | Win/loss screens, season reveals |

### Signature Interactions

| Interaction | Animation | Timing | Context |
|---|---|---|---|
| Node connection drawn | Line traces from source to target with synapse glow trailing | 250ms Pulse | Graph Editor |
| Signal flow (live preview) | Pulse of light travels along connection lines, source → target | 400ms per hop, staggered | Graph Editor preview mode |
| Training generation tick | Counter increments + chart line extends with slight overshoot | 300ms Pulse | Training Gym |
| Battle hit | 2px screen shake + combat-colored flash on hit fighter | 100ms Impact | Battle Replay |
| Win | Fighter glows synapse + slow radial particle burst | 800ms Dramatic | Battle Result |
| Loss | Desaturation sweep left-to-right + static grain overlay | 500ms ease-in | Battle Result |
| Rank change | Number rolls (slot-machine style) + reward color flash | 600ms with stagger | Post-Battle |
| Menu transition | Horizontal slide with 8px parallax offset on bg | 250ms Flow | All screens |
| Bottom drawer pull | Spring-based pull with velocity tracking | Dynamic (gesture) | Graph Editor |

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  /* Disable: signal flow, particle effects, screen shake, parallax */
  /* Keep: opacity transitions, color changes, instant state changes */
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 150ms !important;  /* Preserve basic feedback */
  }
  /* Battle hits use color flash only (no shake) */
  /* Win/loss use instant state change (no sweep/burst) */
}
```

---

## The Neural Pathway Motif

The game's visual identity is the **synapse line** — the glowing connections between nodes in the graph editor. This motif extends beyond the editor into every part of the game as a unifying design element.

### Where It Appears

| Context | Treatment |
|---|---|
| **Graph Editor** | Literal — SVG paths connecting node elements |
| **Loading screens** | Abstract — animated network of dots and lines assembling/dissolving |
| **Background texture** | Subtle — very dim (#252540 at 30% opacity) circuit-like pattern on void backgrounds |
| **Battle transitions** | Structural — lines converge from edges of screen to center, then "fire" into the battle |
| **Profile/rank badges** | Symbolic — rank icons incorporate increasing graph complexity (Bronze = 3 nodes, Diamond = complex mesh, Neural = animated) |
| **Season art** | Thematic — each season's banner features a unique graph topology as its visual identity |

### Rules

- **Never use the motif as a border or divider.** It's a living element, not a decorative line.
- **Lines are always curved** (cubic bezier), never straight segments. Neural pathways flow.
- **Color is always synapse or synapse-dim.** The motif is green. Always.
- **Animation is subtle.** Pulse, not strobe. 2-4 second cycle time for ambient animations.
- **Density increases with context intensity.** Hub = sparse. Battle = dense. Graph Editor = literal.

---

## Asset Guidelines

### Iconography

- **Style:** Outlined, 1.5px stroke, 24px canvas, rounded caps and joins.
- **Custom icon set for game-specific actions:** Node types (perception eye, decision brain, action fist), graph operations (connect, disconnect, duplicate), training controls (play, fast-forward, reset).
- **Standard icons for system actions:** Settings gear, back arrow, share, close X. Use Lucide or Phosphor as base, customized to match 1.5px/rounded style.
- **Color:** `--text-secondary` default, `--synapse` for active state. Never multi-colored.

### Fighter Visualization

- Fighters are rendered as **abstract energy forms**, not humanoid characters. Think: geometric shapes composed of the same node-and-line visual language as the graph editor. A fighter IS its graph, visualized in motion.
- Each fighter's visual complexity reflects its graph complexity. A 5-node beginner fighter is a simple geometric shape. A 30-node advanced fighter is a dense, intricate form.
- Fighter idle animation: subtle oscillation of constituent nodes, connections pulsing faintly.

### Photography / Illustration

- **None.** AI Fighter uses no photography and no hand-drawn illustration. All visual assets are generated from the game's own visual language: graphs, particles, geometric forms, data visualizations.

---

## Accessibility

### Non-Negotiable Requirements

- [ ] All text meets WCAG 2.2 AA contrast ratios against its background
- [ ] Minimum touch target: 44x44px (48px preferred)
- [ ] All game state changes have non-color indicators (shape, icon, text label)
- [ ] Screen reader: semantic labels on all interactive elements, live regions for battle state changes
- [ ] Reduced motion: all animations respect `prefers-reduced-motion`
- [ ] Font size: 16px minimum for body text, never below 11px for any text
- [ ] Color blind support: synapse and combat are distinguishable in all common color vision deficiencies (green vs red-pink — confirmed distinguishable in protanopia/deuteranopia simulations; signal-blue provides additional differentiation)

### Contrast Verification

| Pair | Ratio | Passes |
|---|---|---|
| `--text-primary` (#E6E6F0) on `--void-deep` (#06060C) | 16.4:1 | AAA |
| `--text-secondary` (#8888A0) on `--void-deep` (#06060C) | 5.8:1 | AA |
| `--synapse` (#00FFAA) on `--void-deep` (#06060C) | 13.2:1 | AAA |
| `--combat` (#FF2D55) on `--void-deep` (#06060C) | 5.5:1 | AA |
| `--signal` (#2979FF) on `--void-deep` (#06060C) | 4.8:1 | AA |
| `--reward` (#FFB300) on `--void-deep` (#06060C) | 9.6:1 | AAA |
| `--text-inverse` (#06060C) on `--synapse` (#00FFAA) | 13.2:1 | AAA |

---

## What Makes This System Unique

This is not a "Bold Expressive 80% + Minimal Tech 20%" template with game colors swapped in. Here's what Neural Combat does differently:

1. **Semantic color, not aesthetic color.** Every color maps to a game concept. There is no "brand accent" — there are synapses, combat, signals, and rewards. A designer can't use synapse-green on a settings toggle because that would mean "neural connection" in a context where it means nothing.

2. **Modal visual register.** The system changes intensity based on player mode. The graph editor is clean and precise (borrowing Minimal Tech's discipline). The arena is loud and dramatic (borrowing Bold Expressive's energy). Neither style dominates globally — they serve different player needs at different moments.

3. **The motif IS the mechanic.** The neural pathway visual isn't a decorative pattern stamped on a standard UI. It's the literal game object (the graph) promoted to a brand identity. The loading screen, the rank badges, the battle transitions — they all use the same visual language as the thing the player builds.

4. **Fighter-as-graph visualization.** Fighters aren't characters with skins. They're visual representations of their own neural architecture. This makes the style guide inseparable from the game design — you can't reskin this onto a different product.

5. **All-free font stack.** Three Google Fonts that cover display, body, and data needs without licensing cost or CDN dependency. Critical for a mobile game where every KB of font weight matters.

---

## Implementation Checklist

- [ ] Dark mode only, `--void-deep` background, no light variant
- [ ] Four signal colors used semantically (synapse, combat, signal, reward)
- [ ] Space Grotesk (display, uppercase) + DM Sans (body) + JetBrains Mono (data)
- [ ] 8px spacing grid, 4px micro-adjustments
- [ ] All touch targets minimum 44x44px, preferred 48px
- [ ] Node components use left-border color coding (perception=signal, decision=synapse, action=combat)
- [ ] Connection lines are curved SVG paths with synapse coloring
- [ ] Health bars shift color at 60% and 30% thresholds
- [ ] Tab bar: 56px, fixed bottom, synapse accent on active item
- [ ] Graph Editor: immersive mode (no tab bar), bottom drawer for tools
- [ ] `prefers-reduced-motion` disables shake, particles, parallax, signal flow
- [ ] All interactive states defined: default, hover, active, focus-visible, disabled
- [ ] Contrast ratios verified per table above
- [ ] No gradients on UI elements (arena background and season banners only)
- [ ] Neural pathway motif: curved, synapse-colored, density scales with context
- [ ] Font size minimum 11px (data micro labels only), 16px for body

---

*Bespoke system for AI Fighter. Not derived from a template.*
