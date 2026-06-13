# Style Guide: Knowledge Base — Direction B: Scholar's Terminal

> A power tool for world-builders. Dark, dense, keyboard-first. Content is data to be navigated, connected, and generated at speed.

**Style System:** Minimal Tech 80% + Editorial 20%
**Source Specs:** minimal-tech.md + editorial.md
**Scenario:** AI-powered world-building knowledge graph for authors, game designers, and content creators

---

## Scenario

**Knowledge Base** is a dynamic content generator that creates consistent, cross-referenced world-building materials. This direction treats it as a **power tool** — closer to Obsidian, Notion, or a database admin panel than to a library. The content is important, but the system's ability to navigate, connect, search, generate, and verify that content is what users pay for.

The interface needs to signal **precision, intelligence, and efficiency** — "this tool makes you faster at world-building." When a game master searches for a character mid-session, they need the answer in 200ms, not a beautiful reading experience. When an author generates 20 lore entries in batch, they need a clean queue to review, not a one-at-a-time scroll.

Minimal Tech dominates: dark mode, monochrome palette, single accent, information density, keyboard shortcuts, and clean component architecture. The Editorial accent appears in exactly one place: **entry reading mode** — when you actually sit down to read a lore entry, serif typography and generous line height make the content comfortable. Everywhere else, sans-serif and density rule.

**Reference energy:** obsidian.md (graph + notes), linear.app (keyboard-first tool), notion.so (flexible blocks), arc.net (clean dark browser)

**Brand personality:** Precise. Fast. Powerful. Quiet.

---

## Color Palette

```css
:root {
  /* 80% — Minimal Tech foundation: cool dark */
  --bg-primary: #0A0A0C;        /* Near-black */
  --bg-surface: #141416;         /* Cards, panels */
  --bg-elevated: #1C1C20;        /* Elevated surfaces */
  --bg-overlay: rgba(10, 10, 12, 0.8); /* Modal backdrop */

  /* Text */
  --text-primary: #EDEDF0;       /* Near-white */
  --text-secondary: #8E8E9A;     /* Medium gray */
  --text-tertiary: #56566A;      /* Dark gray */

  /* Borders */
  --border-default: #27272F;     /* Standard */
  --border-subtle: #1C1C22;      /* Barely visible */

  /* Accent — Indigo (signals intelligence, depth) */
  --accent: #6366F1;
  --accent-hover: #818CF8;
  --accent-muted: rgba(99, 102, 241, 0.12);

  /* 20% — Editorial: reading mode tokens */
  --reading-bg: #141416;         /* Slightly elevated for reading */
  --reading-text: #E8E2D9;       /* Warm off-white for long reading */
  --reading-link: #93A3D0;       /* Muted blue for inline links */

  /* Focus */
  --focus-ring: rgba(99, 102, 241, 0.25);

  /* Semantic — content status */
  --canon: #EDEDF0;              /* White — source of truth */
  --canon-muted: rgba(237, 237, 240, 0.06);
  --generated: #C4956A;          /* Warm gold — AI-produced */
  --generated-muted: rgba(196, 149, 106, 0.10);
  --flag-error: #EF4444;         /* Red — hard contradiction */
  --flag-error-muted: rgba(239, 68, 68, 0.10);
  --flag-warn: #EAB308;          /* Yellow — possible conflict */
  --flag-warn-muted: rgba(234, 179, 8, 0.10);
  --flag-suggestion: #60A5FA;    /* Blue — gap to fill */
  --flag-suggestion-muted: rgba(96, 165, 250, 0.10);
  --success: #22C55E;            /* Green — resolved */
  --success-muted: rgba(34, 197, 94, 0.10);
}
```

```
┌──────────────────────────────────────────────┐
│  SCHOLAR'S TERMINAL PALETTE                  │
├──────────────────────────────────────────────┤
│                                              │
│  ██████  #0A0A0C   Near-black (bg)           │
│  ██████  #141416   Surface                   │
│  ██████  #1C1C20   Elevated                  │
│                                              │
│  ██████  #EDEDF0   Primary text              │
│  ██████  #8E8E9A   Secondary text            │
│                                              │
│  ██████  #6366F1   Indigo accent             │
│                                              │
│  ██████  #EDEDF0   Canon (white, confirmed)  │
│  ██████  #C4956A   Generated (warm gold)     │
│  ██████  #EF4444   Error (red)               │
│  ██████  #EAB308   Warning (yellow)          │
│  ██████  #22C55E   Success (green)           │
│                                              │
│  Dark, cool, precise. The accent is          │
│  restrained. Semantic colors signal          │
│  content status. Reading mode warms up.      │
│                                              │
└──────────────────────────────────────────────┘
```

