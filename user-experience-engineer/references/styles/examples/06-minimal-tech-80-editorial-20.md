# Style Guide: Ipso The Lorem — LoremDocs

> Clean developer documentation with editorial warmth for long-form guides.

**Style System:** Minimal Tech 80% + Editorial 20%
**Source Specs:** [minimal-tech.md](../minimal-tech.md) + [editorial.md](../editorial.md)
**Scenario:** SaaS documentation hub

---

## Scenario

Ipso The Lorem's LoremOps product (see [Example 01](01-minimal-tech-100.md)) needs a documentation hub — **LoremDocs**. This isn't a typical API reference with short method signatures. LoremOps is a complex tool, and its docs include long-form conceptual guides (2,000-5,000 words), alongside standard API references and tutorials.

Pure Minimal Tech (Example 01) works for the app dashboard, but applied to documentation it would feel too cold for sustained reading. The long-form guides need **editorial touches** — better reading typography, more generous line spacing, and a content-first hierarchy — without losing the technical credibility of the parent product.

**Mix rationale:** Minimal Tech provides the structural foundation (monochrome palette, functional layout, developer density). Editorial contributes **body serif typography for long-form content** and **reading-optimized spacing** — two specific elements that directly improve the documentation reading experience.

---

## Color Palette

```css
:root {
  /* 80% — Minimal Tech foundation (dark mode) */
  --bg-primary: #0B0B0F;
  --bg-surface: #16161D;
  --bg-elevated: #1E1E28;
  --bg-code: #12121A;

  --text-primary: #EDEDF0;
  --text-secondary: #9494A0;
  --text-tertiary: #5C5C6B;

  --border-default: #2A2A36;

  --accent: #6366F1;
  --accent-hover: #818CF8;
  --accent-muted: rgba(99, 102, 241, 0.12);

  --success: #4ADE80;
  --warning: #FACC15;
  --error: #F87171;
  --info: #60A5FA;

  /* No Editorial color additions — palette stays 100% Minimal Tech */
}
```

**Usage rules:** Identical to Example 01 (LoremOps). The palette is entirely Minimal Tech — Editorial's contribution is typographic, not chromatic.

---

## Typography

**Font stack:**
```css
/* 80% — Minimal Tech: UI and code */
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', Consolas, monospace;

/* 20% — Editorial influence: body text in long-form guides */
--font-prose: 'Source Serif Pro', Georgia, serif;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| H1 | Sans | 28px | 600 | 1.2 | Page titles |
| H2 | Sans | 22px | 600 | 1.25 | Section headers |
| H3 | Sans | 18px | 600 | 1.3 | Subsections |
| Body (API ref) | Sans | 14px | 400 | 1.6 | API docs, short entries |
| **Body (Guide)** | **Serif** | **17px** | **400** | **1.75** | **Long-form conceptual guides** |
| Code | Mono | 13px | 400 | 1.5 | Code blocks and inline code |
| Caption | Sans | 11px | 500 | 1.4 | Breadcrumbs, metadata |
| Sidebar nav | Sans | 13px | 400 | 1.5 | Navigation items |

**Typography notes:**
- **The 20% element:** Long-form guide body text uses Source Serif Pro at 17px with 1.75 line height — borrowed from Editorial's reading-optimized approach. This is the single biggest departure from pure Minimal Tech.
- API references, method signatures, parameter tables, and all UI chrome remain in Inter (sans-serif) — pure Minimal Tech.
- The serif font appears ONLY within `<article class="guide">` containers — never in navigation, sidebars, headers, or code.
- Max content width for guide articles: 72ch (slightly wider than Editorial's strict 65ch, accommodating code examples inline).

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Inter | Adobe Fonts | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/inter) \| [Google Fonts](https://fonts.google.com/specimen/Inter) |
| Source Serif Pro | Adobe Fonts (Adobe original) | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/source-serif) \| [Google Fonts](https://fonts.google.com/specimen/Source+Serif+4) |
| JetBrains Mono | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) \| [GitHub](https://github.com/JetBrains/JetBrainsMono) |
| Fira Code (fallback) | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Fira+Code) |

---

## Spacing & Layout

**Spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96px (Minimal Tech — unchanged)

**Grid:**

| Breakpoint | Columns | Gutter | Margin | Max Width |
|------------|---------|--------|--------|-----------|
| Mobile (<768px) | 4 | 12px | 16px | 100% |
| Tablet (768-1024px) | 8 | 16px | 24px | 100% |
| Desktop (1024-1440px) | 12 | 24px | 32px | 100% |
| Wide (>1440px) | 12 | 24px | 64px | 1440px |

**Layout pattern:** Three-panel documentation layout:
- Left sidebar (240px): navigation tree
- Main content: documentation body
- Right sidebar (200px, desktop only): table of contents / "on this page"

**20% Editorial influence on spacing:** Within long-form guide articles, vertical spacing between paragraphs increases from 16px (Minimal Tech default) to 24px (echoing Editorial's generous rhythm). Heading margins also increase: 48px before H2, 32px before H3 (vs. 32px/24px in pure Minimal Tech).

---

## Component Styling

### Buttons, Inputs, Navigation

Identical to [Example 01 (LoremOps)](01-minimal-tech-100.md). The 20% Editorial accent does not touch interactive components — these remain pure Minimal Tech.

### Guide-Specific Text Treatments (20% Editorial Influence)

```css
/* Long-form guide body — the Editorial accent */
.guide__body {
  font-family: var(--font-prose);
  font-size: 17px;
  line-height: 1.75;
  color: var(--text-primary);
  max-width: 72ch;
}
.guide__body p + p {
  margin-top: 24px; /* more generous than Minimal Tech's 16px */
}

