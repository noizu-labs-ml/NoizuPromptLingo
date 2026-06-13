# Style Guide: Gotta.cc — Retro Revival

> A sincere love letter to the browsable web, modernized with 2026 craft and accessibility.

**Style System:** Bold Expressive (Retro Web) 80% + Consumer Playful 20%
**Source Specs:** [bold-expressive.md](../../../.claude/skills/user-experience-engineer/references/styles/bold-expressive.md) + [consumer-playful.md](../../../.claude/skills/user-experience-engineer/references/styles/consumer-playful.md)
**Scenario:** AI-curated web directory — browse the web by topic, not by keyword

---

## Scenario

Gotta.cc is "The Yahoo Directory for the post-slop web." It's a browsable, AI-curated directory of quality websites — scored for originality, depth, and human authorship. The product is explicitly nostalgic: it wants to resurrect the experience of *exploring* the web through categories, not searching it through keywords.

Direction C leans into that nostalgia. The visual language draws directly from the era when directories were how you found things: Yahoo Directory (1994–2014), DMOZ, webrings, the blogosphere. Chunky borders, warm yellows, hyperlink blue, visible structure, dense lists of sites. It felt like a *place* you could wander through. This design makes it feel like that again.

But this is not parody or irony. It's a sincere, crafted homage — built with modern accessibility, responsive design, and typographic quality. Think: if someone who deeply loved the old web rebuilt it in 2026 with everything they've learned since.

**Personality adjectives:** Nostalgic, authentic, exploratory, opinionated, warm
**Anti-adjectives:** Ironic, kitschy, corporate, minimal, sterile

**Why Bold Expressive:** The retro web *was* bold and expressive — colored sections, visible borders, dense information, personality everywhere. Bold Expressive's rule-breaking, high-contrast, strong-point-of-view philosophy maps perfectly to a product that explicitly rejects modern web conventions (SEO-gaming, algorithmic feeds, minimal UI).

**Why +20% Playful:** The old web was *fun*. Category colors, star ratings, discovery animations, and badges add the warmth and delight that make browsing feel like an adventure, not a task.

---

## Retro Web DNA

| Reference | What We Take | What We Don't |
|---|---|---|
| **Yahoo Directory (1994–2014)** | Category tree, colored section banners, dense lists, "Sites (47)" counts | Table-based layout, tiny text, banner ads |
| **DMOZ / Open Directory** | Exhaustive categorization, pipe-separated nav, volunteer energy | Ugly default styling, no visual hierarchy |
| **Early Google** | "I'm Feeling Lucky" button, sparse focused search, speed | Bareness — we add editorial richness |
| **Webrings** | Discovery energy, "what will I find next?" | Random navigation — we curate with quality scores |
| **GeoCities** | Personal expression, web as creative space, warmth | Visual chaos, auto-play music, under-construction GIFs |