**Usage rules:**
- Dark mode only. No light mode. The dark canvas makes content and data pop.
- **Indigo accent** (`--accent`): primary CTAs, active navigation, focus rings, selected graph nodes, "generate" action
- Canon vs. generated distinction uses brightness: canon entries have a white left-bar indicator, generated entries have warm gold
- Semantic colors (red/yellow/blue/green) are reserved for the consistency checker and status badges
- Background occupies 80%+ of visual field
- No gradients, no decorative shadows (only functional shadows on modals/dropdowns)
- **Reading mode** activates on entry detail: background warms slightly, text shifts to `--reading-text` (warm off-white), font switches to serif

**Contrast ratios (against `--bg-primary: #0A0A0C`):**
- `--text-primary` (#EDEDF0): **17.1:1** — exceeds AAA
- `--text-secondary` (#8E8E9A): **6.6:1** — exceeds AA
- `--accent` (#6366F1): **5.1:1** — meets AA
- `--generated` (#C4956A): **6.8:1** — exceeds AA

---

## Typography

**Font stack:**
```css
/* 80% — Minimal Tech: UI and functional text */
--font-sans: 'Inter', 'Geist', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;

/* 80% — Minimal Tech: data and metadata */
--font-mono: 'JetBrains Mono', 'Geist Mono', 'Fira Code', Consolas, monospace;

/* 20% — Editorial: entry reading mode */
--font-serif: 'Source Serif 4', 'Lora', 'Georgia', serif;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| H1 | Sans | 28px | 600 | 1.2 | Page titles ("Entries", "Knowledge Graph") |
| H2 | Sans | 22px | 600 | 1.25 | Panel titles, universe name |
| H3 | Sans | 18px | 600 | 1.3 | Card headers, section headings |
| Body | Sans | 14px | 400 | 1.6 | Default UI text (developer-dense) |
| Body Small | Sans | 12px | 400 | 1.5 | Metadata labels, timestamps |
| **Reading H1** | **Serif** | **28px** | **700** | **1.2** | **Entry title in reading mode** |
| **Reading H2** | **Serif** | **22px** | **600** | **1.25** | **Entry section heading** |
| **Reading Body** | **Serif** | **17px** | **400** | **1.7** | **Entry body text — reading mode only** |
| Data | Mono | 13px | 400 | 1.4 | Tags, IDs, scores, counts |
| Graph Label | Sans | 12px | 500 | 1.2 | Node labels in knowledge graph |
| Caption | Mono | 11px | 400 | 1.3 | Fine print, version numbers |

**Typography notes:**
- **Sans-serif (Inter) is the default everywhere.** Tool-first density. 14px base for UI consistency with developer tool conventions.
- **The 20% editorial element:** Serif appears ONLY in entry reading mode. When you click into an entry to actually read it, Source Serif 4 takes over at 17px with 1.7 line height. The switch from sans to serif is the signal: "you're reading now, not navigating." Max-width 65ch for reading comfort.
- Monospace for all structured data: tags, entry IDs, word counts, generation timestamps, consistency scores.
- Two weights only: 400 and 600. No bold (700) except serif headings in reading mode.

**Font sources:**

| Font | Source | License |
|------|--------|---------|
| Inter | Google Fonts | OFL |
| Source Serif 4 | Google Fonts | OFL |
| JetBrains Mono | Google Fonts | OFL |

---

## Spacing & Layout

### Base Unit

8px base:

```
4px   — Micro (inline gaps, icon-to-label)
8px   — XS (tight component padding)
12px  — SM (list item gaps)
16px  — MD (standard padding)
24px  — LG (section inner padding)
32px  — XL (card padding, section gaps)
48px  — 2XL (between major sections)
64px  — 3XL (page-level padding)
```

### Grid

| Breakpoint | Columns | Gutter | Margin | Max Width |
|------------|---------|--------|--------|-----------|
| Mobile (<768px) | 4 | 12px | 16px | 100% |
| Tablet (768-1024px) | 8 | 16px | 24px | 100% |
| Desktop (1024-1440px) | 12 | 24px | 32px | 100% |
| Wide (>1440px) | 12 | 24px | 64px | 1440px |

### Layout Pattern

Collapsible sidebar (280px) + main workspace + optional right panel (360px).

```
┌────────────────────────────────────────────────────────────────────┐
│  ◊ KB    ⌘K Search     Entries  Graph  Timeline  Gen  Flags  [⊕]  │
├──────────┬──────────────────────────────────────┬─────────────────┤
│          │                                      │                 │
│ SIDEBAR  │  MAIN WORKSPACE                      │  RIGHT PANEL    │
│ 280px    │                                      │  360px          │
│          │  ┌────────────────────────────────┐  │  (optional)     │
│ ENTRIES  │  │ Entry reading mode:            │  │                 │
│ ├ Kael   │  │ Source Serif 4 at 17px         │  │ CONNECTIONS     │
│ ├ Thorn  │  │ with 1.7 line height.          │  │ → Thornwall     │
│ ├ War    │  │                                │  │ → Guild         │
│ ├ Iron   │  │ Max-width 65ch, centered.      │  │ → War           │
│ ├ Guild  │  │                                │  │                 │
│ │        │  │ This is the ONLY serif zone.    │  │ FLAGS           │
│ TAGS     │  │                                │  │ ⚠ Age conflict  │
│ ├ char   │  └────────────────────────────────┘  │                 │
│ ├ loc    │                                      │ METADATA        │
│ ├ event  │                                      │ Created: ...    │
│ └ fac    │                                      │ Words: 847      │
│          │                                      │ Version: 3      │
├──────────┴──────────────────────────────────────┴─────────────────┤
│  ⌘K Search · 247 entries · 3 flags · Gen queue: 0                 │
└────────────────────────────────────────────────────────────────────┘
```

### Three-Panel Architecture

- **Left sidebar:** Entry navigation, tag filters, entry tree. Always visible on desktop, overlay on mobile.
- **Main workspace:** Entry reading/editing, graph view, timeline, generation queue. This panel switches modes.
- **Right panel:** Context-sensitive metadata, connections, consistency flags. Collapsible. Appears when an entry is selected.

### Border Radius

```css
--radius-sm: 4px;
--radius-md: 6px;
--radius-lg: 8px;
--radius-full: 9999px;
```

---

## Component Styling

### Buttons

```css
/* Primary — indigo accent */
.btn-primary {
  background: var(--accent);
  color: #FFFFFF;
  padding: 8px 16px;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 600;
  font-family: var(--font-sans);
  border: none;
  transition: opacity 150ms ease;
}
.btn-primary:hover { opacity: 0.9; }
.btn-primary:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
.btn-primary:disabled { opacity: 0.4; cursor: not-allowed; }

/* Secondary — bordered */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  padding: 8px 16px;
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 600;
  font-family: var(--font-sans);
  transition: background 150ms ease;
}
.btn-secondary:hover { background: var(--bg-elevated); }

/* Ghost */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  padding: 8px 12px;
  border: none;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 400;
  font-family: var(--font-sans);
  transition: color 150ms ease;
}
.btn-ghost:hover { color: var(--text-primary); }

/* Generate — warm gold accent */
.btn-generate {
  background: var(--generated);
  color: var(--bg-primary);
  padding: 8px 16px;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 600;
  font-family: var(--font-sans);
  border: none;
  transition: opacity 150ms ease;
}
.btn-generate:hover { opacity: 0.9; }
```

### Cards

```css
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  padding: 16px;
  transition: border-color 150ms ease;
}
.card:hover { border-color: var(--text-tertiary); }

.card--canon { border-left: 3px solid var(--canon); }
.card--generated { border-left: 3px solid var(--generated); }
.card--flagged { border-left: 3px solid var(--flag-error); background: var(--flag-error-muted); }
```

### Form Inputs

```css
.input {
  background: var(--bg-surface);
  color: var(--text-primary);
  padding: 8px 12px;
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  font-size: 14px;
  font-family: var(--font-sans);
  transition: border-color 150ms ease;
}
.input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-muted);
  outline: none;
}
.input--error { border-color: var(--flag-error); }
```

### Navigation

```css
.sidebar {
  width: 280px;
  background: var(--bg-primary);
  border-right: 1px solid var(--border-default);
  padding: 16px 0;
}
.nav-item {
  padding: 6px 16px;
  color: var(--text-secondary);
  font-size: 13px;
  font-weight: 400;
  transition: color 150ms ease, background 150ms ease;
}
.nav-item:hover { color: var(--text-primary); background: var(--bg-surface); }
.nav-item--active {
  color: var(--accent);
  background: var(--accent-muted);
  font-weight: 600;
}
.nav-section-label {
  padding: 8px 16px;
  font-size: 11px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-tertiary);
}
```

### Knowledge-Base-Specific Components

#### Command Palette (⌘K)

```css
.command-palette {
  position: fixed;
  top: 20%;
  left: 50%;
  transform: translateX(-50%);
  width: 560px;
  max-height: 400px;
  background: var(--bg-elevated);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.5);
  z-index: 1000;
  overflow: hidden;
}
.command-palette__input {
  width: 100%;
  padding: 16px 20px;
  background: transparent;
  border: none;
  border-bottom: 1px solid var(--border-default);
  font-size: 16px;
  font-family: var(--font-sans);
  color: var(--text-primary);
}
.command-palette__result {
  padding: 10px 20px;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: background 100ms ease;
}
.command-palette__result:hover,
.command-palette__result--selected {
  background: var(--accent-muted);
}
.command-palette__result-type {
  font-family: var(--font-mono);
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-tertiary);
  min-width: 60px;
}
```

#### Entry Status Indicator

```css
.status-dot {
  width: 8px;
  height: 8px;
  border-radius: var(--radius-full);
  flex-shrink: 0;
}
.status-dot--canon { background: var(--canon); }
.status-dot--generated { background: var(--generated); }
.status-dot--flagged {
  background: var(--flag-error);
  box-shadow: 0 0 6px rgba(239, 68, 68, 0.4);
}
```

#### Graph Node (MT-styled)

```css
.graph-node {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  padding: 8px 12px;
  font-family: var(--font-sans);
  font-size: 12px;
  font-weight: 500;
  color: var(--text-primary);
  cursor: pointer;
  transition: border-color 150ms ease;
}
.graph-node:hover { border-color: var(--accent); }
.graph-node--selected {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-muted);
}
.graph-node--canon { border-left: 3px solid var(--canon); }
.graph-node--generated { border-left: 3px solid var(--generated); }

