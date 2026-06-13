# Gotta.cc — Direction A: "Ink & Paper"
# Complete Style Guide v1.0

> **One-liner:** "The web, edited."
> **Signals:** Authority, craftsmanship, depth, timelessness, premium curation
> **Philosophy:** The directory IS a publication. Browsing categories and discovering
> sites should feel like flipping through a beautifully typeset magazine about the web.

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Component Library](#5-component-library)
6. [Navigation](#6-navigation)
7. [Search](#7-search)
8. [Quality Score System](#8-quality-score-system)
9. [Category Browser](#9-category-browser)
10. [Site Listing Cards](#10-site-listing-cards)
11. [Site Detail Page](#11-site-detail-page)
12. [Surprise Me](#12-surprise-me)
13. [Submission Flow](#13-submission-flow)
14. [Collections & Lists](#14-collections--lists)
15. [Buttons & Interactive Elements](#15-buttons--interactive-elements)
16. [Form Elements](#16-form-elements)
17. [Interaction & Motion](#17-interaction--motion)
18. [Asset Guidelines](#18-asset-guidelines)
19. [Directory-Specific Patterns](#19-directory-specific-patterns)
20. [Dark Mode](#20-dark-mode)
21. [Responsive Design](#21-responsive-design)
22. [Accessibility](#22-accessibility)
23. [Implementation Checklist](#23-implementation-checklist)

---

## 1. Design Philosophy

### Core Principles

1. **Typography IS the design.** No illustrations, no decorative graphics. Typefaces,
   rules, whitespace, and hierarchy carry the entire visual identity.
2. **Editorial restraint.** Every element earns its place. No gradients, no shadows,
   no rounded-everything. Flat surfaces, thin rules, generous space.
3. **Reading-first.** Body text is set for sustained reading — large, well-leaded,
   measure-controlled. The summaries ARE the product.
4. **Magazine logic.** Categories are sections. Listings are articles. Scores are
   ratings. Collections are issues. The metaphor is consistent.
5. **Quiet confidence.** Burgundy is used sparingly — an accent, not a theme. The
   confidence comes from typographic craft, not color saturation.

### Anti-Patterns

- No card shadows (editorial surfaces are flat)
- No emoji in UI (use typography and punctuation)
- No icon-heavy navigation (words are the interface)
- No skeleton loaders shaped like cards (use simple progress bars)
- No toast notifications (use inline feedback)
- No hamburger menus on desktop (the nav fits)
- No gradient backgrounds
- No border-radius > 4px

### Design Lineage

This direction draws from:
- *The New York Review of Books* (typographic authority)
- *Monocle* (editorial grid, restrained palette)
- *Arts & Letters Daily* (curated link directory as publication)
- *The Criterion Collection* (numbering, canonical presentation)
- Yahoo Directory circa 2000 (hierarchical browsing) — but beautiful

---

## 2. Color System

### 2.1 Light Mode Palette

```
 PRIMARY PALETTE
 ┌─────────────────────────────────────────────────────────┐
 │                                                         │
 │  Background         #FFFCF7   ████████  Warm Cream      │
 │  Surface            #FFFFFF   ████████  Pure White       │
 │  Surface-alt        #FAF7F2   ████████  Warm Off-white   │
 │                                                         │
 │  Text-primary       #1A1A1A   ████████  Near Black       │
 │  Text-secondary     #666666   ████████  Dark Gray        │
 │  Text-tertiary      #999999   ████████  Medium Gray      │
 │  Text-quaternary    #BBBBBB   ████████  Light Gray       │
 │                                                         │
 │  Accent             #7F1D1D   ████████  Deep Burgundy    │
 │  Accent-hover       #6B1A1A   ████████  Dark Burgundy    │
 │  Accent-light       #FFF5F5   ████████  Burgundy Tint    │
 │  Accent-muted       #B85C5C   ████████  Soft Burgundy    │
 │                                                         │
 │  Border-subtle      #E5E0D8   ████████  Warm Gray        │
 │  Border-rule        #1A1A1A   ████████  Editorial Rule   │
 │  Border-medium      #D1CBC2   ████████  Medium Warm      │
 │                                                         │
 │  Score-high-bg      #FFF5F5   ████████  Score Highlight  │
 │  Score-mid-bg       #FFFCF7   ████████  Score Neutral    │
 │  Score-low-bg       #FAF7F2   ████████  Score Dim        │
 │                                                         │
 │  Success            #2D5F2D   ████████  Forest Green     │
 │  Warning            #8B6914   ████████  Dark Gold        │
 │  Error              #7F1D1D   ████████  (shares accent)  │
 │  Info               #1A4B6E   ████████  Deep Blue        │
 │                                                         │
 └─────────────────────────────────────────────────────────┘
```

### 2.2 CSS Custom Properties — Light Mode

```css
:root {
  /* Backgrounds */
  --color-bg:              #FFFCF7;
  --color-surface:         #FFFFFF;
  --color-surface-alt:     #FAF7F2;

  /* Text */
  --color-text-primary:    #1A1A1A;
  --color-text-secondary:  #666666;
  --color-text-tertiary:   #999999;
  --color-text-quaternary: #BBBBBB;
  --color-text-inverse:    #FFFFFF;

  /* Accent — Deep Burgundy */
  --color-accent:          #7F1D1D;
  --color-accent-hover:    #6B1A1A;
  --color-accent-light:    #FFF5F5;
  --color-accent-muted:    #B85C5C;

  /* Borders */
  --color-border-subtle:   #E5E0D8;
  --color-border-rule:     #1A1A1A;
  --color-border-medium:   #D1CBC2;

  /* Score backgrounds */
  --color-score-high-bg:   #FFF5F5;
  --color-score-mid-bg:    #FFFCF7;
  --color-score-low-bg:    #FAF7F2;

  /* Semantic */
  --color-success:         #2D5F2D;
  --color-warning:         #8B6914;
  --color-error:           #7F1D1D;
  --color-info:            #1A4B6E;

  /* Focus */
  --color-focus-ring:      #7F1D1D;
  --focus-ring:            2px solid var(--color-focus-ring);
  --focus-ring-offset:     2px;
}
```

### 2.3 Color Usage Rules

| Element | Color Token | Notes |
|---------|-------------|-------|
| Page background | `--color-bg` | Warm cream, never pure white |
| Card / panel surface | `--color-surface` | White, distinguishes from page bg |
| Alternating row bg | `--color-surface-alt` | Subtle warmth, not cold gray |
| Headlines | `--color-text-primary` | Always near-black |
| Body text | `--color-text-primary` | High contrast for reading |
| Metadata, dates | `--color-text-secondary` | De-emphasized but readable |
| Placeholder text | `--color-text-tertiary` | Input hints, empty states |
| Disabled text | `--color-text-quaternary` | Clearly inactive |
| Links (inline) | `--color-accent` | Burgundy, underlined |
| Link hover | `--color-accent-hover` | Slightly darker |
| Category dots | `--color-accent` | Featured pick indicator |
| Score highlight | `--color-score-high-bg` | Background behind high scores |
| Horizontal rules | `--color-border-rule` | Full-weight editorial rules |
| Card borders | `--color-border-subtle` | Barely there |
| Divider lines | `--color-border-medium` | Between listings |

### 2.4 Contrast Ratios (WCAG AA Compliance)

| Foreground | Background | Ratio | Pass |
|------------|------------|-------|------|
| #1A1A1A | #FFFCF7 | 17.5:1 | AAA |
| #1A1A1A | #FFFFFF | 18.1:1 | AAA |
| #666666 | #FFFCF7 | 6.4:1 | AA |
| #666666 | #FFFFFF | 6.6:1 | AA |
| #999999 | #FFFCF7 | 3.2:1 | AA-large |
| #7F1D1D | #FFFCF7 | 8.2:1 | AAA |
| #7F1D1D | #FFFFFF | 8.5:1 | AAA |
| #FFFFFF | #7F1D1D | 8.5:1 | AAA |

---

## 3. Typography

### 3.1 Font Stack

| Role | Font | Weight(s) | Fallback Stack | Source |
|------|------|-----------|----------------|--------|
| Display | Playfair Display | 400, 700, 900 | Georgia, "Times New Roman", serif | [Google Fonts](https://fonts.google.com/specimen/Playfair+Display) |
| Body | Lora | 400, 400i, 700, 700i | Georgia, "Palatino Linotype", serif | [Google Fonts](https://fonts.google.com/specimen/Lora) |
| UI | Inter | 400, 500, 600, 700 | -apple-system, "Segoe UI", sans-serif | [Google Fonts](https://fonts.google.com/specimen/Inter) |

**Adobe Alternatives:**

| Role | Adobe Font | Notes |
|------|-----------|-------|
| Display | Freight Display Pro | More refined alternate |
| Body | Freight Text Pro | Matched family |
| UI | Aktiv Grotesk | Slightly warmer than Inter |

### 3.2 Font Loading

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Lora:ital,wght@0,400;0,700;1,400;1,700&family=Playfair+Display:wght@400;700;900&display=swap" rel="stylesheet">
```

```css
/* Font-face fallback strategy */
@font-face {
  font-family: 'Playfair Display';
  font-display: swap; /* Show fallback immediately, swap when loaded */
}

@font-face {
  font-family: 'Lora';
  font-display: swap;
}

@font-face {
  font-family: 'Inter';
  font-display: swap;
}
```

### 3.3 Font Role CSS

```css
:root {
  --font-display: 'Playfair Display', Georgia, 'Times New Roman', serif;
  --font-body:    'Lora', Georgia, 'Palatino Linotype', serif;
  --font-ui:      'Inter', -apple-system, 'Segoe UI', Roboto, sans-serif;
}
```

### 3.4 Type Scale

Base size: 16px (1rem). All sizes in rem, px shown for reference.

```
 TYPE SCALE — EDITORIAL
 ──────────────────────────────────────────────────────────────

 Token              Size        Line-Height   Font           Weight
 ─────────────────  ──────────  ────────────  ─────────────  ──────
 --text-display     4rem/64px   1.1           Playfair       900
 --text-h1          3rem/48px   1.15          Playfair       700
 --text-h2          2.25rem/36px 1.2          Playfair       700
 --text-h3          1.75rem/28px 1.25         Playfair       700
 --text-h4          1.375rem/22px 1.3         Playfair       700
 --text-lead        1.375rem/22px 1.6         Lora           400
 --text-body-lg     1.25rem/20px 1.75         Lora           400
 --text-body        1.125rem/18px 1.8         Lora           400
 --text-body-sm     1rem/16px   1.75          Lora           400
 --text-caption     0.875rem/14px 1.5         Inter          400
 --text-overline    0.75rem/12px 1.4          Inter          600
 --text-micro       0.6875rem/11px 1.4        Inter          500

 ──────────────────────────────────────────────────────────────
```

### 3.5 Type Scale CSS

```css
:root {
  /* Size tokens */
  --text-display:    4rem;      /* 64px */
  --text-h1:         3rem;      /* 48px */
  --text-h2:         2.25rem;   /* 36px */
  --text-h3:         1.75rem;   /* 28px */
  --text-h4:         1.375rem;  /* 22px */
  --text-lead:       1.375rem;  /* 22px */
  --text-body-lg:    1.25rem;   /* 20px */
  --text-body:       1.125rem;  /* 18px */
  --text-body-sm:    1rem;      /* 16px */
  --text-caption:    0.875rem;  /* 14px */
  --text-overline:   0.75rem;   /* 12px */
  --text-micro:      0.6875rem; /* 11px */

  /* Line-height tokens */
  --leading-display: 1.1;
  --leading-heading: 1.2;
  --leading-body:    1.8;
  --leading-ui:      1.5;
  --leading-tight:   1.25;

  /* Tracking tokens */
  --tracking-tight:    -0.02em;
  --tracking-normal:    0;
  --tracking-wide:      0.05em;
  --tracking-overline:  0.1em;

  /* Measure */
  --measure:         65ch;
  --measure-narrow:  45ch;
  --measure-wide:    80ch;
}

/* Heading classes */
.text-display {
  font-family: var(--font-display);
  font-size: var(--text-display);
  font-weight: 900;
  line-height: var(--leading-display);
  letter-spacing: var(--tracking-tight);
  color: var(--color-text-primary);
}

.text-h1 {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  line-height: 1.15;
  letter-spacing: var(--tracking-tight);
  color: var(--color-text-primary);
}

.text-h2 {
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 700;
  line-height: var(--leading-heading);
  color: var(--color-text-primary);
}

.text-h3 {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  line-height: var(--leading-tight);
  color: var(--color-text-primary);
}

.text-h4 {
  font-family: var(--font-display);
  font-size: var(--text-h4);
  font-weight: 700;
  line-height: 1.3;
  color: var(--color-text-primary);
}

.text-lead {
  font-family: var(--font-body);
  font-size: var(--text-lead);
  font-weight: 400;
  line-height: 1.6;
  color: var(--color-text-secondary);
}

.text-body-lg {
  font-family: var(--font-body);
  font-size: var(--text-body-lg);
  font-weight: 400;
  line-height: var(--leading-body);
  color: var(--color-text-primary);
}

.text-body {
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-weight: 400;
  line-height: var(--leading-body);
  color: var(--color-text-primary);
}

.text-body-sm {
  font-family: var(--font-body);
  font-size: var(--text-body-sm);
  font-weight: 400;
  line-height: 1.75;
  color: var(--color-text-primary);
}

.text-caption {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-weight: 400;
  line-height: var(--leading-ui);
  color: var(--color-text-secondary);
}

.text-overline {
  font-family: var(--font-ui);
  font-size: var(--text-overline);
  font-weight: 600;
  line-height: 1.4;
  letter-spacing: var(--tracking-overline);
  text-transform: uppercase;
  color: var(--color-text-secondary);
}

.text-micro {
  font-family: var(--font-ui);
  font-size: var(--text-micro);
  font-weight: 500;
  line-height: 1.4;
  color: var(--color-text-tertiary);
}
```

### 3.6 Typographic Details

```css
/* Paragraph spacing */
p + p {
  margin-top: 1.5em;
}

/* Inline links — editorial underline */
a {
  color: var(--color-accent);
  text-decoration: underline;
  text-decoration-thickness: 1px;
  text-underline-offset: 0.15em;
  transition: color 150ms ease-in-out;
}

a:hover {
  color: var(--color-accent-hover);
}

a:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
  border-radius: 2px;
}

/* Em dash usage — editorial punctuation */
.em-dash::before {
  content: ' — ';
}

/* Drop cap — for feature articles / collection intros */
.drop-cap::first-letter {
  font-family: var(--font-display);
  font-weight: 900;
  float: left;
  font-size: 4.5rem;
  line-height: 0.8;
  margin-right: 0.1em;
  margin-top: 0.05em;
  color: var(--color-accent);
}

/* Pull quote */
.pull-quote {
  font-family: var(--font-body);
  font-size: var(--text-h3);
  font-style: italic;
  font-weight: 400;
  line-height: 1.4;
  color: var(--color-text-primary);
  border-left: 3px solid var(--color-accent);
  padding-left: var(--space-6);
  margin: var(--space-10) 0;
  max-width: var(--measure);
}

/* Small caps — for labels and editorial markers */
.small-caps {
  font-family: var(--font-ui);
  font-variant: small-caps;
  letter-spacing: 0.05em;
}

/* Section number — editorial convention */
.section-number {
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 400;
  color: var(--color-text-quaternary);
  margin-right: var(--space-3);
}
```

---

## 4. Spacing & Layout

### 4.1 Spacing Scale

```
 SPACING SCALE (base unit: 8px)
 ──────────────────────────────────────────────────

 Token          Value        Rem       Usage
 ────────────── ──────────── ───────── ──────────────────
 --space-1      4px          0.25rem   Hairline gaps
 --space-2      8px          0.5rem    Icon-to-label
 --space-3      16px         1rem      Inline spacing
 --space-4      24px         1.5rem    Component padding
 --space-5      32px         2rem      Card padding
 --space-6      48px         3rem      Section gaps
 --space-7      64px         4rem      Major sections
 --space-8      80px         5rem      Page sections
 --space-9      120px        7.5rem    Hero/feature areas
 --space-10     160px        10rem     Dramatic whitespace

 ──────────────────────────────────────────────────
```

### 4.2 Spacing CSS

```css
:root {
  --space-1:   0.25rem;   /*  4px */
  --space-2:   0.5rem;    /*  8px */
  --space-3:   1rem;      /* 16px */
  --space-4:   1.5rem;    /* 24px */
  --space-5:   2rem;      /* 32px */
  --space-6:   3rem;      /* 48px */
  --space-7:   4rem;      /* 64px */
  --space-8:   5rem;      /* 80px */
  --space-9:   7.5rem;    /* 120px */
  --space-10:  10rem;     /* 160px */
}
```

### 4.3 Layout Structure

```
 PAGE LAYOUT — CENTERED EDITORIAL
 ┌──────────────────────────────────────────────────────────────────┐
 │                        Browser viewport                          │
 │  ┌────────────────────────────────────────────────────────────┐  │
 │  │ HEADER  64px height │ Logo left │ Nav right │ border-bottom│  │
 │  └────────────────────────────────────────────────────────────┘  │
 │                                                                  │
 │            ┌──────────────────────────────────┐                  │
 │            │     CONTENT COLUMN               │                  │
 │            │     max-width: 960px             │                  │
 │            │     margin: 0 auto               │                  │
 │            │     padding: 0 var(--space-4)    │                  │
 │            │                                  │                  │
 │            │  ┌────────────────────────────┐  │                  │
 │            │  │  READING COLUMN            │  │                  │
 │            │  │  max-width: 65ch           │  │                  │
 │            │  │  (body text, summaries)    │  │                  │
 │            │  └────────────────────────────┘  │                  │
 │            │                                  │                  │
 │            └──────────────────────────────────┘                  │
 │                                                                  │
 │  ┌────────────────────────────────────────────────────────────┐  │
 │  │ FOOTER  generous padding │ simple links │ editorial credits│  │
 │  └────────────────────────────────────────────────────────────┘  │
 └──────────────────────────────────────────────────────────────────┘
```

### 4.4 Layout CSS

```css
/* Page wrapper */
.page {
  background-color: var(--color-bg);
  min-height: 100vh;
}

/* Content column */
.content {
  max-width: 960px;
  margin-left: auto;
  margin-right: auto;
  padding-left: var(--space-4);
  padding-right: var(--space-4);
}

/* Reading column — for body text and summaries */
.reading-column {
  max-width: var(--measure); /* 65ch */
}

/* Narrow column — for focused content */
.narrow-column {
  max-width: var(--measure-narrow); /* 45ch */
}

/* Wide column — for data tables, grids */
.wide-column {
  max-width: var(--measure-wide); /* 80ch */
}

/* Full bleed — breaks out of content column */
.full-bleed {
  width: 100vw;
  margin-left: calc(-50vw + 50%);
}
```

### 4.5 Site Detail — Asymmetric Layout

```
 SITE DETAIL PAGE — ASYMMETRIC
 ┌──────────────────────────────────────────────────────────┐
 │  max-width: 960px                                        │
 │                                                          │
 │  ┌──────────────────────────────┬───────────────────┐   │
 │  │  MAIN COLUMN (62%)           │  SIDEBAR (34%)     │   │
 │  │                              │                    │   │
 │  │  Site title (H1)             │  Score badge       │   │
 │  │  URL + last checked          │  Score breakdown   │   │
 │  │  Editorial summary           │  Tags              │   │
 │  │  Screenshot                  │  Similar sites     │   │
 │  │  Full description            │  Collections       │   │
 │  │                              │  Submit correction  │   │
 │  └──────────────────────────────┘───────────────────┘   │
 │      gap: var(--space-7)  (4%)                           │
 └──────────────────────────────────────────────────────────┘
```

```css
/* Asymmetric detail layout */
.detail-layout {
  display: grid;
  grid-template-columns: 1fr 340px;
  gap: var(--space-7);
  align-items: start;
}

@media (max-width: 768px) {
  .detail-layout {
    grid-template-columns: 1fr;
    gap: var(--space-6);
  }
}
```

### 4.6 Vertical Rhythm

```css
/* Section spacing */
.section + .section {
  margin-top: var(--space-8);
}

/* Within sections */
.section-header {
  margin-bottom: var(--space-6);
}

/* Horizontal rule — editorial separator */
.rule {
  border: none;
  border-top: 1px solid var(--color-border-rule);
  margin: var(--space-6) 0;
}

.rule--thick {
  border-top-width: 2px;
}

.rule--subtle {
  border-top-color: var(--color-border-subtle);
}

/* Rule above section headers — editorial convention */
.section-header::before {
  content: '';
  display: block;
  width: 100%;
  height: 1px;
  background: var(--color-border-rule);
  margin-bottom: var(--space-4);
}
```

---

## 5. Component Library

### 5.1 Base Component Reset

```css
/* Editorial base reset */
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  font-size: 16px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
}

body {
  font-family: var(--font-body);
  font-size: var(--text-body);
  line-height: var(--leading-body);
  color: var(--color-text-primary);
  background-color: var(--color-bg);
}

img {
  max-width: 100%;
  height: auto;
  display: block;
}

/* Remove default list styles */
ul, ol {
  list-style: none;
}
```

### 5.2 Component Naming Convention

BEM-style with editorial prefix:

```
.ed-{component}
.ed-{component}__{element}
.ed-{component}--{modifier}
```

Examples:
- `.ed-card`, `.ed-card__title`, `.ed-card--featured`
- `.ed-nav`, `.ed-nav__link`, `.ed-nav__link--active`
- `.ed-score`, `.ed-score__value`, `.ed-score--high`

---

## 6. Navigation

### 6.1 Header Structure

```
 HEADER — 64px
 ┌──────────────────────────────────────────────────────────────┐
 │                                                              │
 │  gotta.cc               Browse  Search  Collections  Submit  │
 │  (Playfair 22px)        (Inter 14px uppercase 0.05em)        │
 │                                                              │
 ├──────────────────────────────────────────────────────────────┤
 │  1px solid var(--color-border-rule)                          │
 └──────────────────────────────────────────────────────────────┘
```

### 6.2 Header CSS

```css
.ed-header {
  position: sticky;
  top: 0;
  z-index: 100;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 var(--space-4);
  background-color: var(--color-bg);
  border-bottom: 1px solid var(--color-border-rule);
  transition: transform 300ms ease-in-out;
}

/* Hide on scroll down, show on scroll up */
.ed-header--hidden {
  transform: translateY(-100%);
}

/* Logo / publication name */
.ed-header__logo {
  font-family: var(--font-display);
  font-size: var(--text-h4);
  font-weight: 700;
  color: var(--color-text-primary);
  text-decoration: none;
  letter-spacing: var(--tracking-tight);
}

.ed-header__logo:hover {
  color: var(--color-accent);
}

/* Navigation container */
.ed-nav {
  display: flex;
  align-items: center;
  gap: var(--space-5);
}

/* Navigation link — default */
.ed-nav__link {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-weight: 500;
  letter-spacing: var(--tracking-wide);
  text-transform: uppercase;
  color: var(--color-text-secondary);
  text-decoration: none;
  padding: var(--space-2) 0;
  position: relative;
  transition: color 150ms ease-in-out;
}

/* Navigation link — hover */
.ed-nav__link:hover {
  color: var(--color-text-primary);
}

/* Navigation link — active/current */
.ed-nav__link--active {
  color: var(--color-text-primary);
}

.ed-nav__link--active::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  right: 0;
  height: 2px;
  background-color: var(--color-accent);
}

/* Navigation link — focus */
.ed-nav__link:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
  border-radius: 2px;
}
```

### 6.3 Scroll-Aware Header JavaScript

```javascript
// Minimal scroll direction detection for header hide/show
let lastScrollY = 0;
const header = document.querySelector('.ed-header');

window.addEventListener('scroll', () => {
  const currentScrollY = window.scrollY;
  if (currentScrollY > lastScrollY && currentScrollY > 64) {
    header.classList.add('ed-header--hidden');
  } else {
    header.classList.remove('ed-header--hidden');
  }
  lastScrollY = currentScrollY;
}, { passive: true });
```

### 6.4 Reading Progress Indicator

```css
.ed-progress {
  position: fixed;
  top: 0;
  left: 0;
  width: 0%;
  height: 2px;
  background-color: var(--color-accent);
  z-index: 101;
  transition: width 50ms linear;
}
```

```javascript
// Reading progress bar
const progress = document.querySelector('.ed-progress');
window.addEventListener('scroll', () => {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const scrollPercent = (scrollTop / docHeight) * 100;
  progress.style.width = `${scrollPercent}%`;
}, { passive: true });
```

### 6.5 Mobile Navigation

```css
@media (max-width: 768px) {
  .ed-header {
    height: 56px;
  }

  .ed-header__logo {
    font-size: var(--text-body-lg);
  }

  .ed-nav {
    gap: var(--space-3);
  }

  .ed-nav__link {
    font-size: var(--text-micro);
  }
}

@media (max-width: 480px) {
  /* Stack nav below logo on very small screens */
  .ed-header {
    height: auto;
    flex-direction: column;
    padding: var(--space-3) var(--space-4);
    gap: var(--space-2);
  }

  .ed-nav {
    width: 100%;
    justify-content: space-between;
  }
}
```

---

## 7. Search

### 7.1 Search Input Structure

```
 SEARCH — EDITORIAL SIMPLICITY
 ┌──────────────────────────────────────────────────────────────┐
 │                                                              │
 │  ┌────────────────────────────────────────────────────────┐  │
 │  │  Search the directory...                  (italic Lora) │  │
 │  └────────────────────────────────────────────────────────┘  │
 │  1px solid var(--color-border-subtle)                        │
 │                                                              │
 └──────────────────────────────────────────────────────────────┘
```

### 7.2 Search CSS

```css
/* Search container */
.ed-search {
  max-width: var(--measure);
  margin: 0 auto;
}

/* Search input — default */
.ed-search__input {
  width: 100%;
  padding: var(--space-3) var(--space-4);
  font-family: var(--font-body);
  font-size: var(--text-body);
  font-style: normal;
  line-height: var(--leading-body);
  color: var(--color-text-primary);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border-subtle);
  border-radius: 2px;
  transition: border-color 150ms ease-in-out;
}

/* Search input — placeholder */
.ed-search__input::placeholder {
  font-family: var(--font-body);
  font-style: italic;
  color: var(--color-text-tertiary);
}

/* Search input — focus */
.ed-search__input:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 1px var(--color-accent);
}

/* Search input — focus-visible */
.ed-search__input:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
}

/* Search results container */
.ed-search__results {
  margin-top: var(--space-6);
}

/* Search result count */
.ed-search__count {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-secondary);
  margin-bottom: var(--space-4);
  padding-bottom: var(--space-3);
  border-bottom: 1px solid var(--color-border-subtle);
}

/* Search result item — article-style */
.ed-search__result {
  padding: var(--space-4) 0;
  border-bottom: 1px solid var(--color-border-subtle);
}

.ed-search__result:last-child {
  border-bottom: none;
}

/* Result category overline */
.ed-search__result-category {
  font-family: var(--font-ui);
  font-size: var(--text-overline);
  font-weight: 600;
  letter-spacing: var(--tracking-overline);
  text-transform: uppercase;
  color: var(--color-text-secondary);
  margin-bottom: var(--space-2);
}

/* Result title */
.ed-search__result-title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  line-height: var(--leading-tight);
  color: var(--color-text-primary);
  margin-bottom: var(--space-2);
}

.ed-search__result-title a {
  color: inherit;
  text-decoration: none;
}

.ed-search__result-title a:hover {
  color: var(--color-accent);
}

/* Result excerpt */
.ed-search__result-excerpt {
  font-family: var(--font-body);
  font-size: var(--text-body);
  line-height: var(--leading-body);
  color: var(--color-text-secondary);
  max-width: var(--measure);
}

/* Result metadata */
.ed-search__result-meta {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  margin-top: var(--space-2);
}

/* Search highlight in results */
.ed-search__highlight {
  background-color: var(--color-accent-light);
  color: var(--color-accent);
  padding: 0.05em 0.15em;
  border-radius: 1px;
}

/* Empty state */
.ed-search__empty {
  text-align: center;
  padding: var(--space-8) 0;
}

.ed-search__empty-title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-style: italic;
  color: var(--color-text-tertiary);
  margin-bottom: var(--space-3);
}

.ed-search__empty-text {
  font-family: var(--font-body);
  font-size: var(--text-body);
  color: var(--color-text-tertiary);
}
```

---

## 8. Quality Score System

### 8.1 Score Architecture

Each site receives a composite score (0-100) from five dimensions, each scored 0-20:

| Dimension | Measures | Icon Metaphor |
|-----------|----------|---------------|
| Originality | Unique perspective, not derivative | — |
| Depth | Thoroughness, detail, substance | — |
| Craft | Writing quality, design, technical execution | — |
| Human Signal | Evidence of human authorship vs. AI slop | — |
| Freshness | Active maintenance, current content | — |

No icons are used. Dimension names are the interface.

### 8.2 Score Badge — Large Format

```
 SCORE BADGE — DETAIL PAGE SIDEBAR
 ┌──────────────────────────────┐
 │                              │
 │  ──────────────────────────  │  1px rule
 │  EDITOR'S PICK               │  overline, small caps
 │  ──────────────────────────  │  1px rule
 │                              │
 │         94                   │  Playfair Display, 64px
 │        / 100                 │  Inter caption, tertiary
 │                              │
 │  Originality      ████░  18 │  dimension bars
 │  Depth            █████  20 │
 │  Craft            ████░  19 │
 │  Human Signal     █████  20 │
 │  Freshness        ████░  17 │
 │                              │
 │  ──────────────────────────  │
 │  Indexed: Jan 2026           │  caption metadata
 │  Checked: Mar 2026           │
 │  ──────────────────────────  │
 │                              │
 └──────────────────────────────┘
```

### 8.3 Score CSS

```css
/* Score badge container */
.ed-score {
  background-color: var(--color-surface);
  border: 1px solid var(--color-border-subtle);
  padding: var(--space-5);
}

/* Editor's Pick label */
.ed-score__pick-label {
  font-family: var(--font-ui);
  font-size: var(--text-overline);
  font-weight: 600;
  letter-spacing: var(--tracking-overline);
  text-transform: uppercase;
  font-variant: small-caps;
  color: var(--color-accent);
  text-align: center;
  padding: var(--space-3) 0;
  border-top: 1px solid var(--color-border-rule);
  border-bottom: 1px solid var(--color-border-rule);
  margin-bottom: var(--space-5);
}

/* Hide when not editor's pick */
.ed-score:not(.ed-score--editors-pick) .ed-score__pick-label {
  display: none;
}

/* Composite score — large number */
.ed-score__composite {
  text-align: center;
  margin-bottom: var(--space-5);
}

.ed-score__value {
  font-family: var(--font-display);
  font-size: var(--text-display);
  font-weight: 900;
  line-height: 1;
  color: var(--color-text-primary);
}

.ed-score__denominator {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  margin-left: var(--space-1);
}

/* Score color coding by range */
.ed-score--high .ed-score__value {
  color: var(--color-text-primary);
}

.ed-score--mid .ed-score__value {
  color: var(--color-text-secondary);
}

.ed-score--low .ed-score__value {
  color: var(--color-text-tertiary);
}

/* Dimension breakdown */
.ed-score__dimensions {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

/* Individual dimension row */
.ed-score__dimension {
  display: grid;
  grid-template-columns: 120px 1fr 32px;
  align-items: center;
  gap: var(--space-3);
}

/* Dimension label */
.ed-score__dimension-label {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-secondary);
}

/* Dimension bar track */
.ed-score__bar-track {
  height: 4px;
  background-color: var(--color-border-subtle);
  border-radius: 2px;
  overflow: hidden;
}

/* Dimension bar fill */
.ed-score__bar-fill {
  height: 100%;
  background-color: var(--color-accent);
  border-radius: 2px;
  transition: width 300ms ease-in-out;
}

/* Dimension score number */
.ed-score__dimension-value {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-weight: 600;
  color: var(--color-text-primary);
  text-align: right;
}

/* Metadata below score */
.ed-score__meta {
  margin-top: var(--space-5);
  padding-top: var(--space-4);
  border-top: 1px solid var(--color-border-subtle);
}

.ed-score__meta-item {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  margin-bottom: var(--space-2);
}

.ed-score__meta-item:last-child {
  margin-bottom: 0;
}
```

### 8.4 Score Badge — Compact (Inline with Listing)

For use in listing cards and search results:

```
 COMPACT SCORE — INLINE
 ┌─────────┐
 │   94    │  Playfair 28px
 │  /100   │  Inter 11px
 └─────────┘
```

```css
/* Compact score — for listing cards */
.ed-score-compact {
  text-align: center;
  min-width: 64px;
}

.ed-score-compact__value {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  line-height: 1;
  color: var(--color-text-primary);
}

.ed-score-compact__denominator {
  font-family: var(--font-ui);
  font-size: var(--text-micro);
  color: var(--color-text-tertiary);
}
```

### 8.5 Score Count-Up Animation

```javascript
// Score count-up on scroll into view
const scoreElements = document.querySelectorAll('[data-score-value]');

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const el = entry.target;
      const target = parseInt(el.dataset.scoreValue, 10);
      animateScore(el, 0, target, 300);
      observer.unobserve(el);
    }
  });
}, { threshold: 0.5 });

scoreElements.forEach(el => observer.observe(el));

function animateScore(el, start, end, duration) {
  const startTime = performance.now();
  function update(currentTime) {
    const elapsed = currentTime - startTime;
    const progress = Math.min(elapsed / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3); // ease-out cubic
    el.textContent = Math.round(start + (end - start) * eased);
    if (progress < 1) {
      requestAnimationFrame(update);
    }
  }
  requestAnimationFrame(update);
}
```

### 8.6 Score Thresholds

| Range | Classification | Visual Treatment |
|-------|---------------|-----------------|
| 90-100 | Exceptional | `--color-text-primary`, eligible for "Editor's Pick" |
| 75-89 | Strong | `--color-text-primary` |
| 60-74 | Solid | `--color-text-secondary` |
| 40-59 | Mixed | `--color-text-secondary` |
| 0-39 | Weak | `--color-text-tertiary` (rarely listed) |

---

## 9. Category Browser

### 9.1 Category Page Structure

```
 CATEGORY BROWSER — TYPOGRAPHIC HIERARCHY
 ──────────────────────────────────────────────────────────────

 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TECHNOLOGY                                          142 sites
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Explore tools, frameworks, and platforms built by people
 who care about craft.

 ──────────────────────────────────────────────────────────

   AI & Machine Learning                              38
   │  Natural Language Processing                     12
   │  Computer Vision                                  8
   │  MLOps & Infrastructure                          11
   │  Research & Papers                                7

   Developer Tools                                    27
   │  Code Editors & IDEs                              6
   │  CLI Tools                                        9
   │  Documentation                                    5
   │  Package Managers                                 7

   Web Development                                    34
   │  Frameworks                                      11
   │  CSS & Design Systems                             8
   │  Performance                                      7
   ●  Accessibility                                    8   ← featured

   Hardware & Electronics                             19
   │  Raspberry Pi & Arduino                           6
   │  Mechanical Keyboards                             5
   │  Home Lab                                         8

   Open Source                                        24
   │  Project Showcases                               10
   │  Maintainer Blogs                                 7
   │  Funding & Sustainability                         7

 ──────────────────────────────────────────────────────────────
```

### 9.2 Category Browser CSS

```css
/* Category section header */
.ed-category-header {
  padding-top: var(--space-6);
  margin-bottom: var(--space-6);
  border-top: 2px solid var(--color-border-rule);
}

.ed-category-header__title {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  line-height: 1.15;
  color: var(--color-text-primary);
  display: flex;
  justify-content: space-between;
  align-items: baseline;
}

.ed-category-header__count {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-weight: 400;
  color: var(--color-text-tertiary);
}

.ed-category-header__description {
  font-family: var(--font-body);
  font-size: var(--text-lead);
  line-height: 1.6;
  color: var(--color-text-secondary);
  margin-top: var(--space-3);
  max-width: var(--measure);
}

/* Category list container */
.ed-category-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
  border-top: 1px solid var(--color-border-subtle);
  padding-top: var(--space-6);
}

/* Top-level category group */
.ed-category-group {
  /* No special container styling — typography carries it */
}

/* Category link — top level */
.ed-category-group__name {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  line-height: var(--leading-tight);
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: var(--space-3);
}

.ed-category-group__name a {
  color: var(--color-text-primary);
  text-decoration: none;
  transition: color 150ms ease-in-out;
}

.ed-category-group__name a:hover {
  color: var(--color-accent);
}

.ed-category-group__name a:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
  border-radius: 2px;
}

.ed-category-group__count {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-weight: 400;
  color: var(--color-text-tertiary);
  flex-shrink: 0;
  margin-left: var(--space-3);
}

/* Subcategory list */
.ed-subcategory-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding-left: var(--space-4);
  border-left: 1px solid var(--color-border-subtle);
}

/* Subcategory item */
.ed-subcategory {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
}

.ed-subcategory__name {
  font-family: var(--font-ui);
  font-size: var(--text-body-sm);
  font-weight: 400;
  color: var(--color-text-secondary);
}

.ed-subcategory__name a {
  color: inherit;
  text-decoration: none;
  transition: color 150ms ease-in-out;
}

.ed-subcategory__name a:hover {
  color: var(--color-accent);
}

.ed-subcategory__name a:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
  border-radius: 2px;
}

.ed-subcategory__count {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  flex-shrink: 0;
  margin-left: var(--space-3);
}

/* Featured subcategory — burgundy accent dot */
.ed-subcategory--featured .ed-subcategory__name::before {
  content: '';
  display: inline-block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: var(--color-accent);
  margin-right: var(--space-2);
  vertical-align: middle;
}

.ed-subcategory--featured .ed-subcategory__name {
  color: var(--color-text-primary);
  font-weight: 500;
}
```

### 9.3 Category Breadcrumb

```css
/* Breadcrumb — editorial minimal */
.ed-breadcrumb {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  margin-bottom: var(--space-6);
  display: flex;
  align-items: center;
  gap: var(--space-2);
  flex-wrap: wrap;
}

.ed-breadcrumb__separator {
  color: var(--color-text-quaternary);
}

.ed-breadcrumb__separator::after {
  content: '/';
}

.ed-breadcrumb a {
  color: var(--color-text-secondary);
  text-decoration: none;
}

.ed-breadcrumb a:hover {
  color: var(--color-accent);
  text-decoration: underline;
}

.ed-breadcrumb__current {
  color: var(--color-text-primary);
}
```

---

## 10. Site Listing Cards

### 10.1 Listing Card Structure

```
 SITE LISTING CARD
 ──────────────────────────────────────────────────────────────

 AI & MACHINE LEARNING                                    12px overline
                                                          uppercase

 Simon Willison's Weblog                                  28px Playfair
                                                          H3 serif

 A prolific and deeply technical blog covering LLMs,       18px Lora
 prompt engineering, datasette, and the practical          body serif
 implications of AI for developers. Willison's daily       2-3 lines
 link posts are an essential feed for anyone building
 with language models.

 simonwillison.net                                        14px Inter
 Score: 94/100  ·  Indexed Jan 2026  ·  #ai #llm #blog   caption text

 ──────────────────────────────────────────────────────────────
 1px border-bottom subtle
```

### 10.2 Listing Card CSS

```css
/* Listing card container */
.ed-listing {
  padding: var(--space-5) 0;
  border-bottom: 1px solid var(--color-border-subtle);
}

.ed-listing:first-child {
  padding-top: 0;
}

.ed-listing:last-child {
  border-bottom: none;
}

/* Category overline */
.ed-listing__category {
  font-family: var(--font-ui);
  font-size: var(--text-overline);
  font-weight: 600;
  letter-spacing: var(--tracking-overline);
  text-transform: uppercase;
  color: var(--color-text-secondary);
  margin-bottom: var(--space-2);
}

.ed-listing__category a {
  color: inherit;
  text-decoration: none;
}

.ed-listing__category a:hover {
  color: var(--color-accent);
}

/* Site title */
.ed-listing__title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  line-height: var(--leading-tight);
  color: var(--color-text-primary);
  margin-bottom: var(--space-3);
}

.ed-listing__title a {
  color: inherit;
  text-decoration: none;
  transition: color 150ms ease-in-out;
}

.ed-listing__title a:hover {
  color: var(--color-accent);
}

.ed-listing__title a:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
  border-radius: 2px;
}

/* Editorial summary */
.ed-listing__summary {
  font-family: var(--font-body);
  font-size: var(--text-body);
  line-height: var(--leading-body);
  color: var(--color-text-primary);
  max-width: var(--measure);
  margin-bottom: var(--space-3);

  /* Clamp to 3 lines */
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Metadata row */
.ed-listing__meta {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  display: flex;
  align-items: center;
  gap: var(--space-2);
  flex-wrap: wrap;
}

/* URL */
.ed-listing__url {
  color: var(--color-text-secondary);
}

.ed-listing__url a {
  color: inherit;
  text-decoration: none;
}

.ed-listing__url a:hover {
  color: var(--color-accent);
  text-decoration: underline;
}

/* Metadata separator */
.ed-listing__meta-sep {
  color: var(--color-text-quaternary);
}

.ed-listing__meta-sep::after {
  content: '\00B7'; /* middle dot */
}

/* Inline score */
.ed-listing__score {
  font-weight: 600;
  color: var(--color-text-secondary);
}

/* Tags */
.ed-listing__tags {
  display: flex;
  gap: var(--space-2);
  flex-wrap: wrap;
}

.ed-listing__tag {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  text-decoration: underline;
  text-decoration-thickness: 1px;
  text-underline-offset: 0.15em;
  transition: color 150ms ease-in-out;
}

.ed-listing__tag:hover {
  color: var(--color-accent);
}
```

### 10.3 Listing Card with Screenshot

When screenshots are shown (e.g., featured listings):

```css
/* Listing with screenshot */
.ed-listing--with-screenshot {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-4);
}

/* Screenshot container */
.ed-listing__screenshot {
  width: 100%;
  aspect-ratio: 16 / 10;
  overflow: hidden;
  border: 1px solid var(--color-border-subtle);
}

.ed-listing__screenshot img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: top;
}

