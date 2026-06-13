# Direction C: Signal Mesh

**Product:** IoTGo — Autonomous AI Agents for IoT Fleet Management
**Domain:** iotgo.io
**Style System:** Bold Expressive (Industrial Variant)
**One-liner:** Infrastructure, not interface.

---

## Scenario

Signal Mesh doesn't want to look like software. It wants to look like the thing your software controls.

The entire visual language is stolen from the places where real infrastructure is monitored: SCADA control rooms with their green-on-black CRTs, terminal multiplexers tiling eight processes on a single screen, the dense grids of a Bloomberg terminal where every pixel earns its keep. This is deliberate provocation. Most SaaS products sand down every edge, soften every surface, and add generous whitespace to feel "approachable." Signal Mesh does the opposite. It says: this tool is for people who already know what they're doing. The density is a feature. The monospace is a signal. The black is not "dark mode" — it's the absence of everything that doesn't matter.

The bet is that IoT fleet operators — the people who manage 10,000 temperature sensors in a warehouse network, or keep a manufacturing line's edge devices patched at 3am — will recognize this visual language instantly. They live in terminals. They read logs. They think in grids. Signal Mesh speaks their native tongue, and it doesn't apologize for it. The green accent is industrial green: the color of "system nominal," the color of the LED that means you can go back to sleep. Amber means pay attention. Red means act now. There's no brand-purple hero section. There's no illustration of a friendly robot. There's a fleet health score, a grid of devices, and an agent log scrolling in real time.

This direction is polarizing by design. A marketing VP will hate it. An SRE who's been on-call for six years will feel like they're home. That's the trade, and it's the right one for an infrastructure product that competes on trust, density, and competence — not on visual warmth.

---

## Color System

### CSS Custom Properties

```css
:root {
  /* ══════════════════════════════════════════════════
     SIGNAL MESH — COLOR SYSTEM
     Infrastructure, not interface.
     ══════════════════════════════════════════════════ */

  /* ── Surfaces ── */
  --color-bg:                #000000;
  --color-surface:           #0A0A0A;
  --color-elevated:          #141414;

  /* ── Text ── */
  --color-text-primary:      #E0E0E0;
  --color-text-secondary:    #888888;
  --color-text-tertiary:     #555555;

  /* ── Borders ── */
  --color-border:            #333333;
  --color-border-strong:     #555555;

  /* ── Accent: Electric Green ── */
  --color-accent:            #00E676;
  --color-accent-muted:      rgba(0, 230, 118, 0.10);
  --color-accent-hover:      rgba(0, 230, 118, 0.20);

  /* ── Secondary Accent: Amber ── */
  --color-amber:             #FFB300;
  --color-amber-muted:       rgba(255, 179, 0, 0.10);

  /* ── Device Health (Industrial Palette) ── */
  --color-healthy:           #00E676;
  --color-warning:           #FFB300;
  --color-critical:          #FF1744;
  --color-offline:           #616161;
  --color-in-progress:       #00B0FF;

  /* ── Health with opacity (backgrounds) ── */
  --color-healthy-bg:        rgba(0, 230, 118, 0.08);
  --color-warning-bg:        rgba(255, 179, 0, 0.08);
  --color-critical-bg:       rgba(255, 23, 68, 0.08);
  --color-offline-bg:        rgba(97, 97, 97, 0.08);
  --color-in-progress-bg:    rgba(0, 176, 255, 0.08);

  /* ── Utility ── */
  --color-cyan:              #00B0FF;
  --color-focus-ring:        var(--color-accent);
  --color-selection:         rgba(0, 230, 118, 0.15);
}
```

### Palette Reference (ASCII)