.graph-node__type {
  font-family: var(--font-mono);
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-tertiary);
}

.graph-edge {
  stroke: var(--border-default);
  stroke-width: 1;
}
.graph-edge--highlighted {
  stroke: var(--accent);
  stroke-width: 1.5;
}
```

#### Reading Mode Container

```css
/* The 20% Editorial surface — only for entry detail reading */
.reading-mode {
  max-width: 65ch;
  margin: 0 auto;
  padding: 48px 32px;
}
.reading-mode h1 {
  font-family: var(--font-serif);
  font-size: 28px;
  font-weight: 700;
  color: var(--reading-text);
  line-height: 1.2;
  margin-bottom: 8px;
}
.reading-mode h2 {
  font-family: var(--font-serif);
  font-size: 22px;
  font-weight: 600;
  color: var(--reading-text);
  line-height: 1.25;
  margin-top: 32px;
  margin-bottom: 12px;
}
.reading-mode p {
  font-family: var(--font-serif);
  font-size: 17px;
  font-weight: 400;
  line-height: 1.7;
  color: var(--reading-text);
  margin-bottom: 16px;
}
.reading-mode a {
  color: var(--reading-link);
  text-decoration: underline;
  text-underline-offset: 3px;
}
```

#### Consistency Flag (Compact)

```css
.flag-compact {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-family: var(--font-sans);
}
.flag-compact--error { background: var(--flag-error-muted); color: var(--flag-error); }
.flag-compact--warn { background: var(--flag-warn-muted); color: var(--flag-warn); }
.flag-compact--suggestion { background: var(--flag-suggestion-muted); color: var(--flag-suggestion); }
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Button hover | Opacity fade | 150ms | ease |
| Input focus | Border + shadow | 150ms | ease |
| Nav item hover | Background fade | 150ms | ease |
| Sidebar collapse | Width slide | 200ms | ease-out |
| Right panel slide | SlideX from right | 200ms | ease-out |
| Command palette open | Scale from 0.95 + fade | 150ms | ease-out |
| Graph node hover | Border color change | 150ms | ease |
| Graph zoom/pan | Transform | Continuous | ease-out |
| Reading mode enter | Crossfade sans→serif | 200ms | ease |
| Entry list filter | Staggered fade, 30ms between | 150ms | ease |
| Generation progress | Progress bar fill | Variable | linear |
| Flag resolution | Slide up and fade | 200ms | ease-out |
| Keyboard shortcut hint | Fade in on hover | 100ms | ease |

