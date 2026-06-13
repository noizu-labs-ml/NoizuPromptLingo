# Style Guide: JailbreakingSite

> Operational intelligence aesthetic — dark-first, data-dense, terminal-rooted. Designed for security professionals who live in dark mode and think in severity levels.

**Style System:** Custom — "SecOps Terminal"
**Lineage:** Draws from Minimal Tech (structural discipline, spacing, restraint) but diverges significantly in color philosophy, typography, visual vocabulary, and component patterns. Not a mix — a purpose-built system.
**Scenario:** JailbreakingSite is an attack catalog + defensive testing tool + training academy for LLM security. Its audience is security engineers, red-teamers, and AppSec professionals. The design must signal operational credibility, not marketing polish.

---

## Scenario

JailbreakingSite occupies the intersection of threat intelligence and hands-on training — a space defined by tools like MITRE ATT&CK, Burp Suite, and HackTheBox. Its users spend their days in terminals, IDEs, and SOC dashboards. They are deeply allergic to marketing fluff and instinctively distrust anything that looks "too designed."

The visual system must signal three things simultaneously:

1. **Authority** — "This is the canonical reference, not a blog post." Structured data, consistent taxonomy, rigorous classification. The design should feel like an intelligence database, not a content site.

2. **Operational utility** — "I can use this right now." Dense data, scannable layouts, keyboard-navigable, fast. No decorative whitespace. Every pixel communicates.

3. **Controlled danger** — "This deals with adversarial content." Red doesn't mean "brand color" here — it means CRITICAL severity. The palette is functional, not aesthetic. Color is information, not decoration.

**Why this is not Minimal Tech:** Minimal Tech signals VC-funded calm. JailbreakingSite needs to signal operational urgency. Minimal Tech uses whitespace as a structural element; this system uses density. Minimal Tech avoids strong color; this system uses severity-mapped color as its primary visual vocabulary.

**Why this is not Bold Expressive:** Security professionals don't want experimental interaction or broken grids. They want fast, predictable, data-dense interfaces that work at 2am during an incident.

---

## Color Palette

### Dark Mode (Primary)

```css
:root {
  /* Backgrounds — layered depth */
  --bg-void:      #0B0D0F;  /* Deepest layer — page background */
  --bg-surface:   #12151A;  /* Cards, panels, content areas */
  --bg-elevated:  #1A1E26;  /* Hover states, active panels, modals */
  --bg-overlay:   #222832;  /* Tooltips, dropdowns, popovers */

  /* Text — high contrast for dark backgrounds */
  --text-primary:    #E8EAED;  /* Primary content — not pure white (reduces glare) */
  --text-secondary:  #9AA0A6;  /* Labels, metadata, supporting text */
  --text-tertiary:   #5F6368;  /* Timestamps, disabled, placeholder */
  --text-inverse:    #0B0D0F;  /* Text on light/colored backgrounds */

  /* Borders & Dividers */
  --border-subtle:   #1F2937;  /* Card borders, table rules */
  --border-visible:  #374151;  /* Input borders, active dividers */
  --border-focus:    #60A5FA;  /* Focus rings — always blue for a11y */

  /* Severity Palette — THIS IS THE BRAND */
  --severity-critical: #FF4444;  /* Bright red — demands attention */
  --severity-high:     #FF8C00;  /* Orange — urgent but not emergency */
  --severity-medium:   #FFD700;  /* Gold — notable, investigate */
  --severity-low:      #4CAF50;  /* Green — informational */
  --severity-info:     #60A5FA;  /* Blue — neutral information */

  /* Severity Backgrounds (10% opacity variants for badges/rows) */
  --severity-critical-bg: #FF444418;
  --severity-high-bg:     #FF8C0018;
  --severity-medium-bg:   #FFD70018;
  --severity-low-bg:      #4CAF5018;
  --severity-info-bg:     #60A5FA18;

  /* Functional */
  --accent:          #60A5FA;  /* Links, interactive elements, focus */
  --accent-hover:    #93C5FD;  /* Hovered links and interactive */
  --success:         #4CAF50;
  --warning:         #FFD700;
  --error:           #FF4444;

  /* Special */
  --terminal-green:  #00FF41;  /* Sparingly — scan output, "running" states */
  --scan-pulse:      #60A5FA;  /* Active scan indicator */
}
```