```
╔══════════════════════════════════════════════════════════════════╗
║  SIGNAL MESH — COLOR MAP                                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  SURFACES                                                        ║
║  ████████  #000000  bg              Pure black. The void.        ║
║  ████████  #0A0A0A  surface         Cards, panels.               ║
║  ████████  #141414  elevated        Modals, dropdowns.           ║
║                                                                  ║
║  TEXT                                                            ║
║  ████████  #E0E0E0  primary         Body, headings.              ║
║  ████████  #888888  secondary       Labels, descriptions.        ║
║  ████████  #555555  tertiary        Disabled, placeholders.      ║
║                                                                  ║
║  BORDERS                                                         ║
║  ████████  #333333  default         Structural grid lines.       ║
║  ████████  #555555  strong          Emphasis, active sections.   ║
║                                                                  ║
║  STATUS (INDUSTRIAL)                                             ║
║  ████████  #00E676  healthy/accent  System nominal. All clear.   ║
║  ████████  #FFB300  warning/amber   Attention required.          ║
║  ████████  #FF1744  critical/red    Act now. Escalate.           ║
║  ████████  #616161  offline/gray    Device unreachable.          ║
║  ████████  #00B0FF  in-progress     Updating, deploying.         ║
║                                                                  ║
║  RULE: No decorative color. Every hue maps to a system state.    ║
║  RULE: No blue as info. Cyan replaces blue universally.          ║
║  RULE: Green is not "success" — green is "operational."          ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

### Usage Rules

| Context | Color | Why |
|---|---|---|
| Active accent, focus, primary action | `--color-accent` (#00E676) | Terminal green = system live |
| Warnings, attention states | `--color-amber` (#FFB300) | Industrial warning standard |
| Errors, critical alerts | `--color-critical` (#FF1744) | Universal danger signal |
| Links, informational | `--color-cyan` (#00B0FF) | Replaces info-blue entirely |
| All backgrounds | `--color-bg` / `--color-surface` | Black. Always black. |
| Decorative color | NONE | Color is signal. Never decoration. |

---

## Typography

### Font Sources

```
Space Mono     — Google Fonts: https://fonts.google.com/specimen/Space+Mono
Space Grotesk  — Google Fonts: https://fonts.google.com/specimen/Space+Grotesk
JetBrains Mono — https://www.jetbrains.com/lp/mono/ (fallback)
IBM Plex Mono  — https://fonts.google.com/specimen/IBM+Plex+Mono (fallback)
```

### CSS Custom Properties

```css
:root {
  /* ══════════════════════════════════════════════════
     SIGNAL MESH — TYPOGRAPHY
     Monospace everything. This is a terminal.
     ══════════════════════════════════════════════════ */

  /* ── Font Families ── */
  --font-mono:    'Space Mono', 'JetBrains Mono', 'IBM Plex Mono', monospace;
  --font-display: 'Space Grotesk', 'Inter', sans-serif;

  /* ── Weights (two only — no semibold) ── */
  --weight-regular: 400;
  --weight-bold:    700;

  /* ── Display (hero numbers only) ── */
  --display-size:       56px;
  --display-weight:     var(--weight-bold);
  --display-line:       1.0;
  --display-tracking:   -0.04em;
  --display-font:       var(--font-display);

  /* ── H1 ── */
  --h1-size:            28px;
  --h1-weight:          var(--weight-bold);
  --h1-line:            1.2;
  --h1-tracking:        -0.02em;

  /* ── H2 ── */
  --h2-size:            22px;
  --h2-weight:          var(--weight-bold);
  --h2-line:            1.3;
  --h2-tracking:        -0.01em;

  /* ── H3 ── */
  --h3-size:            18px;
  --h3-weight:          var(--weight-bold);
  --h3-line:            1.4;
  --h3-tracking:        0;

  /* ── Body ── */
  --body-size:          14px;
  --body-weight:        var(--weight-regular);
  --body-line:          1.6;
  --body-tracking:      0;

  /* ── Body Small ── */
  --body-sm-size:       13px;
  --body-sm-weight:     var(--weight-regular);
  --body-sm-line:       1.5;
  --body-sm-tracking:   0;

  /* ── Caption (uppercase labels) ── */
  --caption-size:       11px;
  --caption-weight:     var(--weight-regular);
  --caption-line:       1.4;
  --caption-tracking:   0.05em;
  --caption-transform:  uppercase;

  /* ── Data (telemetry, all numeric) ── */
  --data-size:          13px;
  --data-weight:        var(--weight-regular);
  --data-line:          1.4;
  --data-tracking:      0.02em;
}
```

### Type Scale Reference

```
╔═════════╦════════════════╦══════╦════════╦═══════════╦══════════════╦══════════════════════╗
║ Level   ║ Font           ║ Size ║ Weight ║ Line Ht   ║ Tracking     ║ Use                  ║
╠═════════╬════════════════╬══════╬════════╬═══════════╬══════════════╬══════════════════════╣
║ Display ║ Space Grotesk  ║ 56px ║ 700    ║ 1.0       ║ -0.04em      ║ Hero numbers only    ║
║ H1      ║ Space Mono     ║ 28px ║ 700    ║ 1.2       ║ -0.02em      ║ Page titles          ║
║ H2      ║ Space Mono     ║ 22px ║ 700    ║ 1.3       ║ -0.01em      ║ Section headers      ║
║ H3      ║ Space Mono     ║ 18px ║ 700    ║ 1.4       ║ 0            ║ Subsections          ║
║ Body    ║ Space Mono     ║ 14px ║ 400    ║ 1.6       ║ 0            ║ Primary content      ║
║ Body SM ║ Space Mono     ║ 13px ║ 400    ║ 1.5       ║ 0            ║ Secondary            ║
║ Caption ║ Space Mono     ║ 11px ║ 400    ║ 1.4       ║ 0.05em       ║ Labels (UPPERCASE)   ║
║ Data    ║ Space Mono     ║ 13px ║ 400    ║ 1.4       ║ 0.02em       ║ Telemetry, all data  ║
╚═════════╩════════════════╩══════╩════════╩═══════════╩══════════════╩══════════════════════╝
```

### Typography Rules

- **Monospace is the default.** Everything is Space Mono unless it's a hero number.
- **Space Grotesk** appears ONLY for large display numbers: fleet health score, device count, uptime percentage. These are the only elements that break the monospace rule, purely for legibility at 56px+.
- **Two weights only.** Regular (400) and Bold (700). No semibold. No light. Binary.
- **Captions are always uppercase** with 0.05em tracking. They function as terminal labels.
- **No italic.** If you need emphasis, use bold or accent color.
- All text renders at `--color-text-primary` unless explicitly demoted to secondary/tertiary.

---

## Spacing

### CSS Custom Properties

```css
:root {
  /* ══════════════════════════════════════════════════
     SIGNAL MESH — SPACING
     8px base. Tight. Maximum information density.
     ══════════════════════════════════════════════════ */

  --space-micro: 2px;
  --space-xs:    4px;
  --space-sm:    8px;
  --space-md:    12px;
  --space-lg:    16px;
  --space-xl:    24px;
  --space-2xl:   32px;
  --space-3xl:   48px;
  --space-4xl:   64px;
}
```

### Spacing Reference

```
  2px  ██                           micro  Inline element gaps
  4px  ████                         xs     Icon-to-text, tight pairs
  8px  ████████                     sm     Base unit. Default gap.
 12px  ████████████                 md     Card padding internal
 16px  ████████████████             lg     Card padding, section gaps
 24px  ████████████████████████     xl     Between sections
 32px  ████████████████████████████████  2xl  Major section breaks
 48px  [...]                        3xl    Page section dividers
 64px  [...]                        4xl    Page-level top/bottom