**Motion philosophy:** Functional only. The tool gets out of the way. 150ms is the standard duration for everything — fast enough to feel instant, slow enough to track. No signature animations, no personality — just speed.

**Keyboard shortcuts** are a first-class feature:

| Shortcut | Action |
|----------|--------|
| `⌘K` | Command palette (search everything) |
| `⌘N` | New entry |
| `⌘G` | Switch to graph view |
| `⌘T` | Switch to timeline view |
| `⌘⇧G` | Generate from current entry |
| `⌘⇧P` | Promote generated to canon |
| `⌘[` / `⌘]` | Navigate entry history |
| `⌘\` | Toggle sidebar |
| `⌘⇧\` | Toggle right panel |

All animations respect `prefers-reduced-motion`.

---

## Asset Guidelines

**Photography / Illustration:** None. Data interface.

**Iconography:** Lucide icons (16px default, 1.5px stroke weight). Monochrome — `currentColor`. Small and dense.

**Data visualization:** The knowledge graph is the primary viz. Uses force-directed layout with indigo accent on selected nodes. Additional charts (entry count by type, generation stats) use accent for primary data, `--text-tertiary` for secondary. No 3D effects.

**Empty states:** Single line of text + CTA button. "No entries yet. Create your first." Minimal.

**Logo:** "◊ KB" in Inter at 600 weight. "KB" is the compact mark. Indigo on dark. Used in the sidebar header.

---

## Mixing Notes

### Elements Carrying the 20% Editorial Accent (3 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Entry reading mode** | Sans 14px → Serif 17px with 1.7 line height, warm text color, max-width 65ch | When an author reads a 2000-word lore entry about the founding of a fictional city, it needs to feel like reading, not scanning a database. Source Serif 4 at 17px with generous line height is the minimum for reading comfort. This is the product's content quality moment. |
| **Entry titles in reading mode** | Sans H1 → Serif H1 at 28px, 700 weight | Entry titles are the names of characters, locations, and events in someone's creative universe. "Kael Ashward" in serif carries more weight and authorial intent than in sans. |
| **Inline cross-references** | Standard link styling → Underlined with warm blue (`--reading-link`), underline offset for readability | Within the serif reading surface, cross-references to other entries need to be visible but not disruptive. Warm muted blue with offset underline maintains the reading flow while enabling navigation. |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| Serif throughout (not just reading mode) | Makes the tool feel slow and literary. When scanning a list of 50 entries in the sidebar, sans-serif at 13px is faster to parse than serif. The product is a tool first. |
| Light mode option | Dark mode is the developer-tool-adjacent identity. A light mode would require redesigning all contrast ratios and semantic colors. The product's power-user audience expects dark. |
| Warm cream backgrounds (Direction A's palette) | Cream signals "library" — this direction signals "terminal." The cool dark palette reinforces speed and precision. |
| Animated generation (typewriter effect) | Too slow for power users. A progress bar is faster feedback than watching text appear word-by-word. Typewriter animations are charming but wasteful when reviewing 20 generated entries. |

---

## Implementation Checklist

- [ ] Inter (UI, 400-600) + JetBrains Mono (data, 400) + Source Serif 4 (reading mode only, 400-700)
- [ ] Dark mode only — `#0A0A0C` background
- [ ] Reading mode: serif 17px, 1.7 line height, 65ch max-width, warm text color
- [ ] All non-reading text: sans 14px (dense, developer-tool standard)
- [ ] Command palette (`⌘K`) with full entry and command search
- [ ] Keyboard shortcuts for all major actions
- [ ] Canon entries: white left-bar indicator
- [ ] Generated entries: warm gold left-bar indicator
- [ ] Three-panel layout: sidebar + main + collapsible right panel
- [ ] All interactive elements have visible focus rings
- [ ] Consistency flags use severity colors with muted backgrounds
- [ ] Graph nodes use sans labels, MT-styled borders
- [ ] No decorative shadows or gradients
- [ ] All animations: 150ms ease (no variation)
- [ ] `prefers-reduced-motion`: all transitions disabled
- [ ] Color contrast: all text meets WCAG AA
- [ ] Touch targets: minimum 44px
- [ ] Status bar with entry count, flag count, sync status

---

*Derived from: minimal-tech.md + editorial.md*
*Project: NOIZUAI-4 — Knowledge Base (library.therobotlives.com)*
