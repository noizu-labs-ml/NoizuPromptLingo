# Style Guide: Gotta.cc — Direction B: Warm Browse

> An AI-curated web directory that feels like stepping into a beautifully organized indie bookstore — someone with great taste arranged everything, and you feel welcome to explore.

**Style System:** Editorial 80% + Consumer Playful 20%
**Source Specs:** [editorial.md](../../../skills/user-experience-engineer/references/styles/editorial.md) + [consumer-playful.md](../../../skills/user-experience-engineer/references/styles/consumer-playful.md)
**Scenario:** Full-product design system for an AI-curated website directory
**One-liner:** "Someone smart picked these for you."

---

## Table of Contents

- [Scenario](#scenario)
- [Color Palette](#color-palette)
- [Typography](#typography)
- [Spacing & Layout](#spacing--layout)
- [Component Styling](#component-styling)
  - [Navigation](#navigation)
  - [Category Browser](#category-browser--bento-grid)
  - [Site Listing Card](#site-listing-card)
  - [Quality Score Badge](#quality-score-badge)
  - [Score Breakdown](#score-breakdown)
  - [Search](#search)
  - [Buttons](#buttons)
  - [Form Inputs](#form-inputs)
  - [Tags & Pills](#tags--pills)
  - [Collections & Lists](#collections--lists)
  - [Surprise Me](#surprise-me)
  - [Submission Flow](#submission-flow)
  - [Empty States](#empty-states)
- [Interaction & Motion](#interaction--motion)
- [Asset Guidelines](#asset-guidelines)
- [Dark Mode](#dark-mode)
- [Mixing Notes](#mixing-notes)
- [Directory-Specific Patterns](#directory-specific-patterns)
- [Implementation Checklist](#implementation-checklist)

---

## Scenario

Gotta.cc is **"The Yahoo Directory for the post-slop web"** — an AI-curated website directory that combines human-browsable categories with AI quality scoring, editorial summaries, and discovery tools. Every listed site is scored across five dimensions: originality, depth, freshness, human authorship, and design quality. The web is big again — gotta.cc helps you find the good parts.

The design must send two signals simultaneously. First, **authority and curation** — this directory has editorial standards. Sites are scored, summaries are opinionated, categories are carefully maintained. Users need to trust that the quality bar is real. Second, **warmth and discovery** — browsing the directory should feel like exploration, not research. The category grid should invite clicking. The "Surprise Me" button should feel like a gift. Finding a great site should feel like a recommendation from a friend with good taste.

**Why Editorial 80% + Consumer Playful 20%:** A pure Editorial directory would feel like a library catalog — authoritative but cold, browsable but uninviting. The summaries would read well but nobody would click "Surprise Me." A pure Playful directory would feel like a toy — colorful and clickable but lacking the credibility that makes quality scores trustworthy. The 80/20 mix gives us a typographic foundation (serif summaries, generous reading space, restrained color) softened with five specific Playful elements that add warmth to the browsing experience without undermining editorial authority.

**Signals:** Warmth, curation, approachability, discovery, human touch.
**Anti-signals:** Clinical, corporate, gamified, cluttered, SEO-optimized.

---

## Color Palette

### CSS Custom Properties

```css
:root {
  /* ─── 80% Editorial Foundation ─── */
  --bg-primary: #FFFCF7;           /* warm cream — the page itself */
  --bg-surface: #FFFFFF;           /* white — cards and elevated surfaces */
  --bg-sunken: #F8F5F0;           /* slightly darker cream — code blocks, inset areas */

  --text-primary: #1A1A1A;        /* near-black — headlines, body text */
  --text-secondary: #666666;      /* medium gray — summaries, metadata */
  --text-tertiary: #999999;       /* light gray — timestamps, placeholders */

  --border-default: #E5E0D8;      /* warm gray — card borders, dividers */
  --border-rule: #D4CFC6;         /* slightly darker — horizontal rules */

  /* Editorial accent — Deep Olive Green (authority, nature, curation) */
  --accent: #4A6741;              /* primary editorial accent */
  --accent-hover: #3D5636;        /* darkened on hover */
  --accent-light: #EDF2EC;        /* olive tint for backgrounds */
  --accent-rgb: 74, 103, 65;

  /* ─── 20% Consumer Playful Warmth ─── */
  --warm: #E8704A;                /* warm coral — CTAs, scores, discovery */
  --warm-hover: #D4603D;          /* darkened on hover */
  --warm-light: #FFF0EB;          /* coral tint for hover states, backgrounds */
  --warm-rgb: 232, 112, 74;

  /* ─── Semantic ─── */
  --success: #4A6741;             /* olive green — aligns with editorial accent */
  --warning: #D4A528;             /* warm amber */
  --error: #C44030;               /* muted red */
  --info: #4A7FB5;                /* steel blue */

  /* ─── Category Accent Colors (muted jewel tones) ─── */
  --cat-technology: #3B7A8C;      /* muted teal */
  --cat-culture: #B8860B;         /* dark goldenrod / amber */
  --cat-science: #6B8E6B;         /* sage */
  --cat-making: #A0522D;          /* sienna */
  --cat-games: #7B68AE;           /* muted purple */
  --cat-weird: #C97B84;           /* dusty rose */
  --cat-reference: #5F7A8E;       /* slate blue */
  --cat-community: #8B7355;       /* warm taupe */

  /* ─── Score Colors ─── */
  --score-high: #E8704A;          /* coral — 90+ scores */
  --score-medium: #4A6741;        /* olive — 70-89 scores */
  --score-low: #999999;           /* muted — 60-69 scores */
}
```

### Palette Diagram

```
┌───────────────────────────────────────────────────────────────┐
│  GOTTA.CC — DIRECTION B: WARM BROWSE                         │
│  Editorial 80% + Consumer Playful 20%                        │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  BACKGROUNDS                                                  │
│  ██████  #FFFCF7   Warm Cream (page)                         │
│  ██████  #FFFFFF   White (cards)                              │
│  ██████  #F8F5F0   Sunken Cream (inset)                      │
│                                                               │
│  TEXT                                                          │
│  ██████  #1A1A1A   Near-Black (primary)                      │
│  ██████  #666666   Medium Gray (secondary)                   │
│  ██████  #999999   Light Gray (tertiary)                     │
│                                                               │
│  EDITORIAL ACCENT (80%)                                       │
│  ██████  #4A6741   Deep Olive Green (links, categories)      │
│  ██████  #3D5636   Olive Hover                               │
│  ██████  #EDF2EC   Olive Tint (backgrounds)                  │
│                                                               │
│  PLAYFUL WARMTH (20%)                                         │
│  ██████  #E8704A   Warm Coral (CTAs, scores, discovery)      │
│  ██████  #D4603D   Coral Hover                               │
│  ██████  #FFF0EB   Coral Tint (hover states)                 │
│                                                               │
│  BORDERS                                                      │
│  ██████  #E5E0D8   Default Border                            │
│  ██████  #D4CFC6   Rule / Divider                            │
│                                                               │
│  CATEGORY JEWEL TONES                                         │
│  ██████  #3B7A8C   Technology (muted teal)                   │
│  ██████  #B8860B   Culture (amber)                           │
│  ██████  #6B8E6B   Science (sage)                            │
│  ██████  #A0522D   Making & Crafts (sienna)                  │
│  ██████  #7B68AE   Games (muted purple)                      │
│  ██████  #C97B84   Weird & Wonderful (dusty rose)            │
│  ██████  #5F7A8E   Reference (slate blue)                    │
│  ██████  #8B7355   Community (warm taupe)                    │
│                                                               │
│  SEMANTIC                                                     │
│  ██████  #4A6741   Success (olive)                           │
│  ██████  #D4A528   Warning (amber)                           │
│  ██████  #C44030   Error (muted red)                         │
│  ██████  #4A7FB5   Info (steel blue)                         │
│                                                               │
│  SCORE BADGES                                                 │
│  ██████  #E8704A   High (90-100) — coral filled              │
│  ██████  #4A6741   Medium (70-89) — olive filled             │
│  ██████  #999999   Low (60-69) — muted filled                │
│                                                               │
│  Olive says "quality."                                        │
│  Coral says "discover."                                       │
│  Together: "Someone smart picked these for you."             │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Color Usage Rules

- **Olive green** appears on: content links, category labels, section markers, secondary buttons, medium score badges, tag borders — these are the editorial, informational elements
- **Warm coral** appears ONLY on: primary CTAs, score badges (90+), the "Surprise Me" button, interactive focus rings, and "discovery" moments — these are the action and delight elements
- **Category jewel tones** appear ONLY as soft background tints on category cards (at ~10% opacity) and as thin accent bars — never as text color, never at full saturation
- **Warm cream background** is the page ground, never pure white. Cards are #FFFFFF to lift off the cream
- **Contrast ratios:**
  - `#1A1A1A` on `#FFFCF7` = 15.4:1 (exceeds WCAG AAA)
  - `#666666` on `#FFFCF7` = 5.7:1 (exceeds WCAG AA)
  - `#FFFFFF` on `#E8704A` = 3.3:1 (AA for large text — coral buttons use 16px+ bold, qualifies)
  - `#FFFFFF` on `#4A6741` = 5.2:1 (exceeds WCAG AA)

---

## Typography

### Font Stack

```css
:root {
  /* Display — Fraunces variable serif (Google Fonts)
     The Playful influence on headline font: personality + authority.
     Variable serif with optical sizing, soft terminals, warm character.
     Used for: page titles, site listing titles, collection names. */
  --font-display: 'Fraunces', Georgia, 'Times New Roman', serif;

  /* Body — Source Serif 4 (Google Fonts)
     Clean editorial reading serif. Optimized for screen.
     Used for: site summaries, editorial descriptions, body text. */
  --font-body: 'Source Serif 4', 'Source Serif Pro', Georgia, serif;

  /* UI — Plus Jakarta Sans (Google Fonts)
     The Playful influence on UI font: warmer than Inter, contemporary.
     Friendly geometric sans with open forms.
     Used for: navigation, buttons, labels, metadata, scores, tags. */
  --font-ui: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont,
             'Segoe UI', system-ui, sans-serif;

  /* Monospace — for URLs and technical metadata */
  --font-mono: 'JetBrains Mono', 'SF Mono', 'Cascadia Code',
               'Fira Code', monospace;
}
```

### Type Scale

```
┌───────────────────────────────────────────────────────────────────────────┐
│  GOTTA.CC TYPE SCALE                                                     │
├──────────┬──────┬─────────┬───────┬─────────────┬────────────────────────┤
│ Level    │ Size │ Weight  │ LH    │ Font        │ Use                    │
├──────────┼──────┼─────────┼───────┼─────────────┼────────────────────────┤
│ Display  │ 56px │ 400-700 │ 1.15  │ Fraunces    │ Homepage hero          │
│ H1       │ 40px │ 600     │ 1.2   │ Fraunces    │ Category page titles   │
│ H2       │ 32px │ 600     │ 1.25  │ Fraunces    │ Section headings       │
│ H3       │ 24px │ 500     │ 1.3   │ Fraunces    │ Site listing titles    │
│ H4       │ 20px │ 500     │ 1.35  │ Fraunces    │ Collection names       │
│ Body LG  │ 18px │ 400     │ 1.75  │ Source Sf 4 │ Lead summaries         │
│ Body     │ 16px │ 400     │ 1.75  │ Source Sf 4 │ Site summaries         │
│ Body ALT │ 16px │ 500     │ 1.6   │ Jakarta     │ UI descriptions        │
│ Small    │ 14px │ 500     │ 1.5   │ Jakarta     │ Nav links, metadata    │
│ Caption  │ 12px │ 600     │ 1.4   │ Jakarta     │ Overlines, timestamps  │
│ Overline │ 11px │ 700     │ 1.3   │ Jakarta     │ Category labels (caps) │
│ URL      │ 14px │ 400     │ 1.4   │ JetBrains   │ Site URLs              │
│ Score    │ 24px │ 700     │ 1.0   │ Fraunces    │ Score number in badge  │
│ Score SM │ 11px │ 500     │ 1.0   │ Jakarta     │ "/100" subscript       │
└──────────┴──────┴─────────┴───────┴─────────────┴────────────────────────┘
```

### Type Scale CSS

```css
.display  { font: 400 56px/1.15 var(--font-display); }
.h1       { font: 600 40px/1.2  var(--font-display); }
.h2       { font: 600 32px/1.25 var(--font-display); }
.h3       { font: 500 24px/1.3  var(--font-display); }
.h4       { font: 500 20px/1.35 var(--font-display); }
.body-lg  { font: 400 18px/1.75 var(--font-body); }
.body     { font: 400 16px/1.75 var(--font-body); }
.body-ui  { font: 500 16px/1.6  var(--font-ui); }
.small    { font: 500 14px/1.5  var(--font-ui); }
.caption  { font: 600 12px/1.4  var(--font-ui); }
.overline {
  font: 700 11px/1.3 var(--font-ui);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}
.url      { font: 400 14px/1.4 var(--font-mono); }
```

### Typography Rules

- Body text (site summaries) at 16-18px minimum in Source Serif 4 — this is a reading experience
- Line height 1.75 for body text (Editorial convention — generous for readability)
- Reading measure: `max-width: 65ch` for summaries and editorial text
- Fraunces headlines use variable `WONK` and `SOFT` axes — set `font-variation-settings: 'WONK' 1, 'SOFT' 0` for headlines to activate the "wonky" serifs that give it personality
- Plus Jakarta Sans for all chrome: navigation, buttons, labels, tags, metadata — warmer than Inter, the Playful influence on UI typography
- Category overlines: 11px uppercase Jakarta Sans with 0.08em letter-spacing
- Score numbers: 24px Fraunces bold inside the coral badge
- URLs displayed in JetBrains Mono for clarity

### Responsive Type Scale

```css
/* Mobile-first: tighten the scale */
@media (max-width: 768px) {
  .display  { font-size: 36px; line-height: 1.2; }
  .h1       { font-size: 28px; }
  .h2       { font-size: 24px; }
  .h3       { font-size: 20px; }
  .body-lg  { font-size: 17px; }
  .body     { font-size: 16px; }
}

/* Fluid alternative using clamp() */
.display-fluid {
  font-size: clamp(36px, 5vw + 1rem, 56px);
  line-height: 1.15;
}
```

### Font Sources

| Font | Primary Source | License | Link(s) |
|------|--------------|---------|---------|
| Fraunces | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Fraunces) |
| Source Serif 4 | Adobe Fonts (Adobe original) | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/source-serif) \| [Google Fonts](https://fonts.google.com/specimen/Source+Serif+4) |
| Plus Jakarta Sans | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Plus+Jakarta+Sans) \| [Fontshare](https://www.fontshare.com/fonts/plus-jakarta-sans) |
| JetBrains Mono | JetBrains | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) \| [JetBrains](https://www.jetbrains.com/lp/mono/) |

All four fonts are free and open-source (SIL Open Font License). No paid alternatives needed. Self-hosting recommended for performance — load only the weights used:

```html
<!-- Google Fonts preconnect + load -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400;0,9..144,500;0,9..144,600;0,9..144,700;1,9..144,400&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;1,8..60,400&family=Plus+Jakarta+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400&display=swap" rel="stylesheet">
```

**Performance note:** Fraunces is a variable font (~130KB). Use `font-display: swap` to prevent FOIT. Consider subsetting to Latin characters only if serving primarily English content.

---

## Spacing & Layout

### Spacing Scale

```
┌──────────────────────────────────────────────────────────────┐
│  SPACING SCALE                                                │
├──────┬──────────────────────────────────────────────────────┤
│  8px │ ██                        Micro (icon gaps, inline)   │
│ 12px │ ███                       Tight (related metadata)    │
│ 16px │ ████                      Base (form gaps, list items)│
│ 24px │ ██████                    Medium (card padding, gutter│
│ 32px │ ████████                  Large (section subspacing)  │
│ 48px │ ████████████              XL (between components)     │
│ 64px │ ████████████████          2XL (major section breaks)  │
│ 80px │ ████████████████████      3XL (page section padding)  │
│120px │ ██████████████████████████ 4XL (hero, chapter breaks) │
└──────┴──────────────────────────────────────────────────────┘
```

Generous but slightly tighter than pure Editorial — more content visible per viewport. This is a directory, not a magazine: users need to scan listings, not linger on paragraphs. The 80/20 mix means Editorial's breathing room is preserved but density is increased slightly for browsability.

### Grid Specification

```
┌──────────────────────────────────────────────────────────────┐
│  GRID SYSTEM                                                  │
├──────────────┬────────┬─────────┬────────┬───────────────────┤
│ Breakpoint   │ Cols   │ Gutters │ Margin │ Max Width         │
├──────────────┼────────┼─────────┼────────┼───────────────────┤
│ Mobile       │ 4      │ 16px    │ 16px   │ 100%              │
│ < 640px      │        │         │        │                   │
├──────────────┼────────┼─────────┼────────┼───────────────────┤
│ Tablet       │ 8      │ 20px    │ 32px   │ 100%              │
│ 640-1024px   │        │         │        │                   │
├──────────────┼────────┼─────────┼────────┼───────────────────┤
│ Desktop      │ 12     │ 24px    │ 48px   │ 960px             │
│ 1024-1280px  │        │         │        │                   │
├──────────────┼────────┼─────────┼────────┼───────────────────┤
│ Wide         │ 12     │ 24px    │ auto   │ 1120px            │
│ > 1280px     │        │         │        │                   │
└──────────────┴────────┴─────────┴────────┴───────────────────┘
```

### Layout Zones

```
┌──────────────────────────────────────────────────────────────┐
│  LAYOUT ZONES                                                 │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Navigation bar ──────────────── 960px max, centered          │
│  Hero / Featured ─────────────── 960px max, centered          │
│  Category bento grid ─────────── 960px max, 24px gutters      │
│  Category page listings ──────── 720px max (reading width)    │
│  Site detail / summary text ──── 65ch max (editorial measure) │
│  Search results ──────────────── 720px max                    │
│  Collections ─────────────────── 960px max                    │
│  Submission form ─────────────── 560px max, centered          │
│  Footer ──────────────────────── 960px max                    │
│                                                               │
│  Sidebar (optional) ─────────── 280px fixed, right side       │
│  Used for: score breakdown, related categories, tags          │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Section Spacing

| Section Transition | Spacing | Notes |
|---|---|---|
| Hero to category grid | 80px | Major visual break |
| Between category rows | 24px | Tight grid — Playful bento influence |
| Category grid to collections | 64px | Section break |
| Between site listing cards | 32px | Scannable spacing |
| Site card internal sections | 16px | Compact but readable |
| Between collection items | 24px | List spacing |
| Form field to field | 24px | Comfortable input spacing |

---

## Component Styling

### Navigation

```
┌──────────────────────────────────────────────────────────────┐
│  gotta.cc              Browse  Search  Submit  Collections   │
│  ─────────────────────────────────────────────────────────── │
└──────────────────────────────────────────────────────────────┘
  ↑ Fraunces 24px       ↑ Jakarta Sans 14px, 600
  ↑ height: 64px        ↑ bottom border: 1px #E5E0D8
```

```css
/* ─── Desktop Navigation ─── */
.nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 64px;
  max-width: 960px;
  margin: 0 auto;
  padding: 0 24px;
  border-bottom: 1px solid var(--border-default);
  background: var(--bg-primary);
}

.nav__logo {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 700;
  color: var(--text-primary);
  text-decoration: none;
  font-variation-settings: 'WONK' 1;
}

.nav__links {
  display: flex;
  gap: 32px;
  align-items: center;
}

.nav__link {
  font-family: var(--font-ui);
  font-size: 14px;
  font-weight: 600;
  color: var(--text-secondary);
  text-decoration: none;
  transition: color 200ms ease;
}
.nav__link:hover {
  color: var(--text-primary);
}
.nav__link--active {
  color: var(--text-primary);
  border-bottom: 2px solid var(--accent);
  padding-bottom: 2px;
}

/* Submit button in nav — uses coral (Playful) */
.nav__submit-btn {
  font-family: var(--font-ui);
  font-size: 14px;
  font-weight: 600;
  color: #FFFFFF;
  background: var(--warm);
  border: none;
  border-radius: 12px;  /* Playful radius */
  padding: 8px 20px;
  cursor: pointer;
  transition: background 200ms ease, transform 150ms ease;
}
.nav__submit-btn:hover {
  background: var(--warm-hover);
  transform: translateY(-1px);
}
.nav__submit-btn:active {
  transform: translateY(0);
}
.nav__submit-btn:focus-visible {
  outline: 2px solid var(--warm);
  outline-offset: 2px;
}

/* ─── Mobile Navigation: Bottom Tab Bar (Playful influence) ─── */
@media (max-width: 768px) {
  .nav {
    display: none;  /* Hide desktop nav */
  }

  .nav-mobile-header {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 56px;
    border-bottom: 1px solid var(--border-default);
    background: var(--bg-primary);
  }
  .nav-mobile-header__logo {
    font-family: var(--font-display);
    font-size: 20px;
    font-weight: 700;
    color: var(--text-primary);
  }

  .tab-bar {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    display: flex;
    justify-content: space-around;
    align-items: center;
    height: 64px;
    background: var(--bg-surface);
    border-top: 1px solid var(--border-default);
    padding-bottom: env(safe-area-inset-bottom);
    z-index: 100;
  }
  .tab-bar__item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    font-family: var(--font-ui);
    font-size: 11px;
    font-weight: 500;
    color: var(--text-tertiary);
    text-decoration: none;
    padding: 8px 16px;
    -webkit-tap-highlight-color: transparent;
  }
  .tab-bar__item--active {
    color: var(--warm);  /* Coral for active tab — Playful accent */
  }
  .tab-bar__icon {
    width: 24px;
    height: 24px;
  }
}
```

### Category Browser / Bento Grid

The homepage category grid is the primary entry point. Bento-style layout is a Playful influence — each category gets a soft jewel-tone background tint and rounded corners.

```
┌──────────────────────────────────────────────────────────────┐
│  HOMEPAGE CATEGORY BENTO GRID                                 │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────┐  ┌────────────┐                 │
│  │  Technology             │  │  Culture   │                 │
│  │  ████████████████████   │  │  ████████  │                 │
│  │  247 sites              │  │  189 sites │                 │
│  │  ── Featured ─────────  │  │            │                 │
│  │  uses-this.com  94/100  │  │            │                 │
│  └─────────────────────────┘  └────────────┘                 │
│                                                               │
│  ┌────────────┐  ┌────────────┐  ┌─────────────────────────┐ │
│  │  Science   │  │  Making    │  │  Games                  │ │
│  │  ████████  │  │  ████████  │  │  ████████████████████   │ │
│  │  156 sites │  │  98 sites  │  │  134 sites              │ │
│  └────────────┘  └────────────┘  └─────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────┐  ┌────────────┐                 │
│  │  Weird & Wonderful      │  │  Reference │                 │
│  │  ████████████████████   │  │  ████████  │                 │
│  │  73 sites               │  │  211 sites │                 │
│  └─────────────────────────┘  └────────────┘                 │
│                                                               │
│  Each card: jewel-tone tinted background, rounded corners    │
│  Category name in Fraunces, site count in Jakarta Sans       │
│  Subcategory pills below on hover/expand                     │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

```css
/* ─── Bento Grid Container ─── */
.category-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  max-width: 960px;
  margin: 0 auto;
  padding: 0 24px;
}

@media (max-width: 768px) {
  .category-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    padding: 0 16px;
  }
}
@media (max-width: 480px) {
  .category-grid {
    grid-template-columns: 1fr;
  }
}

/* ─── Bento sizing ─── */
.category-card--2x1 { grid-column: span 2; }
.category-card--1x2 { grid-row: span 2; }
.category-card--2x2 { grid-column: span 2; grid-row: span 2; }

/* ─── Category Card ─── */
.category-card {
  position: relative;
  padding: 32px;
  border-radius: 16px;              /* Playful: rounded corners */
  overflow: hidden;
  cursor: pointer;
  transition:
    transform 200ms ease,
    box-shadow 200ms ease;
  text-decoration: none;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 180px;
}

/* Category-specific background tints (Playful: multi-color) */
.category-card--technology  { background: #E8F2F4; color: #1A3A44; }
.category-card--culture     { background: #F5EDD6; color: #5C4300; }
.category-card--science     { background: #E8F0E8; color: #2D4A2D; }
.category-card--making      { background: #F2E6DD; color: #5C2E15; }
.category-card--games       { background: #EDEAF5; color: #3D3460; }
.category-card--weird       { background: #F5E8EA; color: #5C3038; }
.category-card--reference   { background: #E8EDF2; color: #2E3D4A; }
.category-card--community   { background: #F0EAE0; color: #4A3D28; }

.category-card:hover {
  transform: scale(1.02);           /* Playful: subtle scale on hover */
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}
.category-card:focus-visible {
  outline: 2px solid var(--warm);
  outline-offset: 2px;
}

.category-card__name {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 600;
  line-height: 1.2;
  margin-bottom: 8px;
}

.category-card__count {
  font-family: var(--font-ui);
  font-size: 14px;
  font-weight: 500;
  opacity: 0.7;
}

/* Featured pick inside large category cards */
.category-card__featured {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid rgba(0, 0, 0, 0.1);
}
.category-card__featured-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--warm);           /* Coral dot for featured picks */
  flex-shrink: 0;
}
.category-card__featured-name {
  font-family: var(--font-ui);
  font-size: 13px;
  font-weight: 500;
}
.category-card__featured-score {
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 700;
  color: var(--warm);
  margin-left: auto;
}

/* ─── Subcategory Pills ─── */
.subcategory-pills {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}
.subcategory-pill {
  font-family: var(--font-ui);
  font-size: 12px;
  font-weight: 500;
  padding: 4px 12px;
  border-radius: 12px;               /* Playful: rounded pill shape */
  background: rgba(255, 255, 255, 0.6);
  color: inherit;
  text-decoration: none;
  transition: background 150ms ease;
}
.subcategory-pill:hover {
  background: rgba(255, 255, 255, 0.9);
}
```

### Site Listing Card

The core unit of the directory. Each card displays a scored, summarized website listing.

```
┌──────────────────────────────────────────────────────────────┐
│  SITE LISTING CARD                                            │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌───────────────────────────────────────────────────────┐   │
│  │                                                       │   │
│  │  TECHNOLOGY / DEVELOPER TOOLS          ┌──────┐       │   │
│  │                                        │  94  │       │   │
│  │  Uses This                             │ /100 │       │   │
│  │                                        └──────┘       │   │
│  │  Interviews with creative people about the            │   │
│  │  hardware, software, and tools they use to get        │   │
│  │  their work done. Running since 2009. Focused,        │   │
│  │  niche, lovingly maintained.                          │   │
│  │                                                       │   │
│  │  uses-this.com                                        │   │
│  │                                                       │   │
│  │  ┌─ Originality ─────────────── ██████████░░ 96 ┐    │   │
│  │  ├─ Depth ───────────────────── █████████░░░ 91 ┤    │   │
│  │  ├─ Freshness ───────────────── ████████░░░░ 88 ┤    │   │
│  │  ├─ Human Authorship ────────── ██████████░░ 99 ┤    │   │
│  │  └─ Design Quality ──────────── █████████░░░ 92 ┘    │   │
│  │                                                       │   │
│  │  [interviews] [tools] [creative] [indie-web]          │   │
│  │                                                       │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                               │
│  White card, 16px radius (Playful), hover: lift + shadow     │
│  Category overline: Jakarta Sans uppercase olive             │
│  Title: Fraunces H3                                          │
│  Summary: Source Serif 4 body                                │
│  Score: Coral circle badge (Playful)                         │
│  Tags: Rounded pills with olive border                       │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

```css
/* ─── Site Listing Card ─── */
.site-card {
  background: var(--bg-surface);
  border-radius: 16px;                /* Playful: rounded corners */
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition:
    transform 200ms ease,
    box-shadow 200ms ease;
  position: relative;
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 16px;
}

/* Hover: lift + shadow (Playful micro-interaction, element #4) */
.site-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}
.site-card:focus-within {
  outline: 2px solid var(--warm);
  outline-offset: 2px;
}

/* ── Category Overline ── */
.site-card__category {
  font-family: var(--font-ui);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--accent);              /* Olive green — editorial */
  margin-bottom: 8px;
  grid-column: 1;
}
.site-card__category a {
  color: inherit;
  text-decoration: none;
}
.site-card__category a:hover {
  text-decoration: underline;
  text-underline-offset: 3px;
}

/* ── Title ── */
.site-card__title {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 500;
  line-height: 1.3;
  color: var(--text-primary);
  margin-bottom: 8px;
  grid-column: 1;
}
.site-card__title a {
  color: inherit;
  text-decoration: none;
}
.site-card__title a:hover {
  color: var(--accent);
}

/* ── Summary ── */
.site-card__summary {
  font-family: var(--font-body);
  font-size: 16px;
  font-weight: 400;
  line-height: 1.75;
  color: var(--text-secondary);
  max-width: 55ch;                   /* Slightly narrower than full measure */
  grid-column: 1;

  /* Clamp to 3 lines */
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* ── URL ── */
.site-card__url {
  font-family: var(--font-mono);
  font-size: 14px;
  color: var(--text-tertiary);
  margin-top: 8px;
  grid-column: 1;
}
.site-card__url a {
  color: var(--accent);
  text-decoration: none;
}
.site-card__url a:hover {
  text-decoration: underline;
}

/* ── Screenshot Thumbnail (optional) ── */
.site-card__screenshot {
  width: 100%;
  max-width: 200px;
  aspect-ratio: 16 / 10;
  border-radius: 8px;                /* Rounded corners — Playful */
  object-fit: cover;
  border: 1px solid var(--border-default);
  margin-top: 16px;
  grid-column: 1;
}

/* ── Score Breakdown ── */
.site-card__scores {
  margin-top: 16px;
  grid-column: 1;
}

/* ── Tags ── */
.site-card__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
  grid-column: 1;
}

/* ── Metadata Row ── */
.site-card__meta {
  display: flex;
  gap: 16px;
  margin-top: 12px;
  grid-column: 1;
}
.site-card__meta-item {
  font-family: var(--font-ui);
  font-size: 12px;
  color: var(--text-tertiary);
}

/* ── Editor's Pick Badge ── */
.site-card--editors-pick {
  border: 2px solid var(--warm);
}
.site-card__editors-badge {
  position: absolute;
  top: -1px;
  right: 24px;
  background: var(--warm);
  color: #FFFFFF;
  font-family: var(--font-ui);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 4px 12px 6px;
  border-radius: 0 0 8px 8px;
}

/* ── Compact Variant (for list view) ── */
.site-card--compact {
  padding: 16px 24px;
  grid-template-columns: 1fr auto;
  align-items: center;
  border-radius: 12px;
}
.site-card--compact .site-card__summary {
  -webkit-line-clamp: 1;
  font-size: 14px;
}
.site-card--compact .site-card__scores,
.site-card--compact .site-card__screenshot {
  display: none;
}
```

### Quality Score Badge

```
┌──────────────────────────────────────────────────────────────┐
│  SCORE BADGE VARIANTS                                         │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│   High (90+)       Medium (70-89)     Low (60-69)            │
│  ┌─────────┐      ┌─────────┐       ┌─────────┐             │
│  │  coral   │      │  olive  │       │  gray   │             │
│  │   94     │      │   78    │       │   63    │             │
│  │  /100    │      │  /100   │       │  /100   │             │
│  └─────────┘      └─────────┘       └─────────┘             │
│                                                               │
│  56px diameter circle, white text                            │
│  Score number: Fraunces 24px bold                            │
│  "/100": Jakarta Sans 11px                                   │
│  Editor's Pick (90+): adds ✦ star below                      │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

```css
/* ─── Quality Score Badge ─── */
/* Playful element #2: coral-filled rounded badge instead of plain text */
.score-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  color: #FFFFFF;
  grid-column: 2;
  grid-row: 1 / 4;        /* Span across category, title, summary rows */
  align-self: start;
  flex-shrink: 0;
}

/* Score color by range */
.score-badge--high {
  background: var(--score-high);     /* Coral — 90+ */
}
.score-badge--medium {
  background: var(--score-medium);   /* Olive — 70-89 */
}
.score-badge--low {
  background: var(--score-low);      /* Muted gray — 60-69 */
}

.score-badge__number {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 700;
  line-height: 1;
}
.score-badge__label {
  font-family: var(--font-ui);
  font-size: 10px;
  font-weight: 500;
  opacity: 0.85;
  line-height: 1;
  margin-top: 1px;
}

/* Editor's Pick star */
.score-badge--editors-pick::after {
  content: '✦';
  display: block;
  font-size: 12px;
  margin-top: 4px;
  color: var(--warm);
}

/* ── Large Score Badge (site detail page) ── */
.score-badge--lg {
  width: 80px;
  height: 80px;
}
.score-badge--lg .score-badge__number {
  font-size: 32px;
}
.score-badge--lg .score-badge__label {
  font-size: 12px;
}
```

### Score Breakdown

```css
/* ─── Score Breakdown: 5 horizontal bars ─── */
.score-breakdown {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 16px;
}

.score-bar {
  display: grid;
  grid-template-columns: 120px 1fr 32px;
  align-items: center;
  gap: 12px;
}

.score-bar__label {
  font-family: var(--font-ui);
  font-size: 12px;
  font-weight: 500;
  color: var(--text-secondary);
  text-align: right;
}

.score-bar__track {
  height: 6px;
  background: var(--bg-sunken);
  border-radius: 3px;
  overflow: hidden;
}

.score-bar__fill {
  height: 100%;
  border-radius: 3px;
  transition: width 600ms cubic-bezier(0.25, 0.8, 0.25, 1);
  /* Width set via inline style: style="width: 96%" */
}

/* Bar fill colors by score range */
.score-bar__fill--high   { background: var(--score-high); }   /* 90+ coral */
.score-bar__fill--medium { background: var(--score-medium); } /* 70-89 olive */
.score-bar__fill--low    { background: var(--score-low); }    /* 60-69 gray */

.score-bar__value {
  font-family: var(--font-ui);
  font-size: 12px;
  font-weight: 600;
  color: var(--text-primary);
  text-align: right;
}

/* ── Compact Inline Variant (5 mini bars in a row) ── */
.score-breakdown--inline {
  display: flex;
  flex-direction: row;
  gap: 4px;
  align-items: flex-end;
}
.score-breakdown--inline .score-minibar {
  width: 24px;
  height: var(--bar-height); /* Set proportionally, e.g., --bar-height: 32px */
  border-radius: 3px 3px 0 0;
}
.score-breakdown--inline .score-minibar__label {
  font-family: var(--font-ui);
  font-size: 9px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-tertiary);
  text-align: center;
  margin-top: 4px;
}

/* ── Animated fill on scroll-into-view ── */
.score-bar__fill[data-animate] {
  width: 0;
}
.score-bar__fill[data-animate].is-visible {
  /* Width animates to the real value via CSS transition above */
}
```

### Search

```css
/* ─── Search Component ─── */
.search {
  max-width: 560px;
  margin: 0 auto;
}

.search__input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search__input {
  width: 100%;
  font-family: var(--font-ui);
  font-size: 16px;
  font-weight: 400;
  padding: 14px 48px 14px 44px;
  background: var(--bg-surface);
  border: 2px solid var(--border-default);
  border-radius: 12px;               /* Playful: rounded input */
  color: var(--text-primary);
  transition:
    border-color 200ms ease,
    box-shadow 200ms ease;
}
.search__input::placeholder {
  color: var(--text-tertiary);
}
.search__input:focus {
  border-color: var(--warm);          /* Coral focus ring — Playful */
  box-shadow: 0 0 0 4px rgba(var(--warm-rgb), 0.1);
  outline: none;
}

.search__icon {
  position: absolute;
  left: 16px;
  width: 20px;
  height: 20px;
  color: var(--text-tertiary);
  pointer-events: none;
}

.search__clear {
  position: absolute;
  right: 16px;
  width: 20px;
  height: 20px;
  color: var(--text-tertiary);
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
}
.search__clear:hover {
  color: var(--text-secondary);
}

/* ─── Search Filters ─── */
.search-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}

/* Category filter pill */
.filter-pill {
  font-family: var(--font-ui);
  font-size: 13px;
  font-weight: 500;
  padding: 6px 16px;
  border-radius: 9999px;             /* Full round pill */
  border: 1px solid var(--border-default);
  background: var(--bg-surface);
  color: var(--text-secondary);
  cursor: pointer;
  transition:
    background 150ms ease,
    border-color 150ms ease,
    color 150ms ease;
}
.filter-pill:hover {
  background: var(--bg-sunken);
  border-color: var(--border-rule);
}
.filter-pill--active {
  background: var(--accent-light);
  border-color: var(--accent);
  color: var(--accent);
}

/* Score range slider */
.score-slider {
  display: flex;
  align-items: center;
  gap: 12px;
}
.score-slider__label {
  font-family: var(--font-ui);
  font-size: 13px;
  font-weight: 500;
  color: var(--text-secondary);
  white-space: nowrap;
}
.score-slider__input {
  -webkit-appearance: none;
  appearance: none;
  width: 120px;
  height: 4px;
  background: var(--border-default);
  border-radius: 2px;
  outline: none;
}
.score-slider__input::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: var(--warm);
  cursor: pointer;
  border: 2px solid var(--bg-surface);
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.15);
}
.score-slider__value {
  font-family: var(--font-ui);
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary);
  min-width: 40px;
}
```

### Buttons

```css
/* ─── Button System ─── */

/* Base button */
.btn {
  font-family: var(--font-ui);
  font-weight: 600;
  border: none;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition:
    background 150ms ease,
    transform 150ms ease,
    box-shadow 150ms ease;
  white-space: nowrap;
  text-decoration: none;
}
.btn:focus-visible {
  outline: 2px solid var(--warm);
  outline-offset: 2px;
}
.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
  box-shadow: none !important;
}

/* ── Primary: coral fill, white text (Playful) ── */
.btn--primary {
  font-size: 16px;
  padding: 12px 28px;
  background: var(--warm);
  color: #FFFFFF;
  border-radius: 12px;               /* Playful: 12px pill radius */
  box-shadow: 0 2px 8px rgba(var(--warm-rgb), 0.2);
}
.btn--primary:hover {
  background: var(--warm-hover);
  transform: translateY(-1px);       /* Playful: lift on hover */
  box-shadow: 0 4px 16px rgba(var(--warm-rgb), 0.3);
}
.btn--primary:active {
  transform: translateY(0);
  box-shadow: 0 2px 8px rgba(var(--warm-rgb), 0.2);
}

/* ── Secondary: olive outline ── */
.btn--secondary {
  font-size: 14px;
  padding: 10px 24px;
  background: transparent;
  color: var(--accent);
  border: 1.5px solid var(--accent);
  border-radius: 12px;
}
.btn--secondary:hover {
  background: var(--accent-light);
}
.btn--secondary:active {
  background: var(--accent);
  color: #FFFFFF;
}

/* ── Ghost: underlined text in olive ── */
.btn--ghost {
  font-size: 14px;
  padding: 8px 4px;
  background: transparent;
  color: var(--accent);
  border-radius: 0;
  text-decoration: underline;
  text-underline-offset: 3px;
  text-decoration-thickness: 1px;
}
.btn--ghost:hover {
  color: var(--accent-hover);
}

/* ── Pill: full-round for tags and filters ── */
.btn--pill {
  font-size: 13px;
  padding: 8px 20px;
  border-radius: 9999px;
}

/* ── Size variants ── */
.btn--sm {
  font-size: 13px;
  padding: 8px 18px;
}
.btn--lg {
  font-size: 18px;
  padding: 16px 36px;
}

/* ── Icon-only button ── */
.btn--icon {
  width: 40px;
  height: 40px;
  padding: 0;
  border-radius: 12px;
  background: transparent;
  color: var(--text-secondary);
}
.btn--icon:hover {
  background: var(--bg-sunken);
  color: var(--text-primary);
}
```

### Form Inputs

```css
/* ─── Form Inputs ─── */
.input {
  font-family: var(--font-ui);
  font-size: 16px;
  font-weight: 400;
  padding: 14px 16px;
  background: var(--bg-surface);
  border: 1.5px solid var(--border-default);
  border-radius: 8px;                /* Editorial default — 8px, not 12px */
  color: var(--text-primary);
  width: 100%;
  transition:
    border-color 200ms ease,
    box-shadow 200ms ease;
}
.input::placeholder {
  color: var(--text-tertiary);
}
.input:focus {
  border-color: var(--warm);          /* Coral focus — Playful accent */
  box-shadow: 0 0 0 4px rgba(var(--warm-rgb), 0.08);
  outline: none;
}
.input--error {
  border-color: var(--error);
}
.input--error:focus {
  border-color: var(--error);
  box-shadow: 0 0 0 4px rgba(196, 64, 48, 0.08);
}
.input:disabled {
  background: var(--bg-sunken);
  color: var(--text-tertiary);
  cursor: not-allowed;
}

/* ── Large input variant (for URL submission) ── */
.input--lg {
  font-size: 18px;
  padding: 18px 20px;
  border-radius: 12px;               /* Playful radius on prominent inputs */
  border-width: 2px;
}

/* ── Select dropdown ── */
.select {
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23999999' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 16px center;
  padding-right: 44px;
}

/* ── Textarea ── */
.textarea {
  min-height: 120px;
  resize: vertical;
  line-height: 1.6;
}

/* ── Form Label ── */
.label {
  font-family: var(--font-ui);
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  display: block;
  margin-bottom: 8px;
}
.label__hint {
  font-weight: 400;
  color: var(--text-tertiary);
  margin-left: 4px;
}

/* ── Form Error Message ── */
.field-error {
  font-family: var(--font-ui);
  font-size: 13px;
  font-weight: 500;
  color: var(--error);
  margin-top: 6px;
}
```

### Tags & Pills

```css
/* ─── Tags on Site Listing Cards ─── */
.tag {
  display: inline-flex;
  align-items: center;
  font-family: var(--font-ui);
  font-size: 12px;
  font-weight: 500;
  padding: 4px 12px;
  border-radius: 8px;                /* Rounded pill — Playful shape */
  border: 1px solid var(--border-default);
  background: transparent;
  color: var(--text-secondary);
  text-decoration: none;
  transition:
    background 150ms ease,
    border-color 150ms ease;
}
.tag:hover {
  background: var(--bg-sunken);
  border-color: var(--accent);
  color: var(--accent);
}
.tag--active {
  background: var(--accent-light);
  border-color: var(--accent);
  color: var(--accent);
}

/* ── Category badge (colored) ── */
.category-badge {
  font-family: var(--font-ui);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  padding: 4px 10px;
  border-radius: 6px;
}
/* Category-specific badge colors */
.category-badge--technology  { background: #E8F2F4; color: #3B7A8C; }
.category-badge--culture     { background: #F5EDD6; color: #8B6914; }
.category-badge--science     { background: #E8F0E8; color: #4A6741; }
.category-badge--making      { background: #F2E6DD; color: #A0522D; }
.category-badge--games       { background: #EDEAF5; color: #5D4F99; }
.category-badge--weird       { background: #F5E8EA; color: #9E5060; }
.category-badge--reference   { background: #E8EDF2; color: #5F7A8E; }
.category-badge--community   { background: #F0EAE0; color: #6B5735; }
```

### Collections & Lists

```
┌──────────────────────────────────────────────────────────────┐
│  COLLECTION: "BEST OF" LIST                                  │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌───────────────────────────────────────────────────────┐   │
│  │  EDITOR'S COLLECTION                                  │   │
│  │                                                       │   │
│  │  The 25 Best Personal Blogs                           │   │
│  │  on the Web Right Now                                 │   │
│  │                                                       │   │
│  │  Long-running, lovingly maintained, deeply personal   │   │
│  │  blogs that remind you the web is made by humans.     │   │
│  │                                                       │   │
│  │  24 sites | Updated March 2026                        │   │
│  │                                                       │   │
│  │  ────────────────────────────────────────────────      │   │
│  │                                                       │   │
│  │  1. craigmod.com ........................ 97/100       │   │
│  │  2. robinsloan.com ...................... 95/100       │   │
│  │  3. danluu.com .......................... 94/100       │   │
│  │  ...                                                  │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                               │
│  Collection header: Fraunces H2, editorial spacing           │
│  Numbered list with dotted leaders and score badges          │
│  Overline: "Editor's Collection" in Jakarta Sans caps        │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

```css
/* ─── Collection Card (on Collections listing page) ─── */
.collection-card {
  background: var(--bg-surface);
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition:
    transform 200ms ease,
    box-shadow 200ms ease;
}
.collection-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.collection-card__overline {
  font-family: var(--font-ui);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--warm);                 /* Coral overline for collections */
  margin-bottom: 12px;
}

.collection-card__title {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 600;
  line-height: 1.25;
  color: var(--text-primary);
  margin-bottom: 8px;
}

.collection-card__description {
  font-family: var(--font-body);
  font-size: 16px;
  line-height: 1.75;
  color: var(--text-secondary);
  max-width: 55ch;
}

.collection-card__meta {
  font-family: var(--font-ui);
  font-size: 13px;
  color: var(--text-tertiary);
  margin-top: 16px;
}

/* ─── Collection Detail: Numbered List ─── */
.collection-list {
  max-width: 720px;
  margin: 0 auto;
}

.collection-item {
  display: grid;
  grid-template-columns: 32px 1fr auto;
  align-items: baseline;
  gap: 16px;
  padding: 20px 0;
  border-bottom: 1px solid var(--border-default);
}
.collection-item:last-child {
  border-bottom: none;
}

.collection-item__number {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 600;
  color: var(--text-tertiary);
}

.collection-item__site {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.collection-item__name {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 500;
  color: var(--text-primary);
}
.collection-item__name a {
  color: inherit;
  text-decoration: none;
}
.collection-item__name a:hover {
  color: var(--accent);
}
.collection-item__blurb {
  font-family: var(--font-body);
  font-size: 15px;
  line-height: 1.6;
  color: var(--text-secondary);
}

.collection-item__score {
  font-family: var(--font-display);
  font-size: 18px;
  font-weight: 700;
  color: var(--warm);
}
```

### Surprise Me

```
┌──────────────────────────────────────────────────────────────┐
│  "SURPRISE ME" BUTTON                                         │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│                  ┌──────────────────────┐                    │
│                  │  ✦  Surprise Me      │                    │
│                  └──────────────────────┘                    │
│                                                               │
│  Coral-filled pill button with sparkle icon                  │
│  Hover: scale(1.05) with bouncy easing                       │
│  Click: reveals random site card with slide-in               │
│                                                               │
│  This is Playful element #5: the delight moment.             │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

```css
/* ─── Surprise Me Button (Playful element #5) ─── */
.surprise-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-family: var(--font-ui);
  font-size: 16px;
  font-weight: 600;
  padding: 14px 28px;
  background: var(--warm);
  color: #FFFFFF;
  border: none;
  border-radius: 9999px;             /* Full pill */
  cursor: pointer;
  box-shadow: 0 4px 16px rgba(var(--warm-rgb), 0.25);
  transition:
    transform 300ms cubic-bezier(0.175, 0.885, 0.32, 1.275),   /* Bouncy */
    box-shadow 300ms ease;
}

.surprise-btn:hover {
  transform: scale(1.05);            /* Bouncy scale — Playful delight */
  box-shadow: 0 8px 24px rgba(var(--warm-rgb), 0.35);
}
.surprise-btn:active {
  transform: scale(0.97);
  box-shadow: 0 2px 8px rgba(var(--warm-rgb), 0.2);
}
.surprise-btn:focus-visible {
  outline: 2px solid var(--warm);
  outline-offset: 4px;
}

.surprise-btn__icon {
  font-size: 18px;
  line-height: 1;
}

/* ─── Surprise Me Result: Slide-in Card ─── */
@keyframes surprise-slide-in {
  from {
    opacity: 0;
    transform: translateY(24px) scale(0.96);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.surprise-result {
  animation: surprise-slide-in 400ms cubic-bezier(0.25, 0.8, 0.25, 1) forwards;
  margin-top: 32px;
}

/* Shimmer effect while loading */
@keyframes surprise-shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

.surprise-loading {
  height: 200px;
  border-radius: 16px;
  background: linear-gradient(
    90deg,
    var(--bg-sunken) 25%,
    var(--warm-light) 50%,
    var(--bg-sunken) 75%
  );
  background-size: 200% 100%;
  animation: surprise-shimmer 1.5s ease-in-out infinite;
}
```

### Submission Flow

```
┌──────────────────────────────────────────────────────────────┐
│  SUBMISSION FLOW: MULTI-STEP FORM                             │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Step 1: URL         Step 2: Details      Step 3: Score       │
│  ●────────────────── ○────────────────── ○                   │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐   │
│  │                                                       │   │
│  │  Submit a Site                                        │   │
│  │                                                       │   │
│  │  Know a great website the world should see?           │   │
│  │  Drop the URL below and our AI will take a look.      │   │
│  │                                                       │   │
│  │  ┌───────────────────────────────────────────────┐    │   │
│  │  │  https://                                     │    │   │
│  │  └───────────────────────────────────────────────┘    │   │
│  │                                                       │   │
│  │               [ Score This Site ]                     │   │
│  │                                                       │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                               │
│  Step 3: AI scoring visualization                            │
│  ── Originality    ████████████████░░░░  scoring...           │
│  ── Depth          █████████████░░░░░░░  scoring...           │
│  ── Freshness      ████████████░░░░░░░░  scoring...           │
│  ── Human Author   ████████████████████  98 ✓                │
│  ── Design         █████████████████░░░  scoring...           │
│                                                               │
│  Bars fill sequentially with staggered animation             │
│  Each bar "locks in" with a checkmark when done              │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

```css
/* ─── Submission Flow ─── */
.submit-flow {
  max-width: 560px;
  margin: 0 auto;
  padding: 48px 24px;
}

/* ── Progress Indicator ── */
.submit-progress {
  display: flex;
  align-items: center;
  gap: 0;
  margin-bottom: 48px;
}

.submit-progress__step {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: var(--font-ui);
  font-size: 13px;
  font-weight: 500;
  color: var(--text-tertiary);
}
.submit-progress__step--active {
  color: var(--text-primary);
}
.submit-progress__step--completed {
  color: var(--accent);
}

.submit-progress__dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--border-default);
  flex-shrink: 0;
}
.submit-progress__step--active .submit-progress__dot {
  background: var(--warm);
  box-shadow: 0 0 0 4px rgba(var(--warm-rgb), 0.15);
}
.submit-progress__step--completed .submit-progress__dot {
  background: var(--accent);
}

.submit-progress__line {
  flex: 1;
  height: 2px;
  background: var(--border-default);
  margin: 0 8px;
}
.submit-progress__line--completed {
  background: var(--accent);
}

/* ── Step Header ── */
.submit-flow__title {
  font-family: var(--font-display);
  font-size: 32px;
  font-weight: 600;
  line-height: 1.25;
  color: var(--text-primary);
  margin-bottom: 8px;
}
.submit-flow__description {
  font-family: var(--font-body);
  font-size: 18px;
  line-height: 1.75;
  color: var(--text-secondary);
  margin-bottom: 32px;
  max-width: 50ch;
}

/* ── URL Input (large and prominent) ── */
.submit-url-input {
  font-family: var(--font-mono);
  font-size: 18px;
  padding: 18px 20px;
  border: 2px solid var(--border-default);
  border-radius: 12px;
  width: 100%;
  background: var(--bg-surface);
  color: var(--text-primary);
  transition:
    border-color 200ms ease,
    box-shadow 200ms ease;
}
.submit-url-input:focus {
  border-color: var(--warm);
  box-shadow: 0 0 0 4px rgba(var(--warm-rgb), 0.1);
  outline: none;
}
.submit-url-input::placeholder {
  font-family: var(--font-ui);
  color: var(--text-tertiary);
}

/* ── AI Scoring Visualization ── */
.scoring-visualization {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin: 32px 0;
}

.scoring-row {
  display: grid;
  grid-template-columns: 130px 1fr 40px 24px;
  align-items: center;
  gap: 12px;
}

.scoring-row__label {
  font-family: var(--font-ui);
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
}

.scoring-row__bar {
  height: 8px;
  background: var(--bg-sunken);
  border-radius: 4px;
  overflow: hidden;
}

.scoring-row__fill {
  height: 100%;
  border-radius: 4px;
  background: var(--warm);
  width: 0;
  transition: width 800ms cubic-bezier(0.25, 0.8, 0.25, 1);
}

.scoring-row__value {
  font-family: var(--font-ui);
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  text-align: right;
  opacity: 0;
  transition: opacity 200ms ease;
}
.scoring-row__value--visible {
  opacity: 1;
}

.scoring-row__check {
  width: 20px;
  height: 20px;
  color: var(--success);
  opacity: 0;
  transition: opacity 200ms ease;
}
.scoring-row__check--visible {
  opacity: 1;
}

/* Staggered animation for sequential bar fills */
.scoring-row:nth-child(1) .scoring-row__fill { transition-delay: 0ms; }
.scoring-row:nth-child(2) .scoring-row__fill { transition-delay: 600ms; }
.scoring-row:nth-child(3) .scoring-row__fill { transition-delay: 1200ms; }
.scoring-row:nth-child(4) .scoring-row__fill { transition-delay: 1800ms; }
.scoring-row:nth-child(5) .scoring-row__fill { transition-delay: 2400ms; }

/* ── Result Card ── */
.submit-result {
  margin-top: 32px;
  padding: 32px;
  background: var(--bg-surface);
  border-radius: 16px;
  border: 2px solid var(--accent-light);
  animation: surprise-slide-in 400ms cubic-bezier(0.25, 0.8, 0.25, 1) forwards;
}
.submit-result__header {
  font-family: var(--font-ui);
  font-size: 13px;
  font-weight: 600;
  color: var(--accent);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 8px;
}
/* The result card renders as a standard .site-card inside this container */
```

### Empty States

```css
/* ─── Empty States (warmth: Playful influence) ─── */
.empty-state {
  text-align: center;
  padding: 80px 24px;
  max-width: 400px;
  margin: 0 auto;
}

.empty-state__illustration {
  width: 120px;
  height: 120px;
  margin: 0 auto 24px;
  /* Hand-drawn style spot illustrations — Playful influence */
}

.empty-state__title {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8px;
}

.empty-state__message {
  font-family: var(--font-body);
  font-size: 16px;
  line-height: 1.75;
  color: var(--text-secondary);
  margin-bottom: 24px;
}

/* Example messages:
   - No search results: "Nothing matched — try browsing a category?"
   - Empty category: "Nothing here yet — submit a site!"
   - Empty collection: "Start curating. Add sites you love."
   - No submissions: "You haven't submitted any sites yet. Found something great?"
*/
```

---

## Interaction & Motion

### Motion Specification

| Element | Effect | Duration | Easing | Trigger |
|---|---|---|---|---|
| **Site card hover** | translateY(-2px) + shadow expand | 200ms | ease | Hover (Playful #4) |
| **Category card hover** | scale(1.02) + shadow | 200ms | ease | Hover (Playful #3) |
| **Collection card hover** | translateY(-2px) + shadow expand | 200ms | ease | Hover |
| **Surprise Me hover** | scale(1.05) | 300ms | cubic-bezier(0.175, 0.885, 0.32, 1.275) | Hover (Playful #5) |
| **Surprise Me press** | scale(0.97) | 100ms | ease | Active |
| **Surprise Me result** | translateY(24px) to 0 + fade | 400ms | cubic-bezier(0.25, 0.8, 0.25, 1) | Reveal |
| **Primary btn hover** | translateY(-1px) + shadow | 150ms | ease | Hover |
| **Primary btn press** | translateY(0) | 100ms | ease | Active |
| **Score bars fill** | width 0 to N% | 600ms | cubic-bezier(0.25, 0.8, 0.25, 1) | Scroll into view |
| **Scoring bars (submit)** | width 0 to N%, staggered | 800ms each | cubic-bezier(0.25, 0.8, 0.25, 1) | Sequential |
| **Nav link hover** | color shift | 200ms | ease | Hover |
| **Tag hover** | bg + border color | 150ms | ease | Hover |
| **Input focus** | border-color + shadow | 200ms | ease | Focus |
| **Filter pill active** | bg + border + color | 150ms | ease | Click |
| **Loading shimmer** | bg-position cycle | 1500ms | ease-in-out, infinite | Loading |
| **Page content** | No entrance animations | -- | -- | -- |

### Motion Philosophy

- **Editorial foundation:** Content does not animate on load. No parallax, no scroll reveals, no staggered entrance. The directory is a reading experience — content should be immediately present
- **Playful additions are limited to interaction responses:** hover lifts on cards, bouncy scale on Surprise Me, animated score bars on scroll-into-view. These reward exploration without distracting from reading
- **Duration range:** 150-200ms for UI feedback, 300ms for bouncy interactions, 400ms for reveals, 600-800ms for score bar fills
- **No motion on mobile by default** — touch interfaces don't have hover states. The Surprise Me button uses active state instead

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

  /* Score bars: show final state immediately */
  .score-bar__fill {
    transition: none;
  }

  /* Surprise Me: no bouncy scale */
  .surprise-btn:hover {
    transform: none;
  }

  /* Cards: no lift on hover */
  .site-card:hover,
  .category-card:hover,
  .collection-card:hover {
    transform: none;
  }
}
```

---

## Asset Guidelines

### Photography

None. Site screenshots are the only imagery. This is a directory of websites, not a lifestyle product. Screenshots are captured automatically and displayed as thumbnails.

```css
/* Screenshot treatment */
.screenshot {
  border-radius: 8px;
  border: 1px solid var(--border-default);
  overflow: hidden;
}
/* On site detail pages, screenshots can be larger */
.screenshot--hero {
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}
```

### Iconography

- **Style:** Rounded, 2px stroke, consistent — Lucide icon set or equivalent
- **Sizes:** 16px (inline), 20px (navigation), 24px (tab bar, empty states)
- **Color:** Inherits text color via `currentColor`. Never uses accent colors unless interactive
- **Category icons:** Simple, rounded, one color per category. Can use the category jewel tone at 100% for the icon and 10% for the background

```
Icon set: Lucide (https://lucide.dev)

Key icons:
  Compass / Globe     — Browse
  Search               — Search
  Plus / Send          — Submit
  Bookmark / Layers    — Collections
  Sparkles (✦)         — Surprise Me / Editor's Pick
  External Link        — Visit site
  Star                 — Score badge indicator
  Check                — Scoring complete
  Filter               — Filter controls
  ChevronRight         — Breadcrumb separator
  ArrowLeft            — Back navigation
  User                 — Profile
  Flag                 — Report / Flag
  Heart                — Save to collection
```

### Illustrations

Optional small spot illustrations for empty states only. Hand-drawn style with a single line weight, warm and imperfect. Think: quick pen sketches on cream paper. Never photographic, never 3D, never complex.

- **Color:** Single color — olive (#4A6741) on cream background, or white on coral
- **Scale:** 120px max, centered above empty state text
- **Subjects:** A magnifying glass over a tiny web page, a little bookshelf with sites, an envelope for "no results," a compass for "explore"

---

## Dark Mode

### Dark Mode Color Mappings

```css
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #111111;           /* Deep near-black */
    --bg-surface: #1A1A1A;          /* Slightly lifted surface */
    --bg-sunken: #0D0D0D;           /* Darker inset areas */

    --text-primary: #E8E4DF;        /* Warm off-white */
    --text-secondary: #A09A92;      /* Warm medium gray */
    --text-tertiary: #706B64;       /* Warm dark gray */

    --border-default: #2A2622;      /* Warm dark border */
    --border-rule: #3A352F;         /* Slightly lighter rule */

    /* Olive lightens for visibility */
    --accent: #7DA374;              /* Lightened olive */
    --accent-hover: #8FB586;
    --accent-light: #1E2A1C;        /* Very dark olive tint */
    --accent-rgb: 125, 163, 116;

    /* Coral stays — vibrant on dark backgrounds */
    --warm: #E8704A;
    --warm-hover: #F07E5A;          /* Slightly lighter on hover */
    --warm-light: #2A1A14;          /* Very dark coral tint */
    --warm-rgb: 232, 112, 74;

    --success: #7DA374;
    --warning: #E8B84A;
    --error: #E85050;
    --info: #6BA0D4;

    /* Category colors — slightly lighter for dark backgrounds */
    --cat-technology: #5A9AAE;
    --cat-culture: #D4A020;
    --cat-science: #8AAE8A;
    --cat-making: #C8784A;
    --cat-games: #9B88C8;
    --cat-weird: #D4909A;
    --cat-reference: #7A9AB0;
    --cat-community: #A89070;

    /* Score colors */
    --score-high: #E8704A;          /* Coral stays */
    --score-medium: #7DA374;        /* Lightened olive */
    --score-low: #706B64;           /* Warm muted */
  }

  /* Category card backgrounds: much darker tints */
  .category-card--technology  { background: #152028; color: #B0D4DE; }
  .category-card--culture     { background: #241E0A; color: #E0C860; }
  .category-card--science     { background: #152015; color: #B0D4B0; }
  .category-card--making      { background: #241810; color: #D4A080; }
  .category-card--games       { background: #1A162A; color: #C0B0E0; }
  .category-card--weird       { background: #241820; color: #D4A0B0; }
  .category-card--reference   { background: #151A20; color: #A0B8D0; }
  .category-card--community   { background: #201A10; color: #C0A880; }

  /* Card shadows: lighter for visibility on dark */
  .site-card {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  }
  .site-card:hover {
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
  }

  /* Score badge: ensure white text contrast */
  .score-badge--medium {
    background: var(--score-medium);
    color: #111111;                  /* Dark text on light olive */
  }

  /* Navigation border */
  .nav {
    border-bottom-color: var(--border-default);
    background: var(--bg-primary);
  }

  /* Subcategory pills on dark */
  .subcategory-pill {
    background: rgba(255, 255, 255, 0.08);
  }
  .subcategory-pill:hover {
    background: rgba(255, 255, 255, 0.15);
  }
}
```

### Dark Mode Palette Diagram

```
┌──────────────────────────────────────────────────────────────┐
│  GOTTA.CC DARK MODE                                           │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  BACKGROUNDS                                                  │
│  ██████  #111111   Deep background                           │
│  ██████  #1A1A1A   Card surface                              │
│  ██████  #0D0D0D   Sunken areas                              │
│                                                               │
│  TEXT                                                          │
│  ██████  #E8E4DF   Warm off-white (primary)                  │
│  ██████  #A09A92   Warm gray (secondary)                     │
│  ██████  #706B64   Warm dark gray (tertiary)                 │
│                                                               │
│  ACCENTS                                                      │
│  ██████  #7DA374   Lightened Olive (editorial)               │
│  ██████  #E8704A   Coral stays (interactive)                 │
│                                                               │
│  Dark mode is warm, never blue-tinted. All grays lean warm.  │
│  Coral pops on dark backgrounds — effective for CTAs.        │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Dark Mode Contrast Verification

| Pairing | Ratio | WCAG |
|---|---|---|
| `#E8E4DF` on `#111111` | 14.1:1 | AAA |
| `#A09A92` on `#111111` | 6.2:1 | AA |
| `#E8E4DF` on `#1A1A1A` | 12.3:1 | AAA |
| `#FFFFFF` on `#E8704A` | 3.3:1 | AA Large |
| `#111111` on `#7DA374` | 5.8:1 | AA |
| `#E8704A` on `#111111` | 4.6:1 | AA |

---

## Mixing Notes

### The 5 Elements Carrying the 20% Consumer Playful Accent

| # | Element | What Changed from Pure Editorial | Why This Element |
|---|---------|----------------------------------|------------------|
| **1** | **CTA button shape** — 12px border-radius pill instead of Editorial's 4px sharp rectangles | The directory's primary actions are "Submit a Site," "Subscribe," and "Visit." These need to feel inviting, not academic. A sharp-cornered button says "submit your paper." A rounded pill says "try this." The radius softens the commitment implied by the action. |
| **2** | **Score badges** — Coral-filled circular badges instead of plain text scores | Plain text scores would disappear into the editorial layout. The coral circle makes the quality score the most visually prominent element on every card — which is the entire point of the directory. The circle shape + coral color = an evaluative moment that catches the eye. Scores are not content to be read, they're signals to be noticed. |
| **3** | **Category cards** — Soft jewel-tone background tints per category instead of Editorial's monochrome cards | The category grid is the front door of the directory. In pure Editorial, all categories would be cream/white with serif text — elegant but undifferentiated. The jewel-tone tints make each category visually distinct, which is critical for a directory where the taxonomy IS the navigation. Color-coding categories is a Playful convention that serves an Editorial purpose. |
| **4** | **Hover lift on site cards** — translateY(-2px) + shadow expansion instead of Editorial's subtle underline/color change | The directory is about discovery. A lifted card says "pick me up" — it implies interactivity and exploration. Editorial hover states (text color shift, underline thickening) communicate "this is a link." Playful hover states (lift, shadow) communicate "this is explorable." The lift transforms scanning into browsing. |
| **5** | **"Surprise Me" button** — Bouncy coral pill with scale(1.05) hover animation | The single highest-delight moment in the product. Pure Editorial would render this as an underlined text link — functional but joyless. The bouncy animation + coral fill + sparkle icon turns a utilitarian random function into a moment of wonder. This button is the personality of the entire directory compressed into one interaction. |

### What Was Considered and Rejected

| Candidate Element | Why Rejected |
|---|---|
| **Playful typography for display headlines (e.g., Clash Display, Cabinet Grotesk)** | Fraunces already provides the Playful influence on headlines via its variable serif character (wonky axis, soft terminals). Adding a geometric display sans would create two personality systems competing. One characterful serif handles both editorial authority and playful personality. |
| **Confetti or particle animation on Surprise Me reveal** | Too gamified. The directory signals "curation," not "luck." A confetti explosion after revealing a random site would undermine the message that every site in the directory is quality-vetted. The slide-in card animation is delight enough — the content IS the reward. |
| **Rounded corners on ALL cards (24px+)** | Pure Playful uses 16-24px radius everywhere. For the directory, 16px on cards is already a Playful concession from Editorial's 0-4px. Going higher would make the interface feel like a consumer app, not a curated directory. 16px is the sweet spot — friendly without being bubbly. |
| **Multi-color accent system (coral + teal + purple)** | Playful's multi-color approach would clash with the category jewel-tone system. The directory already uses 8 category colors. Adding multiple UI accent colors on top would create visual chaos. Two accent colors (olive for editorial, coral for action) is the maximum. |
| **Bouncy hover on ALL cards (not just site cards)** | If everything bounces, nothing bounces. The lift effect on site cards is special because category cards use subtle scale instead, and collection cards use a gentler lift. Variety in hover states creates hierarchy of interactivity. |
| **Gradient backgrounds on category cards** | Gradients would tip the balance too far toward Consumer Playful. Flat muted tints feel curated and intentional. Gradients feel marketed and designed. The tints should feel like someone painted watercolor swatches in the margins of a reference book. |
| **Animated category card icons** | Motion on content elements violates the Editorial principle that content should be still and immediately present. Animation is reserved for interaction responses (hover, click, reveal), not passive display. |
| **Bottom tab bar on desktop** | Mobile bottom tab bar is a Playful concession for thumb-reachable navigation. On desktop, the top navigation bar follows Editorial conventions. Mixing mobile patterns into desktop would feel confused, not mixed. |

---

## Directory-Specific Patterns

### Homepage Structure

```
┌──────────────────────────────────────────────────────────────┐
│  gotta.cc              Browse  Search  Submit  Collections   │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Browse the web by topic,                   (Fraunces 56px)  │
│  not by keyword.                                             │
│                                                               │
│  An AI-curated directory of the best        (Source Serif 4) │
│  websites on the internet. Every site                        │
│  scored for quality.                                         │
│                                                               │
│  [Search the directory...         ]   [ ✦ Surprise Me ]      │
│                                                               │
│  ════════════════════════════════════════════════════════     │
│                                                               │
│  BROWSE BY CATEGORY                         (Jakarta caps)   │
│                                                               │
│  ┌─────────────────┐  ┌─────────┐  ┌─────────┐              │
│  │  Technology      │  │ Culture │  │ Science │              │
│  │  ███ 247 sites   │  │ ███    │  │ ███     │              │
│  └─────────────────┘  └─────────┘  └─────────┘              │
│                                                               │
│  ┌─────────┐  ┌─────────┐  ┌─────────────────┐              │
│  │  Making  │  │  Games  │  │  Weird & Wonder │              │
│  │  ███     │  │  ███    │  │  ███ 73 sites   │              │
│  └─────────┘  └─────────┘  └─────────────────┘              │
│                                                               │
│  ════════════════════════════════════════════════════════     │
│                                                               │
│  RECENTLY ADDED                             (Jakarta caps)   │
│                                                               │
│  ┌─ Site Card ─────────────────────── 94 ─┐                 │
│  │  uses-this.com ...                      │                 │
│  └─────────────────────────────────────────┘                 │
│  ┌─ Site Card ─────────────────────── 91 ─┐                 │
│  │  another-site.com ...                   │                 │
│  └─────────────────────────────────────────┘                 │
│                                                               │
│  ════════════════════════════════════════════════════════     │
│                                                               │
│  EDITOR'S COLLECTIONS                                        │
│                                                               │
│  ┌─ Collection Card ─┐  ┌─ Collection Card ─┐               │
│  │  Best Personal     │  │  Indie Tools      │               │
│  │  Blogs of 2026     │  │  Worth Paying For │               │
│  └────────────────────┘  └────────────────────┘              │
│                                                               │
├──────────────────────────────────────────────────────────────┤
│  Footer: About | How Scoring Works | Submit | API | RSS      │
│  gotta.cc | The Yahoo Directory for the post-slop web        │
└──────────────────────────────────────────────────────────────┘
```

### Category Page Structure

```
┌──────────────────────────────────────────────────────────────┐
│  gotta.cc > Technology > Developer Tools                     │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Developer Tools                        (Fraunces H1 40px)  │
│  247 sites | Last updated Mar 12, 2026  (Jakarta 14px)      │
│                                                               │
│  SUBCATEGORIES:                                              │
│  [Terminals] [Code Editors] [CLI] [Debugging] [All]          │
│                                                               │
│  Sort: Score (high-low) ▼    View: [Cards] [List]            │
│                                                               │
│  ┌─ Site Card ─────────────────────────────── 96 ─┐         │
│  │  TERMINALS & SHELLS                             │         │
│  │  Warp Terminal                                  │         │
│  │  A modern terminal reimagined from scratch...   │         │
│  │  warp.dev                                       │         │
│  │  [terminal] [developer] [rust]                  │         │
│  └─────────────────────────────────────────────────┘         │
│                                                               │
│  ┌─ Site Card ─────────────────────────────── 94 ─┐         │
│  │  ...                                            │         │
│  └─────────────────────────────────────────────────┘         │
│                                                               │
│  ┌─ Site Card ─────────────────────────────── 91 ─┐         │
│  │  ...                                            │         │
│  └─────────────────────────────────────────────────┘         │
│                                                               │
│  [Load more sites]                                           │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Site Detail Page Structure

```
┌──────────────────────────────────────────────────────────────┐
│  gotta.cc > Technology > Interviews > Uses This              │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  TECHNOLOGY / INTERVIEWS                                     │
│                                                               │
│  Uses This                              (Fraunces H1 40px)  │
│  uses-this.com                          (JetBrains Mono)    │
│                                                               │
│  ┌────────────────────────┐  ┌────────────────────────────┐  │
│  │  Screenshot            │  │  Score: 94/100             │  │
│  │  ████████████████████  │  │  ┌── ★ Editor's Pick ──┐  │  │
│  │  ████████████████████  │  │  │                      │  │  │
│  │  ████████████████████  │  │  │  Originality    96   │  │  │
│  │  ████████████████████  │  │  │  Depth          91   │  │  │
│  │                        │  │  │  Freshness      88   │  │  │
│  └────────────────────────┘  │  │  Human Author   99   │  │  │
│                               │  │  Design         92   │  │  │
│                               │  │                      │  │  │
│                               │  └──────────────────────┘  │  │
│                               └────────────────────────────┘  │
│                                                               │
│  Interviews with creative people about the hardware,         │
│  software, and tools they use to get their work done.        │
│  Running since 2009. Focused, niche, lovingly maintained.    │
│  The site proves that a simple concept executed with         │
│  consistency and genuine curiosity never gets old. Over      │
│  700 interviews and counting, each one revealing something   │
│  about how different people approach their craft.            │
│                                                 (Source Sf 4)│
│                                                               │
│  ────────────────────────────────────────────────────────     │
│                                                               │
│  Categories: Technology / Interviews, Culture                │
│  Tags: [interviews] [tools] [creative] [indie-web]           │
│  First indexed: June 14, 2024                                │
│  Last checked: March 12, 2026                                │
│  Link status: Alive ●                                        │
│  Submitted by: community                                     │
│                                                               │
│  [ Visit Site → ]   [ Save to Collection ]   [ Flag ]        │
│                                                               │
│  ════════════════════════════════════════════════════════     │
│                                                               │
│  RELATED SITES IN THIS CATEGORY                              │
│                                                               │
│  ┌─ Site Card ────── 91 ─┐  ┌─ Site Card ────── 88 ─┐      │
│  │  ...                   │  │  ...                   │      │
│  └────────────────────────┘  └────────────────────────┘      │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Breadcrumb Navigation

```css
/* ─── Breadcrumbs ─── */
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: var(--font-ui);
  font-size: 13px;
  font-weight: 500;
  padding: 16px 0;
}

.breadcrumb__item {
  color: var(--text-tertiary);
  text-decoration: none;
}
.breadcrumb__item:hover {
  color: var(--accent);
  text-decoration: underline;
  text-underline-offset: 3px;
}
.breadcrumb__item--current {
  color: var(--text-primary);
}

.breadcrumb__separator {
  color: var(--text-tertiary);
  font-size: 10px;
}
```

### Pagination / Load More

```css
/* ─── Load More (preferred over pagination) ─── */
.load-more {
  text-align: center;
  padding: 32px 0;
}

.load-more__btn {
  /* Uses .btn--secondary styling */
}

.load-more__count {
  font-family: var(--font-ui);
  font-size: 13px;
  color: var(--text-tertiary);
  margin-top: 8px;
}
/* e.g., "Showing 20 of 247 sites" */
```

### Footer

```css
/* ─── Footer ─── */
.footer {
  border-top: 1px solid var(--border-default);
  padding: 48px 24px;
  max-width: 960px;
  margin: 80px auto 0;
}

.footer__grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr;
  gap: 48px;
}

@media (max-width: 768px) {
  .footer__grid {
    grid-template-columns: 1fr 1fr;
    gap: 32px;
  }
}

.footer__brand {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 8px;
}
.footer__tagline {
  font-family: var(--font-body);
  font-size: 14px;
  line-height: 1.6;
  color: var(--text-secondary);
  max-width: 30ch;
}

.footer__heading {
  font-family: var(--font-ui);
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-tertiary);
  margin-bottom: 16px;
}

.footer__link {
  display: block;
  font-family: var(--font-ui);
  font-size: 14px;
  color: var(--text-secondary);
  text-decoration: none;
  padding: 4px 0;
}
.footer__link:hover {
  color: var(--accent);
}

.footer__bottom {
  margin-top: 48px;
  padding-top: 24px;
  border-top: 1px solid var(--border-default);
  font-family: var(--font-ui);
  font-size: 13px;
  color: var(--text-tertiary);
}
```

---

## Implementation Checklist

### Editorial Foundation (80%)

- [ ] Body text (site summaries) is 16-18px Source Serif 4 with 1.75 line height
- [ ] Display/headline text uses Fraunces variable serif
- [ ] UI text (nav, buttons, labels) uses Plus Jakarta Sans
- [ ] Reading measure limited to 65ch for summaries, 55ch for card summaries
- [ ] Warm cream background (#FFFCF7) — never pure white for page ground
- [ ] Cards use white (#FFFFFF) to lift off cream background
- [ ] Deep olive green (#4A6741) for editorial elements: links, category labels, section markers
- [ ] Navigation follows editorial conventions: 64px height, bottom border, serif logo
- [ ] Content does NOT animate on page load — immediately present
- [ ] Generous vertical spacing between sections (64-80px)
- [ ] Horizontal rules use warm gray (#D4CFC6), not black
- [ ] Links use underline + color change on hover (editorial accessibility convention)
- [ ] Dark mode uses warm grays, never cool/blue grays

### Playful Accents (20%) — Exactly 5 Elements

- [ ] **#1 CTA button shape:** 12px border-radius pill, coral fill, hover lift
- [ ] **#2 Score badges:** Coral-filled circular badges (56px), white text, not plain text scores
- [ ] **#3 Category cards:** Jewel-tone background tints per category, 16px radius
- [ ] **#4 Site card hover:** translateY(-2px) + shadow expansion on hover
- [ ] **#5 Surprise Me button:** Bouncy scale(1.05) hover, coral pill, sparkle icon

### Accessibility

- [ ] Color contrast: all text meets WCAG AA minimum (4.5:1 for body, 3:1 for large)
- [ ] Color contrast: white on coral buttons meets AA Large (3.3:1 at 16px bold+)
- [ ] All interactive elements have visible `:focus-visible` outlines
- [ ] Touch targets are minimum 44x44px on mobile
- [ ] `prefers-reduced-motion` disables all animations and transitions
- [ ] Score badges convey information via text, not color alone
- [ ] Category colors are supplementary — text labels provide the information
- [ ] Form inputs have associated labels and error messages
- [ ] Navigation is keyboard-accessible with tab order
- [ ] Skip-to-content link available

### Typography

- [ ] Fraunces loaded as variable font with optical sizing
- [ ] Source Serif 4 loaded with regular and italic weights
- [ ] Plus Jakarta Sans loaded with 400, 500, 600, 700 weights
- [ ] JetBrains Mono loaded with 400 weight only
- [ ] `font-display: swap` on all font declarations
- [ ] System font fallbacks specified for all font stacks
- [ ] Total font payload under 300KB (compressed)

### Components

- [ ] Category bento grid responsive: 3 cols desktop, 2 cols tablet, 1 col mobile
- [ ] Site listing cards support both card view and compact list view
- [ ] Score breakdown bars animate width on scroll-into-view
- [ ] Search input has coral focus ring and rounded corners
- [ ] Filter pills use full-round (9999px) radius
- [ ] Submission flow uses multi-step progress indicator
- [ ] Scoring visualization shows sequential bar fills with staggered delays
- [ ] Empty states have warm, personality-driven messaging
- [ ] Collections use numbered lists with editorial typography
- [ ] Footer uses 4-column grid, collapses to 2 on mobile
- [ ] Mobile uses bottom tab bar (Playful influence) instead of hamburger menu

### Dark Mode

- [ ] Background: #111111 (not pure black)
- [ ] Text: #E8E4DF (warm off-white, not pure white)
- [ ] Coral accent unchanged (#E8704A)
- [ ] Olive accent lightened to #7DA374
- [ ] Category card backgrounds use very dark tints
- [ ] Card shadows increased for visibility on dark
- [ ] All contrast ratios verified against dark backgrounds

---

*Derived from: [editorial.md](../../../skills/user-experience-engineer/references/styles/editorial.md) + [consumer-playful.md](../../../skills/user-experience-engineer/references/styles/consumer-playful.md)*
*Construction process: [style-guide-construction.md](../../../skills/user-experience-engineer/references/process/style-guide-construction.md)*
*Version: 0.1.0*
*Created: 2026-03-13*