```

### Spacing Rules

- **Default gap between elements:** `--space-sm` (8px). Not 16. Not 12. Eight.
- **Card internal padding:** `--space-lg` (16px). Dense.
- **Between related sections:** `--space-xl` (24px).
- **Between major page sections:** `--space-2xl` (32px) or `--space-3xl` (48px).
- **No generous whitespace.** If it feels "airy," you're spacing wrong.
- **Information density is the goal.** Compress until it's tight, then stop one step before unreadable.

---

## Grid System

### CSS Custom Properties

```css
:root {
  /* ══════════════════════════════════════════════════
     SIGNAL MESH — GRID
     Visible grid lines. Bento layout.
     ══════════════════════════════════════════════════ */

  /* ── Desktop ── */
  --grid-columns-desktop:  12;
  --grid-gutter-desktop:   16px;
  --grid-margin-desktop:   24px;
  --grid-max-width:        1600px;

  /* ── Tablet ── */
  --grid-columns-tablet:   8;
  --grid-gutter-tablet:    12px;
  --grid-margin-tablet:    16px;

  /* ── Mobile ── */
  --grid-columns-mobile:   4;
  --grid-gutter-mobile:    12px;
  --grid-margin-mobile:    12px;
}
```

### Grid Rules

- **Gutters are tight.** 16px desktop, 12px tablet/mobile. This is not a magazine layout.
- **Max-width 1600px.** IoT operators have wide monitors. Use them.
- **Bento grid with visible grid lines.** The 2px borders between grid cells are structural, not decorative. They create the control-panel feel.
- **Grid lines use `--color-border`** (#333333). Always visible. Never hidden.
- **Every panel in the bento grid has a 2px border.** No floating cards. Everything is wired into the grid.

### Bento Grid Example

```
┌──────────────┬──────────────┬──────────────────────────┐
│ FLEET HEALTH │ ACTIVE AGENTS│ ANOMALIES (24H)          │
│              │              │                          │
│    97.3%     │     12/12    │  ▁▂▃▅▂▁▁▃▅▇█▅▃▂▁       │
│              │              │                          │
├──────────────┴──────────────┼──────────────────────────┤
│ DEVICE GRID                 │ AGENT LOG                │
│ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■  │ [14:23:07] AGENT-03 >   │
│ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■  │   EXEC restart WH-E-047 │
│ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■  │ [14:23:04] AGENT-01 >   │
│ ■ ■ ■ ■ ■ ▲ ■ ■ ■ ■ ■ ■  │   DETECT anomaly:drift  │
│ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■  │   scope:WH-WEST/temp    │
│ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■  │ [14:22:58] AGENT-07 >   │
│ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■ ■  │   OK canary:FW-2.4.1    │
│                             │   health:nominal 100%    │
├─────────────────────────────┼──────────────────────────┤
│ PENDING ACTIONS             │ TELEMETRY FEED           │
│ ▸ FW rollout: WH-EAST [██░│ temp: 72.4F  ▁▂▃▅▃▂▁    │
│ ▸ Config push: MFG-03  [AP│ humid: 44%   ▃▃▃▅▃▃▃    │
│ ▸ Restart queue: 3 devices │ volt: 3.31V  ▇▇▇▇▇▇▇    │
└─────────────────────────────┴──────────────────────────┘
```

---

## Components

### Buttons

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — BUTTONS
   Outline primary. Zero radius. Uppercase mono.
   ══════════════════════════════════════════════════ */

.btn {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  font-weight: var(--weight-bold);
  letter-spacing: 0.08em;
  text-transform: uppercase;
  line-height: 1;
  border-radius: 0;
  cursor: pointer;
  transition: all 100ms linear;
  padding: var(--space-sm) var(--space-lg);
}

/* ── Primary: Ghost/Outline ── */
.btn-primary {
  background: transparent;
  color: var(--color-accent);
  border: 2px solid var(--color-accent);
}

.btn-primary:hover {
  background: var(--color-accent);
  color: var(--color-bg);
}

.btn-primary:active {
  background: var(--color-bg);
  color: var(--color-accent);
}

/* ── Secondary: Muted border ── */
.btn-secondary {
  background: transparent;
  color: var(--color-text-primary);
  border: 2px solid var(--color-border);
}

.btn-secondary:hover {
  border-color: var(--color-text-primary);
}

/* ── Danger ── */
.btn-danger {
  background: transparent;
  color: var(--color-critical);
  border: 2px solid var(--color-critical);
}

.btn-danger:hover {
  background: var(--color-critical);
  color: var(--color-bg);
}

/* ── Ghost (no border) ── */
.btn-ghost {
  background: transparent;
  color: var(--color-text-secondary);
  border: 2px solid transparent;
}

.btn-ghost:hover {
  color: var(--color-text-primary);
  border-color: var(--color-border);
}

/* ── Disabled ── */
.btn:disabled {
  opacity: 0.3;
  cursor: not-allowed;
  pointer-events: none;
}

/* ── Sizes ── */
.btn-sm {
  padding: var(--space-xs) var(--space-sm);
  font-size: 10px;
}

.btn-lg {
  padding: var(--space-md) var(--space-xl);
  font-size: var(--body-sm-size);
}
```

### Button Anatomy

```
┌────────────────────────┐
│  DEPLOY AGENT          │  .btn-primary
│                        │  2px accent border, 0 radius
│  bg: transparent       │  hover: bg fills accent, text inverts
│  color: #00E676        │  100ms linear transition
│  border: 2px #00E676   │
└────────────────────────┘

         ↓ :hover

┌████████████████████████┐
│  DEPLOY AGENT          │  background fills with accent
│                        │  text inverts to #000000
│  bg: #00E676           │
│  color: #000000        │
└████████████████████████┘
```

---

### Inputs

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — INPUTS
   Terminal-style. Sharp. Monospace.
   ══════════════════════════════════════════════════ */

.input {
  font-family: var(--font-mono);
  font-size: var(--body-size);
  font-weight: var(--weight-regular);
  color: var(--color-text-primary);
  background: var(--color-bg);
  border: 2px solid var(--color-border);
  border-radius: 0;
  padding: var(--space-sm) var(--space-md);
  width: 100%;
  transition: border-color 100ms linear;
}

.input::placeholder {
  color: var(--color-text-tertiary);
  text-transform: uppercase;
  font-size: var(--caption-size);
  letter-spacing: 0.05em;
}

.input:focus {
  outline: none;
  border-color: var(--color-accent);
  /* No box-shadow. Border only. */
}

.input:hover:not(:focus) {
  border-color: var(--color-border-strong);
}

/* ── Input with label ── */
.input-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-xs);
}

.input-label {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  font-weight: var(--weight-regular);
  letter-spacing: var(--caption-tracking);
  text-transform: uppercase;
  color: var(--color-text-secondary);
}

/* ── Input with prefix (terminal prompt style) ── */
.input-terminal {
  display: flex;
  align-items: center;
  gap: var(--space-xs);
}