### Light Mode (Secondary)

```css
[data-theme="light"] {
  --bg-void:      #F8F9FA;
  --bg-surface:   #FFFFFF;
  --bg-elevated:  #F1F3F5;
  --bg-overlay:   #FFFFFF;

  --text-primary:    #1A1A1A;
  --text-secondary:  #5F6368;
  --text-tertiary:   #9AA0A6;
  --text-inverse:    #FFFFFF;

  --border-subtle:   #E5E7EB;
  --border-visible:  #D1D5DB;
  --border-focus:    #2563EB;

  /* Severity colors darken slightly for light backgrounds */
  --severity-critical: #DC2626;
  --severity-high:     #EA580C;
  --severity-medium:   #CA8A04;
  --severity-low:      #16A34A;
  --severity-info:     #2563EB;

  --accent:          #2563EB;
  --accent-hover:    #1D4ED8;
}
```

### Palette Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  JAILBREAKINGSITE COLOR SYSTEM                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Depth Layers (background → foreground):                    │
│  ░░░░░░░░  #0B0D0F  void                                   │
│  ▒▒▒▒▒▒▒▒  #12151A  surface                                │
│  ▓▓▓▓▓▓▓▓  #1A1E26  elevated                               │
│  ████████  #222832  overlay                                 │
│                                                             │
│  Severity (the visual vocabulary):                          │
│  ████  #FF4444  CRITICAL — active, unpatched, exploit avail │
│  ████  #FF8C00  HIGH     — exploitable, patch available     │
│  ████  #FFD700  MEDIUM   — requires specific conditions     │
│  ████  #4CAF50  LOW      — theoretical or mitigated         │
│  ████  #60A5FA  INFO     — informational, no severity       │
│                                                             │
│  Functional:                                                │
│  ████  #60A5FA  accent (links, focus, interactive)          │
│  ████  #00FF41  terminal green (scan output, sparingly)     │
│                                                             │
│  Text:                                                      │
│  ████  #E8EAED  primary (body, headings)                    │
│  ████  #9AA0A6  secondary (labels, metadata)                │
│  ████  #5F6368  tertiary (timestamps, disabled)             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Color Usage Rules

- **Severity colors are functional, not decorative.** Never use `--severity-critical` for a CTA button or brand element. Red means CRITICAL. Always.
- **Accent blue is the only "brand" color.** Used for links, focus rings, active nav items, primary buttons. It's cool and calm — counterpoint to severity warmth.
- **Terminal green is a seasoning, not a sauce.** Use only for: active scan output streams, "running" status indicators, success confirmations. Never for backgrounds or large text.
- **Background layers create depth.** Cards sit on `--bg-surface` over `--bg-void`. Hover raises to `--bg-elevated`. This z-layering replaces borders and shadows as the primary spatial organizer.
- **Text hierarchy uses exactly three levels.** Primary, secondary, tertiary. No in-between grays. No colored text except severity indicators and links.

---

## Typography

### Font Stack

```css
:root {
  /* Display/Headings — geometric monospace with character */
  --font-display: 'JetBrains Mono', 'Fira Code', 'SF Mono', 'Consolas', monospace;

  /* Body — clean geometric sans for readability at density */
  --font-body: 'Inter', 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;

  /* Data/Code — same as display, smaller */
  --font-mono: 'JetBrains Mono', 'Fira Code', 'SF Mono', 'Consolas', monospace;
}
```

**Why monospace for display:** Security professionals read monospace all day. Using it for headings and data creates instant familiarity — "this is a tool, not a marketing site." Body text stays sans-serif for comfortable reading at density.

### Type Scale

Base: 15px (slightly smaller than typical — density matters here)

