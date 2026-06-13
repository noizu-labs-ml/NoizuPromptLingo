# Style Guide: CodeFresh — Direction D: Forge

> The evaluation IS the design. Warm precision, built from the product outward.

**Style System:** Bespoke — derived from CodeFresh's product concepts, not from a generic style spec
**Design Philosophy:** Eval-First
**Scenario:** AI agent behavioral testing platform — visual identity inseparable from the product

---

## Scenario

Directions A, B, and C apply external style systems to CodeFresh. They're professionally executed skins. Forge is different: it asks **"what does CodeFresh look like if the design comes from the product itself?"**

Three product concepts define the visual identity:

1. **Eval states are the color system.** Pass/warn/fail/freeball aren't semantic colors applied to a neutral palette — they ARE the palette. Everything else is designed to make these four states maximally distinguishable, readable, and emotionally resonant. The brand accent is **copper** — warm, metallic, connoting both the forge (testing under heat) and circuitry (engineering precision). It lives in the same warm family as freeball orange but is distinct enough for brand use.

2. **The graph node is the design atom.** Not a card component adapted from a library — the actual conversation graph node, with its border-weight, internal structure, and state behaviors, propagates to every card-like element in the interface. If you redesign a graph node, you've redesigned the entire system.

3. **Three voices need visual distinction.** Every conversation has three participants: the script author (engineer), the agent under test, and the evaluator (CodeFresh). Each gets a typographic treatment, making transcripts instantly scannable without reading a word.

**Signals:** Engineered warmth, forensic precision, controlled heat. "We test AI agents the way metallurgists test alloys — with heat, pressure, and exact measurement."

**What this is NOT:** A retro/skeuomorphic "forge" aesthetic. No anvils, no fire emojis. The metaphor is structural, not decorative. The warmth comes from color temperature and typography, not from illustration.

---

## Color Palette

### Design Rationale