.input-terminal::before {
  content: '>';
  font-family: var(--font-mono);
  color: var(--color-accent);
  font-weight: var(--weight-bold);
}

/* ── Error state ── */
.input-error {
  border-color: var(--color-critical);
}

.input-error-message {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  color: var(--color-critical);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

/* ── Select ── */
.select {
  appearance: none;
  font-family: var(--font-mono);
  font-size: var(--body-size);
  color: var(--color-text-primary);
  background: var(--color-bg);
  border: 2px solid var(--color-border);
  border-radius: 0;
  padding: var(--space-sm) var(--space-md);
  padding-right: var(--space-xl);
  cursor: pointer;
}
```

---

### Cards

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — CARDS
   Panels. 0 radius. 2px border. No shadow.
   ══════════════════════════════════════════════════ */

.card {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: 0;
  padding: var(--space-lg);
  box-shadow: none;
}

/* ── Card with accent top ── */
.card-accent {
  border-top: 4px solid var(--color-accent);
}

.card-accent-warning {
  border-top: 4px solid var(--color-warning);
}

.card-accent-critical {
  border-top: 4px solid var(--color-critical);
}

/* ── Card header ── */
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: var(--space-md);
  border-bottom: 2px solid var(--color-border);
  margin-bottom: var(--space-md);
}

.card-title {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  font-weight: var(--weight-bold);
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: var(--color-text-secondary);
}

/* ── Stat card (hero number) ── */
.card-stat {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: 0;
  padding: var(--space-lg);
}

.card-stat-value {
  font-family: var(--font-display);
  font-size: var(--display-size);
  font-weight: var(--weight-bold);
  line-height: var(--display-line);
  letter-spacing: var(--display-tracking);
  color: var(--color-text-primary);
}

.card-stat-label {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-secondary);
  margin-top: var(--space-xs);
}

/* ── Dense card (tighter padding) ── */
.card-dense {
  padding: var(--space-md);
}
```

### Card Anatomy

```
┌──────────────────────────────────────┐
│  FLEET HEALTH              ◆ LIVE    │  .card-header — 11px uppercase
│──────────────────────────────────────│  2px border-bottom
│                                      │
│           97.3%                      │  .card-stat-value — Space Grotesk 56px
│                                      │
│  FLEET HEALTH SCORE                  │  .card-stat-label — 11px uppercase
│  ▁▂▃▅▆▇█▇▅▃▂▁▂▃▅▆▇█▇▅▃▂           │  Unicode sparkline
│                                      │
└──────────────────────────────────────┘
  0 radius | 2px border #333 | 16px padding | no shadow
```

---

### Navigation

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — NAVIGATION
   NO sidebar. Tab bar. tmux-style.
   ══════════════════════════════════════════════════ */

/* ── Top navigation bar ── */
.nav-bar {
  display: flex;
  align-items: center;
  background: var(--color-bg);
  border-bottom: 2px solid var(--color-border);
  padding: 0 var(--space-xl);
  height: 48px;
}

.nav-logo {
  font-family: var(--font-mono);
  font-size: var(--h3-size);
  font-weight: var(--weight-bold);
  color: var(--color-accent);
  letter-spacing: -0.02em;
  margin-right: var(--space-2xl);
}

/* ── Tab items ── */
.nav-tabs {
  display: flex;
  gap: 0;
  height: 100%;
}

.nav-tab {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  font-weight: var(--weight-bold);
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: var(--color-text-secondary);
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  padding: 0 var(--space-lg);
  height: 100%;
  display: flex;
  align-items: center;
  cursor: pointer;
  transition: color 100ms linear, border-color 100ms linear;
}

.nav-tab:hover {
  color: var(--color-text-primary);
}

.nav-tab-active {
  color: var(--color-accent);
  border-bottom-color: var(--color-accent);
}

/* ── Breadcrumbs (always visible) ── */
.breadcrumbs {
  display: flex;
  align-items: center;
  gap: var(--space-xs);
  padding: var(--space-sm) var(--space-xl);
  border-bottom: 1px solid var(--color-border);
  background: var(--color-bg);
}

.breadcrumb-item {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: var(--color-text-tertiary);
}

.breadcrumb-item-active {
  color: var(--color-text-secondary);
}

.breadcrumb-separator {
  color: var(--color-text-tertiary);
}

.breadcrumb-separator::after {
  content: '/';
}

/* ── Status bar (bottom, optional) ── */
.status-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--color-surface);
  border-top: 2px solid var(--color-border);
  padding: var(--space-xs) var(--space-xl);
  height: 28px;
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
```

### Navigation Anatomy

```
┌══════════════════════════════════════════════════════════════════════┐
│ iotgo   OVERVIEW  FLEETS  AGENTS  PLAYBOOKS  ACTIONS  SETTINGS     │
│         ────────                                                    │
├──────────────────────────────────────────────────────────────────────┤
│ FLEETS / WAREHOUSE-EAST / TEMPERATURE-SENSORS                       │
├══════════════════════════════════════════════════════════════════════┤
│                                                                      │
│  [page content]                                                      │
│                                                                      │
├══════════════════════════════════════════════════════════════════════┤
│ 12 AGENTS ACTIVE  |  847/852 DEVICES ONLINE  |  LAST SYNC: 14:23:07│
└══════════════════════════════════════════════════════════════════════┘
```

---

### Tables

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — TABLES
   Dense. Every cell bordered. Industrial data grid.
   ══════════════════════════════════════════════════ */

.table {
  width: 100%;
  border-collapse: collapse;
  border: 2px solid var(--color-border);
  font-family: var(--font-mono);
}

/* ── Header ── */
.table thead {
  background: var(--color-accent-muted);
}

.table th {
  font-size: var(--caption-size);
  font-weight: var(--weight-bold);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-secondary);
  text-align: left;
  padding: var(--space-sm) var(--space-md);
  border: 1px solid var(--color-border);
}

/* ── Body rows ── */
.table td {
  font-size: var(--data-size);
  font-weight: var(--weight-regular);
  letter-spacing: var(--data-tracking);
  color: var(--color-text-primary);
  padding: var(--space-sm) var(--space-md);
  border: 1px solid var(--color-border);
}

/* ── Dense rows (8px vertical padding) ── */
.table-dense td {
  padding: var(--space-sm) var(--space-md);
}

/* ── Extra dense (tighter) ── */
.table-xdense td {
  padding: var(--space-xs) var(--space-sm);
}

/* ── Row hover ── */
.table tbody tr:hover {
  background: var(--color-accent-muted);
}

/* ── Active row: 4px accent left border ── */
.table tbody tr.row-active {
  border-left: 4px solid var(--color-accent);
}

/* ── Row states ── */
.table tbody tr.row-warning {
  background: var(--color-warning-bg);
}

.table tbody tr.row-critical {
  background: var(--color-critical-bg);
}

/* ── Zebra (optional, subtle) ── */
.table-striped tbody tr:nth-child(even) {
  background: var(--color-surface);
}
```