| Level | Size | Weight | Line Height | Font | Use |
|---|---|---|---|---|---|
| Display | 36-48px | 700 | 1.1 | `--font-display` | Page hero only (e.g., "Threat Pulse") |
| H1 | 28px | 700 | 1.2 | `--font-display` | Page titles, section headers |
| H2 | 22px | 600 | 1.3 | `--font-display` | Subsection headers |
| H3 | 18px | 600 | 1.4 | `--font-display` | Card titles, panel headers |
| H4 | 15px | 600 | 1.5 | `--font-body` | Labels, group headers |
| Body | 15px | 400 | 1.6 | `--font-body` | Primary content |
| Body SM | 13px | 400 | 1.5 | `--font-body` | Secondary content, descriptions |
| Caption | 11px | 500 | 1.4 | `--font-mono` | Metadata, technique IDs, timestamps |
| Code | 14px | 400 | 1.5 | `--font-mono` | Code blocks, technique payloads |
| Badge | 11px | 700 | 1.0 | `--font-mono` | Severity badges, status labels |

### Typography Rules

- **Headings are monospace, body is sans-serif.** This split is the signature. It creates a visual rhythm: structured data (mono) → readable prose (sans).
- **Technique IDs (AJS-2026-XXXX) are always monospace, always `--text-secondary`.** They are metadata, not content. Never style them as headings.
- **No italic.** Security content is factual. Italic signals emphasis or editorial voice — neither belongs here. Use **bold** or UPPERCASE for emphasis.
- **UPPERCASE is reserved for:** severity labels, status badges, section labels in navigation. Never for body text or headings.
- **Letter-spacing: `-0.02em` for display, `0.05em` for UPPERCASE labels, `0` for everything else.**
- **Max line length: `75ch` for body text, unrestricted for data tables.**

### Font Sources