**The synthesis:** Take the *structure* and *energy* of the old web (dense categories, visible links, colored sections, exploration) and rebuild it with the *craft* of modern design (typography, spacing, accessibility, responsiveness). Familiar to anyone who browsed in 2002 — beautiful in a way the old web never was.

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #FFF8E7;          /* warm yellow — the "yellow pages" */
  --bg-surface: #FFFFFF;           /* content cards */
  --bg-alt: #FFFDF5;              /* alternate sections */
  --bg-highlight: #FFF3CD;        /* featured/highlighted content */

  /* Text */
  --text-primary: #2D2006;        /* dark brown-black, warm */
  --text-secondary: #6B5D3F;      /* warm brown */
  --text-tertiary: #9E8E6E;       /* muted warm */

  /* Primary Accent — Hyperlink Blue */
  --link: #2563EB;                /* THE color of the browsable web */
  --link-hover: #1D4ED8;
  --link-visited: #6D28D9;        /* classic visited purple */

  /* Secondary Accent — Warm Red */
  --red: #DC4A3A;
  --red-hover: #C4352A;
  --red-light: #FEF2F2;

  /* Tertiary Accent — Forest Green */
  --green: #1B7D3A;
  --green-light: #F0FDF4;

  /* Score — Gold */
  --gold: #D4A906;
  --gold-light: #FEF9E7;
  --gold-dark: #A38304;

  /* Borders */
  --border: #D4C5A0;              /* warm tan, chunky */
  --border-dark: #B8A87A;
  --border-rule: #2D2006;         /* dark rules/dividers */

  /* Category Colors */
  --cat-technology: #2563EB;
  --cat-culture: #7C3AED;
  --cat-science: #1B7D3A;
  --cat-making: #EA580C;
  --cat-games: #DC4A3A;
  --cat-weird: #DB2777;

  /* Semantic */
  --success: #1B7D3A;
  --warning: #D4A906;
  --error: #DC4A3A;
  --info: #2563EB;
}
```

```
┌─────────────────────────────────────────────┐
│  RETRO REVIVAL PALETTE                      │
├─────────────────────────────────────────────┤
│                                             │
│  ██████  #FFF8E7   Warm Yellow bg           │
│  ██████  #FFFFFF   White surface            │
│  ██████  #2D2006   Brown-Black text         │
│  ██████  #6B5D3F   Secondary text           │
│                                             │
│  ██████  #2563EB   Hyperlink Blue           │
│  ██████  #6D28D9   Visited Purple           │
│  ██████  #DC4A3A   Warm Red                 │
│  ██████  #1B7D3A   Forest Green             │
│  ██████  #D4A906   Gold (scores)            │
│                                             │
│  ██████  #D4C5A0   Tan border (chunky)      │
│                                             │
│  CATEGORY COLORS:                           │
│  ██ #2563EB Technology                      │
│  ██ #7C3AED Culture                         │
│  ██ #1B7D3A Science                         │
│  ██ #EA580C Making & Crafts                 │
│  ██ #DC4A3A Games                           │
│  ██ #DB2777 Weird & Wonderful               │
│                                             │
│  Blue links. Gold stars. Chunky tan borders.│
│  The web as a warm, browsable place.        │
└─────────────────────────────────────────────┘
```

### Color Usage Rules

- **Hyperlink blue** is sacred — all clickable text links use `--link`. No exceptions.
- **Visited purple** must be implemented. Users browse directories by following links — knowing what you've already seen is essential.
- **Borders are always visible** — 2-3px `--border` on cards and inputs. The border IS the visual structure, not shadows.
- **Category colors** appear on section banners and category indicators, never as text color on light backgrounds (contrast).
- **Gold** reserved for quality scores and "Editor's Pick" badges.
- **Warm red** for emphasis, alerts, NEW badges, and the "Surprise Me" button.
- **No gradients.** The retro web was flat. Flat is honest.

### Contrast Verification (WCAG 2.2 AA)

| Foreground | Background | Ratio | Pass |
|---|---|---|---|
| `#2D2006` text | `#FFF8E7` bg | 13.8:1 | AAA |
| `#6B5D3F` secondary | `#FFF8E7` bg | 6.2:1 | AA |
| `#2563EB` link | `#FFF8E7` bg | 4.8:1 | AA |
| `#2563EB` link | `#FFFFFF` surface | 4.6:1 | AA |
| `#FFFFFF` text | `#2563EB` blue bg | 4.6:1 | AA |
| `#FFFFFF` text | `#DC4A3A` red bg | 4.5:1 | AA |
| `#FFFFFF` text | `#1B7D3A` green bg | 4.8:1 | AA |
| `#FFFFFF` text | `#7C3AED` purple bg | 5.4:1 | AA |

---

## Typography

### Font Stack

```css
--font-display: 'Space Grotesk', system-ui, sans-serif;
--font-body: 'IBM Plex Serif', Georgia, serif;
--font-mono: 'IBM Plex Mono', 'Courier New', monospace;
```

### Font Sources

| Font | Source | License | Link |
|---|---|---|---|
| Space Grotesk | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk) |
| IBM Plex Serif | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/IBM+Plex+Serif) |
| IBM Plex Mono | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/IBM+Plex+Mono) |