/* Screenshot caption */
.ed-listing__screenshot-caption {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-style: italic;
  color: var(--color-text-tertiary);
  margin-top: var(--space-2);
}
```

### 10.4 Listing Card — Featured Variant

```css
/* Featured listing — top pick with more presence */
.ed-listing--featured {
  padding: var(--space-5);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border-subtle);
  border-bottom: 1px solid var(--color-border-subtle);
  margin-bottom: var(--space-4);
}

.ed-listing--featured .ed-listing__title {
  font-size: var(--text-h2);
}

.ed-listing--featured .ed-listing__summary {
  font-size: var(--text-body-lg);
  -webkit-line-clamp: 5; /* Show more for featured */
}

/* Featured badge */
.ed-listing--featured::before {
  content: '';
  display: block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: var(--color-accent);
  margin-bottom: var(--space-3);
}
```

### 10.5 Listing Card — Compact Variant

For dense listing views:

```css
/* Compact listing — category index view */
.ed-listing--compact {
  padding: var(--space-3) 0;
  display: grid;
  grid-template-columns: 1fr auto;
  gap: var(--space-3);
  align-items: start;
}

.ed-listing--compact .ed-listing__category {
  display: none; /* Already in category context */
}

.ed-listing--compact .ed-listing__title {
  font-size: var(--text-h4);
  margin-bottom: var(--space-1);
}