| Font | Source | License | Link |
|---|---|---|---|
| JetBrains Mono | JetBrains / Google Fonts | OFL 1.1 (free) | [fonts.google.com/specimen/JetBrains+Mono](https://fonts.google.com/specimen/JetBrains+Mono) |
| Inter | Google Fonts | OFL 1.1 (free) | [fonts.google.com/specimen/Inter](https://fonts.google.com/specimen/Inter) |

Both fonts are free, self-hostable, and have variable font versions for optimal performance.

---

## Spacing & Layout

### Spacing Scale

```
2px   — Hairline (border offsets, badge padding vertical)
4px   — Micro (icon-to-text gap, inline badge padding)
8px   — XS (related elements, tight groups)
12px  — SM (form field padding, card internal gaps)
16px  — MD (standard spacing, card padding)
20px  — LG (between card groups)
24px  — XL (between sections within a page)
32px  — 2XL (major page sections)
48px  — 3XL (page-level top/bottom)
```

**Density note:** This scale is tighter than Minimal Tech. Security dashboards favor density. Users prefer scrolling less and seeing more.

### Grid System

```
Mobile:    1 column, 12px gutters, 12px margins
Tablet:    8 columns, 16px gutters, 24px margins
Desktop:   12 columns, 20px gutters, 32px margins
Wide:      12 columns, 24px gutters, max-width 1440px centered
```

**Max-width is 1440px** (wider than typical) because data tables and technique entries need horizontal space. The catalog taxonomy browser uses a sidebar + main layout that benefits from width.

### Primary Layouts

**1. Sidebar + Main (Catalog, Academy)**
```
┌──────────────────────────────────────────────────┐
│  HEADER (56px)                                   │
├──────────┬───────────────────────────────────────┤
│ SIDEBAR  │  MAIN CONTENT                         │
│ 260px    │  Flexible                              │
│          │                                        │
│ Taxonomy │  Technique list / detail / lab          │
│ tree,    │                                        │
│ filters, │                                        │
│ nav      │                                        │
│          │                                        │
├──────────┴───────────────────────────────────────┤
│  FOOTER (minimal — copyright, API link, status)  │
└──────────────────────────────────────────────────┘
```

**2. Full-Width Dashboard (Home, Defender Reports)**
```
┌──────────────────────────────────────────────────┐
│  HEADER (56px)                                   │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐           │
│  │ Stat │ │ Stat │ │ Stat │ │ Stat │  ← Bento  │
│  └──────┘ └──────┘ └──────┘ └──────┘            │
│                                                  │
│  ┌──────────────────┐ ┌────────────────┐        │
│  │ Latest Critical  │ │ Featured Labs  │        │
│  │ (tall card)      │ │ (card grid)    │        │
│  └──────────────────┘ └────────────────┘        │
│                                                  │
│  ┌──────────────────────────────────────┐       │
│  │ Monthly Report / Timeline            │       │
│  └──────────────────────────────────────┘       │
│                                                  │
└──────────────────────────────────────────────────┘
```

**3. Focus View (Technique Detail, Lab Active)**
```
┌──────────────────────────────────────────────────┐
│  HEADER (56px) — breadcrumb: Catalog > Category  │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────────────────────────────────┐       │
│  │ Technique Header Block               │       │
│  │ ID · Severity Badge · Status · Date  │       │
│  │                                      │       │
│  │ TECHNIQUE NAME (H1, mono)            │       │
│  │ Category > Subcategory               │       │
│  └──────────────────────────────────────┘       │
│                                                  │
│  [Description] [Detection] [Mitigations]  ← Tabs│
│                                                  │
│  ┌──────────────────────────────────────┐       │
│  │ Tab content — prose + code blocks    │       │
│  │ Max-width: 75ch for readability      │       │
│  └──────────────────────────────────────┘       │
│                                                  │
│  ┌──────────────┐ ┌────────────────────┐        │
│  │ Related      │ │ Affected Models    │        │
│  │ Techniques   │ │ (table)            │        │
│  └──────────────┘ └────────────────────┘        │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## Component Styling

### Header / Navigation

```css
.site-header {
  height: 56px;
  background: var(--bg-surface);
  border-bottom: 1px solid var(--border-subtle);
  display: flex;
  align-items: center;
  padding: 0 24px;
}

/* Logo: monospace wordmark, not an icon */
.site-logo {
  font-family: var(--font-display);
  font-size: 16px;
  font-weight: 700;
  color: var(--text-primary);
  letter-spacing: -0.02em;
  text-decoration: none;
}

/* Nav items */
.nav-item {
  font-family: var(--font-body);
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
  text-decoration: none;
  padding: 8px 12px;
  border-radius: 4px;
  transition: color 0.1s, background 0.1s;
}
.nav-item:hover {
  color: var(--text-primary);
  background: var(--bg-elevated);
}
.nav-item[aria-current="page"] {
  color: var(--accent);
}
```

**Header rules:**
- 56px height (compact — screen real estate is precious)
- Logo is a text wordmark in `--font-display`, not a graphic mark
- Nav items: 5 max (Catalog, Defender, Academy, API, Community)
- Sign-in button is ghost style, right-aligned
- Mobile: hamburger → full-screen overlay with dark background

### Severity Badges

The most important component in the system. These must be immediately scannable.

```css
.severity-badge {
  font-family: var(--font-mono);
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  padding: 2px 8px;
  border-radius: 3px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  line-height: 1;
}

.severity-badge--critical {
  color: var(--severity-critical);
  background: var(--severity-critical-bg);
  border: 1px solid color-mix(in srgb, var(--severity-critical) 30%, transparent);
}
.severity-badge--high {
  color: var(--severity-high);
  background: var(--severity-high-bg);
  border: 1px solid color-mix(in srgb, var(--severity-high) 30%, transparent);
}
.severity-badge--medium {
  color: var(--severity-medium);
  background: var(--severity-medium-bg);
  border: 1px solid color-mix(in srgb, var(--severity-medium) 30%, transparent);
}
.severity-badge--low {
  color: var(--severity-low);
  background: var(--severity-low-bg);
  border: 1px solid color-mix(in srgb, var(--severity-low) 30%, transparent);
}
.severity-badge--info {
  color: var(--severity-info);
  background: var(--severity-info-bg);
  border: 1px solid color-mix(in srgb, var(--severity-info) 30%, transparent);
}
```

### Technique Cards

```css
.technique-card {
  background: var(--bg-surface);
  border: 1px solid var(--border-subtle);
  border-radius: 6px;
  padding: 16px;
  transition: border-color 0.15s, background 0.15s;
  cursor: pointer;
}
.technique-card:hover {
  border-color: var(--border-visible);
  background: var(--bg-elevated);
}
/* Left border accent matches severity */
.technique-card[data-severity="critical"] {
  border-left: 3px solid var(--severity-critical);
}
.technique-card[data-severity="high"] {
  border-left: 3px solid var(--severity-high);
}
.technique-card[data-severity="medium"] {
  border-left: 3px solid var(--severity-medium);
}
.technique-card[data-severity="low"] {
  border-left: 3px solid var(--severity-low);
}

/* Card internals */
.technique-card__id {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--text-secondary);
}
.technique-card__title {
  font-family: var(--font-display);
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 4px 0;
}
.technique-card__meta {
  font-family: var(--font-body);
  font-size: 13px;
  color: var(--text-secondary);
}
```

**Technique card signature:** The left-border severity stripe. This is the single most recognizable pattern in the system — a 3px colored left border that communicates severity before the user reads a word. Borrowed from log-level patterns in developer tools.

### Buttons

```css
/* Primary — accent blue */
.btn-primary {
  background: var(--accent);
  color: var(--text-inverse);
  border: none;
  border-radius: 4px;
  padding: 8px 16px;
  font-family: var(--font-body);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.1s;
}
.btn-primary:hover {
  background: var(--accent-hover);
}
.btn-primary:focus-visible {
  outline: 2px solid var(--border-focus);
  outline-offset: 2px;
}

/* Secondary — outline */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  border: 1px solid var(--border-visible);
  border-radius: 4px;
  padding: 8px 16px;
  font-family: var(--font-body);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.1s, border-color 0.1s;
}
.btn-secondary:hover {
  background: var(--bg-elevated);
  border-color: var(--text-secondary);
}