### Table Anatomy

```
┌──────────────┬──────────┬──────────┬──────────┬──────────┐
│ DEVICE ID    │ STATUS   │ TEMP     │ UPTIME   │ AGENT    │  thead: accent-muted bg
├──────────────┼──────────┼──────────┼──────────┼──────────┤  11px uppercase bold
│▎WH-E-T001   │ ■ ONLINE │ 72.4F    │ 99.97%   │ AGENT-03 │  active: 4px left accent
│ WH-E-T002   │ ■ ONLINE │ 71.8F    │ 99.94%   │ AGENT-03 │
│ WH-E-T003   │ ▲ WARN   │ 78.2F    │ 99.91%   │ AGENT-03 │  warning row bg
│ WH-E-T004   │ ■ ONLINE │ 72.1F    │ 99.99%   │ AGENT-03 │
│ WH-E-T005   │ ■ OFFL   │ --       │ 0%       │ --       │  offline: gray text
└──────────────┴──────────┴──────────┴──────────┴──────────┘
  2px outer border | 1px cell borders | 8px padding | all mono
```

---

### Status Indicators

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — STATUS INDICATORS
   SQUARES not circles. Text badges. Industrial.
   ══════════════════════════════════════════════════ */

/* ── Status square (inline) ── */
.status-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  border-radius: 0;     /* SQUARE. Not circle. */
  flex-shrink: 0;
}

.status-dot-sm {
  width: 4px;
  height: 4px;
}

.status-dot-healthy  { background: var(--color-healthy); }
.status-dot-warning  { background: var(--color-warning); }
.status-dot-critical { background: var(--color-critical); }
.status-dot-offline  { background: var(--color-offline); }
.status-dot-progress { background: var(--color-in-progress); }

/* ── Critical: pulsing ── */
.status-dot-critical {
  animation: pulse-critical 1s ease-in-out infinite;
}

@keyframes pulse-critical {
  0%, 100% { opacity: 1; }
  50%      { opacity: 0.3; }
}

/* ── Text badges (terminal-style) ── */
.badge {
  font-family: var(--font-mono);
  font-size: 10px;
  font-weight: var(--weight-bold);
  letter-spacing: 0.05em;
  text-transform: uppercase;
  padding: var(--space-micro) var(--space-xs);
  border-radius: 0;
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs);
}

.badge-online {
  color: var(--color-healthy);
  background: var(--color-healthy-bg);
  border: 1px solid rgba(0, 230, 118, 0.20);
}

/* Content: [ONLINE] */
.badge-online::before { content: '['; }
.badge-online::after  { content: ']'; }

.badge-warn {
  color: var(--color-warning);
  background: var(--color-warning-bg);
  border: 1px solid rgba(255, 179, 0, 0.20);
}

.badge-warn::before { content: '['; }
.badge-warn::after  { content: ']'; }

.badge-critical {
  color: var(--color-critical);
  background: var(--color-critical-bg);
  border: 1px solid rgba(255, 23, 68, 0.20);
  animation: pulse-badge 1s ease-in-out infinite;
}

.badge-critical::before { content: '['; }
.badge-critical::after  { content: ']'; }

@keyframes pulse-badge {
  0%, 100% { border-color: rgba(255, 23, 68, 0.20); }
  50%      { border-color: rgba(255, 23, 68, 0.60); }
}

.badge-offline {
  color: var(--color-offline);
  background: var(--color-offline-bg);
  border: 1px solid rgba(97, 97, 97, 0.20);
}

.badge-offline::before { content: '['; }
.badge-offline::after  { content: ']'; }

.badge-progress {
  color: var(--color-in-progress);
  background: var(--color-in-progress-bg);
  border: 1px solid rgba(0, 176, 255, 0.20);
}

.badge-progress::before { content: '['; }
.badge-progress::after  { content: ']'; }
```

### Status Reference

```
  SQUARE INDICATORS                    TEXT BADGES

  ■  6x6 healthy   #00E676            [ONLINE]    green on green/10%
  ■  6x6 warning   #FFB300            [WARN]      amber on amber/10%
  ■  6x6 critical  #FF1744 (pulse)    [CRITICAL]  red on red/10% (pulse border)
  ■  6x6 offline   #616161            [OFFLINE]   gray on gray/10%
  ■  6x6 progress  #00B0FF            [UPDATING]  cyan on cyan/10%

  RULE: Squares. Never circles. Circles are soft. This is not soft.
  RULE: Critical always pulses. 1s cycle. The eye must be drawn.
  RULE: Brackets are literal. [ONLINE] not ONLINE. Terminal aesthetic.
```

---

### Agent Log Component

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — AGENT LOG
   Terminal entries. Timestamped. Scrollable.
   ══════════════════════════════════════════════════ */

.agent-log {
  background: var(--color-bg);
  border: 2px solid var(--color-border);
  padding: var(--space-sm);
  overflow-y: auto;
  font-family: var(--font-mono);
  font-size: var(--data-size);
  line-height: var(--data-line);
}

.agent-log-entry {
  display: flex;
  gap: var(--space-sm);
  padding: var(--space-micro) 0;
}

.agent-log-timestamp {
  color: var(--color-text-tertiary);
  flex-shrink: 0;
}

.agent-log-agent {
  color: var(--color-cyan);
  flex-shrink: 0;
}

.agent-log-action {
  color: var(--color-accent);
}

.agent-log-target {
  color: var(--color-text-primary);
}

/* ── Log levels ── */
.agent-log-entry-warn .agent-log-action {
  color: var(--color-warning);
}

.agent-log-entry-critical .agent-log-action {
  color: var(--color-critical);
}
```