.ed-listing--compact .ed-listing__summary {
  font-size: var(--text-body-sm);
  -webkit-line-clamp: 2;
}
```

---

## 11. Site Detail Page

### 11.1 Detail Page Structure

```
 SITE DETAIL PAGE
 ──────────────────────────────────────────────────────────────

 AI & MACHINE LEARNING / NLP                         breadcrumb

 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                                     2px rule

 Simon Willison's Weblog                             48px H1
 simonwillison.net                                   byline

 ──────────────────────────────────────────────────  ┌─────────┐
                                                     │         │
 A prolific and deeply technical blog covering       │   94    │
 LLMs, prompt engineering, datasette, and the        │  /100   │
 practical implications of AI for developers.        │         │
 Willison's daily link posts are an essential         │ Editor's│
 feed for anyone building with language models.       │  Pick   │
 His commitment to open source and transparent       │         │
 tooling makes this one of the most valuable         │ Orig 18 │
 resources in the AI development space.              │ Dept 20 │
                                                     │ Crft 19 │
 ┌────────────────────────────────────────────────┐  │ Humn 20 │
 │                                                │  │ Frsh 17 │
 │           [SCREENSHOT — full width]            │  │         │
 │                                                │  │ Indexed │
 └────────────────────────────────────────────────┘  │ Jan '26 │
 Homepage as of March 2026                           │         │
                                                     │ Checked │
 "The thing I love about working with LLMs           │ Mar '26 │
  is that every week brings genuinely new            └─────────┘
  capabilities."
  — Pull quote from site

 Tags: #ai  #llm  #blog  #python  #open-source

 ──────────────────────────────────────────────────────────────
 Similar sites  ·  Add to collection  ·  Report issue
 ──────────────────────────────────────────────────────────────