/* Ghost — text only */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  border: none;
  padding: 8px 12px;
  font-family: var(--font-body);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
}
.btn-ghost:hover {
  color: var(--text-primary);
}

/* Danger — for destructive actions in Defender */
.btn-danger {
  background: var(--severity-critical);
  color: #FFFFFF;
  border: none;
  border-radius: 4px;
  padding: 8px 16px;
  font-family: var(--font-body);
  font-size: 14px;
  font-weight: 600;
}
.btn-danger:hover {
  background: #E03E3E;
}
```

**Button rules:**
- Border radius: `4px` — sharper than Minimal Tech (6-8px). Security tools don't do rounded.
- No shadows, no gradients, no uppercase text on buttons.
- Primary button used sparingly — max 1 per visible viewport.
- Danger button only in Defender scan flows and destructive actions.

### Form Inputs

```css
.input {
  background: var(--bg-void);
  border: 1px solid var(--border-visible);
  border-radius: 4px;
  padding: 10px 12px;
  font-family: var(--font-body);
  font-size: 14px;
  color: var(--text-primary);
  transition: border-color 0.15s;
}
.input:focus {
  border-color: var(--accent);
  outline: none;
  box-shadow: 0 0 0 2px var(--severity-info-bg);
}
.input::placeholder {
  color: var(--text-tertiary);
}
.input--error {
  border-color: var(--severity-critical);
}