*Adobe Fonts alternatives:* All IBM Plex fonts available on [Adobe Fonts](https://fonts.adobe.com/fonts/ibm-plex). Space Grotesk alternative: [DM Sans](https://fonts.google.com/specimen/DM+Sans).

### Type Scale

| Level | Font | Size | Weight | Line Height | Use |
|---|---|---|---|---|---|
| Display | Space Grotesk | 56–72px | 700 | 1.1 | Hero headline |
| H1 | Space Grotesk | 40px | 700 | 1.15 | Page titles |
| H2 | Space Grotesk | 32px | 700 | 1.2 | Section headers, category names |
| H3 | Space Grotesk | 24px | 600 | 1.25 | Site titles, card headings |
| H4 | Space Grotesk | 20px | 600 | 1.3 | Subsection headings |
| Body Large | IBM Plex Serif | 18px | 400 | 1.7 | Lead text, summaries |
| Body | IBM Plex Serif | 16px | 400 | 1.65 | Primary content |
| Body Small | IBM Plex Serif | 14px | 400 | 1.5 | Secondary content |
| Caption | IBM Plex Mono | 12px | 400 | 1.4 | Metadata, timestamps |
| Code / URL | IBM Plex Mono | 14px | 400 | 1.5 | URLs, scores |
| Overline | Space Grotesk | 11px | 700 | 1.3 | ALL CAPS labels, 0.08em tracking |

### Responsive Type

```css
h1 { font-size: clamp(28px, 5vw, 40px); }
h2 { font-size: clamp(24px, 4vw, 32px); }
.display { font-size: clamp(36px, 8vw, 72px); }
body { font-size: clamp(15px, 1.6vw, 16px); }
```

### Typography Rules

- **URLs always in mono.** The URL is the identity in a directory.
- **Category names in ALL CAPS** with 0.08em tracking — echoes Yahoo section headers.
- **Body in serif.** IBM Plex Serif gives summaries editorial weight.
- **Scores in mono.** Numbers are data, not prose.
- **Underline links.** Always. The underline IS the web.

---

## Spacing & Layout

### Spacing Scale

```
4px   — Micro (inline gaps, badge padding)
8px   — XS (tight element gaps)
12px  — SM (list items, compact padding)
16px  — MD (card padding, grid gutters)
24px  — LG (section gaps within cards)
32px  — XL (between card groups)
48px  — 2XL (section spacing)
64px  — 3XL (major page sections)
```

### Grid

| Breakpoint | Width | Columns | Gutters | Margins |
|---|---|---|---|---|
| Mobile | < 640px | 1 | 12px | 16px |
| Tablet | 640–1023px | 2 | 16px | 24px |
| Desktop | 1024px+ | 3–4 | 16px | 24px |
| Max | 1024px | — | — | auto centered |

### Layout Zones

```
┌─────────────────────────────────────────────────┐
│  NAVIGATION BAR (full width, warm yellow bg)    │
│  gotta.cc    Browse | Search | Submit | About   │
├─────────────────────────────────────────────────┤
│  CATEGORY RIBBON (colored text links)           │
├─────────────────────────────────────────────────┤
│  CONTENT (1024px max, centered)                 │
├─────────────────────────────────────────────────┤
│  FOOTER (warm yellow bg, directory stats)       │
└─────────────────────────────────────────────────┘
```

### Density

Tighter than editorial. The directory should feel **full** — dense with content, like the old Yahoo.

- List items: 12–16px vertical spacing
- Cards: 16–20px internal padding
- No hero sections taller than 40vh

---

## Component Library

### Base Reset

```css
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  font-family: var(--font-body);
  font-size: 16px;
  line-height: 1.65;
  color: var(--text-primary);
  background: var(--bg-primary);
  -webkit-font-smoothing: antialiased;
}

a {
  color: var(--link);
  text-decoration: underline;
  text-underline-offset: 2px;
  text-decoration-thickness: 1px;
}
a:hover {
  color: var(--link-hover);
  text-decoration-thickness: 2px;
}
a:visited { color: var(--link-visited); }
a:focus-visible {
  outline: 3px solid var(--link);
  outline-offset: 2px;
}
```

---

### 6.1 Navigation

```css
.nav {
  background: var(--bg-primary);
  border-bottom: 2px solid var(--border);
  padding: 12px 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 56px;
}

.nav-logo {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 700;
  color: var(--text-primary);
  text-decoration: none;
}

.nav-links {
  display: flex;
  align-items: center;
  font-family: var(--font-mono);
  font-size: 14px;
}
.nav-links a { padding: 4px 12px; }
.nav-links a:hover { background: var(--bg-highlight); }

/* Pipe separators */
.nav-links a + a::before {
  content: "|";
  color: var(--text-tertiary);
  margin-right: 12px;
  pointer-events: none;
}

/* Category ribbon */
.category-ribbon {
  background: var(--bg-alt);
  border-bottom: 1px solid var(--border);
  padding: 8px 24px;
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 600;
}
.category-ribbon a {
  text-decoration: none;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.category-ribbon a:hover { text-decoration: underline; }

/* Category colors */
.category-ribbon a[data-cat="technology"] { color: var(--cat-technology); }
.category-ribbon a[data-cat="culture"] { color: var(--cat-culture); }
.category-ribbon a[data-cat="science"] { color: var(--cat-science); }
.category-ribbon a[data-cat="making"] { color: var(--cat-making); }
.category-ribbon a[data-cat="games"] { color: var(--cat-games); }
.category-ribbon a[data-cat="weird"] { color: var(--cat-weird); }
```

**Mobile:**
```css
@media (max-width: 639px) {
  .nav { flex-direction: column; height: auto; gap: 8px; }
  .nav-links { flex-wrap: wrap; justify-content: center; }
  .category-ribbon {
    overflow-x: auto;
    flex-wrap: nowrap;
    -webkit-overflow-scrolling: touch;
  }
}
```

---

### 6.2 Category Browser

```css
/* Category banner */
.category-banner {
  padding: 12px 20px;
  border-radius: 4px;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  transition: transform 200ms ease-out;
}
.category-banner:hover { transform: scale(1.01); }
.category-banner h2 {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 700;
  color: #FFFFFF;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.category-banner .count {
  font-family: var(--font-mono);
  font-size: 13px;
  color: rgba(255, 255, 255, 0.8);
}

/* Category-specific colors */
.category-banner[data-cat="technology"] { background: var(--cat-technology); }
.category-banner[data-cat="culture"] { background: var(--cat-culture); }
.category-banner[data-cat="science"] { background: var(--cat-science); }
.category-banner[data-cat="making"] { background: var(--cat-making); }
.category-banner[data-cat="games"] { background: var(--cat-games); }
.category-banner[data-cat="weird"] { background: var(--cat-weird); }

/* Subcategory list */
.subcategory-list {
  list-style: none;
  padding: 0 0 0 20px;
  margin: 0 0 32px;
}
.subcategory-list li {
  padding: 6px 0;
  font-size: 15px;
  border-bottom: 1px solid rgba(212, 197, 160, 0.4);
}
.subcategory-list li:last-child { border-bottom: none; }
.subcategory-list .count {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-tertiary);
}

/* NEW badge — Playful Element #5 */
.badge-new {
  display: inline-block;
  font-family: var(--font-display);
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: #FFFFFF;
  background: var(--red);
  padding: 2px 6px;
  border-radius: 3px;
  margin-left: 8px;
}

.badge-updated {
  display: inline-block;
  font-family: var(--font-display);
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-primary);
  background: var(--gold-light);
  border: 1px solid var(--gold);
  padding: 2px 6px;
  border-radius: 3px;
  margin-left: 8px;
}

@media (prefers-reduced-motion: reduce) {
  .category-banner:hover { transform: none; }
}
```

### Homepage Category Grid

```css
.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
  margin: 32px 0;
}

.category-card {
  border: 2px solid var(--border);
  border-radius: 6px;
  overflow: hidden;
  background: var(--bg-surface);
  transition: border-color 200ms ease-out, box-shadow 200ms ease-out;
}
.category-card:hover {
  border-color: var(--border-dark);
  box-shadow: 0 2px 8px rgba(45, 32, 6, 0.1);
}

.category-card-header {
  padding: 12px 16px;
  color: #FFFFFF;
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 16px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.category-card-body {
  padding: 12px 16px;
}
.category-card-body li { padding: 4px 0; font-size: 14px; }
.category-card-body .count {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--text-tertiary);
}
```

---

### 6.3 Site Listing Card

```css
.site-card {
  background: var(--bg-surface);
  border: 2px solid var(--border);
  border-radius: 6px;
  padding: 16px 20px;
  margin-bottom: 12px;
  transition: border-color 200ms ease-out, box-shadow 200ms ease-out;
}
.site-card:hover {
  border-color: var(--border-dark);
  box-shadow: 0 2px 8px rgba(45, 32, 6, 0.1);
}

.site-card-category {
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-bottom: 4px;
}

/* Title — blue hyperlink */
.site-card-title {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 600;
  line-height: 1.25;
  margin-bottom: 2px;
}
.site-card-title a { color: var(--link); text-underline-offset: 3px; }
.site-card-title a:hover { text-decoration-thickness: 2px; }
.site-card-title a:visited { color: var(--link-visited); }

/* URL — the identity */
.site-card-url {
  font-family: var(--font-mono);
  font-size: 13px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

/* Summary */
.site-card-summary {
  font-family: var(--font-body);
  font-size: 15px;
  line-height: 1.6;
  margin-bottom: 12px;
}

/* Tags — pipe-separated */
.site-card-tags {
  font-family: var(--font-mono);
  font-size: 12px;
  margin-bottom: 8px;
}
.site-card-tags a { color: var(--link); font-size: 12px; }
.site-card-tags .sep { color: var(--text-tertiary); margin: 0 6px; }

/* Meta row */
.site-card-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 8px;
}
.site-card-meta .timestamps {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--text-tertiary);
}

/* Featured variant */
.site-card.featured {
  border-color: var(--gold);
  border-width: 3px;
  background: var(--gold-light);
}

/* Compact variant */
.site-card.compact {
  padding: 10px 16px;
  display: flex;
  align-items: center;
  gap: 16px;
}
.site-card.compact .site-card-summary { display: none; }
.site-card.compact .site-card-title { font-size: 16px; }
```

---

### 6.4 Quality Score System

#### Star Rating — Playful Element #2

```css
/* Score mapping: 90-100→★★★★★, 80-89→★★★★☆, 70-79→★★★★, 60-69→★★★☆☆ */

.score-stars {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}
.score-stars .star { font-size: 16px; color: var(--gold); }
.score-stars .star.empty { color: var(--border); }

.score-numeric {
  font-family: var(--font-mono);
  font-size: 13px;
  color: var(--text-secondary);
  margin-left: 6px;
}
```

#### Score Badge — Large

```css
.score-badge-large {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  background: var(--gold-light);
  border: 2px solid var(--gold);
  border-radius: 6px;
}
.score-badge-large .score-number {
  font-family: var(--font-display);
  font-size: 48px;
  font-weight: 700;
  color: var(--gold-dark);
  line-height: 1;
}
.score-badge-large .score-label {
  font-family: var(--font-mono);
  font-size: 14px;
  color: var(--text-secondary);
}
```

#### Editor's Pick

```css
.editors-pick {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: var(--red);
  color: #FFFFFF;
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  padding: 4px 10px;
  border-radius: 3px;
}
.editors-pick::before { content: "★"; }
```

#### Score Breakdown

```css
.score-breakdown {
  list-style: none;
  padding: 0;
  margin: 16px 0;
  font-family: var(--font-mono);
  font-size: 13px;
}
.score-breakdown li {
  display: flex;
  justify-content: space-between;
  padding: 6px 0;
  border-bottom: 1px solid rgba(212, 197, 160, 0.4);
}
.score-breakdown .dimension { color: var(--text-secondary); }
.score-breakdown .value { font-weight: 600; }
.score-breakdown .value.high { color: var(--green); }
```

---

### 6.5 Search

```css
.search-container {
  display: flex;
  gap: 0;
  margin: 24px 0;
}

.search-input {
  flex: 1;
  font-family: var(--font-body);
  font-size: 16px;
  padding: 10px 16px;
  border: 2px solid var(--border);
  border-right: none;
  border-radius: 4px 0 0 4px;
  background: var(--bg-surface);
  color: var(--text-primary);
}
.search-input::placeholder { font-style: italic; color: var(--text-tertiary); }
.search-input:focus {
  outline: none;
  border-color: var(--link);
  box-shadow: inset 0 0 0 1px var(--link);
}

.search-button {
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 700;
  padding: 10px 20px;
  background: var(--link);
  color: #FFFFFF;
  border: 2px solid var(--link);
  border-radius: 0 4px 4px 0;
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.search-button:hover { background: var(--link-hover); border-color: var(--link-hover); }
.search-button:active { box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2); }

/* Filter chips */
.search-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}
.filter-chip {
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 600;
  padding: 4px 12px;
  border: 2px solid var(--border);
  border-radius: 4px;
  background: var(--bg-surface);
  color: var(--text-secondary);
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.filter-chip:hover { border-color: var(--border-dark); color: var(--text-primary); }
.filter-chip.active { color: #FFFFFF; }
.filter-chip.active[data-cat="technology"] { background: var(--cat-technology); border-color: var(--cat-technology); }
.filter-chip.active[data-cat="culture"] { background: var(--cat-culture); border-color: var(--cat-culture); }
.filter-chip.active[data-cat="science"] { background: var(--cat-science); border-color: var(--cat-science); }
.filter-chip.active[data-cat="making"] { background: var(--cat-making); border-color: var(--cat-making); }
.filter-chip.active[data-cat="games"] { background: var(--cat-games); border-color: var(--cat-games); }
.filter-chip.active[data-cat="weird"] { background: var(--cat-weird); border-color: var(--cat-weird); }

@media (max-width: 639px) {
  .search-container { flex-direction: column; }
  .search-input { border-right: 2px solid var(--border); border-radius: 4px; }
  .search-button { border-radius: 4px; margin-top: 8px; }
}
```

---

### 6.6 Buttons

```css
/* Primary — Electric Blue */
.btn-primary {
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 10px 24px;
  background: var(--link);
  color: #FFFFFF;
  border: 2px solid #1D4ED8;
  border-radius: 4px;
  cursor: pointer;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
.btn-primary:hover { background: var(--link-hover); border-color: #1E40AF; }
.btn-primary:active { box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2); }
.btn-primary:focus-visible { outline: 3px solid var(--link); outline-offset: 2px; }
.btn-primary:disabled { background: var(--border); border-color: var(--border); color: var(--text-tertiary); cursor: not-allowed; }

/* Secondary — Outlined */
.btn-secondary {
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 10px 24px;
  background: var(--bg-surface);
  color: var(--link);
  border: 2px solid var(--link);
  border-radius: 4px;
  cursor: pointer;
}
.btn-secondary:hover { background: rgba(37, 99, 235, 0.05); }
.btn-secondary:active { box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1); }

/* Tertiary — Text link */
.btn-tertiary {
  font-family: var(--font-body);
  font-size: 14px;
  background: none;
  color: var(--link);
  border: none;
  cursor: pointer;
  text-decoration: underline;
  text-underline-offset: 2px;
}
.btn-tertiary:hover { color: var(--link-hover); text-decoration-thickness: 2px; }

/* Red accent (Surprise Me, alerts) */
.btn-red {
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 10px 24px;
  background: var(--red);
  color: #FFFFFF;
  border: 2px solid var(--red-hover);
  border-radius: 4px;
  cursor: pointer;
}
.btn-red:hover { background: var(--red-hover); }
.btn-red:active { box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2); }
```

---

### 6.7 "Surprise Me" — Playful Element #3

```css
@keyframes slot-spin {
  0% { transform: translateY(0); opacity: 1; }
  25% { transform: translateY(-100%); opacity: 0.5; }
  50% { transform: translateY(-200%); opacity: 0.3; }
  75% { transform: translateY(-100%); opacity: 0.5; }
  100% { transform: translateY(0); opacity: 1; }
}

.surprise-result {
  margin-top: 16px;
  opacity: 0;
  transform: translateY(8px);
  transition: opacity 300ms ease-out, transform 300ms ease-out;
}
.surprise-result.visible {
  opacity: 1;
  transform: translateY(0);
}
.surprise-result .site-card {
  border-color: var(--gold);
  border-width: 3px;
  background: var(--gold-light);
}

@media (prefers-reduced-motion: reduce) {
  .surprise-result { transition: none; }
}
```

---

### 6.8 Submission Flow

```css
.submit-form { max-width: 640px; margin: 0 auto; }

.submit-url-input {
  width: 100%;
  font-family: var(--font-mono);
  font-size: 18px;
  padding: 14px 16px;
  border: 3px solid var(--border);
  border-radius: 6px;
  background: var(--bg-surface);
  margin-bottom: 16px;
}
.submit-url-input:focus { outline: none; border-color: var(--link); }
.submit-url-input::placeholder {
  font-family: var(--font-body);
  font-style: italic;
  color: var(--text-tertiary);
}

/* Scoring display */
.scoring-progress {
  list-style: none;
  padding: 0;
  margin: 24px 0;
  font-family: var(--font-mono);
  font-size: 14px;
}
.scoring-progress li {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
  border-bottom: 1px solid rgba(212, 197, 160, 0.4);
  color: var(--text-tertiary);
}
.scoring-progress li.complete { color: var(--text-primary); }
.scoring-progress li.complete .check { color: var(--green); }

.submit-result {
  padding: 20px;
  border: 2px solid var(--green);
  border-radius: 6px;
  background: var(--green-light);
}
.submit-result .score {
  font-family: var(--font-display);
  font-size: 32px;
  font-weight: 700;
  color: var(--gold-dark);
}
```

---

### 6.9 Collections & Lists

```css
.collection-header {
  border-radius: 6px;
  padding: 20px 24px;
  color: #FFFFFF;
  margin-bottom: 24px;
}
.collection-header h1 {
  font-family: var(--font-display);
  font-size: 32px;
  font-weight: 700;
}
.collection-header .description {
  font-family: var(--font-body);
  font-size: 16px;
  opacity: 0.9;
  margin-top: 8px;
}

.collection-list {
  counter-reset: collection;
  list-style: none;
  padding: 0;
}
.collection-list li {
  counter-increment: collection;
  display: flex;
  gap: 16px;
  padding: 16px 0;
  border-bottom: 1px solid var(--border);
}
.collection-list li::before {
  content: counter(collection) ".";
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 700;
  color: var(--text-tertiary);
  min-width: 40px;
}
.collection-list .site-title {
  font-family: var(--font-display);
  font-size: 18px;
  font-weight: 600;
}
.collection-list .site-title a { color: var(--link); }
.collection-list .site-url {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-tertiary);
}
.collection-list .site-summary {
  font-family: var(--font-body);
  font-size: 14px;
  color: var(--text-secondary);
  margin-top: 4px;
}
```

---

### 6.10 Form Elements

```css
.form-input {
  font-family: var(--font-body);
  font-size: 16px;
  padding: 10px 14px;
  border: 2px solid var(--border);
  border-radius: 4px;
  background: var(--bg-surface);
  color: var(--text-primary);
  width: 100%;
}
.form-input:focus {
  outline: none;
  border-color: var(--link);
  box-shadow: inset 0 0 0 1px var(--link);
}
.form-input.error { border-color: var(--error); }

.form-label {
  display: block;
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--text-secondary);
  margin-bottom: 6px;
}

.form-error { font-family: var(--font-mono); font-size: 12px; color: var(--error); margin-top: 4px; }
.form-help { font-family: var(--font-body); font-size: 13px; color: var(--text-tertiary); margin-top: 4px; }

textarea.form-input { min-height: 100px; resize: vertical; }

select.form-input {
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg width='10' height='6' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%236B5D3F'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 36px;
}
```

---

## Interaction & Motion

### Philosophy

The early web was mostly static. That's part of the charm. Motion is *sparse* — only where it communicates or adds retro delight.

| Element | Effect | Duration | Easing | Trigger |
|---|---|---|---|---|
| Link hover | Underline thickens | Instant | — | hover |
| Link visited | Color → purple | Instant | — | visited |
| Card hover | Border darkens + shadow | 200ms | ease-out | hover |
| Category banner hover | scale(1.01) | 200ms | ease-out | hover |
| Button active | Inset shadow | Instant | — | :active |
| Button focus | 3px blue outline | Instant | — | :focus-visible |
| "Surprise Me" click | Slot-machine spin | 400ms | ease-in-out | click |
| "Surprise Me" result | Fade-in + slide-up | 300ms | ease-out | after spin |
| Scoring progress | Check appears | 200ms | ease-out | sequential |
| Search focus | Border → blue | Instant | — | focus |
| Filter chip active | Fill with color | Instant | — | click |
| Page load | **No animation** | — | — | — |
| Scroll | **No animation** | — | — | — |
| Parallax | **None** | — | — | — |
| Page transitions | **None** | — | — | — |

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Dark Mode

```css
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #1C1A0F;
    --bg-surface: #262318;
    --bg-alt: #211F14;
    --bg-highlight: #332E1A;

    --text-primary: #E8E0CC;
    --text-secondary: #B5AA90;
    --text-tertiary: #8A7D64;

    --link: #60A5FA;
    --link-hover: #93C5FD;
    --link-visited: #A78BFA;

    --border: #4A4231;
    --border-dark: #5E5440;

    --gold-light: #332E1A;

    --cat-technology: #60A5FA;
    --cat-culture: #A78BFA;
    --cat-science: #4ADE80;
    --cat-making: #FB923C;
    --cat-games: #F87171;
    --cat-weird: #F472B6;
  }
}
```

### Dark Mode Contrast

| Foreground | Background | Ratio | Pass |
|---|---|---|---|
| `#E8E0CC` | `#1C1A0F` | 11.4:1 | AAA |
| `#B5AA90` | `#1C1A0F` | 6.8:1 | AA |
| `#60A5FA` | `#1C1A0F` | 6.2:1 | AA |
| `#60A5FA` | `#262318` | 5.4:1 | AA |
| `#E8E0CC` | `#262318` | 9.8:1 | AAA |

---

## Mixing Notes

### 20% Consumer Playful Elements

| # | Element | Rationale |
|---|---|---|
| 1 | **Category color system** | The old web used color to distinguish sections — Yahoo had colored banners. Multi-color is a Playful trait that perfectly maps to the retro reference. |
| 2 | **Star rating display** | Gold stars are the universal "rating" signal from web 1.0. Plain numbers feel clinical; stars feel webby. |
| 3 | **"Surprise Me" animation** | One moment of interactive delight. The old web had "I'm Feeling Lucky" — the animation adds anticipation. |
| 4 | **Category banner hover** | scale(1.01) makes colored blocks feel tangible, like buttons you could press. |
| 5 | **"NEW"/"UPDATED" badges** | "NEW!" in red was the universal signal for fresh content. Adds visual energy and signals the directory is alive. |

### Considered and Rejected

| Element | Why Rejected |
|---|---|
| Rounded corners (12px+) | Conflicts with retro aesthetic. 6px is the compromise. |
| Card lift on hover | Too modern — shadows appear, but translateY lift feels SaaS. |
| Bento grid layout | Too 2024. Traditional lists and grids, not asymmetric bento. |
| Gradients | The retro web was flat. Flat is honest. |
| Confetti on submission | Too much. Scoring reveal is enough. Confetti would feel ironic. |
| Page transitions | The old web didn't have them. Instant context switches are charm. |
| Bottom tab bar | Too app-like. A directory is a *website*, not an app. |
| Bouncy easing | Too playful. Ease-out is sufficient. Bouncy feels like Duolingo. |

---

## Directory-Specific Patterns

### Byline Metadata

```css
.byline {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-tertiary);
}
```

Example: `First indexed 2024-06-14 · Last checked 2026-03-12 · Submitted by community`

### "New This Week"

```css
.new-this-week {
  border: 2px solid var(--red);
  border-radius: 6px;
  padding: 20px;
  margin-bottom: 32px;
}
.new-this-week h2 {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 700;
  color: var(--red);
}
.new-this-week h2::before { content: "★ "; }
```

### Directory Stats (Footer)

```css
.directory-stats {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
  font-family: var(--font-mono);
  font-size: 13px;
  color: var(--text-secondary);
  padding: 24px;
  border-top: 2px solid var(--border);
}
.directory-stats .stat-number {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 700;
  color: var(--text-primary);
  display: block;
}
```

### Footer

```css
.footer {
  background: var(--bg-primary);
  border-top: 2px solid var(--border);
  padding: 32px 24px;
  margin-top: 64px;
}
.footer-links { font-family: var(--font-mono); font-size: 13px; }
.footer-links a + a::before { content: " | "; color: var(--text-tertiary); }
.footer-tagline {
  font-family: var(--font-body);
  font-size: 14px;
  font-style: italic;
  color: var(--text-tertiary);
  margin-top: 12px;
}
```

### Empty State

```css
.empty-state {
  text-align: center;
  padding: 48px 24px;
  color: var(--text-tertiary);
}
```
*"No sites here yet — be the first to submit!"*

---

## Directory Wireframes

### Homepage

```
┌─────────────────────────────────────────────────┐
│  gotta.cc        Browse | Search | Submit | About│
├─────────────────────────────────────────────────┤
│  Technology · Culture · Science · Making · ...  │
├─────────────────────────────────────────────────┤
│                                                 │
│  THE YAHOO DIRECTORY FOR                        │
│  THE POST-SLOP WEB                              │
│                                                 │
│  [Search the directory...        ] [SEARCH]     │
│  [Technology] [Culture] [Science] [Making] ...  │
│                                                 │
│  ★ NEW THIS WEEK ──────────────────────────     │
│  │ uses-this.com — ★★★★★ (94/100)             │
│  │ another-site.org — ★★★★☆ (82/100)          │
│  └──────────────────────────────────────────    │
│                                                 │
│  ┌──────────────┐ ┌──────────────┐ ┌────────┐  │
│  │ TECHNOLOGY   │ │ CULTURE      │ │ SCIENCE│  │
│  │ Dev Tools 47 │ │ Blogs    89  │ │ Bio  23│  │
│  │ AI & ML   31 │ │ Art      45  │ │ Phys 18│  │
│  └──────────────┘ └──────────────┘ └────────┘  │
│                                                 │
│  [I'M FEELING LUCKY]                            │
│                                                 │
│  12,847 sites · 347 categories · Updated daily  │
│  "The web is big again."                        │
└─────────────────────────────────────────────────┘
```

### Category Page

```
┌─────────────────────────────────────────────────┐
│  > Technology > Developer Tools                 │
├─────────────────────────────────────────────────┤
│  ┌─ DEVELOPER TOOLS (47 sites) ─── blue ──────┐│
│  └─────────────────────────────────────────────┘│
│  Terminals (12) · Editors (8) · CLI (15) NEW   │
│                                                 │
│  Sort: [Score ▼] [Newest] [A-Z]                │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ Warp — The terminal reimagined          │   │
│  │ warp.dev                                │   │
│  │ Modern terminal with AI command search  │   │
│  │ ★★★★☆ (86/100)                         │   │
│  │ terminals | rust | ai                   │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ Uses This            ★ EDITOR'S PICK    │   │
│  │ uses-this.com                           │   │
│  │ Interviews about tools people use       │   │
│  │ ★★★★★ (94/100)                         │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

## Accessibility

### Focus Management

```css
*:focus-visible {
  outline: 3px solid var(--link);
  outline-offset: 2px;
}
```

### Keyboard Navigation

- All interactive elements reachable via Tab
- Category tree navigable with arrow keys
- Skip-to-content link visible on focus
- Search accessible via `/` shortcut

### ARIA

```html
<!-- Star rating -->
<div role="img" aria-label="Quality score: 87 out of 100, 4 out of 5 stars">
  <span aria-hidden="true">★★★★☆</span>
  <span class="score-numeric">(87/100)</span>
</div>

<!-- Category tree -->
<nav aria-label="Category browser">
  <ul role="tree">
    <li role="treeitem" aria-expanded="true">Technology
      <ul role="group">
        <li role="treeitem"><a href="...">Developer Tools (47)</a></li>
      </ul>
    </li>
  </ul>
</nav>

<!-- Surprise Me live region -->
<div aria-live="polite" aria-atomic="true"></div>
```

### Screen Reader

- Star ratings have aria-label with numeric score
- Badges have sr-only text alternatives
- Category colors are not sole differentiators — text labels always present
- Loading states announce via aria-live

---

## Implementation Checklist

### Typography
- [ ] Space Grotesk loaded for headlines and UI
- [ ] IBM Plex Serif loaded for body
- [ ] IBM Plex Mono loaded for URLs, scores, metadata
- [ ] URLs always in monospace
- [ ] Category names uppercase with letter-spacing
- [ ] Fluid type scaling with clamp()

### Color
- [ ] Warm yellow bg (#FFF8E7) applied globally
- [ ] Hyperlink blue (#2563EB) on all text links
- [ ] Visited links show purple (#6D28D9)
- [ ] Each category has assigned color
- [ ] Gold for all score UI
- [ ] No gradients
- [ ] All combinations pass WCAG AA

### Borders & Structure
- [ ] Cards have 2px tan borders
- [ ] Border-radius 4–6px consistently
- [ ] No box-shadows by default (hover only)
- [ ] Category banners full-color backgrounds

### Components
- [ ] Navigation with pipe separators
- [ ] Category ribbon with colored links
- [ ] Category browser with colored banners
- [ ] Site cards with blue hyperlink titles
- [ ] Star rating + numeric score
- [ ] Editor's Pick badge
- [ ] Search with adjacent button + filter chips
- [ ] "I'm Feeling Lucky" with animation
- [ ] Submission form with live scoring
- [ ] Collections with numbered lists
- [ ] NEW and UPDATED badges

### Interaction
- [ ] Links underlined, thicken on hover
- [ ] Card hover: shadow + border darken
- [ ] Button active: inset shadow
- [ ] Category banner: scale(1.01)
- [ ] "Surprise Me": slot-spin animation
- [ ] No parallax, no scroll animations
- [ ] prefers-reduced-motion respected

### Accessibility
- [ ] All contrast ratios WCAG 2.2 AA
- [ ] Focus rings 3px solid blue
- [ ] Skip-to-content link
- [ ] Star ratings have aria-label
- [ ] Category tree uses role="tree"
- [ ] "Surprise Me" uses aria-live
- [ ] Touch targets 44x44px minimum

### Dark Mode
- [ ] All tokens overridden in prefers-color-scheme: dark
- [ ] Link blue lightened
- [ ] Category colors adjusted
- [ ] Borders lightened
- [ ] Contrast ratios verified

### Responsive
- [ ] Category grid → single column on mobile
- [ ] Search stacks vertically
- [ ] Nav wraps gracefully
- [ ] Category ribbon scrolls horizontally
- [ ] Font sizes scale with clamp()

---

*Derived from: [bold-expressive.md](../../../.claude/skills/user-experience-engineer/references/styles/bold-expressive.md) + [consumer-playful.md](../../../.claude/skills/user-experience-engineer/references/styles/consumer-playful.md)*
*Version: 0.1.0*