```

### 11.2 Detail Page CSS

```css
/* Detail page hero area */
.ed-detail {
  padding-top: var(--space-6);
}

/* Top rule */
.ed-detail__rule {
  border: none;
  border-top: 2px solid var(--color-border-rule);
  margin-bottom: var(--space-5);
}

/* Site title */
.ed-detail__title {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  line-height: 1.15;
  color: var(--color-text-primary);
  margin-bottom: var(--space-2);
}

/* Site URL byline */
.ed-detail__url {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-secondary);
  margin-bottom: var(--space-6);
}

.ed-detail__url a {
  color: inherit;
  text-decoration: underline;
  text-decoration-thickness: 1px;
}

.ed-detail__url a:hover {
  color: var(--color-accent);
}

/* Full editorial summary */
.ed-detail__summary {
  font-family: var(--font-body);
  font-size: var(--text-body-lg);
  line-height: var(--leading-body);
  color: var(--color-text-primary);
  max-width: var(--measure);
  margin-bottom: var(--space-6);
}

/* Screenshot — editorial full-width with caption */
.ed-detail__screenshot {
  margin-bottom: var(--space-6);
}

.ed-detail__screenshot img {
  width: 100%;
  border: 1px solid var(--color-border-subtle);
}

.ed-detail__screenshot figcaption {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-style: italic;
  color: var(--color-text-tertiary);
  margin-top: var(--space-2);
}

/* Pull quote from site */
.ed-detail__pullquote {
  font-family: var(--font-body);
  font-size: var(--text-h3);
  font-style: italic;
  font-weight: 400;
  line-height: 1.4;
  color: var(--color-text-primary);
  border-left: 3px solid var(--color-accent);
  padding-left: var(--space-6);
  margin: var(--space-7) 0;
  max-width: var(--measure);
}

.ed-detail__pullquote-attribution {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-style: normal;
  color: var(--color-text-tertiary);
  margin-top: var(--space-3);
}

/* Tags section */
.ed-detail__tags {
  display: flex;
  gap: var(--space-3);
  flex-wrap: wrap;
  margin-bottom: var(--space-6);
}

.ed-detail__tag {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-secondary);
  text-decoration: underline;
  text-decoration-thickness: 1px;
  text-underline-offset: 0.15em;
}

.ed-detail__tag:hover {
  color: var(--color-accent);
}

/* Actions bar */
.ed-detail__actions {
  display: flex;
  gap: var(--space-4);
  align-items: center;
  padding: var(--space-4) 0;
  border-top: 1px solid var(--color-border-subtle);
  border-bottom: 1px solid var(--color-border-subtle);
  font-family: var(--font-ui);
  font-size: var(--text-caption);
}

.ed-detail__action {
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: color 150ms ease-in-out;
}

.ed-detail__action:hover {
  color: var(--color-accent);
}

.ed-detail__action-sep {
  color: var(--color-text-quaternary);
}

.ed-detail__action-sep::after {
  content: '\00B7';
}
```

### 11.3 Similar Sites Section

```css
/* Similar sites — compact listing below detail */
.ed-similar {
  margin-top: var(--space-7);
}

.ed-similar__heading {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  margin-bottom: var(--space-4);
  padding-bottom: var(--space-3);
  border-bottom: 1px solid var(--color-border-rule);
}

/* Reuse .ed-listing--compact for similar site items */
```

---

## 12. Surprise Me

### 12.1 Surprise Me Button

```
 "SURPRISE ME" — DISTINCTIVE EDITORIAL CTA

 Before hover:
 ┌─────────────────────────────────────────┐
 │                                         │
 │     Surprise me                  ->     │
 │     (italic Lora)          (thin arrow) │
 │                                         │
 └─────────────────────────────────────────┘

 On hover:
 ┌─────────────────────────────────────────┐
 │                                         │
 │     Surprise me                  ->     │
 │     ──────────────                      │
 │     (burgundy underline appears)        │
 │                                         │
 └─────────────────────────────────────────┘
```

### 12.2 Surprise Me CSS

```css
/* Surprise Me — distinctive editorial element */
.ed-surprise {
  display: inline-flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) 0;
  cursor: pointer;
  background: none;
  border: none;
  position: relative;
}

.ed-surprise__label {
  font-family: var(--font-body);
  font-size: var(--text-h4);
  font-style: italic;
  font-weight: 400;
  color: var(--color-text-primary);
  transition: color 150ms ease-in-out;
  position: relative;
}