/* API endpoint input — special styling for Defender */
.input--endpoint {
  font-family: var(--font-mono);
  font-size: 13px;
  background: var(--bg-void);
  color: var(--terminal-green);
  border: 1px solid var(--border-subtle);
}
```

### Tables (Data-Dense)

```css
.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.data-table th {
  font-family: var(--font-mono);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-tertiary);
  text-align: left;
  padding: 8px 12px;
  border-bottom: 1px solid var(--border-visible);
  position: sticky;
  top: 0;
  background: var(--bg-surface);
}
.data-table td {
  padding: 10px 12px;
  border-bottom: 1px solid var(--border-subtle);
  color: var(--text-primary);
  font-family: var(--font-body);
}
.data-table tr:hover {
  background: var(--bg-elevated);
}
/* Sortable column header */
.data-table th[aria-sort] {
  cursor: pointer;
}
.data-table th[aria-sort]:hover {
  color: var(--text-secondary);
}
```

### Scan Results Component (Defender-Specific)

```css
/* Scan progress bar */
.scan-progress {
  height: 4px;
  background: var(--bg-elevated);
  border-radius: 2px;
  overflow: hidden;
}
.scan-progress__fill {
  height: 100%;
  background: var(--accent);
  transition: width 0.3s ease-out;
}
.scan-progress__fill--complete {
  background: var(--success);
}

/* Results summary bar chart */
.results-bar {
  display: flex;
  height: 8px;
  border-radius: 4px;
  overflow: hidden;
  gap: 1px;
}
.results-bar__segment--critical { background: var(--severity-critical); }
.results-bar__segment--high     { background: var(--severity-high); }
.results-bar__segment--medium   { background: var(--severity-medium); }
.results-bar__segment--low      { background: var(--severity-low); }
.results-bar__segment--pass     { background: var(--severity-info); }
```

### Taxonomy Tree (Catalog Sidebar)

```css
.taxonomy-node {
  font-family: var(--font-body);
  font-size: 14px;
  color: var(--text-secondary);
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.taxonomy-node:hover {
  background: var(--bg-elevated);
  color: var(--text-primary);
}
.taxonomy-node[aria-expanded="true"] {
  color: var(--text-primary);
  font-weight: 500;
}
.taxonomy-node__count {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--text-tertiary);
}
/* Indent levels */
.taxonomy-node--level-1 { padding-left: 12px; }
.taxonomy-node--level-2 { padding-left: 28px; }
.taxonomy-node--level-3 { padding-left: 44px; }

/* Tree connector lines */
.taxonomy-node--level-2::before,
.taxonomy-node--level-3::before {
  content: '';
  position: absolute;
  left: 20px;
  top: 0;
  bottom: 0;
  width: 1px;
  background: var(--border-subtle);
}
```

### Code Blocks (Technique Payloads, Detection Signatures)

```css
.code-block {
  background: var(--bg-void);
  border: 1px solid var(--border-subtle);
  border-radius: 4px;
  padding: 16px;
  font-family: var(--font-mono);
  font-size: 13px;
  line-height: 1.6;
  color: var(--text-primary);
  overflow-x: auto;
}
/* Redacted code block — for authenticated-only content */
.code-block--redacted {
  filter: blur(4px);
  user-select: none;
  position: relative;
}
.code-block--redacted::after {
  content: 'Sign in to view reproduction steps';
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: color-mix(in srgb, var(--bg-void) 80%, transparent);
  filter: none;
  font-family: var(--font-body);
  font-size: 14px;
  color: var(--text-secondary);
}
```

### Lab Cards (Academy)

```css
.lab-card {
  background: var(--bg-surface);
  border: 1px solid var(--border-subtle);
  border-radius: 6px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.lab-card__type {
  font-family: var(--font-mono);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.lab-card__type--attack  { color: var(--severity-critical); }
.lab-card__type--defense { color: var(--severity-info); }
.lab-card__type--incident { color: var(--severity-high); }
.lab-card__type--build   { color: var(--success); }

.lab-card__difficulty {
  display: flex;
  gap: 3px;
}
/* Difficulty dots */
.lab-card__dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--border-visible);
}
.lab-card__dot--filled {
  background: var(--accent);
}
```

---

## Interaction & Motion

### Animation Principles

| Property | Value | Rationale |
|---|---|---|
| Default duration | 100-150ms | Security tools feel fast. Sluggish animations feel untrustworthy. |
| Easing | `ease-out` for enters, `ease-in` for exits | Standard, predictable |
| Hover transitions | 100ms | Near-instant feedback |
| Panel open/close | 200ms | Fast enough to feel responsive |
| Page transitions | None | No page transition animations. Content appears immediately. |

### Interaction Table

| Element | Effect | Duration | Easing |
|---|---|---|---|
| Buttons | Background color shift | 100ms | ease-out |
| Links | Color shift, underline appears | 100ms | ease-out |
| Cards (hover) | Border brightens, bg lifts one layer | 150ms | ease-out |
| Sidebar expand/collapse | Width transition | 200ms | ease-out |
| Tooltip appear | Opacity 0→1 | 150ms | ease-out |
| Modal open | Opacity 0→1, scale 0.98→1 | 200ms | ease-out |
| Scan progress | Width transition | 300ms | ease-out |
| Severity badge pulse (critical active) | Box-shadow pulse | 2000ms | ease-in-out, infinite |

### Special: Active Scan Animation

The only "fancy" animation in the system. When a Defender scan is running:

```css
@keyframes scan-pulse {
  0%, 100% { box-shadow: 0 0 0 0 var(--scan-pulse); }
  50% { box-shadow: 0 0 0 4px color-mix(in srgb, var(--scan-pulse) 25%, transparent); }
}
.scan-active {
  animation: scan-pulse 2s ease-in-out infinite;
}
```

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
  .scan-active {
    box-shadow: 0 0 0 2px var(--scan-pulse);
    animation: none;
  }
}
```