### Agent Log Format

```
[14:23:07] AGENT-03 > EXEC restart device:WH-EAST-T047
[14:23:04] AGENT-01 > DETECT anomaly:drift scope:WH-WEST/temp
[14:22:58] AGENT-07 > OK canary:FW-2.4.1 health:nominal 100%
[14:22:41] AGENT-03 > ESCALATE device:WH-EAST-T012 reason:3x-restart-fail
[14:22:33] AGENT-12 > APPLY config:hvac-setpoint-22C fleet:BLD-NORTH
[14:22:19] AGENT-01 > BASELINE updated scope:WH-WEST/humidity +7d
```

Each entry: `[HH:MM:SS] AGENT-XX > VERB target details`

---

### Progress Indicators

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — PROGRESS
   Text-based. ASCII. No smooth animations.
   ══════════════════════════════════════════════════ */

.progress-text {
  font-family: var(--font-mono);
  font-size: var(--data-size);
  color: var(--color-text-primary);
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}

.progress-bar-text {
  color: var(--color-accent);
}

.progress-percent {
  color: var(--color-text-secondary);
  min-width: 3ch;
  text-align: right;
}
```

### Progress Format

```
  Text-based progress bar:

  [████████░░░░░░░░]  47%     In progress
  [████████████████] 100%     Complete
  [░░░░░░░░░░░░░░░░]   0%     Not started
  [██████░░░░░░░░░░]  38%     Canary rollout

  Characters: █ (filled), ░ (empty), [ ] (bookends)
  Width: 16 blocks standard
  Color: accent green for filled, border color for empty
```

---

### Device Grid Tiles

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — DEVICE GRID
   Dense grid of device tiles. Not a map.
   ══════════════════════════════════════════════════ */

.device-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 2px;    /* Grid lines are the gap */
  background: var(--color-border);  /* Visible grid lines */
  border: 2px solid var(--color-border);
}

.device-tile {
  background: var(--color-surface);
  padding: var(--space-sm) var(--space-md);
  display: flex;
  flex-direction: column;
  gap: var(--space-micro);
  cursor: pointer;
  transition: background 100ms linear;
}

.device-tile:hover {
  background: var(--color-elevated);
}

.device-tile-id {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  font-weight: var(--weight-bold);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-primary);
}

.device-tile-status {
  display: flex;
  align-items: center;
  gap: var(--space-xs);
}

.device-tile-sparkline {
  font-family: var(--font-mono);
  font-size: 10px;
  color: var(--color-text-tertiary);
  letter-spacing: 0;
}

/* ── Tile states ── */
.device-tile-healthy {
  border-left: 3px solid var(--color-healthy);
}

.device-tile-warning {
  border-left: 3px solid var(--color-warning);
  background: var(--color-warning-bg);
}

.device-tile-critical {
  border-left: 3px solid var(--color-critical);
  background: var(--color-critical-bg);
  animation: pulse-tile 1s ease-in-out infinite;
}

@keyframes pulse-tile {
  0%, 100% { border-left-color: var(--color-critical); }
  50%      { border-left-color: transparent; }
}

.device-tile-offline {
  opacity: 0.4;
}
```

### Device Tile Anatomy

```
┌─────────────────┐
│▎WH-E-T001       │  3px left accent (health color)
│ ■ ONLINE        │  6px status square + label
│ 72.4F           │  Primary telemetry value
│ ▁▂▃▅▃▂▁        │  Unicode sparkline (24h)
└─────────────────┘
  140px min | 8px padding | 2px gap (grid line)
```

---

### ASCII Section Dividers

For use between major sections in the UI or in documentation/onboarding screens.

```
═══════════════════════════════════════════════════════════

── FLEET OVERVIEW ─────────────────────────────────────────

╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

▸ AGENTS ──────────────────────────────────────────────────
```

---

## Interaction Model

### Transition Table

| Interaction | Duration | Easing | Notes |
|---|---|---|---|
| Button hover/active | 100ms | linear | Brief invert on click |
| Input focus | 100ms | linear | Border color change only |
| Tab switch | 0ms (instant) | none | No crossfade. Swap. |
| Card hover | 100ms | linear | Background shift only |
| Table row hover | 100ms | linear | Accent-muted background |
| Modal open | 0ms (instant) | none | No fade-in. Appears. |
| Modal close | 0ms (instant) | none | No fade-out. Gone. |
| Page transition | 0ms (instant) | none | No smooth scroll, no slide |
| Dropdown open | 0ms (instant) | none | Snap open |
| Toast/notification | 0ms appear | none | No slide-in |
| Toast dismiss | 100ms | linear | Opacity to 0 |
| Loading state | continuous | linear | Text-based progress bar |
| Critical alert pulse | 1000ms | ease-in-out | Border/indicator pulsing |
| Sparkline update | 0ms | none | Data just changes |

### Interaction Rules

- **100ms or instant.** There is no middle ground. Nothing takes 300ms. Nothing eases.
- **Linear only.** No `ease`, no `ease-in-out` (except the critical pulse, which is an alarm signal, not a UI transition).
- **No smooth scrolling.** `scroll-behavior: auto`. Jump cuts.
- **No fade-ins on page load.** Content is there or it isn't.
- **Click feedback:** 100ms background invert, then return. That's it.
- **Critical alerts pulse.** This is the ONLY animation in the system that loops. Everything else is a state change.

```css
/* ── Global transition reset ── */
* {
  scroll-behavior: auto !important;
}

/* ── No animation for reduced motion ── */
@media (prefers-reduced-motion: reduce) {
  * {
    animation: none !important;
    transition-duration: 0ms !important;
  }
}
```

---

## Data Visualization

### Principles