/* Callout blocks in guides — subtle Editorial influence */
.guide__callout {
  border-left: 3px solid var(--accent);
  padding: 16px 20px;
  margin: 32px 0;
  background: var(--bg-surface);
  border-radius: 0 6px 6px 0;
  font-style: italic; /* Editorial touch */
}

/* API reference body — stays Minimal Tech */
.api__body {
  font-family: var(--font-sans);
  font-size: 14px;
  line-height: 1.6;
}
```

---

## Interaction & Motion

Identical to [Example 01 (LoremOps)](01-minimal-tech-100.md). All 150ms ease transitions, functional-only animations. Editorial does not influence interaction patterns — its contribution is purely typographic/spatial.

---

## Asset Guidelines

Same as Example 01. No photography, Lucide icons, monochrome data visualizations. Editorial's photographic and drop-cap conventions are not imported — they don't fit a documentation context.

---

## Mixing Notes

### Elements Carrying the 20% Editorial Accent (3 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Guide body typography** | Sans → Serif (Source Serif Pro), 14px → 17px, line-height 1.6 → 1.75 | Long-form conceptual guides require sustained reading. Serif type at larger size with more spacing reduces eye fatigue across 3,000+ word documents. |
| **Guide paragraph spacing** | 16px → 24px between paragraphs | Matches the increased line height. Denser spacing with taller line height creates an uncomfortable rhythm; increasing both together maintains proportional whitespace. |
| **Guide heading margins** | 32px/24px before H2/H3 → 48px/32px | Long articles need clearer section breaks. More generous heading margins help readers scan and re-orient in lengthy guides. |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| Drop caps on guide introductions | Too decorative for a developer documentation context. Would feel like a magazine, not a reference. |
| Reading progress bar | Unnecessary for documentation (users jump sections, not read linearly). |
| Warm cream background | Conflicts with dark mode Minimal Tech palette. Would require a separate light theme, adding complexity. |
| Serif headings (Playfair Display) | Creates too much visual distinction between guide pages and API pages. Users should feel they're in one product, not two. |
| Pull quotes | Documentation doesn't have quotable moments — content is instructional, not argumentative. |

---

## Implementation Checklist

- [ ] Inter (sans) for UI, navigation, API docs
- [ ] Source Serif Pro (serif) for guide body text only
- [ ] JetBrains Mono for code blocks everywhere
- [ ] Serif appears ONLY in `.guide__body` containers
- [ ] Guide body max-width: 72ch
- [ ] Guide paragraph spacing: 24px (not 16px)
- [ ] Guide heading margins: 48px before H2, 32px before H3
- [ ] API reference pages remain pure Minimal Tech (14px sans, 16px paragraph spacing)
- [ ] All other components (buttons, inputs, nav, cards) unchanged from Minimal Tech
- [ ] Callout blocks have italic text + accent border-left
- [ ] Dark mode only (consistent with parent LoremOps product)
- [ ] Accessible contrast: serif text on dark bg meets AA

---

*Derived from: [minimal-tech.md](../minimal-tech.md) + [editorial.md](../editorial.md)*
*Example #6 of 10 — See [README.md](README.md) for full series*