.ed-surprise__label::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 1px;
  background-color: var(--color-accent);
  transition: width 200ms ease-in-out;
}

.ed-surprise:hover .ed-surprise__label::after {
  width: 100%;
}

.ed-surprise:hover .ed-surprise__label {
  color: var(--color-accent);
}

/* Arrow */
.ed-surprise__arrow {
  font-family: var(--font-ui);
  font-size: var(--text-body);
  color: var(--color-text-tertiary);
  transition: transform 200ms ease-in-out, color 150ms ease-in-out;
}

.ed-surprise__arrow::after {
  content: '\2192'; /* right arrow → */
}

.ed-surprise:hover .ed-surprise__arrow {
  transform: translateX(4px);
  color: var(--color-accent);
}

/* Focus */
.ed-surprise:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
  border-radius: 2px;
}

/* Active press */
.ed-surprise:active .ed-surprise__label {
  color: var(--color-accent-hover);
}
```

### 12.3 Surprise Me — Page Variant

When used as a standalone page feature (e.g., hero or empty state):

```css
/* Large hero variant */
.ed-surprise--hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: var(--space-9) 0;
}

.ed-surprise--hero .ed-surprise__label {
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-style: italic;
}

.ed-surprise--hero .ed-surprise__subtext {
  font-family: var(--font-body);
  font-size: var(--text-body);
  color: var(--color-text-tertiary);
  margin-top: var(--space-3);
  max-width: var(--measure-narrow);
}
```

---

## 13. Submission Flow

### 13.1 Submission Page Structure

```
 SUBMISSION FLOW — EDITORIAL RESTRAINT
 ──────────────────────────────────────────────────────────────

 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Submit a Site
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Every site in our directory is reviewed by our editorial
 AI and scored for originality, depth, and craft. Submit
 a site you think belongs here.

 ──────────────────────────────────────────────────────────

 URL *
 ┌────────────────────────────────────────────────────────┐
 │  https://                                              │
 └────────────────────────────────────────────────────────┘

 Suggested Category
 ┌────────────────────────────────────────────────────────┐
 │  Select a category...                           ▼     │
 └────────────────────────────────────────────────────────┘

 Why this site? (optional)
 ┌────────────────────────────────────────────────────────┐
 │                                                        │
 │  Tell us what makes this site worth including...       │
 │                                                        │
 │                                                        │
 └────────────────────────────────────────────────────────┘

 Your email (optional — for submission updates)
 ┌────────────────────────────────────────────────────────┐
 │  you@example.com                                       │
 └────────────────────────────────────────────────────────┘

                                       ┌──────────────┐
                                       │   Submit      │
                                       └──────────────┘

 ──────────────────────────────────────────────────────────
 We review submissions weekly. Sites scoring above 60
 are added to the directory. We don't list SEO farms,
 AI-generated content mills, or aggregator sites.
 ──────────────────────────────────────────────────────────
```

### 13.2 Submission Form CSS

```css
/* Submission page */
.ed-submit {
  max-width: var(--measure);
  margin: 0 auto;
  padding: var(--space-6) 0;
}

.ed-submit__title {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  margin-bottom: var(--space-3);
  padding-top: var(--space-4);
  border-top: 2px solid var(--color-border-rule);
}

.ed-submit__intro {
  font-family: var(--font-body);
  font-size: var(--text-lead);
  color: var(--color-text-secondary);
  line-height: 1.6;
  margin-bottom: var(--space-6);
  padding-bottom: var(--space-6);
  border-bottom: 1px solid var(--color-border-subtle);
}

/* Form group */
.ed-form-group {
  margin-bottom: var(--space-5);
}

/* Labels */
.ed-form-group__label {
  display: block;
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: var(--space-2);
}

.ed-form-group__label--required::after {
  content: ' *';
  color: var(--color-accent);
}

/* Optional indicator */
.ed-form-group__optional {
  font-weight: 400;
  color: var(--color-text-tertiary);
  font-style: italic;
}

/* Footer note */
.ed-submit__footer {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  line-height: 1.6;
  margin-top: var(--space-6);
  padding-top: var(--space-4);
  border-top: 1px solid var(--color-border-subtle);
}

/* Success state */
.ed-submit__success {
  text-align: center;
  padding: var(--space-8) 0;
}

.ed-submit__success-title {
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: var(--space-3);
}

.ed-submit__success-text {
  font-family: var(--font-body);
  font-size: var(--text-body);
  color: var(--color-text-secondary);
  max-width: var(--measure-narrow);
  margin: 0 auto;
}
```

### 13.3 Submission Status States

```css
/* Submission status — shown after submit or on status page */
.ed-status {
  padding: var(--space-4);
  border: 1px solid var(--color-border-subtle);
  background-color: var(--color-surface);
}

.ed-status__label {
  font-family: var(--font-ui);
  font-size: var(--text-overline);
  font-weight: 600;
  letter-spacing: var(--tracking-overline);
  text-transform: uppercase;
  margin-bottom: var(--space-2);
}

.ed-status--pending .ed-status__label {
  color: var(--color-warning);
}

.ed-status--approved .ed-status__label {
  color: var(--color-success);
}

.ed-status--rejected .ed-status__label {
  color: var(--color-text-tertiary);
}

.ed-status__message {
  font-family: var(--font-body);
  font-size: var(--text-body-sm);
  color: var(--color-text-secondary);
}
```

---

## 14. Collections & Lists

### 14.1 Collections — Magazine "Best Of" Styling

```
 COLLECTION PAGE — MAGAZINE ISSUE
 ──────────────────────────────────────────────────────────────

 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 COLLECTIONS                                         overline
 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Best of Independent Web, 2025                       H1 title
 ──────────────────────────────────────────────────────────────

 Our editors selected 25 sites that represent the              lead text
 best of what the independent web produced last year.
 No platforms. No corporations. Just people making
 remarkable things.

 ──────────────────────────────────────────────────────────────

 01.  Simon Willison's Weblog                    94/100
      AI & Machine Learning
      The essential daily feed for developers building
      with language models.

 02.  Maggie Appleton                            91/100
      Design & Digital Gardens
      Visual essays at the intersection of
      programming and anthropology.

 03.  ...

 ──────────────────────────────────────────────────────────────
```

### 14.2 Collection CSS

```css
/* Collection page header */
.ed-collection {
  padding-top: var(--space-6);
}

.ed-collection__overline {
  font-family: var(--font-ui);
  font-size: var(--text-overline);
  font-weight: 600;
  letter-spacing: var(--tracking-overline);
  text-transform: uppercase;
  color: var(--color-text-secondary);
  margin-bottom: var(--space-3);
  padding-top: var(--space-4);
  border-top: 2px solid var(--color-border-rule);
}

.ed-collection__title {
  font-family: var(--font-display);
  font-size: var(--text-h1);
  font-weight: 700;
  line-height: 1.15;
  color: var(--color-text-primary);
  margin-bottom: var(--space-4);
  padding-bottom: var(--space-4);
  border-bottom: 1px solid var(--color-border-rule);
}

.ed-collection__intro {
  font-family: var(--font-body);
  font-size: var(--text-lead);
  line-height: 1.6;
  color: var(--color-text-secondary);
  max-width: var(--measure);
  margin-bottom: var(--space-6);
  padding-bottom: var(--space-6);
  border-bottom: 1px solid var(--color-border-subtle);
}

/* Drop cap for collection intro */
.ed-collection__intro--drop-cap::first-letter {
  font-family: var(--font-display);
  font-weight: 900;
  float: left;
  font-size: 4.5rem;
  line-height: 0.8;
  margin-right: 0.1em;
  margin-top: 0.05em;
  color: var(--color-accent);
}

/* Numbered listing within collection */
.ed-collection__item {
  display: grid;
  grid-template-columns: 48px 1fr auto;
  gap: var(--space-4);
  align-items: start;
  padding: var(--space-5) 0;
  border-bottom: 1px solid var(--color-border-subtle);
}

.ed-collection__item:last-child {
  border-bottom: none;
}

/* Item number — editorial convention */
.ed-collection__number {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 400;
  color: var(--color-text-quaternary);
  line-height: 1;
  padding-top: 0.1em;
}

/* Item content */
.ed-collection__item-content {
  /* Contains title, category, summary */
}

.ed-collection__item-title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  line-height: var(--leading-tight);
  color: var(--color-text-primary);
  margin-bottom: var(--space-1);
}

.ed-collection__item-title a {
  color: inherit;
  text-decoration: none;
}

.ed-collection__item-title a:hover {
  color: var(--color-accent);
}

.ed-collection__item-category {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  margin-bottom: var(--space-2);
}

.ed-collection__item-summary {
  font-family: var(--font-body);
  font-size: var(--text-body);
  line-height: var(--leading-body);
  color: var(--color-text-secondary);
  max-width: var(--measure);
}

/* Score in collection context */
.ed-collection__item-score {
  font-family: var(--font-display);
  font-size: var(--text-h4);
  font-weight: 700;
  color: var(--color-text-primary);
  white-space: nowrap;
}

.ed-collection__item-score span {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-weight: 400;
  color: var(--color-text-tertiary);
}
```

### 14.3 Collection Index Page

```css
/* Collection index — list of all collections */
.ed-collection-index__item {
  padding: var(--space-5) 0;
  border-bottom: 1px solid var(--color-border-subtle);
}

.ed-collection-index__item-title {
  font-family: var(--font-display);
  font-size: var(--text-h3);
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: var(--space-2);
}

.ed-collection-index__item-title a {
  color: inherit;
  text-decoration: none;
}

.ed-collection-index__item-title a:hover {
  color: var(--color-accent);
}

.ed-collection-index__item-meta {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
}

.ed-collection-index__item-description {
  font-family: var(--font-body);
  font-size: var(--text-body);
  color: var(--color-text-secondary);
  margin-top: var(--space-2);
  max-width: var(--measure);
}
```

---

## 15. Buttons & Interactive Elements

### 15.1 Button Scale

```
 BUTTON HIERARCHY
 ──────────────────────────────────────────────────────────────

 PRIMARY:    ┌──────────────────┐    Burgundy fill, white text
             │     Submit       │    Most prominent action
             └──────────────────┘

 SECONDARY:  ┌──────────────────┐    Thin border, burgundy text
             │  Add to List     │    Supporting action
             └──────────────────┘

 GHOST:      Add to List            Underlined text link style
             ─────────────          Tertiary / inline actions

 ──────────────────────────────────────────────────────────────
```

### 15.2 Button CSS — All States

```css
/* Base button reset */
.ed-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  font-weight: 600;
  letter-spacing: var(--tracking-wide);
  text-transform: uppercase;
  line-height: 1;
  padding: 12px 24px;
  border-radius: 4px;
  border: 1px solid transparent;
  cursor: pointer;
  text-decoration: none;
  transition:
    background-color 150ms ease-in-out,
    border-color 150ms ease-in-out,
    color 150ms ease-in-out,
    box-shadow 150ms ease-in-out;
}

/* ─── PRIMARY ─── */

/* Default */
.ed-btn--primary {
  background-color: var(--color-accent);
  color: var(--color-text-inverse);
  border-color: var(--color-accent);
}

/* Hover */
.ed-btn--primary:hover {
  background-color: var(--color-accent-hover);
  border-color: var(--color-accent-hover);
}

/* Focus */
.ed-btn--primary:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
}

/* Active */
.ed-btn--primary:active {
  background-color: #5A1515;
  border-color: #5A1515;
}

/* Disabled */
.ed-btn--primary:disabled,
.ed-btn--primary[aria-disabled="true"] {
  background-color: var(--color-border-subtle);
  border-color: var(--color-border-subtle);
  color: var(--color-text-tertiary);
  cursor: not-allowed;
}

/* ─── SECONDARY ─── */

/* Default */
.ed-btn--secondary {
  background-color: transparent;
  color: var(--color-accent);
  border-color: var(--color-border-medium);
}

/* Hover */
.ed-btn--secondary:hover {
  border-color: var(--color-accent);
  background-color: var(--color-accent-light);
}

/* Focus */
.ed-btn--secondary:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
}

/* Active */
.ed-btn--secondary:active {
  background-color: #FDE8E8;
  border-color: var(--color-accent-hover);
}

/* Disabled */
.ed-btn--secondary:disabled,
.ed-btn--secondary[aria-disabled="true"] {
  border-color: var(--color-border-subtle);
  color: var(--color-text-quaternary);
  cursor: not-allowed;
}

/* ─── GHOST ─── */