- **Monochrome + accent only.** No rainbow charts. Green for current/positive, amber for attention, red for problems, gray for inactive. Cyan for secondary data series.
- **ASCII-style where possible.** Unicode sparklines, text progress bars, bracket-notation for status. If it could render in a terminal, it's the right approach.
- **Visible grid lines.** Chart grids use `--color-border` (#333333). No hidden grids.
- **Monospace axis labels.** All axes, legends, and annotations in Space Mono at caption size.
- **Large display numbers.** When a single metric is the point, use Space Grotesk at display size. The number IS the visualization.

### Sparklines (Unicode)

```
  Characters: ▁ ▂ ▃ ▄ ▅ ▆ ▇ █  (Unicode block elements)

  Temperature (24h):  ▁▂▃▅▆▇█▇▅▃▂▁▂▃▅▆▇█▇▅▃▂▁
  Humidity (24h):     ▃▃▃▅▅▃▃▃▅▅▃▃▃▅▅▃▃▃▅▅▃▃▃▃
  CPU Load (24h):     ▁▁▁▂▃▇████▇▃▂▁▁▁▂▃▇████▇▃
  Anomaly Score:      ▁▁▁▁▁▁▂▅█▅▂▁▁▁▁▁▁▁▁▁▁▁▁▁

  Color: --color-text-tertiary for normal
         --color-accent for highlighted/active segment
         --color-critical for anomaly spikes
```

### Chart Styling

```css
/* ══════════════════════════════════════════════════
   SIGNAL MESH — DATA VIZ
   Minimal chrome. Grid visible. Monospace labels.
   ══════════════════════════════════════════════════ */

.chart-container {
  background: var(--color-bg);
  border: 2px solid var(--color-border);
  padding: var(--space-lg);
}

.chart-title {
  font-family: var(--font-mono);
  font-size: var(--caption-size);
  font-weight: var(--weight-bold);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-secondary);
  margin-bottom: var(--space-md);
}

.chart-axis-label {
  font-family: var(--font-mono);
  font-size: 10px;
  fill: var(--color-text-tertiary);
  letter-spacing: 0.02em;
}

.chart-grid-line {
  stroke: var(--color-border);
  stroke-width: 1px;
}

.chart-line-primary {
  stroke: var(--color-accent);
  stroke-width: 2px;
  fill: none;
}

.chart-line-secondary {
  stroke: var(--color-cyan);
  stroke-width: 1px;
  fill: none;
  stroke-dasharray: 4 2;
}

.chart-area-fill {
  fill: var(--color-accent-muted);
}

.chart-threshold-line {
  stroke: var(--color-critical);
  stroke-width: 1px;
  stroke-dasharray: 6 3;
}

.chart-tooltip {
  background: var(--color-elevated);
  border: 2px solid var(--color-border);
  padding: var(--space-xs) var(--space-sm);
  font-family: var(--font-mono);
  font-size: var(--data-size);
  color: var(--color-text-primary);
  border-radius: 0;
  box-shadow: none;
}
```

### Data Viz Examples

```
  ┌─── TEMPERATURE (WH-EAST) ────────────────────────────────┐
  │                                                ·          │
  │                                   ·    ·  ·  ·  ·        │
  │                              ·  ·                    ·    │
  │─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ 78F ─ ─│  threshold
  │                         ·                              ·  │
  │                    ·  ·                                    │
  │               ·  ·                                        │
  │          ·  ·                                              │
  │     ·  ·                                                   │
  │  ·                                                         │
  ├────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┤
  │ 00 │ 02 │ 04 │ 06 │ 08 │ 10 │ 12 │ 14 │ 16 │ 18 │ 20 │ 22│
  └────────────────────────────────────────────────────────────┘

  FLEET HEALTH HEATMAP (DEVICES x TIME)

  DEVICE    00  02  04  06  08  10  12  14  16  18  20  22
  WH-E-001  ■   ■   ■   ■   ■   ■   ■   ■   ■   ■   ■   ■
  WH-E-002  ■   ■   ■   ■   ■   ▲   ▲   ■   ■   ■   ■   ■
  WH-E-003  ■   ■   ■   ■   ■   ■   ■   ■   ■   ■   ■   ■
  WH-E-004  ●   ●   ■   ■   ■   ■   ■   ■   ■   ■   ■   ■
  WH-E-005  ■   ■   ■   ■   ■   ■   ■   ■   ■   ▲   ■   ■

  ■ = healthy  ▲ = warning  ● = offline
```

---

## Asset Guidelines

### What to Use

| Element | Approach |
|---|---|
| Icons | Text symbols: `>` `■` `▲` `●` `◆` `▸` `✕` `+` `-` |
| Arrows | `→` `←` `↑` `↓` `▸` `▾` |
| Decorative graphics | NONE |
| Photography | NONE |
| Illustrations | NONE |
| Marketing imagery | NONE |
| Diagrams | ASCII/Unicode box drawing: `┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼ ─ │` |
| Sparklines | Unicode blocks: `▁ ▂ ▃ ▄ ▅ ▆ ▇ █` |
| Progress | Text: `[████████░░░░░░░░] 47%` |
| Separators | ASCII: `═══`, `───`, `╌╌╌` |
| Status | Squares: `■` (6px CSS) or text badges: `[ONLINE]` |
| Logos | Monospace text mark: `iotgo` in accent green |

### What NOT to Use

- No SVG icon libraries (no Lucide, no Heroicons, no Font Awesome)
- No photography (no stock photos, no team photos, no hardware photos)
- No illustrations (no isometric, no hand-drawn, no abstract)
- No gradients (anywhere, ever)
- No rounded shapes (border-radius is always 0)
- No shadows (box-shadow is always none)
- No blur effects (no backdrop-filter)
- No emoji in the product UI (symbols only)

### Logo Treatment

```
  iotgo            ← Space Mono, 18px bold, #00E676, lowercase
  iotgo.io         ← With domain, .io in #555555

  On dark bg only. There is no light version. The brand lives in the dark.
```

### Engineering Schematic Style (for Architecture Diagrams)

```
  ┌───────────┐     MQTT      ┌───────────┐    ┌───────────┐
  │  DEVICES  │───────────────│  IOTGO    │────│  AGENTS   │
  │  (fleet)  │    telemetry  │  INGEST   │    │  (x12)    │
  └───────────┘               └─────┬─────┘    └─────┬─────┘
                                    │                 │
                              ┌─────┴─────┐    ┌─────┴─────┐
                              │  ANOMALY  │    │ PLAYBOOKS │
                              │  ENGINE   │    │  (v2.4)   │
                              └───────────┘    └───────────┘

  All diagrams: monospace, box-drawing characters, labeled connections.
  No curved lines. No gradients. No icons. Text only.
```

---

## Reference Energy

| Reference | What to Steal |
|---|---|
| **Bloomberg Terminal** | Information density, grid-everything, no whitespace guilt, the feeling that every pixel is earning rent |
| **SCADA / HMI interfaces** | Green-on-black, status squares, alarm pulsing, industrial color vocabulary |
| **htop / btop** | Dense real-time data, sparklines, progress bars, header stats |
| **Warp terminal** | Modern terminal aesthetics, monospace as primary font, command-line interaction patterns |
| **tmux** | Tab-based navigation, status bar, split-pane layouts, no sidebar |
| **Grafana (dark)** | Time-series charts with visible grids, threshold lines, compact legends |

What NOT to reference: Stripe (too soft), Linear (too polished), Notion (too friendly), Apple (too minimal). This direction rejects the entire SaaS design consensus.

---

## Implementation Checklist

### Phase 0: Foundation

- [ ] Set up CSS custom properties (all color, typography, spacing tokens above)
- [ ] Configure `@font-face` for Space Mono (400, 700) and Space Grotesk (700)
- [ ] Set global resets: `border-radius: 0`, `box-shadow: none`, `scroll-behavior: auto`
- [ ] Set `background: var(--color-bg)`, `color: var(--color-text-primary)` on body
- [ ] Set `font-family: var(--font-mono)` on body (monospace default)
- [ ] Set `::selection` background to `var(--color-selection)`

### Phase 1: Layout Shell

- [ ] Build top navigation bar (tab-style, no sidebar)
- [ ] Build breadcrumb bar (always visible)
- [ ] Build status bar (bottom, optional)
- [ ] Set up bento grid layout with visible 2px borders between cells
- [ ] Implement 12-col grid with 16px gutters, 1600px max-width
- [ ] Responsive breakpoints: tablet (8-col), mobile (4-col)

### Phase 2: Core Components

- [ ] Buttons: primary (outline/ghost), secondary, danger, ghost, sizes
- [ ] Inputs: text, select, terminal-prefix style, error states
- [ ] Cards: default, accent-top variants, stat cards, dense variant
- [ ] Tables: bordered, dense, row states, active row accent
- [ ] Status indicators: square dots (4px, 6px), text badges with brackets
- [ ] Progress: text-based `[████░░░░] XX%`

### Phase 3: IoTGo-Specific Components

- [ ] Device grid (dense tile layout with 2px gap grid lines)
- [ ] Device tile (ID, status square, primary metric, sparkline)
- [ ] Agent log (terminal-style scrolling entries)
- [ ] Fleet health stat card (Space Grotesk 56px number)
- [ ] Playbook viewer (monospace YAML with syntax coloring)
- [ ] Action detail panel (reasoning chain + telemetry snapshot)
- [ ] Pending approvals queue

### Phase 4: Data Visualization

- [ ] Sparklines (Unicode block elements, colored by state)
- [ ] Time-series line charts (monochrome + accent, visible grid)
- [ ] Fleet heatmap (devices x time, symbol-based)
- [ ] Threshold lines (dashed, colored by severity)
- [ ] Chart tooltips (sharp, bordered, monospace)

### Phase 5: Interactions

- [ ] Verify all transitions are 100ms linear or instant
- [ ] Verify no smooth scrolling anywhere
- [ ] Critical alert pulsing (1s cycle on indicators, badges, tile borders)
- [ ] Click invert feedback (100ms)
- [ ] `prefers-reduced-motion` media query kills all animation

### Phase 6: Stress Test

- [ ] Render 500+ device tiles in grid — verify performance and density
- [ ] Render 1000-row table — verify readability at dense spacing
- [ ] Agent log with 200+ entries — verify scroll performance
- [ ] All components at 1600px, 1280px, 768px, 375px widths
- [ ] Verify WCAG AA contrast ratios (particularly #888 on #000 = 5.7:1, passes)

---

## Contrast Verification

| Pair | Foreground | Background | Ratio | WCAG AA |
|---|---|---|---|---|
| Primary text on bg | #E0E0E0 | #000000 | 14.7:1 | PASS |
| Secondary text on bg | #888888 | #000000 | 5.7:1 | PASS |
| Tertiary text on bg | #555555 | #000000 | 3.3:1 | FAIL (decorative only) |
| Accent on bg | #00E676 | #000000 | 8.2:1 | PASS |
| Amber on bg | #FFB300 | #000000 | 9.2:1 | PASS |
| Critical on bg | #FF1744 | #000000 | 4.6:1 | PASS (large text / UI) |
| Cyan on bg | #00B0FF | #000000 | 5.5:1 | PASS |
| Primary text on surface | #E0E0E0 | #0A0A0A | 13.9:1 | PASS |
| Secondary text on surface | #888888 | #0A0A0A | 5.4:1 | PASS |
| Accent on surface | #00E676 | #0A0A0A | 7.8:1 | PASS |

Tertiary (#555555) is used ONLY for disabled states, placeholders, and decorative elements — never for essential content.

---

## Summary

Signal Mesh is infrastructure cosplay that isn't cosplay. It borrows the visual language of the systems IoTGo actually manages — terminals, control rooms, industrial HMIs — and wears it without irony. The result is a product that feels purpose-built for its audience: dense, monospace, sharp-edged, information-first. No rounded corners. No illustrations. No whitespace for the sake of whitespace. Every pixel is a data point or a border that separates data points.

The trade-off is clear: this direction will alienate anyone who expects SaaS software to look like SaaS software. That's the point. IoTGo isn't SaaS. It's infrastructure. And Signal Mesh looks like it.
