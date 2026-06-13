# Style Guide: Knowledge Base — Direction A: Vellum & Ink

> A library that feels like opening a beautiful book. Content breathes. Typography leads. The knowledge graph looks like marginalia in an illuminated manuscript.

**Style System:** Editorial 80% + Minimal Tech 20%
**Source Specs:** editorial.md + minimal-tech.md
**Scenario:** AI-powered world-building knowledge graph for authors, game designers, and content creators

---

## Scenario

**Knowledge Base** is a dynamic content generator that creates consistent, cross-referenced world-building materials — lore entries, character backstories, in-universe documents, timelines, and relationship maps. Its primary users are **novelists and TTRPG game masters** who spend hours maintaining creative universes and need the supporting materials to feel as crafted as the work itself.

The interface needs to signal **authority, depth, and craftsmanship** — "this tool respects your creative work." When an author reads a generated entry about the founding of their fictional city, it should feel like reading a page from the city's own history book, not like viewing a database record.

The Editorial foundation delivers this: serif typography, generous margins, warm cream backgrounds, and typography as the primary design element. Content is the hero. The UI chrome steps back and lets the words speak.

The Minimal Tech accent provides the structural discipline needed for the **knowledge graph**, **consistency checker**, **search**, and **generation controls**. These functional surfaces need systematic spacing, clean data presentation, and restrained interaction patterns. MT contributes sans-serif labels, monospace for metadata, focus rings, and systematic grid spacing for non-content surfaces.

**Reference energy:** notion.so (flexible workspace), worldanvil.com (creative structure), are.na (beautiful curation), stripe.com/docs (editorial + technical harmony)

**Brand personality:** Scholarly. Warm. Authoritative. Patient.

---

## Color Palette

```css
:root {
  /* 80% — Editorial foundation: warm, paper-inspired */
  --bg-primary: #FAF9F6;       /* Warm cream — the page */
  --bg-surface: #FFFFFF;        /* Cards, panels, elevated */
  --bg-elevated: #F5F0EA;       /* Sidebar, navigation, secondary */
  --bg-reading: #FFFCF7;        /* Entry reading mode — slightly warmer */

  /* Text — high contrast, ink-inspired */
  --text-primary: #1A1714;      /* Near-black with warm undertone */
  --text-secondary: #6B6560;    /* Warm medium gray */
  --text-tertiary: #9E9790;     /* Light warm gray */

  /* Borders — warm, subtle */
  --border-default: #E8E2D9;    /* Warm gray */
  --border-subtle: #F0EBE3;     /* Barely visible */
  --border-heavy: #C4BDB3;      /* Heavier rule lines */

  /* 80% — Editorial accent: library/leather/scholarly */
  --accent: #8B4513;            /* Saddle brown — bookbinding, leather */
  --accent-hover: #A0522D;      /* Sienna */
  --accent-muted: rgba(139, 69, 19, 0.08);

  /* Links — scholarly blue (editorial tradition) */
  --link: #2D5A8E;
  --link-hover: #1E3F66;
  --link-visited: #5B4A8A;

  /* 20% — Minimal Tech: functional tokens */
  --focus-ring: rgba(45, 90, 142, 0.25);

  /* Semantic — content status */
  --canon: #1A1714;             /* Ink black — source of truth */
  --canon-muted: rgba(26, 23, 20, 0.06);
  --generated: #8B7355;         /* Sepia — AI-produced, pending review */
  --generated-muted: rgba(139, 115, 85, 0.08);
  --flag-error: #C4432B;        /* Manuscript red — hard contradiction */
  --flag-error-muted: rgba(196, 67, 43, 0.08);
  --flag-warn: #B8860B;         /* Dark goldenrod — possible conflict */
  --flag-warn-muted: rgba(184, 134, 11, 0.08);
  --flag-suggestion: #2D5A8E;   /* Scholarly blue — gap to fill */
  --flag-suggestion-muted: rgba(45, 90, 142, 0.08);
  --success: #3D7A4A;           /* Forest green — resolved, promoted */
  --success-muted: rgba(61, 122, 74, 0.08);
}
```