/* Default */
.ed-btn--ghost {
  background-color: transparent;
  color: var(--color-accent);
  border-color: transparent;
  padding: var(--space-2) 0;
  text-decoration: underline;
  text-decoration-thickness: 1px;
  text-underline-offset: 0.15em;
  text-transform: none;
  letter-spacing: normal;
  font-weight: 500;
}

/* Hover */
.ed-btn--ghost:hover {
  color: var(--color-accent-hover);
}

/* Focus */
.ed-btn--ghost:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
  border-radius: 2px;
}

/* Active */
.ed-btn--ghost:active {
  color: #5A1515;
}

/* Disabled */
.ed-btn--ghost:disabled,
.ed-btn--ghost[aria-disabled="true"] {
  color: var(--color-text-quaternary);
  text-decoration-color: var(--color-text-quaternary);
  cursor: not-allowed;
}

/* ─── SIZE VARIANTS ─── */

.ed-btn--sm {
  font-size: var(--text-micro);
  padding: 8px 16px;
}

.ed-btn--lg {
  font-size: var(--text-body-sm);
  padding: 16px 32px;
}

/* ─── LOADING STATE ─── */

.ed-btn--loading {
  position: relative;
  color: transparent;
  pointer-events: none;
}

.ed-btn--loading::after {
  content: '';
  position: absolute;
  width: 16px;
  height: 16px;
  border: 2px solid var(--color-text-inverse);
  border-top-color: transparent;
  border-radius: 50%;
  animation: ed-spin 600ms linear infinite;
}

.ed-btn--secondary.ed-btn--loading::after {
  border-color: var(--color-accent);
  border-top-color: transparent;
}

@keyframes ed-spin {
  to { transform: rotate(360deg); }
}
```

---

## 16. Form Elements

### 16.1 Text Input

```css
/* Text input — default */
.ed-input {
  width: 100%;
  padding: var(--space-3) var(--space-4);
  font-family: var(--font-body);
  font-size: var(--text-body-sm);
  line-height: 1.5;
  color: var(--color-text-primary);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border-subtle);
  border-radius: 2px;
  transition: border-color 150ms ease-in-out;
}

/* Placeholder */
.ed-input::placeholder {
  font-style: italic;
  color: var(--color-text-tertiary);
}

/* Hover */
.ed-input:hover {
  border-color: var(--color-border-medium);
}

/* Focus */
.ed-input:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 1px var(--color-accent);
}

.ed-input:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
}

/* Error */
.ed-input--error {
  border-color: var(--color-error);
}

.ed-input--error:focus {
  box-shadow: 0 0 0 1px var(--color-error);
}

/* Disabled */
.ed-input:disabled {
  background-color: var(--color-surface-alt);
  color: var(--color-text-tertiary);
  cursor: not-allowed;
}
```

### 16.2 Textarea

```css
/* Textarea */
.ed-textarea {
  width: 100%;
  min-height: 120px;
  padding: var(--space-3) var(--space-4);
  font-family: var(--font-body);
  font-size: var(--text-body-sm);
  line-height: var(--leading-body);
  color: var(--color-text-primary);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border-subtle);
  border-radius: 2px;
  resize: vertical;
  transition: border-color 150ms ease-in-out;
}

.ed-textarea::placeholder {
  font-style: italic;
  color: var(--color-text-tertiary);
}

.ed-textarea:hover {
  border-color: var(--color-border-medium);
}

.ed-textarea:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 1px var(--color-accent);
}

.ed-textarea:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
}
```

### 16.3 Select

```css
/* Select — editorial clean */
.ed-select {
  width: 100%;
  padding: var(--space-3) var(--space-4);
  padding-right: 40px;
  font-family: var(--font-ui);
  font-size: var(--text-body-sm);
  color: var(--color-text-primary);
  background-color: var(--color-surface);
  border: 1px solid var(--color-border-subtle);
  border-radius: 2px;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1L6 6L11 1' stroke='%23999999' stroke-width='1.5' stroke-linecap='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 16px center;
  cursor: pointer;
  transition: border-color 150ms ease-in-out;
}

.ed-select:hover {
  border-color: var(--color-border-medium);
}

.ed-select:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 1px var(--color-accent);
}

.ed-select:focus-visible {
  outline: var(--focus-ring);
  outline-offset: var(--focus-ring-offset);
}

/* Placeholder option */
.ed-select option[value=""] {
  color: var(--color-text-tertiary);
}
```

### 16.4 Checkbox & Radio

```css
/* Checkbox */
.ed-checkbox {
  display: flex;
  align-items: flex-start;
  gap: var(--space-2);
  cursor: pointer;
}

.ed-checkbox__input {
  width: 18px;
  height: 18px;
  margin-top: 2px;
  accent-color: var(--color-accent);
  cursor: pointer;
}

.ed-checkbox__label {
  font-family: var(--font-ui);
  font-size: var(--text-body-sm);
  color: var(--color-text-primary);
  line-height: 1.4;
}

/* Radio — same structure */
.ed-radio {
  display: flex;
  align-items: flex-start;
  gap: var(--space-2);
  cursor: pointer;
}

.ed-radio__input {
  width: 18px;
  height: 18px;
  margin-top: 2px;
  accent-color: var(--color-accent);
  cursor: pointer;
}

.ed-radio__label {
  font-family: var(--font-ui);
  font-size: var(--text-body-sm);
  color: var(--color-text-primary);
  line-height: 1.4;
}
```

### 16.5 Form Validation Messages

```css
/* Error message below input */
.ed-form-error {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-error);
  margin-top: var(--space-1);
}

/* Help text below input */
.ed-form-help {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  margin-top: var(--space-1);
}

/* Character count */
.ed-form-count {
  font-family: var(--font-ui);
  font-size: var(--text-micro);
  color: var(--color-text-tertiary);
  text-align: right;
  margin-top: var(--space-1);
}

.ed-form-count--warn {
  color: var(--color-warning);
}

.ed-form-count--error {
  color: var(--color-error);
}
```

---

## 17. Interaction & Motion

### 17.1 Motion Principles

1. **Editorial restraint** — Motion is purposeful, never decorative
2. **Subtle and fast** — 150-300ms maximum for UI transitions
3. **Functional** — Motion communicates state changes, not personality
4. **Accessible** — All motion respects `prefers-reduced-motion`

### 17.2 Easing Functions

```css
:root {
  --ease-default:   ease-in-out;
  --ease-in:        cubic-bezier(0.4, 0, 1, 1);
  --ease-out:       cubic-bezier(0, 0, 0.2, 1);
  --ease-spring:    cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

### 17.3 Duration Scale

| Token | Value | Usage |
|-------|-------|-------|
| `--duration-fast` | 100ms | Micro-interactions (color change) |
| `--duration-base` | 150ms | Standard transitions (hover states) |
| `--duration-slow` | 200ms | Page transitions, reveals |
| `--duration-score` | 300ms | Score count-up animation |

```css
:root {
  --duration-fast:  100ms;
  --duration-base:  150ms;
  --duration-slow:  200ms;
  --duration-score: 300ms;
}
```

### 17.4 Transition Catalog

```css
/* Hover on cards — subtle border darken */
.ed-listing {
  transition: border-color var(--duration-base) var(--ease-default);
}

.ed-listing:hover {
  border-color: var(--color-border-medium);
}

/* Link color transitions */
a {
  transition: color var(--duration-base) var(--ease-default);
}

/* Button transitions */
.ed-btn {
  transition:
    background-color var(--duration-base) var(--ease-default),
    border-color var(--duration-base) var(--ease-default),
    color var(--duration-base) var(--ease-default);
}

/* Input focus transitions */
.ed-input,
.ed-textarea,
.ed-select {
  transition: border-color var(--duration-base) var(--ease-default);
}

/* Page transition — fade */
.ed-page-enter {
  opacity: 0;
}

.ed-page-enter-active {
  opacity: 1;
  transition: opacity var(--duration-slow) var(--ease-default);
}

.ed-page-exit {
  opacity: 1;
}

.ed-page-exit-active {
  opacity: 0;
  transition: opacity var(--duration-fast) var(--ease-default);
}

/* Surprise Me arrow slide */
.ed-surprise__arrow {
  transition: transform var(--duration-slow) var(--ease-default);
}

.ed-surprise:hover .ed-surprise__arrow {
  transform: translateX(4px);
}

/* Surprise Me underline reveal */
.ed-surprise__label::after {
  transition: width var(--duration-slow) var(--ease-default);
}

/* Header show/hide on scroll */
.ed-header {
  transition: transform var(--duration-score) var(--ease-default);
}
```

### 17.5 Reduced Motion

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

  .ed-header {
    transition: none;
  }

  .ed-surprise__label::after {
    transition: none;
  }

  .ed-surprise__arrow {
    transition: none;
  }

  /* Disable score count-up — show final value immediately */
  [data-score-value] {
    /* JS should check: matchMedia('(prefers-reduced-motion: reduce)').matches */
  }
}
```

### 17.6 Score Count-Up with Reduced Motion Check

```javascript
// Respect reduced motion preferences
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches;

const scoreElements = document.querySelectorAll('[data-score-value]');

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const el = entry.target;
      const target = parseInt(el.dataset.scoreValue, 10);

      if (prefersReducedMotion) {
        el.textContent = target; // Show immediately
      } else {
        animateScore(el, 0, target, 300);
      }

      observer.unobserve(el);
    }
  });
}, { threshold: 0.5 });

scoreElements.forEach(el => observer.observe(el));
```

---

## 18. Asset Guidelines

### 18.1 Photography

**None in UI.** The external site screenshots ARE the imagery. Gotta.cc does not
use stock photography, hero images, or decorative photos. The design lives
entirely through typography, whitespace, and editorial structure.

### 18.2 Screenshots

- Captured at 1280x800 viewport
- Full page, cropped to above-fold
- 1px border in `--color-border-subtle`
- No rounded corners on screenshots
- Displayed at full content width on detail pages
- Caption below in italic `--text-caption`
- Format: WebP with JPEG fallback, quality 85
- Lazy loaded below the fold

```html
<figure class="ed-detail__screenshot">
  <picture>
    <source srcset="screenshot.webp" type="image/webp">
    <img
      src="screenshot.jpg"
      alt="Homepage of Simon Willison's Weblog showing recent posts"
      loading="lazy"
      width="1280"
      height="800"
    >
  </picture>
  <figcaption>Homepage as of March 2026</figcaption>
</figure>
```

### 18.3 Iconography

- **Minimal use** — text labels are preferred over icons
- Style: outline, 1.5px stroke weight
- Size: 16px (inline with caption text), 20px (with body text), 24px (standalone)
- Color: inherits text color of parent
- Source: Lucide Icons (MIT license, consistent with Inter's geometry)
- Only used for: external link indicator, search, chevrons in breadcrumbs, sort arrows

```css
/* Icon base */
.ed-icon {
  display: inline-block;
  width: 1em;
  height: 1em;
  vertical-align: -0.125em;
  stroke: currentColor;
  stroke-width: 1.5;
  fill: none;
}

/* Size variants */
.ed-icon--sm  { width: 16px; height: 16px; }
.ed-icon--md  { width: 20px; height: 20px; }
.ed-icon--lg  { width: 24px; height: 24px; }
```

### 18.4 Illustrations

**None.** Typography IS the design. No illustrations, no mascots, no decorative
SVGs, no abstract shapes.

### 18.5 Decorative Elements

The only decorative elements are typographic:

| Element | Usage | CSS |
|---------|-------|-----|
| Horizontal rules | Section dividers, above headers | `border-top: 1px/2px solid` |
| Em dashes | Inline separation, attribution | `\2014` or ` — ` |
| Section numbers | Collection items, numbered lists | Playfair Display, light weight, quaternary color |
| Bullet dots | Featured category indicator | 6px burgundy circle |
| Middle dots | Metadata separator | `\00B7` |
| Slashes | Breadcrumb separator | `/` in tertiary color |

---

## 19. Directory-Specific Patterns

### 19.1 Category Tree as Typographic Hierarchy

Categories are NOT represented with folder icons, tree lines, or expandable widgets.
They are a **typographic hierarchy** — section > subsection > item — using font
size, weight, indentation, and spacing to communicate structure.

```
 HIERARCHY MAPPING:

 Top-level category  →  H3, Playfair 700, full border-bottom
 Subcategory         →  Body-sm, Inter 400, indented + left border
 Featured pick       →  Same as subcategory + burgundy dot + weight 500