---

## Asset Guidelines

### Logo

- **Type:** Text wordmark only — `JAILBREAKINGSITE` in `--font-display` (JetBrains Mono), weight 700
- **No logomark/icon.** The name is distinctive enough. An icon would be either too generic (shield) or too edgy (skull/lock).
- **Treatments:**
  - Full: `JAILBREAKINGSITE` — all caps, `letter-spacing: -0.02em`
  - Short: `AJS` — for favicons, mobile header, compact contexts
  - Wordmark color: `--text-primary` (adapts to dark/light mode)
- **Clear space:** Minimum `1em` on all sides
- **Minimum size:** 120px wide (full), 24px (AJS mark)

### Iconography

- **Style:** Outline icons, 1.5px stroke, 20px default size
- **Source:** Lucide Icons (free, MIT license, consistent with the aesthetic)
- **Color:** `--text-secondary` default, `--text-primary` on hover/active
- **Severity icons:** Use filled circles with severity colors, not custom icons
  - CRITICAL: filled red circle
  - HIGH: filled orange circle
  - MEDIUM: filled gold circle
  - LOW: filled green circle
  - INFO: filled blue circle

### Imagery

- **No stock photography.** Ever. This is a data-driven tool, not a marketing site.
- **Diagrams and schematics** are the primary visual content: attack flow diagrams, technique relationship graphs, scan result visualizations
- **Diagram style:** Monochrome with severity color accents. Rendered as SVG or canvas. No drop shadows, no 3D, no gradients.
- **Screenshots:** Allowed for documentation. Always dark mode, always cropped tight.

---

## Unique Patterns

### 1. Threat Pulse (Home Dashboard)

The home page opens with a real-time snapshot — not a hero banner, not a marketing message. Stats are the hero.

```
┌──────────────────────────────────────────────────┐
│  412              47              3              │
│  techniques       new this        critical       │
│  cataloged        month           (active)       │
│                                                  │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░  83% coverage        │
│  models with full technique mapping              │
└──────────────────────────────────────────────────┘
```

Numbers are Display-size in `--font-display`. Labels are Caption-size in `--font-body`. The contrast between giant monospace numbers and small labels is the visual signature of the home page.

### 2. Severity-Striped Lists

Anywhere techniques appear in a list, the left-border severity stripe creates a scannable color channel:

```
  ┃ ████ AJS-2026-0203  Indirect Injection via RAG       CRITICAL
  ┃ ████ AJS-2026-0198  MCP Tool Chain Priv Escalation   CRITICAL
  ┃ ████ AJS-2026-0191  Multi-Turn Crescendo v3          HIGH
  ┃ ████ AJS-2026-0187  Base64 Payload in Tool Args      MEDIUM
  ┃ ████ AJS-2025-0412  Role-Play Persistence (patched)  LOW
```

### 3. Redacted Content Blocks

Unauthenticated users see blurred code blocks with a sign-in prompt. This is both a security measure and a visual pattern that signals "there's more here."

### 4. Keyboard Navigation Emphasis

The entire catalog and academy should be keyboard-navigable. Focus indicators are always visible (never `outline: none` without replacement). Tab order follows visual order. Shortcuts are displayed in the UI (e.g., `/ to search`, `j/k to navigate`, `Enter to open`).

---

## Implementation Checklist

### Foundation
- [ ] Dark mode is the default experience
- [ ] Light mode is complete and consistent
- [ ] All CSS custom properties defined in `:root`
- [ ] Font files self-hosted (not CDN-loaded) for privacy-conscious audience

### Color
- [ ] Severity colors used ONLY for severity communication
- [ ] No decorative use of severity colors
- [ ] All text passes WCAG 2.2 AA contrast (4.5:1 body, 3:1 large)
- [ ] Focus indicators visible in both modes

### Typography
- [ ] JetBrains Mono used for headings and data
- [ ] Inter used for body text
- [ ] Type scale applied consistently
- [ ] No italic usage
- [ ] UPPERCASE restricted to badges and section labels

### Components
- [ ] Severity badges render consistently at all sizes
- [ ] Technique cards show severity stripe
- [ ] Code blocks support syntax highlighting
- [ ] Redacted blocks blur and overlay correctly
- [ ] Tables are sortable with clear sort indicators
- [ ] All form inputs have focus, error, and disabled states

### Interaction
- [ ] All transitions ≤200ms (except scan pulse)
- [ ] `prefers-reduced-motion` respected
- [ ] No page transition animations
- [ ] Hover states on all interactive elements
- [ ] Keyboard shortcuts documented and functional

### Accessibility
- [ ] WCAG 2.2 AA compliance minimum
- [ ] All images have alt text
- [ ] Keyboard navigation covers all interactions
- [ ] Screen reader landmarks for all major regions
- [ ] Focus never trapped (except modals, with Escape exit)
- [ ] Severity communicated by text, not color alone (badges include text labels)
- [ ] `aria-sort` on sortable table columns
- [ ] `aria-expanded` on taxonomy tree nodes
- [ ] `aria-current="page"` on active nav

### Performance
- [ ] Total font payload < 100KB (variable fonts)
- [ ] No images on initial load (data-driven, not image-driven)
- [ ] LCP < 1.5s (dashboard stats are server-rendered)
- [ ] Tables virtualized for >100 rows

---

## Anti-Patterns (What This Is NOT)

| Temptation | Why Not | Instead |
|---|---|---|
| Neon green terminal background | Feels like a movie prop, not a professional tool | `--terminal-green` only for scan output streams |
| Glitch effects on text | Inaccessible, edgy-for-edgy's-sake | Clean, sharp rendering. The content is edgy enough. |
| Skull/crossbones/lock icons | Juvenile. Security professionals roll their eyes. | Lucide outline icons. Let the data be the visual. |
| Animated matrix rain background | Performance killer, distracting, cliche | Solid dark backgrounds. Quiet confidence. |
| "Hacker font" (e.g., VT323) | Low readability, parody aesthetic | JetBrains Mono — a professional monospace with character |
| Red as brand/accent color | Conflicts with severity system. Red = CRITICAL, always. | Blue accent. Red is reserved for danger. |
| Bright green "success" everywhere | Desensitizes users to the severity palette | Green used sparingly: success confirmations, LOW severity |

---

*Custom style system designed for JailbreakingSite. Not derived from any single source specification — purpose-built for the LLM security operations domain.*