```
┌──────────────────────────────────────────────┐
│  VELLUM & INK PALETTE                        │
├──────────────────────────────────────────────┤
│                                              │
│  ██████  #FAF9F6   Cream page (bg)           │
│  ██████  #FFFFFF   Surface (cards)           │
│  ██████  #F5F0EA   Elevated (sidebar)        │
│                                              │
│  ██████  #1A1714   Ink black (text)          │
│  ██████  #6B6560   Warm gray (secondary)     │
│                                              │
│  ██████  #8B4513   Saddle brown (accent)     │
│  ██████  #2D5A8E   Scholarly blue (links)    │
│                                              │
│  ██████  #1A1714   Canon (solid, approved)   │
│  ██████  #8B7355   Generated (sepia, draft)  │
│  ██████  #C4432B   Error flag (manuscript red)│
│  ██████  #B8860B   Warning (goldenrod)       │
│  ██████  #3D7A4A   Success (forest green)    │
│                                              │
│  Warm and restrained. Color is earned,       │
│  not default. Semantic colors serve the      │
│  content status system, not decoration.      │
│                                              │
└──────────────────────────────────────────────┘
```

**Usage rules:**
- Light mode only. No dark mode variant. The warm cream background is the product's signature — it signals "paper," "library," "care."
- **Saddle brown** (`--accent`): primary CTA buttons, active sidebar items, selected graph nodes, "promote to canon" action
- **Scholarly blue** (`--link`): all hyperlinks between entries, inline cross-references, "view in graph" links
- **Canon vs. generated** is the primary visual system:
  - Canon entries: solid left border in `--canon` (ink black)
  - Generated entries: dashed left border in `--generated` (sepia)
  - This distinction is visible on every entry card, list item, and graph node
- **Flag colors** (red, goldenrod, blue) appear only in the consistency checker — they are the only "loud" colors in the interface
- Background colors occupy 80%+ of visual field. The interface should feel predominantly cream/white.
- No gradients. No box-shadows heavier than `0 1px 3px rgba(0,0,0,0.06)`.