```

### 19.2 Score as Editorial Rating

Scores are presented like magazine review ratings:
- Large serif number (like a restaurant rating in a food magazine)
- `/100` in small caption beside it
- No stars, no filled circles, no progress rings
- Dimension breakdown as clean data rows, not radar charts

### 19.3 Pull Quotes from Site Summaries

On detail pages and collection pages, pull quotes extract compelling
phrases from editorial summaries:

```css
/* Pull quote — extracted from summary */
.ed-pullquote {
  font-family: var(--font-body);
  font-size: var(--text-h3);
  font-style: italic;
  font-weight: 400;
  line-height: 1.4;
  color: var(--color-text-primary);
  border-left: 3px solid var(--color-accent);
  padding-left: var(--space-6);
  margin: var(--space-7) 0;
  max-width: var(--measure);
}
```

### 19.4 Byline-Style Metadata

Dates and indexing info are presented in byline format, like a magazine article:

```
 First indexed January 14, 2026
 Last verified March 12, 2026
 Category: AI & Machine Learning / NLP
```

```css
/* Byline metadata */
.ed-byline {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.ed-byline__item {
  /* inherits */
}

.ed-byline__label {
  /* No separate label — written in prose:
     "First indexed January 14, 2026"
     not "Indexed: Jan 14, 2026" */
}
```

### 19.5 "New This Week" Section

```css
/* New this week — editorial feature section */
.ed-new-this-week {
  padding: var(--space-6) 0;
}

.ed-new-this-week__heading {
  font-family: var(--font-display);
  font-size: var(--text-h2);
  font-weight: 700;
  padding-bottom: var(--space-4);
  border-bottom: 2px solid var(--color-border-rule);
  margin-bottom: var(--space-6);
}

.ed-new-this-week__date {
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  color: var(--color-text-tertiary);
  font-weight: 400;
  margin-left: var(--space-3);
}
```

### 19.6 Footer

```css
/* Footer — editorial credits */
.ed-footer {
  padding: var(--space-8) 0 var(--space-6);
  border-top: 1px solid var(--color-border-rule);
  margin-top: var(--space-9);
}

.ed-footer__tagline {
  font-family: var(--font-display);
  font-size: var(--text-h4);
  font-style: italic;
  color: var(--color-text-primary);
  margin-bottom: var(--space-4);
}

.ed-footer__description {
  font-family: var(--font-body);
  font-size: var(--text-body-sm);
  color: var(--color-text-secondary);
  max-width: var(--measure);
  margin-bottom: var(--space-6);
}

.ed-footer__links {
  display: flex;
  gap: var(--space-4);
  font-family: var(--font-ui);
  font-size: var(--text-caption);
}

.ed-footer__link {
  color: var(--color-text-tertiary);
  text-decoration: none;
}

.ed-footer__link:hover {
  color: var(--color-accent);
}

.ed-footer__copyright {
  font-family: var(--font-ui);
  font-size: var(--text-micro);
  color: var(--color-text-quaternary);
  margin-top: var(--space-6);
}
```

---

## 20. Dark Mode

### 20.1 Dark Mode Palette

```
 DARK MODE PALETTE
 ┌─────────────────────────────────────────────────────────┐
 │                                                         │
 │  Background         #0A0A0A   ████████  Near Black       │
 │  Surface            #141414   ████████  Dark Gray        │
 │  Surface-alt        #1A1A1A   ████████  Slightly Lighter │
 │                                                         │
 │  Text-primary       #E5E5E5   ████████  Light Gray       │
 │  Text-secondary     #A3A3A3   ████████  Medium Gray      │
 │  Text-tertiary      #737373   ████████  Dim Gray         │
 │  Text-quaternary    #525252   ████████  Very Dim          │
 │                                                         │
 │  Accent             #D4817B   ████████  Warm Rose         │
 │  Accent-hover       #E09A95   ████████  Lighter Rose      │
 │  Accent-light       #1F1515   ████████  Dark Rose Tint    │
 │  Accent-muted       #A36B67   ████████  Dusty Rose        │
 │                                                         │
 │  Border-subtle      #262626   ████████  Dark Border       │
 │  Border-rule        #404040   ████████  Medium Border     │
 │  Border-medium      #333333   ████████  Between          │
 │                                                         │
 │  Score-high-bg      #1F1515   ████████  Dark Rose Tint    │
 │  Score-mid-bg       #141414   ████████  Surface           │
 │  Score-low-bg       #0F0F0F   ████████  Near bg           │
 │                                                         │
 │  Success            #6BBF6B   ████████  Soft Green        │
 │  Warning            #D4A843   ████████  Warm Gold         │
 │  Error              #D4817B   ████████  (shares accent)   │
 │  Info               #6BA3C7   ████████  Soft Blue         │
 │                                                         │
 └─────────────────────────────────────────────────────────┘
```

### 20.2 Dark Mode CSS

```css
@media (prefers-color-scheme: dark) {
  :root {
    /* Backgrounds */
    --color-bg:              #0A0A0A;
    --color-surface:         #141414;
    --color-surface-alt:     #1A1A1A;

    /* Text */
    --color-text-primary:    #E5E5E5;
    --color-text-secondary:  #A3A3A3;
    --color-text-tertiary:   #737373;
    --color-text-quaternary: #525252;
    --color-text-inverse:    #0A0A0A;

    /* Accent — Warm Rose (lightened burgundy) */
    --color-accent:          #D4817B;
    --color-accent-hover:    #E09A95;
    --color-accent-light:    #1F1515;
    --color-accent-muted:    #A36B67;

    /* Borders */
    --color-border-subtle:   #262626;
    --color-border-rule:     #404040;
    --color-border-medium:   #333333;

    /* Score backgrounds */
    --color-score-high-bg:   #1F1515;
    --color-score-mid-bg:    #141414;
    --color-score-low-bg:    #0F0F0F;

    /* Semantic */
    --color-success:         #6BBF6B;
    --color-warning:         #D4A843;
    --color-error:           #D4817B;
    --color-info:            #6BA3C7;

    /* Focus */
    --color-focus-ring:      #D4817B;
  }
}

/* Manual dark mode toggle support */
[data-theme="dark"] {
  --color-bg:              #0A0A0A;
  --color-surface:         #141414;
  --color-surface-alt:     #1A1A1A;
  --color-text-primary:    #E5E5E5;
  --color-text-secondary:  #A3A3A3;
  --color-text-tertiary:   #737373;
  --color-text-quaternary: #525252;
  --color-text-inverse:    #0A0A0A;
  --color-accent:          #D4817B;
  --color-accent-hover:    #E09A95;
  --color-accent-light:    #1F1515;
  --color-accent-muted:    #A36B67;
  --color-border-subtle:   #262626;
  --color-border-rule:     #404040;
  --color-border-medium:   #333333;
  --color-score-high-bg:   #1F1515;
  --color-score-mid-bg:    #141414;
  --color-score-low-bg:    #0F0F0F;
  --color-success:         #6BBF6B;
  --color-warning:         #D4A843;
  --color-error:           #D4817B;
  --color-info:            #6BA3C7;
  --color-focus-ring:      #D4817B;
}
```

### 20.3 Dark Mode Contrast Ratios

| Foreground | Background | Ratio | Pass |
|------------|------------|-------|------|
| #E5E5E5 | #0A0A0A | 17.4:1 | AAA |
| #E5E5E5 | #141414 | 14.1:1 | AAA |
| #A3A3A3 | #0A0A0A | 8.8:1 | AAA |
| #737373 | #0A0A0A | 4.7:1 | AA |
| #D4817B | #0A0A0A | 6.7:1 | AA |
| #D4817B | #141414 | 5.5:1 | AA |
| #0A0A0A | #D4817B | 6.7:1 | AA |

### 20.4 Dark Mode — Component Adjustments

```css
/* Screenshot border in dark mode becomes more visible */
@media (prefers-color-scheme: dark) {
  .ed-detail__screenshot img {
    border-color: var(--color-border-medium);
  }

  /* Score badge gets subtle surface distinction */
  .ed-score {
    background-color: var(--color-surface);
    border-color: var(--color-border-medium);
  }

  /* Featured listing card */
  .ed-listing--featured {
    background-color: var(--color-surface);
    border-color: var(--color-border-medium);
  }

  /* Buttons — primary needs inversion check */
  .ed-btn--primary {
    background-color: var(--color-accent);
    color: var(--color-text-inverse);
    border-color: var(--color-accent);
  }

  .ed-btn--primary:hover {
    background-color: var(--color-accent-hover);
    border-color: var(--color-accent-hover);
  }

  /* Loading spinner in dark */
  .ed-btn--loading::after {
    border-color: var(--color-text-inverse);
    border-top-color: transparent;
  }

  /* Drop cap color */
  .drop-cap::first-letter,
  .ed-collection__intro--drop-cap::first-letter {
    color: var(--color-accent);
  }

  /* Form inputs */
  .ed-input,
  .ed-textarea,
  .ed-select {
    background-color: var(--color-surface);
    border-color: var(--color-border-subtle);
    color: var(--color-text-primary);
  }

  .ed-input:hover,
  .ed-textarea:hover,
  .ed-select:hover {
    border-color: var(--color-border-medium);
  }

  /* Select arrow color adjustment */
  .ed-select {
    background-image: url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1L6 6L11 1' stroke='%23737373' stroke-width='1.5' stroke-linecap='round'/%3E%3C/svg%3E");
  }
}
```

---

## 21. Responsive Design

### 21.1 Breakpoints

```css
:root {
  /* Breakpoint reference (used in media queries, not as custom properties) */
  /* --bp-sm: 480px;  Mobile */
  /* --bp-md: 768px;  Tablet */
  /* --bp-lg: 960px;  Desktop (matches max-width) */
}
```

| Breakpoint | Range | Layout |
|------------|-------|--------|
| Mobile | 0 - 479px | Single column, stacked |
| Tablet | 480px - 767px | Single column, wider padding |
| Desktop | 768px+ | Full layout, sidebar on detail |

### 21.2 Type Scale — Responsive

```css
/* Mobile type adjustments */
@media (max-width: 767px) {
  :root {
    --text-display:  2.5rem;   /* 40px (was 64px) */
    --text-h1:       2rem;     /* 32px (was 48px) */
    --text-h2:       1.75rem;  /* 28px (was 36px) */
    --text-h3:       1.5rem;   /* 24px (was 28px) */
    --text-h4:       1.25rem;  /* 20px (was 22px) */
    --text-lead:     1.125rem; /* 18px (was 22px) */
    --text-body-lg:  1.125rem; /* 18px (was 20px) */
    --text-body:     1rem;     /* 16px (was 18px) */
    --text-body-sm:  0.9375rem; /* 15px (was 16px) */
  }
}
```

### 21.3 Layout — Mobile

```css
/* Content padding on mobile */
@media (max-width: 479px) {
  .content {
    padding-left: var(--space-3);
    padding-right: var(--space-3);
  }
}

/* Detail page — stack sidebar below main on mobile */
@media (max-width: 767px) {
  .detail-layout {
    grid-template-columns: 1fr;
    gap: var(--space-6);
  }

  /* Score moves above content on mobile */
  .ed-score {
    order: -1;
    display: grid;
    grid-template-columns: auto 1fr;
    gap: var(--space-4);
    align-items: start;
  }

  .ed-score__composite {
    text-align: left;
  }

  .ed-score__value {
    font-size: var(--text-h1);
  }
}

/* Collection items — single column on mobile */
@media (max-width: 479px) {
  .ed-collection__item {
    grid-template-columns: 32px 1fr;
    gap: var(--space-3);
  }

  .ed-collection__item-score {
    grid-column: 2;
    font-size: var(--text-body-sm);
  }

  .ed-collection__number {
    font-size: var(--text-h4);
  }
}

/* Category groups — tighter spacing on mobile */
@media (max-width: 767px) {
  .ed-category-list {
    gap: var(--space-5);
  }

  .ed-subcategory-list {
    padding-left: var(--space-3);
  }
}

/* Nav — responsive */
@media (max-width: 479px) {
  .ed-header {
    height: auto;
    flex-wrap: wrap;
    padding: var(--space-3);
    gap: var(--space-2);
  }

  .ed-nav {
    width: 100%;
    overflow-x: auto;
    gap: var(--space-3);
    -webkit-overflow-scrolling: touch;
  }

  .ed-nav__link {
    white-space: nowrap;
  }
}

/* Search — full width on mobile */
@media (max-width: 479px) {
  .ed-search__input {
    font-size: var(--text-body-sm); /* prevent iOS zoom */
  }
}
```

### 21.4 Spacing — Responsive

```css
/* Reduce dramatic whitespace on mobile */
@media (max-width: 767px) {
  :root {
    --space-7:  3rem;    /* 48px, was 64px */
    --space-8:  4rem;    /* 64px, was 80px */
    --space-9:  5rem;    /* 80px, was 120px */
    --space-10: 6rem;    /* 96px, was 160px */
  }
}
```

---

## 22. Accessibility

### 22.1 Focus Management

```css
/* Global focus-visible styles */
:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 2px;
  border-radius: 2px;
}