The palette is built outward from the four eval states. Background and text colors are warm-shifted (toward amber/brown, away from blue/cool) so that eval colors — particularly pass green and fail red — read with maximum clarity against them. Most dev tools use blue-shifted dark backgrounds (#09090B, zinc-900) which compete with blue semantic colors and flatten the difference between warn-amber and freeball-orange. Forge's warm ink background creates a neutral field where all four eval states pop equally.

The accent color (copper) is chosen because:
- It's warm — harmonizes with the warm background instead of fighting it
- It's distinct from all four eval states (pass=green, warn=gold, fail=red, freeball=orange — copper sits between orange and brown, darker than either)
- It's virtually unused in the dev tool space (violet, blue, and green dominate)
- It connotes engineering, circuitry, and craft — fitting for a testing tool

```css
:root {
  /* --- Backgrounds (warm ink) --- */
  --bg-void: #08090D;       /* deepest — app chrome, behind everything */
  --bg-primary: #0E1017;    /* main workspace background */
  --bg-surface: #151820;    /* cards, panels, graph canvas */
  --bg-elevated: #1D2029;   /* popovers, dropdowns, modals */
  --bg-well: #0B0C11;       /* inset areas — code blocks, input fields */

  /* --- Text (warm white) --- */
  --text-primary: #E8E5E0;   /* body text — warm, not blue-white */
  --text-secondary: #908D87; /* labels, metadata — warm gray */
  --text-tertiary: #5C5A55;  /* placeholders, disabled — warm dark gray */
  --text-ghost: #3A3835;     /* decorative text, watermarks */

  /* --- Borders (warm, layered) --- */
  --border-default: #2A2D33; /* panel borders, dividers */
  --border-subtle: #1D2029;  /* inner separators */
  --border-strong: #3D4048;  /* emphasized containers */

  /* --- Accent: Copper --- */
  --copper: #D4915E;
  --copper-bright: #E8A474;
  --copper-dim: #A06B3F;
  --copper-muted: rgba(212, 145, 94, 0.12);
  --copper-wash: rgba(212, 145, 94, 0.06);

  /* --- Eval States: THE color system --- */
  --eval-pass: #3EC97E;
  --eval-pass-strong: #2DB86A;
  --eval-pass-muted: rgba(62, 201, 126, 0.10);
  --eval-pass-wash: rgba(62, 201, 126, 0.05);

  --eval-warn: #E5C53E;
  --eval-warn-strong: #D4B42D;
  --eval-warn-muted: rgba(229, 197, 62, 0.10);
  --eval-warn-wash: rgba(229, 197, 62, 0.05);

  --eval-fail: #E54E4E;
  --eval-fail-strong: #D43D3D;
  --eval-fail-muted: rgba(229, 78, 78, 0.10);
  --eval-fail-wash: rgba(229, 78, 78, 0.05);

  --eval-freeball: #E8863D;
  --eval-freeball-strong: #D4752C;
  --eval-freeball-muted: rgba(232, 134, 61, 0.10);
  --eval-freeball-wash: rgba(232, 134, 61, 0.05);

  /* --- Utility --- */
  --info: #5DA4E8;
  --info-muted: rgba(93, 164, 232, 0.10);
}
```

```
+------------------------------------------+
|  CODEFRESH PALETTE — Direction D: Forge   |
+------------------------------------------+
|                                           |
|  BACKGROUNDS (warm ink)                   |
|  ██████  #08090D  Void                    |
|  ██████  #0E1017  Primary                 |
|  ██████  #151820  Surface                 |
|  ██████  #1D2029  Elevated                |
|                                           |
|  TEXT (warm white)                         |
|  ██████  #E8E5E0  Primary                 |
|  ██████  #908D87  Secondary               |
|  ██████  #5C5A55  Tertiary                |
|                                           |
|  ACCENT                                   |
|  ██████  #D4915E  Copper                  |
|  ██████  #E8A474  Copper Bright           |
|  ██████  #A06B3F  Copper Dim              |
|                                           |
|  EVAL STATES (the brand)                  |
|  ██████  #3EC97E  Pass                    |
|  ██████  #E5C53E  Warn                    |
|  ██████  #E54E4E  Fail                    |
|  ██████  #E8863D  Freeball                |
|                                           |
+------------------------------------------+
```

**Usage rules:**
- Dark mode only — the warm ink background IS the design
- Copper accent is used for: primary CTAs, active navigation, focus rings, brand elements, and the "Run" action button
- Eval colors are the **primary visual interest** — they're louder than the accent on purpose
- Backgrounds use 4 depths (void → primary → surface → elevated) — maintain this hierarchy religiously
- `--bg-well` is for inset/recessed areas (code blocks, form inputs) — darker than primary, creating visual depth
- Freeball orange and copper are in the same warm family but differ by ~20% lightness and saturation — never place them adjacent without a border or background separator
- No gradients. No decorative shadows. Surface elevation is communicated through border and background steps only.

### Contrast Verification

| Combination | Ratio | Status |
|---|---|---|
| `--text-primary` (#E8E5E0) on `--bg-primary` (#0E1017) | 14.8:1 | AAA |
| `--text-secondary` (#908D87) on `--bg-primary` (#0E1017) | 5.4:1 | AA |
| `--text-tertiary` (#5C5A55) on `--bg-primary` (#0E1017) | 3.1:1 | AA large text only |
| `--copper` (#D4915E) on `--bg-primary` (#0E1017) | 7.2:1 | AAA |
| `--eval-pass` (#3EC97E) on `--bg-primary` (#0E1017) | 8.9:1 | AAA |
| `--eval-warn` (#E5C53E) on `--bg-primary` (#0E1017) | 10.8:1 | AAA |
| `--eval-fail` (#E54E4E) on `--bg-primary` (#0E1017) | 4.5:1 | AA |
| `--eval-freeball` (#E8863D) on `--bg-primary` (#0E1017) | 6.8:1 | AAA |
| `--copper` (#D4915E) on `--bg-surface` (#151820) | 6.3:1 | AAA |

---

## Typography

### Three Voices

CodeFresh conversations involve three distinct participants. Each gets a typographic treatment so transcripts are scannable at a glance:

| Voice | Font | Weight | Visual Signal |
|---|---|---|---|
| **Script Author** (engineer writing prompts) | Mono, muted color | 400 | "I wrote this" — code-like, recessive |
| **Agent Under Test** (AI responses) | Sans, primary color, slightly larger | 400 | "The agent said this" — readable prose, prominent |
| **Evaluator** (CodeFresh's assessments, scores, expectations) | Sans, copper, smaller | 500 | "The system measured this" — annotation, authoritative |

This three-voice system is CodeFresh's typographic signature. No other dev tool needs it because no other tool mediates between script author, AI agent, and evaluator.

### Font Stack

```css
--font-sans: 'Plus Jakarta Sans', 'DM Sans', -apple-system, BlinkMacSystemFont, sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', Consolas, monospace;
```

**Why Plus Jakarta Sans:** Geometric sans-serif with soft terminals and slightly wider letter-spacing than Inter/Geist. It's precise without being cold — matching Forge's "engineered warmth" positioning. Variable font, so weight and width adjustments are smooth. It has distinctive lowercase 'a' and 'g' shapes that separate it from the Inter/Geist monoculture.

**Why JetBrains Mono:** Best-in-class ligatures for code, wide language support, purpose-built for reading code. Free. Many engineers already have it installed.

### Type Scale

| Level | Size | Weight | Line Height | Letter Spacing | Use |
|---|---|---|---|---|---|
| Display | clamp(32px, 4vw, 48px) | 700 | 1.1 | -0.02em | Dashboard hero metrics, empty state headlines |
| H1 | 26px | 700 | 1.2 | -0.015em | Page titles ("Scripts", "Runs", "Agents") |
| H2 | 20px | 600 | 1.25 | -0.01em | Panel titles, script names in list |
| H3 | 16px | 600 | 1.35 | 0 | Card headers, graph node titles |
| Body | 14px | 400 | 1.6 | 0 | Default UI text |
| Body (Agent) | 15px | 400 | 1.7 | 0.005em | Agent responses in transcripts |
| Body Small | 12px | 400 | 1.5 | 0.01em | Metadata, timestamps |
| Code | 13px | 400 | 1.5 | 0 | Prompts, YAML, expectation definitions |
| Evaluator | 12px | 500 | 1.5 | 0.02em | Scores, expectation results, system annotations |
| Caption | 11px | 500 | 1.4 | 0.03em | Graph edge labels, overlines |

**Typography notes:**
- Two weights for sans: 400 and 600/700. No 500 except for evaluator voice.
- Negative letter-spacing on headlines — creates visual density and confidence at large sizes
- Positive letter-spacing on small sizes — improves readability of metadata and labels
- Agent responses are 15px (1px larger than UI body) with 1.7 line height — subtle but measurable readability improvement for the content engineers spend the most time reading
- Evaluator text is always 12px with 500 weight and wider spacing — it reads like marginalia, annotation-like

### Font Sources

| Font | Primary Source | License | Link | Fallback |
|---|---|---|---|---|
| Plus Jakarta Sans | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Plus+Jakarta+Sans) | DM Sans (Google Fonts) |
| JetBrains Mono | JetBrains | Free / OFL | [GitHub](https://github.com/JetBrains/JetBrainsMono) | Fira Code (Google Fonts) |

---

## Spacing & Layout

**Base unit:** 4px
**Spacing scale:** 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96px

Note: Forge includes 20px and 40px stops that the generic systems skip. These intermediate values are needed for the graph node internal padding (20px) and transcript turn spacing (40px) — both derived from product-specific requirements.

### Grid

| Breakpoint | Columns | Gutter | Margin | Max Width |
|---|---|---|---|---|
| Mobile (<768px) | 4 | 12px | 16px | 100% |
| Tablet (768–1024px) | 8 | 16px | 24px | 100% |
| Desktop (1024–1440px) | 12 | 20px | 32px | 100% |
| Wide (>1440px) | 12 | 24px | 48px | 1400px |

### Layout Pattern: Command + Context

Forge doesn't use a persistent sidebar or full-width layout. Instead:

1. **Top bar** — Logo, primary nav tabs, "Run" button, command palette trigger
2. **Breadcrumb trail** — Shows current location in the graph path (e.g., `onboarding-flow > node-3 > node-3a`). This is always visible and interactive — clicking a crumb navigates the graph.
3. **Main workspace** — Full width for graph editor; split view for run detail (graph left, transcript right)
4. **Context panel** — Slides in from the right edge on demand (node detail, expectation config). Overlays the workspace partially, not a permanent split.

```
+================================================================+
|  codefre.sh     Scripts  Runs  Agents  Personas   [⌘K]  [▶ Run]|
+================================================================+
|  onboarding-flow  ›  node-3  ›  node-3a (hostile)              |
+----------------------------------------------------------------+
|                                                                  |
|  ┌───────────────────────────────────────────────────────────┐  |
|  │                                                           │  |
|  │   MAIN WORKSPACE (100% width)                             │  |
|  │                                                           │  |
|  │   Graph editor, results view, or dashboard fills this     │  |
|  │                                                           │  |
|  │                                          ┌────────────┐   │  |
|  │                                          │ CONTEXT    │   │  |
|  │                                          │ PANEL      │   │  |
|  │                                          │ (360px)    │   │  |
|  │                                          │            │   │  |
|  │                                          │ slides in  │   │  |
|  │                                          │ on demand  │   │  |
|  │                                          └────────────┘   │  |
|  │                                                           │  |
|  └───────────────────────────────────────────────────────────┘  |
|                                                                  |
+================================================================+
```

**Why no persistent sidebar:** The graph editor needs maximum horizontal space. A 260px sidebar steals 18% of a 1440px viewport for information (script list, agent list) that's needed during setup, not during active work. The command palette (`⌘K`) surfaces the same navigation without spatial cost.

---

## Component Styling

### Design Atom: The Graph Node

Everything card-like in Forge inherits from the graph node. This is the fundamental design decision: the graph node's visual DNA — border-radius (6px), border-weight (1.5px), internal padding (20px), state transition speed (120ms) — propagates to cards, panels, badges, and inputs.

```css
/* --- The graph node: Forge's design atom --- */
.graph-node {
  background: var(--bg-surface);
  border: 1.5px solid var(--border-default);
  border-radius: 6px;
  padding: 20px;
  min-width: 200px;
  max-width: 320px;
  font-family: var(--font-sans);
  font-size: 14px;
  transition: border-color 120ms ease, background 120ms ease;
}
.graph-node:hover {
  border-color: var(--border-strong);
}
.graph-node--selected {
  border-color: var(--copper);
  box-shadow: 0 0 0 3px var(--copper-muted);
}

/* --- Eval state treatments --- */
.graph-node--pass {
  border-color: var(--eval-pass);
  background: var(--eval-pass-wash);
}
.graph-node--warn {
  border-color: var(--eval-warn);
  background: var(--eval-warn-wash);
}
.graph-node--fail {
  border-color: var(--eval-fail);
  background: var(--eval-fail-wash);
}

/* --- Freeball: the signature state --- */
.graph-node--freeball {
  border-color: var(--eval-freeball);
  background: var(--eval-freeball-wash);
  border-style: dashed;
  border-width: 2px;
  position: relative;
}
/* Freeball nodes get a subtle pulsing border to indicate "live" / improvised */
@keyframes freeball-pulse {
  0%, 100% { border-color: var(--eval-freeball); }
  50% { border-color: var(--eval-freeball-strong); }
}
.graph-node--freeball.is-active {
  animation: freeball-pulse 2s ease-in-out infinite;
}

/* Graph edges */
.graph-edge {
  stroke: var(--border-default);
  stroke-width: 1.5;
}
.graph-edge--freeball {
  stroke: var(--eval-freeball);
  stroke-dasharray: 6 4;
  stroke-width: 2;
}
.graph-edge--active {
  stroke: var(--copper);
  stroke-width: 2;
}
```

### Buttons

```css
/* Primary — Copper, used for "Run", "Save", "Create" */
.btn-primary {
  background: var(--copper);
  color: var(--bg-void);
  padding: 8px 20px;
  border: 1.5px solid var(--copper);
  border-radius: 6px;
  font-family: var(--font-sans);
  font-size: 13px;
  font-weight: 600;
  transition: background 120ms ease, border-color 120ms ease;
}
.btn-primary:hover {
  background: var(--copper-bright);
  border-color: var(--copper-bright);
}
.btn-primary:focus-visible {
  outline: 2px solid var(--copper);
  outline-offset: 2px;
}
.btn-primary:active {
  background: var(--copper-dim);
  border-color: var(--copper-dim);
}
.btn-primary:disabled {
  opacity: 0.35;
  cursor: not-allowed;
}

/* Secondary — ghost with border */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  padding: 8px 20px;
  border: 1.5px solid var(--border-default);
  border-radius: 6px;
  font-family: var(--font-sans);
  font-size: 13px;
  font-weight: 600;
  transition: border-color 120ms ease, background 120ms ease;
}
.btn-secondary:hover {
  border-color: var(--border-strong);
  background: var(--bg-elevated);
}

/* Ghost — text only, no border */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  padding: 8px 12px;
  border: none;
  border-radius: 6px;
  font-family: var(--font-sans);
  font-size: 13px;
  font-weight: 400;
  transition: color 120ms ease;
}
.btn-ghost:hover {
  color: var(--text-primary);
}

/* Eval-state buttons (e.g., "Promote to branch" on a freeball node) */
.btn-eval {
  background: transparent;
  padding: 6px 12px;
  border: 1.5px solid currentColor;
  border-radius: 6px;
  font-family: var(--font-sans);
  font-size: 12px;
  font-weight: 500;
}
.btn-eval--pass { color: var(--eval-pass); }
.btn-eval--warn { color: var(--eval-warn); }
.btn-eval--fail { color: var(--eval-fail); }
.btn-eval--freeball { color: var(--eval-freeball); }
```

### Form Inputs

```css
.input {
  background: var(--bg-well);
  color: var(--text-primary);
  padding: 10px 14px;
  border: 1.5px solid var(--border-default);
  border-radius: 6px;
  font-family: var(--font-sans);
  font-size: 14px;
  transition: border-color 120ms ease, box-shadow 120ms ease;
}
.input:focus {
  border-color: var(--copper);
  box-shadow: 0 0 0 3px var(--copper-muted);
  outline: none;
}
.input:hover:not(:focus) {
  border-color: var(--border-strong);
}
.input--error {
  border-color: var(--eval-fail);
  box-shadow: 0 0 0 3px var(--eval-fail-muted);
}
.input::placeholder {
  color: var(--text-tertiary);
}

/* Code input — YAML/JSON script editing */
.input--code {
  font-family: var(--font-mono);
  font-size: 13px;
  background: var(--bg-well);
  line-height: 1.5;
}
```

### Score Badges

```css
/* Inline score indicators — show the confidence value */
.score-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 3px 10px;
  border-radius: 4px;
  font-family: var(--font-mono);
  font-size: 12px;
  font-weight: 600;
}
.score-badge--pass {
  background: var(--eval-pass-muted);
  color: var(--eval-pass);
}
.score-badge--warn {
  background: var(--eval-warn-muted);
  color: var(--eval-warn);
}
.score-badge--fail {
  background: var(--eval-fail-muted);
  color: var(--eval-fail);
}
.score-badge--freeball {
  background: var(--eval-freeball-muted);
  color: var(--eval-freeball);
  border: 1px dashed var(--eval-freeball);
}

/* Confidence bar — spark visualization within the badge */
.score-bar {
  width: 40px;
  height: 4px;
  background: var(--bg-well);
  border-radius: 2px;
  overflow: hidden;
}
.score-bar__fill {
  height: 100%;
  border-radius: 2px;
  transition: width 300ms ease-out;
}
.score-bar__fill--pass { background: var(--eval-pass); }
.score-bar__fill--warn { background: var(--eval-warn); }
.score-bar__fill--fail { background: var(--eval-fail); }
```

### Transcript Components (Three-Voice System)

```css
/* Transcript container */
.transcript {
  max-width: 72ch;
  padding: 24px;
}

/* Voice 1: Script Author — code-like, recessive */
.voice-author {
  font-family: var(--font-mono);
  font-size: 13px;
  line-height: 1.5;
  color: var(--text-secondary);
  padding: 12px 16px;
  background: var(--bg-well);
  border-radius: 6px;
  border-left: 3px solid var(--border-default);
}

/* Voice 2: Agent Under Test — prominent, readable */
.voice-agent {
  font-family: var(--font-sans);
  font-size: 15px;
  line-height: 1.7;
  color: var(--text-primary);
  padding: 16px 20px;
  border-left: 3px solid var(--text-tertiary);
}
.voice-agent p + p {
  margin-top: 16px;
}

/* Voice 3: Evaluator — annotation-like, authoritative */
.voice-evaluator {
  font-family: var(--font-sans);
  font-size: 12px;
  font-weight: 500;
  line-height: 1.5;
  letter-spacing: 0.02em;
  color: var(--copper);
  padding: 8px 16px;
  background: var(--copper-wash);
  border-radius: 4px;
  border-left: 3px solid var(--copper-dim);
}

/* Turn separator */
.turn-separator {
  margin: 40px 0;
  border: none;
  border-top: 1px solid var(--border-subtle);
  position: relative;
}
.turn-separator::after {
  content: attr(data-turn);
  position: absolute;
  top: -8px;
  left: 20px;
  font-family: var(--font-mono);
  font-size: 10px;
  color: var(--text-ghost);
  background: var(--bg-primary);
  padding: 0 8px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}
```

### Navigation

```css
/* Top bar */
.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  height: 52px;
  background: var(--bg-void);
  border-bottom: 1.5px solid var(--border-default);
}

/* Logo */
.logo {
  font-family: var(--font-sans);
  font-size: 16px;
  font-weight: 700;
  color: var(--text-primary);
  letter-spacing: -0.01em;
}
.logo .dot {
  color: var(--copper);
}

/* Nav tabs */
.nav-tab {
  padding: 14px 16px;
  font-family: var(--font-sans);
  font-size: 13px;
  font-weight: 400;
  color: var(--text-secondary);
  border-bottom: 2px solid transparent;
  transition: color 120ms ease, border-color 120ms ease;
}
.nav-tab:hover {
  color: var(--text-primary);
}
.nav-tab--active {
  color: var(--copper);
  border-bottom-color: var(--copper);
  font-weight: 600;
}

/* Breadcrumb trail */
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 24px;
  background: var(--bg-primary);
  border-bottom: 1px solid var(--border-subtle);
  font-family: var(--font-mono);
  font-size: 12px;
}
.breadcrumb__item {
  color: var(--text-secondary);
  transition: color 120ms ease;
}
.breadcrumb__item:hover {
  color: var(--text-primary);
}
.breadcrumb__item--current {
  color: var(--copper);
  font-weight: 500;
}
.breadcrumb__separator {
  color: var(--text-ghost);
}

/* Command palette trigger */
.cmd-trigger {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border: 1.5px solid var(--border-default);
  border-radius: 6px;
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-tertiary);
  transition: border-color 120ms ease;
}
.cmd-trigger:hover {
  border-color: var(--border-strong);
  color: var(--text-secondary);
}
```

### Cards

```css
/* Card — inherits from graph node DNA */
.card {
  background: var(--bg-surface);
  border: 1.5px solid var(--border-default);
  border-radius: 6px;
  padding: 20px;
  transition: border-color 120ms ease;
}
.card:hover {
  border-color: var(--border-strong);
}
.card--active {
  border-color: var(--copper);
}

/* Script card in list view */
.card--script {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.card--script .card__title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
}
.card--script .card__meta {
  font-size: 12px;
  color: var(--text-secondary);
}
.card--script .card__tags {
  display: flex;
  gap: 6px;
}

/* Persona tag */
.tag {
  display: inline-flex;
  padding: 2px 8px;
  border-radius: 4px;
  font-family: var(--font-mono);
  font-size: 11px;
  font-weight: 500;
  background: var(--bg-elevated);
  color: var(--text-secondary);
  border: 1px solid var(--border-subtle);
}
.tag--hostile { color: var(--eval-fail); border-color: var(--eval-fail-muted); }
.tag--confused { color: var(--eval-warn); border-color: var(--eval-warn-muted); }
.tag--adversarial { color: var(--eval-freeball); border-color: var(--eval-freeball-muted); }
```

---

## Interaction & Motion

All transitions use 120ms — faster than the 150ms default of Minimal Tech, signaling responsiveness without the 100ms abruptness of Neo-Brutalist.

| Element | Effect | Duration | Easing |
|---|---|---|---|
| Button hover | Background/border shift | 120ms | ease |
| Button press | Darken fill | 60ms | ease |
| Input focus | Border + copper ring | 120ms | ease |
| Nav tab hover | Color shift | 120ms | ease |
| Card hover | Border lighten | 120ms | ease |
| Graph node hover | Border lighten | 120ms | ease |
| Context panel open | SlideX from right | 200ms | cubic-bezier(0.16, 1, 0.3, 1) |
| Context panel close | SlideX to right | 150ms | ease-in |
| Breadcrumb update | Text crossfade | 150ms | ease |
| Score counter | Number tick-up | 400ms | ease-out |

### Signature Moment: The Forge Sequence

When eval results load, graph nodes undergo a "forging" sequence:
1. All nodes briefly flash `--bg-well` (darkest) — the graph goes dark (100ms)
2. Nodes then illuminate to their eval state color in path-order (60ms per node, following conversation edges)
3. The breadcrumb trail simultaneously populates as nodes illuminate

This creates a brief "the forge is testing" → "results are emerging" → "the path is revealed" narrative. Total duration: 100ms + (node_count × 60ms).

`prefers-reduced-motion`: Skip step 1 (no flash), nodes appear in final state with no stagger.

### Command Palette

The `⌘K` command palette is a core navigation element:

```css
.cmd-palette {
  position: fixed;
  top: 20%;
  left: 50%;
  transform: translateX(-50%);
  width: min(560px, 90vw);
  background: var(--bg-elevated);
  border: 1.5px solid var(--border-strong);
  border-radius: 8px;
  box-shadow: 0 24px 48px rgba(0, 0, 0, 0.4);
  z-index: 100;
}
.cmd-palette__input {
  width: 100%;
  padding: 16px 20px;
  font-family: var(--font-sans);
  font-size: 16px;
  background: transparent;
  border: none;
  border-bottom: 1px solid var(--border-default);
  color: var(--text-primary);
}
.cmd-palette__result {
  padding: 10px 20px;
  font-size: 14px;
  color: var(--text-secondary);
  transition: background 60ms ease;
}
.cmd-palette__result:hover,
.cmd-palette__result--selected {
  background: var(--copper-wash);
  color: var(--text-primary);
}
.cmd-palette__result .shortcut {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--text-tertiary);
}
```

---

## Asset Guidelines

**Photography:** None.

**Iconography:** Lucide icons, 18px default, 1.5px stroke weight. Uses `currentColor`. Strictly outlined, never filled. When an eval state needs icon representation alongside color (for accessibility), use:
- Pass: `check-circle`
- Warn: `alert-triangle`
- Fail: `x-circle`
- Freeball: `compass` (going off the map)

**Data visualization:** Eval colors are the data colors. Line charts use 2px strokes. Area fills use wash variants (0.05 opacity). Axes and grid lines use `--border-subtle`. Tooltips use `--bg-elevated` with `--border-strong`. No 3D, no decorative fills.

**Empty states:** Centered text + single CTA in copper. No illustration. Example:

```
                    No scripts yet

     Create your first evaluation script to start
           testing agent behavior.

               [+ Create Script]
```

**Logo direction:** "codefre.sh" in Plus Jakarta Sans at 700 weight, lowercase. The period before "sh" is rendered in `--copper`. At small sizes (favicon, app icon), reduce to "cf" monogram in a 6px-radius square with copper background and void text.

---

## Custom SVG Glyph System

### Glyph Design Principles

Every bespoke CodeFresh glyph follows these rules:
- **1.5px stroke weight** — matches the border system (the design atom's border)
- **24×24 viewBox** — standard size, compatible with Lucide when mixed
- **`currentColor` inheritance** — glyphs pick up their parent's text color
- **Stroke-only** — no fills except small indicator dots (matching the icon philosophy)
- **6px corner radius** on enclosed shapes (matching the graph node)
- **Rooted in the graph node** — eval glyphs use the node's rounded-rect silhouette as their container, so you instantly recognize "this is about a node"

### Eval State Glyphs

These replace generic Lucide icons for eval-specific UI. Each glyph is a **graph node silhouette** (rounded rect, rx=3) containing a state indicator. This makes them instantly recognizable as CodeFresh eval states even without color.

#### Pass: "The Seal"

A graph node with a checkmark stroke. The check is slightly left-weighted — not centered — giving it a hand-marked "approved" quality.

```svg
<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="5" width="18" height="14" rx="3"/>
  <path d="M8.5 12.5l2.5 2.5 5-5"/>
</svg>
```

#### Warn: "The Flag"

A graph node with an exclamation mark. The dot at the bottom is a filled circle (the only fill in the glyph set) — it anchors the eye to the warning.

```svg
<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="5" width="18" height="14" rx="3"/>
  <line x1="12" y1="9" x2="12" y2="13"/>
  <circle cx="12" cy="15.5" r="0.75" fill="currentColor" stroke="none"/>
</svg>
```

#### Fail: "The Break"

A graph node with offset diagonal lines. They DON'T form a clean X — one pair is shifted 1px, creating a "fractured" effect. The break is intentional: this node's expectations shattered.

```svg
<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="5" width="18" height="14" rx="3"/>
  <path d="M9 9.5l6 5.5"/>
  <path d="M15 9l-6 6"/>
</svg>
```

#### Freeball: "The Drift"

A graph node with a **dashed border** and a diagonal arrow pointing up-right — the agent left the expected path. The arrow exits toward the node's corner, suggesting escape from the script.

```svg
<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="5" width="18" height="14" rx="3" stroke-dasharray="4 3"/>
  <path d="M10 14l4.5-4.5"/>
  <path d="M11.5 9.5h3v3"/>
</svg>
```

### Voice Indicator Glyphs

Small (16×16) markers that precede transcript entries, identifying which participant is speaking. These appear in the left margin of the three-voice transcript system.

#### Author: "The Prompt"

A terminal chevron + cursor — the engineer's voice.

```svg
<svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 4.5l3.5 3.5L3 11.5"/>
  <line x1="9" y1="11.5" x2="13" y2="11.5"/>
</svg>
```

#### Agent: "The Eye"

A circle with a concentric dot — the AI under observation. The double-ring suggests both "being watched" and "artificial intelligence."

```svg
<svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round">
  <circle cx="8" cy="8" r="5.5"/>
  <circle cx="8" cy="8" r="2" fill="currentColor" stroke="none"/>
</svg>
```

#### Evaluator: "The Gauge"

A half-circle with a needle — a measurement instrument. This is the evaluator passing judgment.

```svg
<svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 11a5.5 5.5 0 0110 0"/>
  <line x1="8" y1="11" x2="10.5" y2="6.5"/>
  <circle cx="8" cy="11" r="1" fill="currentColor" stroke="none"/>
</svg>
```

### Graph Element Glyphs

Used within the graph editor canvas.

#### Branch Point

A node where the conversation forks into multiple paths.

```svg
<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="6" cy="12" r="2.5"/>
  <circle cx="18" cy="7" r="2.5"/>
  <circle cx="18" cy="17" r="2.5"/>
  <path d="M8.5 11l5 -3.5"/>
  <path d="M8.5 13l5 3.5"/>
</svg>
```

#### Terminal Node

The end of a conversation path. A filled dot — the path stops here.

```svg
<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round">
  <circle cx="12" cy="12" r="6"/>
  <circle cx="12" cy="12" r="3" fill="currentColor" stroke="none"/>
</svg>
```

#### Edge Arrowhead

The directional marker on graph edges. Flat-bottomed, not a filled triangle — matches the geometric precision of the system.

```svg
<svg viewBox="0 0 12 10" width="12" height="10" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M1 1l5 4-5 4"/>
</svg>
```

#### Freeball Edge Arrowhead

Same shape but with a perpendicular tick mark — indicating "this path was improvised."

```svg
<svg viewBox="0 0 16 10" width="16" height="10" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M1 1l5 4-5 4"/>
  <line x1="10" y1="2" x2="10" y2="8"/>
</svg>
```

### Logo System

#### Wordmark

"codefre.sh" in Plus Jakarta Sans at weight 700. The period is `--copper`. The rest is `--text-primary`. Always lowercase.

```svg
<svg viewBox="0 0 200 32" width="200" height="32" xmlns="http://www.w3.org/2000/svg">
  <style>
    .wordmark { font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 700; font-size: 22px; }
    .text-primary { fill: #E8E5E0; }
    .copper { fill: #D4915E; }
  </style>
  <text x="0" y="24" class="wordmark">
    <tspan class="text-primary">codefre</tspan><tspan class="copper">.</tspan><tspan class="text-primary">sh</tspan>
  </text>
</svg>
```

**Usage rules:**
- Minimum width: 120px (below this, use monogram)
- Clear space: 1× the height of the 'h' on all sides
- Never change the typeface — the wordmark IS Plus Jakarta Sans 700
- Never capitalize — it's always lowercase
- The copper dot is non-negotiable — it's the brand mark within the wordmark

#### Monogram: "cf"

For favicons, app icons, and tight spaces. A 'c' and 'f' that share a stroke, inside a rounded square.

```svg
<svg viewBox="0 0 32 32" width="32" height="32" xmlns="http://www.w3.org/2000/svg">
  <rect x="1" y="1" width="30" height="30" rx="6" fill="#D4915E"/>
  <text x="16" y="23" text-anchor="middle" font-family="'Plus Jakarta Sans', sans-serif" font-weight="700" font-size="18" fill="#08090D">cf</text>
</svg>
```

**Monogram variants:**

| Variant | Background | Text | Use |
|---|---|---|---|
| Default | Copper `#D4915E` | Void `#08090D` | Favicon, app icon |
| Inverted | Void `#08090D` | Copper `#D4915E` | On light external backgrounds |
| Outline | Transparent | Copper `#D4915E` (+ 1.5px stroke rect) | Watermarks, subtle branding |

#### Icon Mark: "The Node"

For the smallest contexts (16×16 favicon). A single graph node silhouette in copper — the design atom at its most reduced.

```svg
<svg viewBox="0 0 16 16" width="16" height="16" xmlns="http://www.w3.org/2000/svg">
  <rect x="2" y="3" width="12" height="10" rx="2.5" fill="#D4915E"/>
  <circle cx="8" cy="8" r="1.5" fill="#08090D"/>
</svg>
```

### Decorative Motif: The Circuit Trace

A horizontal line pattern inspired by PCB traces — right-angle jogs at intervals. Used for section dividers, background texture, and the forge sequence visual.

#### As a section divider

```svg
<svg viewBox="0 0 400 8" width="100%" height="8" fill="none" stroke="#D4915E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" opacity="0.3" preserveAspectRatio="none">
  <path d="M0 4h80l4-3h40l4 3h30l4 3h60l4-3h40l4 3h130"/>
</svg>
```

#### As a background texture (tile)

```svg
<svg viewBox="0 0 120 24" width="120" height="24" fill="none" stroke="#D4915E" stroke-width="0.75" opacity="0.04" xmlns="http://www.w3.org/2000/svg">
  <path d="M0 12h20l3-6h14l3 6h10l3 6h14l3-6h10l3-6h14l3 6h20"/>
</svg>
```

**Usage rules for the circuit trace:**
- Section dividers: 0.3 opacity, copper color, full-width
- Background texture: 0.04 opacity maximum — barely perceptible, creates depth without distraction
- Never animate the trace (it's a static structural element, not a loading indicator)
- The trace always runs horizontally — never vertical, never diagonal
- Do NOT use as a border pattern — it's a standalone decorative element with its own spacing

### Glyph Summary

| Glyph | Name | Size | Context | Color |
|---|---|---|---|---|
| Pass node | The Seal | 24×24 | Graph nodes, result summaries | `--eval-pass` |
| Warn node | The Flag | 24×24 | Graph nodes, result summaries | `--eval-warn` |
| Fail node | The Break | 24×24 | Graph nodes, result summaries | `--eval-fail` |
| Freeball node | The Drift | 24×24 | Graph nodes, result summaries | `--eval-freeball` |
| Author voice | The Prompt | 16×16 | Transcript margins | `--text-secondary` |
| Agent voice | The Eye | 16×16 | Transcript margins | `--text-primary` |
| Evaluator voice | The Gauge | 16×16 | Transcript margins | `--copper` |
| Branch point | — | 24×24 | Graph editor | `--text-secondary` |
| Terminal node | — | 24×24 | Graph editor | `--text-secondary` |
| Edge arrow | — | 12×10 | Graph edges | `--border-default` |
| Freeball arrow | — | 16×10 | Freeball edges | `--eval-freeball` |
| Wordmark | codefre.sh | 200×32 | Nav, marketing | Primary + copper |
| Monogram | cf | 32×32 | Favicon, app icon | Copper + void |
| Icon mark | The Node | 16×16 | Tiny favicon | Copper |
| Circuit trace | — | Fluid | Dividers, texture | Copper, low opacity |

---

## Design Guidelines

### Do's & Don'ts

#### Color

| Do | Don't | Why |
|---|---|---|
| Use eval state colors as the loudest element on any screen | Let the copper accent overpower eval colors | Eval results are the product's reason to exist — they must always dominate |
| Separate freeball orange (`#E8863D`) from copper (`#D4915E`) with a border or background step | Place freeball and copper elements adjacent without separation | They're 20% apart in lightness and can blur together at small sizes |
| Use `--wash` (0.05) variants for node backgrounds | Use full-opacity eval colors as backgrounds | Full-opacity eval colors on dark backgrounds create eye strain and reduce text readability |
| Apply eval icons + color together for state indication | Rely on color alone for pass/warn/fail/freeball | Color-blind users need the icon shape as a redundant channel |
| Keep backgrounds at 80%+ of visual field | Fill screens with colored panels and cards | The warm ink background is the design — it needs space to breathe |

#### Typography

| Do | Don't | Why |
|---|---|---|
| Use the three-voice system in all transcript views | Display agent responses in monospace | Agent responses are prose — engineers need to read and judge natural language quality, not scan code |
| Keep evaluator text at 12px/500/copper everywhere | Vary evaluator treatment across views | Consistency makes the evaluator voice instantly recognizable in any context |
| Use negative letter-spacing on headings only | Apply negative letter-spacing to body text | Tight tracking improves headline confidence but destroys body readability |
| Use JetBrains Mono for all code-like content | Mix monospace fonts (e.g., Fira Code for one view, JetBrains Mono for another) | Font consistency prevents the "Frankenstein" effect |

#### Components

| Do | Don't | Why |
|---|---|---|
| Inherit graph node DNA (6px radius, 1.5px border, 20px padding) for all card-like containers | Introduce a different border-radius or weight for "special" cards | The graph node IS the design atom — everything flows from it |
| Use dashed borders exclusively for freeball/improvised states | Use dashes for other decorative purposes | The dash pattern is a semantic signal, not decoration |
| Reserve the freeball pulse animation for actively-running evaluations | Add pulse to historical/completed freeball nodes | Animation indicates "live" — a completed freeball should be static |
| Keep buttons under 3 variants (primary, secondary, ghost) + eval-state | Invent new button styles for specific features | Proliferating button variants erodes hierarchy |

#### Layout

| Do | Don't | Why |
|---|---|---|
| Give the graph editor 100% of available width | Permanently dedicate screen space to navigation or panels | Graph readability is directly proportional to available space |
| Use the command palette for navigation between sections | Build a sidebar "just in case" | The sidebar's spatial cost isn't justified by its usage frequency during active work |
| Slide context panels in as overlays | Push the workspace aside when panels open | Content shift during inspection is disorienting — overlays maintain spatial context |

### Color Pairing Matrix

Not every color combination is valid. This matrix defines which eval and accent colors can be used together.

```
             Pass    Warn    Fail    Freeball  Copper
Pass         ──      ✓       ✓       ✓         ✓
Warn         ✓       ──      ✓       ⚠         ✓
Fail         ✓       ✓       ──      ✓         ✓
Freeball     ✓       ⚠       ✓       ──        ⚠
Copper       ✓       ✓       ✓       ⚠         ──

✓ = safe to use adjacent
⚠ = requires a separator (border, background step, or 20px+ gap)
── = same color (no pairing needed)
```

**Why Warn ↔ Freeball and Freeball ↔ Copper need separation:**
- Warn (#E5C53E) and Freeball (#E8863D) are close in hue (gold vs. orange) — at small sizes or in peripheral vision, they merge
- Freeball (#E8863D) and Copper (#D4915E) are 20% apart in lightness within the same warm family — they need a background step between them

**Separator strategies:**
1. **Border:** 1.5px `--border-default` between adjacent elements
2. **Background step:** Place one on `--bg-surface` and the other on `--bg-elevated`
3. **Spatial gap:** 20px+ gap between elements (wider than the 8px default)

### Graph Visualization Guidelines

The conversation graph is CodeFresh's hero surface. These rules maintain readability across scales.

#### Node Dimensions

| Property | Min | Default | Max | Notes |
|---|---|---|---|---|
| Width | 160px | 240px | 320px | Narrow enough for 4 nodes visible at once on a 1440px viewport |
| Height | Auto (content) | Auto | 200px | Truncate with "..." + expand trigger if content exceeds max |
| Padding | 12px | 20px | 20px | At zoom <60%, padding reduces to 12px to preserve node count |
| Font size | 11px | 14px (body), 16px (title) | 16px | Below 60% zoom, node titles drop to 13px |

#### Edge Routing

1. **Direction:** Edges flow left-to-right (primary direction) or top-to-bottom (when horizontal space is constrained). Never right-to-left.
2. **Curve style:** Bézier curves with minimum 40px radius — no hard right angles on edges
3. **Crossing avoidance:** If edges must cross, use a 4px gap at the intersection point (one edge "hops" over the other)
4. **Freeball edges:** Always dashed (`stroke-dasharray: 6 4`), 2px stroke weight (0.5px heavier than standard)
5. **Active path:** When a node is selected, the full path from root to selected node highlights in copper (`--copper`, 2px stroke)
6. **Labels:** Edge labels (branch conditions) render at 11px, centered on the edge, with a `--bg-primary` background pill to prevent overlap with the edge stroke

#### Zoom Behaviors

| Zoom Level | What Changes |
|---|---|
| >100% | Full detail: all node content visible, expectation previews shown |
| 60–100% | Default: node titles + score badges visible, full expectations hidden |
| 30–60% | Compact: titles truncated to 24ch, score badges become colored dots, edges simplified |
| <30% | Minimap: nodes are colored rectangles only, no text, edges are simple lines |

#### Large Graphs (>50 nodes)

- Enable horizontal scrolling with a minimap in the bottom-right corner (160×100px, `--bg-elevated`)
- Collapse subtrees by double-clicking a node — collapsed subtrees show a count badge ("12 nodes")
- The breadcrumb trail becomes essential — it shows where you are even when the full graph isn't visible
- Consider grouping nodes by persona run (separate horizontal lanes per persona)

### Density Modes

Forge supports three density modes. The same information renders differently depending on context:

| Mode | Base Font | Padding Scale | Line Height | Use Case |
|---|---|---|---|---|
| **Compact** | 13px | ×0.75 | 1.4 | Graph editor, data tables, CI/CD output, sidebars |
| **Comfortable** | 14px | ×1.0 | 1.6 | Default — script list, agent config, dashboard |
| **Spacious** | 15–16px | ×1.25 | 1.7 | Transcript review, onboarding, empty states, marketing |

```css
/* Density via data attribute on the parent container */
[data-density="compact"] {
  --density-font: 13px;
  --density-padding: 0.75;
  --density-leading: 1.4;
}
[data-density="comfortable"] {
  --density-font: 14px;
  --density-padding: 1;
  --density-leading: 1.6;
}
[data-density="spacious"] {
  --density-font: 15px;
  --density-padding: 1.25;
  --density-leading: 1.7;
}
```

**Rule:** The user should never have to switch density mode manually. Forge views select their own density:
- Graph editor → compact
- Script list → comfortable
- Run transcript → spacious
- Dashboard → comfortable (metrics) + spacious (hero)

### Copy & Voice Guidelines

CodeFresh's UI copy follows a "confident lab technician" voice. Precise, not cold. Helpful, not chatty.

#### Tone Spectrum

```
  ← Too cold                             Too warm →
  "Error."        "Run failed."         "Oops, something"
                   ↑ HERE                "went wrong!"
```

#### Copy Patterns

| Context | Pattern | Example |
|---|---|---|
| **Empty state — headline** | Statement of what's missing (not a greeting) | "No scripts yet" — not "Welcome to CodeFresh!" |
| **Empty state — body** | One sentence explaining what they'd do here | "Create your first evaluation script to start testing agent behavior." |
| **Empty state — CTA** | Verb + object | "+ Create Script" — not "Get Started" |
| **Error — inline** | What happened + what to do | "Connection failed — check agent URL and retry" |
| **Error — toast** | State + action (one line) | "Run timed out after 120s. Increase timeout in settings." |
| **Success — toast** | Confirmation + detail (one line) | "Script saved. 8 nodes, 3 personas." |
| **Confirmation dialog** | Consequence + action pair | "This will remove the script and all 12 associated runs. Delete permanently?" |
| **Loading** | What's happening (no ellipsis animation) | "Running evaluation..." — not "Please wait..." |
| **Score annotation** | Metric + confidence (evaluator voice) | "asks clarifying questions: 0.92" — decimal, no percentage, no "score:" prefix |
| **Breadcrumb labels** | Node name or short description | "onboarding-flow › node-3 › ask-audience" — not "Node #3" |

#### Terminology

| Use | Don't Use | Reason |
|---|---|---|
| Script | Test, flow, scenario | "Script" is the core CodeFresh metaphor |
| Node | Step, turn, prompt | Nodes are graph elements, not linear steps |
| Expectation | Assertion, check, requirement | "Expectation" implies fuzziness; "assertion" implies binary |
| Freeball | Off-script, deviation, exception | "Freeball" is the brand term — own it |
| Run | Execution, session, attempt | Short, clear, conventional in testing tools |
| Persona | Profile, character, user type | "Persona" is UX-standard and accurate |
| Promote | Approve, accept, merge | "Promote" for converting a freeball path into a permanent branch |

### Accessibility Beyond Contrast

Forge's accessibility model goes beyond passing contrast ratios.

#### Redundant Encoding

Every eval state is communicated through **three channels simultaneously**:

| Channel | Pass | Warn | Fail | Freeball |
|---|---|---|---|---|
| **Color** | Green `#3EC97E` | Gold `#E5C53E` | Red `#E54E4E` | Orange `#E8863D` |
| **Icon** | The Seal (✓ in node) | The Flag (! in node) | The Break (✗ in node) | The Drift (↗ in dashed node) |
| **Border style** | Solid | Solid | Solid | **Dashed** |

This means a color-blind user can distinguish all four states by icon shape and border pattern alone.

#### Keyboard Navigation in the Graph

The graph editor must be fully keyboard-navigable:

| Key | Action |
|---|---|
| `Tab` | Move focus to next node (follows edge direction) |
| `Shift+Tab` | Move focus to previous node |
| `Enter` | Open node detail panel |
| `Escape` | Close panel / deselect node |
| `Arrow keys` | Navigate between sibling branches at a fork |
| `Home` | Jump to root node |
| `End` | Jump to terminal node on current path |
| `Space` | Toggle node collapse/expand (for subtrees) |
| `⌘K` / `Ctrl+K` | Open command palette |

Focus indicators: 3px `--copper` outline with 2px offset — visible against all backgrounds.

#### Screen Reader Announcements

When an eval state changes or results load:

```
[Node: "ask-audience"] Status: Pass. Score: 0.92.
Expects: "asks clarifying questions."
Branch: 2 paths. Next: "discuss-scope" or "suggest-framework."
```

When a freeball occurs:
```
[Node: "unexpected-response"] Status: Freeball.
Agent deviated from script.
Improvised path: 3 tentative nodes generated.
Action available: Promote to permanent branch.
```

#### Focus Management for Panels

When the context panel opens:
1. Focus moves to the panel's first interactive element
2. Tab is trapped within the panel until `Escape` closes it
3. On close, focus returns to the graph node that triggered the panel

#### Motion Sensitivity

All animation respects `prefers-reduced-motion`:

| Feature | Default | Reduced Motion |
|---|---|---|
| Forge sequence | Dark flash → staggered illumination | Instant final state |
| Freeball pulse | 2s ease-in-out infinite | Static dashed border |
| Context panel slide | 200ms cubic-bezier | Instant appear |
| Score counter tick-up | 400ms ease-out | Instant final value |
| Node hover border | 120ms ease | Instant color change |

---

## What Makes This Different

| Dimension | Directions A/B/C | Direction D: Forge |
|---|---|---|
| **Color origin** | Picked from style spec palette | Derived from eval states + warm-shifted to support them |
| **Accent** | Violet (A/B) or Lime (C) — generic dev tool colors | Copper — unique in the space, warm, connotes engineering |
| **Typography** | Geist (= Vercel) or Space Mono (= generic brutalist) | Plus Jakarta Sans — distinctive geometric, not overused |
| **Design atoms** | Generic cards/panels adapted from library | Graph node DNA propagates to all card-like elements |
| **Transcript** | Mono (A), Serif (B), or Mono (C) — binary choice | Three-voice system: Author (mono), Agent (sans), Evaluator (copper sans) |
| **Layout** | Persistent sidebar (A/B) or hamburger menu (C) | Command palette + breadcrumb trail — navigates without spatial cost |
| **Motion signature** | Staggered color fade (A/B) or hard cut (C) | "Forge sequence" — dark flash → path-ordered illumination |
| **Background temp** | Cool (zinc/neutral) | Warm (blue-shifted ink) — eval colors pop harder |

---

## Implementation Checklist

- [ ] Plus Jakarta Sans (sans) for all UI, agent transcript text
- [ ] JetBrains Mono for prompts, YAML, expectations, code, script author voice
- [ ] Copper accent for CTAs, active states, focus rings, evaluator voice
- [ ] Three-voice transcript system: author (mono/muted), agent (sans/primary), evaluator (sans/copper)
- [ ] Eval state colors are the loudest elements in any view
- [ ] Background warmth: `--bg-primary` is #0E1017 (warm ink), not zinc/neutral
- [ ] Graph node DNA (6px radius, 1.5px border, 20px padding, 120ms transitions) propagated to all cards
- [ ] Freeball nodes: dashed border, active pulse animation
- [ ] Command palette (`⌘K`) as primary navigation mechanism
- [ ] Breadcrumb trail showing graph path position
- [ ] No persistent sidebar — context panel slides in on demand
- [ ] Forge sequence on eval result load
- [ ] `prefers-reduced-motion` respected (no stagger, instant state)
- [ ] WCAG AA contrast on all text (verified in table above)
- [ ] Eval-fail red (#E54E4E) used at 14px+ or paired with `x-circle` icon
- [ ] Dark mode only
- [ ] No gradients, no decorative shadows

---

*Derived from: CodeFresh product concepts (eval-first design philosophy). Not based on a generic style spec.*