**Contrast ratios (against `--bg-primary: #FAF9F6`):**
- `--text-primary` (#1A1714): **15.2:1** — exceeds AAA
- `--text-secondary` (#6B6560): **4.8:1** — meets AA
- `--accent` (#8B4513): **6.7:1** — exceeds AA
- `--link` (#2D5A8E): **5.9:1** — exceeds AA
- `--flag-error` (#C4432B): **5.1:1** — meets AA

---

## Typography

**Font stack:**
```css
/* 80% — Editorial: content type */
--font-serif: 'Lora', 'Source Serif 4', 'Georgia', serif;

/* 80% — Editorial: body reading */
--font-body: 'Source Serif 4', 'Lora', 'Georgia', serif;

/* 20% — Minimal Tech: UI and functional text */
--font-sans: 'Inter', 'DM Sans', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;

/* 20% — Minimal Tech: metadata and data */
--font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;
```

| Level | Font | Size | Weight | Line Height | Letter Spacing | Use |
|-------|------|------|--------|-------------|----------------|-----|
| Display | Serif | 40px | 700 | 1.1 | -0.01em | Universe name on overview |
| H1 | Serif | 32px | 700 | 1.2 | -0.01em | Entry title ("Kael Ashward") |
| H2 | Serif | 24px | 600 | 1.25 | 0 | Section heading within entry |
| H3 | Serif | 20px | 600 | 1.3 | 0 | Subsection, card title |
| Body Large | Body | 18px | 400 | 1.7 | 0 | Entry body text — the reading experience |
| Body | Sans | 15px | 400 | 1.6 | 0 | UI text, sidebar, navigation |
| Body Small | Sans | 13px | 400 | 1.5 | 0 | Secondary UI labels |
| **Metadata** | **Mono** | **12px** | **400** | **1.4** | **0.02em** | **Tags, dates, entry IDs, consistency scores** |
| **Graph Label** | **Sans** | **12px** | **500** | **1.2** | **0** | **Node labels in knowledge graph** |
| Caption | Sans | 11px | 400 | 1.3 | 0.02em | Fine print, version numbers, word counts |

**Typography notes:**
- **Serif is king.** Lora for headings (warm, slightly calligraphic), Source Serif 4 for body text (optimized for screen reading at long lengths). Every entry reads like a page from a well-typeset book.
- Entry body text is 18px with 1.7 line height and 65ch max-width. This is the heart of the product — the reading experience must be excellent.
- **The 20% MT element:** Sans-serif (Inter) for all UI chrome — sidebar navigation, button labels, search, filters, form labels. The shift from serif (content) to sans (controls) visually separates "what you're reading" from "how you navigate."
- Monospace (JetBrains Mono) for metadata: entry IDs, tag lists, timestamps, consistency flag details, and structured data. Mono signals "system information" vs. serif's "authored content."
- **Never use serif for buttons or navigation.** Serif says "read this." Sans says "click this."

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Lora | Google Fonts | OFL | [Google Fonts](https://fonts.google.com/specimen/Lora) |
| Source Serif 4 | Google Fonts | OFL | [Google Fonts](https://fonts.google.com/specimen/Source+Serif+4) |
| Inter | Google Fonts | OFL | [Google Fonts](https://fonts.google.com/specimen/Inter) |
| JetBrains Mono | Google Fonts | OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) |

*All fonts are free and open-source.*

---

## Spacing & Layout

### Base Unit

8px base, following Minimal Tech's systematic scale:

```
4px   — Micro (inline gaps, icon-to-label)
8px   — XS (tight component padding)
12px  — SM (list item gaps)
16px  — MD (standard UI padding)
24px  — LG (section inner padding)
32px  — XL (card padding, between sections)
48px  — 2XL (between major sections)
64px  — 3XL (page-level top/bottom padding)
96px  — 4XL (hero/display spacing)
```

### Grid Specification

| Breakpoint | Columns | Gutter | Margin | Max Width | Notes |
|------------|---------|--------|--------|-----------|-------|
| Mobile (<768px) | 4 | 16px | 16px | 100% | Single column, full-width entries |
| Tablet (768-1024px) | 8 | 20px | 24px | 100% | Sidebar collapses to overlay |
| Desktop (1024-1440px) | 12 | 24px | 32px | 100% | Sidebar + main content |
| Wide (>1440px) | 12 | 24px | 64px | 1200px | Max-width constrains for readability |

### Layout Split: Content vs. System

**Editorial (80%)** — Entry detail, reading mode, universe overview:
- Centered content column with generous margins (`max-width: 65ch` for body text)
- Left-aligned headings breaking out of the column slightly for visual interest
- Generous vertical spacing between paragraphs (24px)
- Entry connections listed below content, styled as quiet links

**Minimal Tech (20%)** — Knowledge graph, consistency checker, search, generation controls:
- Systematic sidebar + workspace layout
- Dense information grids (filter rows, tag clouds, status tables)
- No max-width constraint — use available space
- 8px grid spacing enforced rigorously

```
┌────────────────────────────────────────────────────────────┐
│  ◊ KNOWLEDGE BASE                     [Search…]    [⊕]    │
├────────┬───────────────────────────────────────────────────┤
│        │                                                   │
│ SIDEBAR│  MAIN CONTENT AREA                                │
│ (Sans) │  (Serif for content, Sans for controls)           │
│        │                                                   │
│ ◊ Over │  ┌─ Entry Detail ─────────────────────────┐      │
│ 📋 List│  │                                        │      │
│ 📊 Graph│  │  Entry Title (Lora, 32px)              │      │
│ 📅 Time│  │                                        │      │
│ ✦ Gen  │  │  Body text in Source Serif 4 at 18px    │      │
│ ⚠ Flags│  │  with 1.7 line height and 65ch max     │      │
│        │  │  width. Generous margins. Links in      │      │
│ ──────── │  │  scholarly blue.                        │      │
│ ENTRIES│  │                                        │      │
│ Kael   │  │  Tags: protagonist · swordsmith         │      │
│ Thorn… │  │  (JetBrains Mono, 12px)                │      │
│ War of │  │                                        │      │
│ Iron T…│  │  Connections ────────────────────       │      │
│ Blacks…│  │  → Thornwall (location)                │      │
│        │  │  → Blacksmith Guild (faction)           │      │
│        │  └────────────────────────────────────────┘      │
│        │                                                   │
├────────┴───────────────────────────────────────────────────┤
│  Status bar: 247 entries · 3 flags · Last sync 2m ago      │
└────────────────────────────────────────────────────────────┘
```

### Border Radius

```css
--radius-none: 0;
--radius-sm: 4px;       /* Tags, small badges, inputs */
--radius-md: 8px;       /* Cards, panels, modals */
--radius-lg: 12px;      /* Large cards (universe selector) */
--radius-full: 9999px;  /* Pill badges (canon/generated indicator) */
```

---

## Component Styling

### Buttons

```css
/* Primary CTA — saddle brown, understated authority */
.btn-primary {
  background: var(--accent);
  color: #FFFFFF;
  font-family: var(--font-sans);
  font-size: 14px;
  font-weight: 600;
  padding: 10px 20px;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: background 200ms ease;
}
.btn-primary:hover {
  background: var(--accent-hover);
}
.btn-primary:active {
  transform: translateY(1px);
}
.btn-primary:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
.btn-primary:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
}

/* Secondary — bordered, quiet */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  font-family: var(--font-sans);
  font-size: 14px;
  font-weight: 500;
  padding: 9px 19px;
  border: 1px solid var(--border-default);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: border-color 200ms ease, background 200ms ease;
}
.btn-secondary:hover {
  border-color: var(--border-heavy);
  background: var(--bg-elevated);
}

/* Ghost — minimal text button */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  font-family: var(--font-sans);
  font-size: 14px;
  font-weight: 400;
  padding: 8px 12px;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: color 200ms ease;
}
.btn-ghost:hover {
  color: var(--text-primary);
}

/* Generate — special CTA for AI generation */
.btn-generate {
  background: var(--generated);
  color: #FFFFFF;
  font-family: var(--font-sans);
  font-size: 14px;
  font-weight: 600;
  padding: 10px 20px;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: background 200ms ease;
}
.btn-generate:hover {
  background: #7A6345;
}
```

### Form Inputs

```css
.input {
  background: var(--bg-surface);
  color: var(--text-primary);
  font-family: var(--font-sans);
  font-size: 15px;
  padding: 10px 14px;
  border: 1px solid var(--border-default);
  border-radius: var(--radius-sm);
  width: 100%;
  transition: border-color 200ms ease, box-shadow 200ms ease;
}
.input:focus {
  border-color: var(--link);
  box-shadow: 0 0 0 3px var(--focus-ring);
  outline: none;
}
.input::placeholder {
  color: var(--text-tertiary);
}
.input--error {
  border-color: var(--flag-error);
}
.input:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

/* Search bar — prominent, top of workspace */
.input-search {
  background: var(--bg-elevated);
  font-family: var(--font-sans);
  font-size: 15px;
  padding: 12px 16px 12px 40px; /* space for search icon */
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-md);
}
.input-search:focus {
  background: var(--bg-surface);
  border-color: var(--border-default);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

/* Generation prompt — editorial-styled textarea */
.textarea-generate {
  background: var(--bg-surface);
  color: var(--text-primary);
  font-family: var(--font-body);
  font-size: 16px;
  line-height: 1.6;
  padding: 16px;
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  resize: vertical;
  min-height: 100px;
}
```

### Cards

```css
/* Standard card — entry preview in list view */
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-md);
  padding: 24px;
  transition: border-color 200ms ease, box-shadow 200ms ease;
}
.card:hover {
  border-color: var(--border-default);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

/* Canon entry card — solid left border */
.card--canon {
  border-left: 3px solid var(--canon);
}

/* Generated entry card — dashed left border, sepia tint */
.card--generated {
  border-left: 3px dashed var(--generated);
}

/* Flagged entry card — subtle error background */
.card--flagged {
  border-left: 3px solid var(--flag-error);
  background: var(--flag-error-muted);
}

/* Universe card — larger, featured on dashboard */
.card-universe {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  padding: 32px;
  transition: transform 200ms ease, box-shadow 200ms ease;
}
.card-universe:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
}
```

### Navigation

```css
/* Left sidebar — book-spine aesthetic */
.sidebar {
  width: 240px;
  background: var(--bg-elevated);
  border-right: 1px solid var(--border-default);
  padding: 24px 0;
  font-family: var(--font-sans);
}
.nav-item {
  padding: 8px 20px;
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 400;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: color 200ms ease, background 200ms ease;
  text-decoration: none;
}
.nav-item:hover {
  color: var(--text-primary);
  background: rgba(139, 69, 19, 0.04);
}
.nav-item--active {
  color: var(--accent);
  background: var(--accent-muted);
  font-weight: 600;
}
.nav-section-label {
  padding: 8px 20px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-tertiary);
  margin-top: 16px;
}

/* Entry list in sidebar — entry names in serif */
.nav-entry {
  padding: 6px 20px 6px 32px;
  font-family: var(--font-serif);
  font-size: 14px;
  font-weight: 400;
  color: var(--text-secondary);
}
.nav-entry:hover {
  color: var(--text-primary);
}
.nav-entry--canon::before {
  content: '■';
  margin-right: 8px;
  font-size: 8px;
  color: var(--canon);
}
.nav-entry--generated::before {
  content: '□';
  margin-right: 8px;
  font-size: 8px;
  color: var(--generated);
}
```

### Knowledge-Base-Specific Components

#### Entry Status Badge

```css
.badge-status {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 10px;
  border-radius: var(--radius-full);
  font-family: var(--font-mono);
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 0.02em;
  text-transform: uppercase;
}
.badge-status--canon {
  background: var(--canon-muted);
  color: var(--canon);
  border: 1px solid rgba(26, 23, 20, 0.15);
}
.badge-status--generated {
  background: var(--generated-muted);
  color: var(--generated);
  border: 1px solid rgba(139, 115, 85, 0.2);
}
.badge-status--flagged {
  background: var(--flag-error-muted);
  color: var(--flag-error);
  border: 1px solid rgba(196, 67, 43, 0.2);
}
```

#### Entry Type Icon

```css
/* Entry type icons use a hand-drawn/woodcut aesthetic
   SVGs with slightly irregular lines, 1.5px stroke */
.entry-type-icon {
  width: 20px;
  height: 20px;
  color: var(--text-tertiary);
  stroke-width: 1.5;
}
/* Type-specific colors (subtle, not overwhelming) */
.entry-type-icon--character { color: var(--accent); }
.entry-type-icon--location { color: var(--success); }
.entry-type-icon--event { color: var(--flag-warn); }
.entry-type-icon--faction { color: var(--link); }
.entry-type-icon--object { color: var(--text-secondary); }
.entry-type-icon--concept { color: var(--link-visited); }
.entry-type-icon--rule { color: var(--text-primary); }
```

#### Inline Cross-Reference

```css
/* Hyperlinks between entries within body text */
.entry-ref {
  color: var(--link);
  text-decoration: none;
  border-bottom: 1px solid rgba(45, 90, 142, 0.3);
  transition: border-color 200ms ease;
}
.entry-ref:hover {
  border-color: var(--link);
}
.entry-ref:visited {
  color: var(--link-visited);
  border-color: rgba(91, 74, 138, 0.3);
}

/* Tooltip preview on hover (shows first 2 lines of linked entry) */
.entry-ref-tooltip {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  padding: 12px 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  max-width: 320px;
  font-family: var(--font-body);
  font-size: 14px;
  line-height: 1.5;
}
```

#### Consistency Flag

```css
.flag {
  display: flex;
  gap: 12px;
  padding: 16px;
  border-radius: var(--radius-md);
  font-family: var(--font-sans);
  font-size: 14px;
  line-height: 1.5;
}
.flag--error {
  background: var(--flag-error-muted);
  border-left: 3px solid var(--flag-error);
}
.flag--warning {
  background: var(--flag-warn-muted);
  border-left: 3px solid var(--flag-warn);
}
.flag--suggestion {
  background: var(--flag-suggestion-muted);
  border-left: 3px solid var(--flag-suggestion);
}
.flag__icon {
  flex-shrink: 0;
  width: 18px;
  height: 18px;
}
.flag__title {
  font-weight: 600;
  margin-bottom: 4px;
}
.flag__detail {
  color: var(--text-secondary);
  font-size: 13px;
}
.flag__actions {
  margin-top: 8px;
  display: flex;
  gap: 8px;
}
```

#### Knowledge Graph Node

```css
/* Graph nodes styled as marginalia — serif labels, subtle borders */
.graph-node {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  padding: 8px 14px;
  font-family: var(--font-serif);
  font-size: 13px;
  color: var(--text-primary);
  cursor: pointer;
  transition: border-color 200ms ease, box-shadow 200ms ease;
}
.graph-node:hover {
  border-color: var(--accent);
}
.graph-node--selected {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-muted);
}
.graph-node--canon {
  border-left: 3px solid var(--canon);
}
.graph-node--generated {
  border-left: 3px dashed var(--generated);
}
.graph-node--flagged {
  border-color: var(--flag-error);
}
.graph-node__type {
  font-family: var(--font-mono);
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-tertiary);
  margin-bottom: 2px;
}

/* Graph edges — dark ink lines */
.graph-edge {
  stroke: var(--border-heavy);
  stroke-width: 1;
  fill: none;
}
.graph-edge:hover {
  stroke: var(--accent);
  stroke-width: 1.5;
}
.graph-edge--highlighted {
  stroke: var(--link);
  stroke-width: 1.5;
}
```

#### Timeline Entry

```css
.timeline-item {
  display: flex;
  gap: 16px;
  padding: 16px 0;
  border-bottom: 1px solid var(--border-subtle);
}
.timeline-marker {
  width: 12px;
  height: 12px;
  border-radius: var(--radius-full);
  background: var(--accent);
  margin-top: 6px;
  flex-shrink: 0;
  position: relative;
}
.timeline-marker::after {
  content: '';
  position: absolute;
  top: 12px;
  left: 5px;
  width: 2px;
  height: calc(100% + 20px);
  background: var(--border-default);
}
.timeline-date {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-tertiary);
  min-width: 100px;
}
.timeline-title {
  font-family: var(--font-serif);
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
}
.timeline-summary {
  font-family: var(--font-body);
  font-size: 14px;
  color: var(--text-secondary);
  margin-top: 4px;
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing | Source |
|---------|--------|----------|--------|--------|
| Button hover | Background darken | 200ms | ease | Editorial |
| Button press | Subtle translateY(1px) | 100ms | ease | MT |
| Card hover | Border darken + light shadow | 200ms | ease | Editorial |
| Entry link hover | Underline opacity increase | 200ms | ease | Editorial |
| Entry open | Content fades up with 8px vertical shift | 250ms | ease-out | Editorial |
| Sidebar nav hover | Background tint | 200ms | ease | MT |
| Graph node hover | Border accent + connected edges highlight | 150ms | ease | MT |
| Graph zoom/pan | Transform | Continuous | ease-out | MT |
| Generation progress | Sepia text appears word-by-word (typewriter) | Variable, ~30ms/word | linear | Editorial |
| Promote to canon | Dashed border solidifies, sepia shifts to ink | 300ms | ease-in-out | Editorial |
| Consistency flag appear | Slide down from top of entry, 8px shift | 200ms | ease-out | MT |
| Search results load | Staggered fade-in, 30ms between items | 150ms per item | ease | MT |
| Entry link tooltip | Fade in on 300ms hover delay | 150ms | ease | Editorial |

**Motion philosophy:** Restrained and purposeful. The reading experience should feel *still* — no competing animations. Motion serves transitions between states (page loading, entry opening, canon promotion) and functional feedback (hover, focus). The one signature moment: when AI generation completes, text appears word-by-word in sepia, as if being written by an invisible scribe, before the user reviews and optionally promotes it to ink-black canon.

**Reduced motion:**
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
  /* Generation text appears instantly instead of typewriter */
  .generation-output { animation: none; }
}
```

---

## Asset Guidelines

**Visual motifs:**
- **Book/manuscript textures** — Warm cream tones throughout, never stark white. The product should feel like high-quality paper, not a screen.
- **Ink/woodcut iconography** — Entry type icons (Character, Location, Event, etc.) in a slightly hand-drawn style with 1.5px stroke weight. Think: marginalia illustrations, not clinical UI icons.
- **The knowledge graph** — Dark ink lines on warm background. Nodes as small rounded rectangles with serif labels. The graph should evoke a hand-drawn diagram in a scholar's notebook — systematic but warm.
- **Rule lines** — Thin horizontal rules (`--border-default`) to separate content sections within entries. Inspired by manuscript ruling lines.

**Iconography:**
- Lucide icons as base set (18px default, 1.5px stroke weight)
- Entry type icons may use custom SVGs matching Lucide's stroke style but with slightly organic lines
- Icons are always `--text-tertiary` or type-specific muted colors — never loud

**Illustration:** None in the app. The content (entry text, graph, timeline) is the visual interest. No decorative illustrations, no mascots, no hero images.

**Photography:** None. This is a text-first product.

**Logo:** "KNOWLEDGE BASE" in Lora at 700 weight, small caps, tracked at `0.08em`. Saddle brown on cream. The "◊" diamond character as a compact mark. Minimum clear space: 12px all sides.

---

## Mixing Notes

### Elements Carrying the 20% Minimal Tech Accent (5 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Knowledge graph view** | Editorial's content-flow layout → MT's systematic workspace with toolbar, filters, and zoom controls | The knowledge graph is a data visualization tool, not a reading surface. Users need precise node placement, zoom controls, filter dropdowns, and search — all requiring MT's systematic component patterns. Serif labels on nodes keep the editorial warmth while MT handles the chrome. |
| **Form inputs and controls** | (Editorial doesn't define forms) → MT input patterns with sans-serif type, focus rings, 4px radius | The generation prompt, search bar, tag editor, and entry metadata forms need functional, accessible controls. MT provides consistent focus states, error styling, and interaction patterns that editorial's typography-first approach doesn't cover. |
| **Sidebar navigation** | Editorial's minimal-chrome approach → MT's structured sidebar with sections, labels, and active states | Users need to navigate between entries, views (list/graph/timeline), and tools (generate, consistency check) efficiently. MT's sidebar pattern with section labels, hover states, and active indicators provides the information architecture. |
| **Consistency checker** | No editorial precedent → MT's systematic data display (flag cards, status badges, resolution queue) | The consistency checker is a technical feature — timeline conflicts, duplicate names, contradiction detection. It needs structured data presentation: severity levels, entry references, resolution buttons. This is fundamentally a MT surface wearing editorial colors. |
| **Metadata and structured data** | Serif for everything → Mono for tags, dates, IDs, entry counts, word counts | When viewing entry metadata (created date, word count, version number, tag list), monospace type signals "system data" clearly. It prevents confusion between authored content (serif) and system information (mono). |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| Dark mode option | The warm cream background is load-bearing for brand identity. "Library" and "paper" are the product's metaphors — dark mode would make it feel like a code editor, not a scholar's desk. |
| Bold Expressive accents (replacing brown with neon) | The product signals craftsmanship and authority, not energy. Neon colors would undermine the editorial calm. |
| Consumer Playful rounded corners (16px everywhere) | 16px radius would make the interface feel soft and toy-like. This product needs to feel like a serious tool for serious creative work. 4-8px radius is precise but not sharp. |
| All-serif UI text (including buttons and navigation) | Serif for buttons reads as "click to read," not "click to act." The sans/serif split is essential for distinguishing content from controls. |
| Heavy box shadows on cards | The editorial aesthetic relies on flat surfaces with subtle borders. Heavy shadows would add visual weight that competes with the content. |

---

## Implementation Checklist

- [ ] Lora (headings, 600-700) + Source Serif 4 (body, 400) + Inter (UI, 400-600) + JetBrains Mono (metadata, 400)
- [ ] Entry body text: 18px, 1.7 line height, 65ch max-width — the reading experience
- [ ] Warm cream `#FAF9F6` background — never pure white
- [ ] Canon entries: solid 3px left border in `--canon`
- [ ] Generated entries: dashed 3px left border in `--generated`
- [ ] All entry cross-references are hyperlinked with scholarly blue
- [ ] Consistency flags use appropriate severity color (red/goldenrod/blue)
- [ ] Knowledge graph nodes use serif labels with MT-styled chrome
- [ ] All interactive elements have visible focus rings (`--focus-ring`)
- [ ] All buttons and navigation use sans-serif (never serif for controls)
- [ ] Metadata (tags, dates, IDs) uses monospace
- [ ] No box-shadows heavier than `0 2px 8px rgba(0,0,0,0.06)`
- [ ] Generation typewriter animation respects `prefers-reduced-motion`
- [ ] Color contrast: all text meets WCAG AA minimum
- [ ] Touch targets: minimum 44px for all interactive elements
- [ ] Light mode only — no theme toggle

---

*Derived from: editorial.md + minimal-tech.md*
*Project: NOIZUAI-4 — Knowledge Base (library.therobotlives.com)*