/* Remove default outline for mouse users */
:focus:not(:focus-visible) {
  outline: none;
}

/* Skip link */
.ed-skip-link {
  position: absolute;
  top: -100%;
  left: var(--space-3);
  padding: var(--space-2) var(--space-3);
  font-family: var(--font-ui);
  font-size: var(--text-caption);
  background-color: var(--color-accent);
  color: var(--color-text-inverse);
  z-index: 200;
  text-decoration: none;
  border-radius: 2px;
}

.ed-skip-link:focus {
  top: var(--space-2);
}
```

### 22.2 Semantic HTML Guidelines

| Component | Element | Notes |
|-----------|---------|-------|
| Header | `<header>` | Contains `<nav>` |
| Navigation | `<nav aria-label="Main">` | Labeled nav |
| Category list | `<nav aria-label="Categories">` | Secondary nav |
| Main content | `<main>` | One per page |
| Search | `<search>` or `<form role="search">` | Semantic search |
| Listing | `<article>` | Each listing is an article |
| Score badge | `<aside>` on detail page | Supplementary |
| Footer | `<footer>` | Site-wide |
| Breadcrumb | `<nav aria-label="Breadcrumb">` | With `<ol>` |
| Heading hierarchy | `h1 > h2 > h3` | Never skip levels |
| Screenshot | `<figure>` + `<figcaption>` | Always captioned |

### 22.3 ARIA Patterns

```html
<!-- Score badge — accessible reading -->
<div class="ed-score" role="complementary" aria-label="Quality score">
  <div class="ed-score__composite">
    <span class="ed-score__value" aria-label="Overall score 94 out of 100">94</span>
    <span class="ed-score__denominator" aria-hidden="true">/100</span>
  </div>
  <div class="ed-score__dimensions" role="list" aria-label="Score breakdown">
    <div class="ed-score__dimension" role="listitem">
      <span class="ed-score__dimension-label">Originality</span>
      <div class="ed-score__bar-track" role="progressbar"
           aria-valuenow="18" aria-valuemin="0" aria-valuemax="20"
           aria-label="Originality: 18 out of 20">
        <div class="ed-score__bar-fill" style="width: 90%"></div>
      </div>
      <span class="ed-score__dimension-value" aria-hidden="true">18</span>
    </div>
  </div>
</div>

<!-- Surprise Me — accessible button -->
<button class="ed-surprise" aria-label="Show a random site from the directory">
  <span class="ed-surprise__label">Surprise me</span>
  <span class="ed-surprise__arrow" aria-hidden="true"></span>
</button>

<!-- Breadcrumb — structured -->
<nav aria-label="Breadcrumb">
  <ol class="ed-breadcrumb">
    <li><a href="/">Home</a></li>
    <li class="ed-breadcrumb__separator" aria-hidden="true"></li>
    <li><a href="/technology">Technology</a></li>
    <li class="ed-breadcrumb__separator" aria-hidden="true"></li>
    <li aria-current="page" class="ed-breadcrumb__current">AI & Machine Learning</li>
  </ol>
</nav>
```

### 22.4 Color Accessibility

- All text meets WCAG AA (4.5:1 for normal text, 3:1 for large text)
- Primary text on both light and dark backgrounds exceeds AAA (7:1)
- Accent color (burgundy) on cream/white exceeds AAA (8.2:1 / 8.5:1)
- Interactive elements have visible focus indicators
- Color is never the sole indicator of state (always paired with text/shape)
- See Section 2.4 and 20.3 for full contrast ratio tables

### 22.5 Screen Reader Considerations

- Score bars have `role="progressbar"` with `aria-valuenow/min/max`
- Decorative separators (`·`, `/`, rules) use `aria-hidden="true"`
- External links include `rel="noopener"` and visually hidden "(opens in new tab)" text
- Score count-up animation starts from target value (not 0) in DOM — animation is progressive enhancement
- Collection numbers are semantic `<ol>` — CSS numbers are presentational layer

---

## 23. Implementation Checklist

### 23.1 Design Tokens

- [ ] All color tokens defined as CSS custom properties
- [ ] Light mode palette applied to `:root`
- [ ] Dark mode palette applied via `prefers-color-scheme: dark` and `[data-theme="dark"]`
- [ ] Font stacks defined as custom properties
- [ ] Type scale tokens with rem values
- [ ] Spacing scale tokens
- [ ] Duration and easing tokens
- [ ] Focus ring tokens
- [ ] Measure (line length) tokens

### 23.2 Typography

- [ ] Google Fonts loaded with `display=swap`
- [ ] Preconnect hints for Google Fonts
- [ ] Display font (Playfair Display) applied to all headings
- [ ] Body font (Lora) applied to summaries and descriptions
- [ ] UI font (Inter) applied to navigation, labels, metadata
- [ ] Overline style: uppercase, tracked, Inter 600
- [ ] Caption style: Inter 400, secondary color
- [ ] Pull quote style: italic serif, border-left accent
- [ ] Drop cap style for collection intros
- [ ] Max-width `65ch` on all reading content
- [ ] Line height 1.75-1.8 on body text
- [ ] Responsive type scale for mobile

### 23.3 Components

- [ ] Header: 64px, sticky, hide-on-scroll-down
- [ ] Navigation: uppercase Inter links with active underline
- [ ] Reading progress bar: 2px burgundy, fixed top
- [ ] Search input: serif placeholder, thin border
- [ ] Search results: article-style with overline category
- [ ] Category browser: typographic hierarchy, no icons
- [ ] Category groups: H3 serif with count right-aligned
- [ ] Subcategories: indented with left border
- [ ] Featured indicator: burgundy dot
- [ ] Breadcrumbs: caption text with slash separators
- [ ] Listing card: overline + H3 title + body summary + meta row
- [ ] Listing card compact variant
- [ ] Listing card featured variant
- [ ] Listing card with screenshot
- [ ] Site detail page: asymmetric grid layout
- [ ] Score badge large: serif number, dimension bars
- [ ] Score badge compact: inline use
- [ ] Score count-up animation on scroll
- [ ] Editor's Pick label with rules
- [ ] Pull quote on detail pages
- [ ] Surprise Me button: italic serif, arrow, underline-on-hover
- [ ] Surprise Me hero variant
- [ ] Submission form: clean inputs, editorial intro
- [ ] Submission status states (pending, approved, rejected)
- [ ] Collection page: numbered items, magazine-issue styling
- [ ] Collection index: list of all collections
- [ ] Footer: editorial credits, minimal links

### 23.4 Buttons & Forms

- [ ] Primary button: burgundy fill, all states (hover, focus, active, disabled, loading)
- [ ] Secondary button: outline, all states
- [ ] Ghost button: underline link style, all states
- [ ] Button size variants (sm, lg)
- [ ] Loading spinner animation
- [ ] Text input: all states (default, hover, focus, error, disabled)
- [ ] Textarea: resizable, all states
- [ ] Select: custom arrow, all states
- [ ] Checkbox and radio: accent-color burgundy
- [ ] Form labels and required indicators
- [ ] Error messages and help text
- [ ] Character count

### 23.5 Interaction & Motion

- [ ] All transitions use defined duration tokens
- [ ] All transitions use `ease-in-out`
- [ ] `prefers-reduced-motion` respected globally
- [ ] Score count-up checks reduced motion preference
- [ ] Header scroll behavior with passive listener
- [ ] Surprise Me arrow and underline animations
- [ ] Page transition fade (if SPA)

### 23.6 Responsive

- [ ] Mobile type scale override (max-width: 767px)
- [ ] Mobile spacing overrides
- [ ] Detail page stacks to single column on tablet
- [ ] Score badge reformats on mobile
- [ ] Navigation scrollable on smallest screens
- [ ] Collection items reduce columns on mobile
- [ ] Input font-size >= 16px on iOS (prevent zoom)

### 23.7 Accessibility

- [ ] Skip link present and functional
- [ ] All interactive elements have focus-visible styles
- [ ] Semantic HTML throughout (nav, main, article, aside, figure)
- [ ] ARIA labels on score components
- [ ] ARIA progressbar on score dimension bars
- [ ] Breadcrumb with aria-current="page"
- [ ] External links labeled for screen readers
- [ ] Decorative elements use aria-hidden
- [ ] All images have alt text
- [ ] Heading hierarchy is logical (no skipped levels)
- [ ] Color is never sole state indicator
- [ ] All contrast ratios meet WCAG AA minimum

### 23.8 Performance

- [ ] Fonts loaded with `display: swap`
- [ ] Preconnect hints for external font hosts
- [ ] Screenshots lazy-loaded below fold
- [ ] WebP with JPEG fallback for screenshots
- [ ] Minimal JavaScript (scroll handler, score animation)
- [ ] Passive event listeners on scroll handlers
- [ ] CSS custom properties for theming (no runtime JS for dark mode via media query)
- [ ] No CSS framework dependency — vanilla custom properties

---

## Appendix A: Complete HTML Skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Technology / AI & Machine Learning — gotta.cc</title>
  <meta name="description" content="AI-curated directory of the best independent websites. Browse by topic, not by keyword.">

  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Lora:ital,wght@0,400;0,700;1,400;1,700&family=Playfair+Display:wght@400;700;900&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="/styles.css">
</head>
<body class="page">
  <!-- Skip link -->
  <a href="#main" class="ed-skip-link">Skip to content</a>

  <!-- Reading progress -->
  <div class="ed-progress" aria-hidden="true"></div>

  <!-- Header -->
  <header class="ed-header">
    <a href="/" class="ed-header__logo">gotta.cc</a>
    <nav class="ed-nav" aria-label="Main navigation">
      <a href="/browse" class="ed-nav__link ed-nav__link--active">Browse</a>
      <a href="/search" class="ed-nav__link">Search</a>
      <a href="/collections" class="ed-nav__link">Collections</a>
      <a href="/submit" class="ed-nav__link">Submit</a>
    </nav>
  </header>

  <!-- Main content -->
  <main id="main" class="content">
    <!-- Page content here -->
  </main>

  <!-- Footer -->
  <footer class="ed-footer content">
    <p class="ed-footer__tagline">The web, edited.</p>
    <p class="ed-footer__description">
      gotta.cc is an AI-curated directory of remarkable websites.
      Every listed site is scored for originality, depth, and human authorship.
    </p>
    <div class="ed-footer__links">
      <a href="/about" class="ed-footer__link">About</a>
      <a href="/submit" class="ed-footer__link">Submit a site</a>
      <a href="/methodology" class="ed-footer__link">Methodology</a>
      <a href="/api" class="ed-footer__link">API</a>
    </div>
    <p class="ed-footer__copyright">gotta.cc 2026. The web, edited.</p>
  </footer>

  <script src="/scripts.js" defer></script>
</body>
</html>
```

---

## Appendix B: Token Quick Reference

```
 TOKENS AT A GLANCE
 ──────────────────────────────────────────────────────────────

 COLORS          LIGHT          DARK
 bg              #FFFCF7        #0A0A0A
 surface         #FFFFFF        #141414
 text-primary    #1A1A1A        #E5E5E5
 text-secondary  #666666        #A3A3A3
 accent          #7F1D1D        #D4817B
 border-subtle   #E5E0D8        #262626
 border-rule     #1A1A1A        #404040

 FONTS
 display         Playfair Display
 body            Lora
 ui              Inter

 TYPE SCALE      DESKTOP        MOBILE
 display         4rem/64px      2.5rem/40px
 h1              3rem/48px      2rem/32px
 h2              2.25rem/36px   1.75rem/28px
 h3              1.75rem/28px   1.5rem/24px
 body            1.125rem/18px  1rem/16px

 SPACING
 space-2         8px            Component gaps
 space-3         16px           Inline spacing
 space-4         24px           Component padding
 space-5         32px           Card padding
 space-6         48px           Section gaps
 space-8         80px           Page sections

 MOTION
 fast            100ms          Color changes
 base            150ms          Hover states
 slow            200ms          Reveals
 score           300ms          Count-up

 LAYOUT
 max-width       960px          Content column
 measure         65ch           Reading column
 header          64px           Sticky header height

 ──────────────────────────────────────────────────────────────
```

---

*Style guide version 1.0 — Direction A: Ink & Paper*
*gotta.cc — "The web, edited."*
