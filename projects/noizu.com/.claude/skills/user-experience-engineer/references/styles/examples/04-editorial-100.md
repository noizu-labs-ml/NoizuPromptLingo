# Style Guide: Ipso The Lorem — The Lorem Review

> Typography-first design for a case study publication and thought leadership blog.

**Style System:** Editorial 100%
**Source Spec:** [editorial.md](../editorial.md)
**Scenario:** Long-form case study publication

---

## Scenario

**The Lorem Review** is Ipso The Lorem's thought leadership arm — a publication featuring in-depth case studies, technical retrospectives, and essays on the intersection of design and technology. Articles run 2,000-8,000 words with supporting data, images, and pull quotes.

The audience is peers: product leaders, design directors, and senior engineers at other consultancies and tech companies. They're here to learn, not to be sold to. The publication must signal **authority, craftsmanship, and intellectual depth**. It should feel like a well-edited magazine, not a company blog.

Editorial style is purpose-built for this: typography IS the design. Generous line heights, a carefully controlled 65-character measure, serif headlines for gravitas, and an interface that disappears so the content can breathe.

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #FFFCF7;   /* warm cream */
  --bg-surface: #FFFFFF;
  --bg-code: #F5F3EF;

  /* Text */
  --text-primary: #1A1A1A;
  --text-secondary: #666666;
  --text-tertiary: #999999;

  /* Borders */
  --border-default: #E5E0D8;
  --border-rule: #1A1A1A;   /* for horizontal rules and pull quote borders */

  /* Accent — Editorial Red (subtle authority) */
  --accent: #C0392B;
  --accent-hover: #A93226;

  /* No semantic color system — content doesn't use success/error/warning patterns */
}
```

```
┌─────────────────────────────────────────┐
│  THE LOREM REVIEW PALETTE               │
├─────────────────────────────────────────┤
│                                         │
│  ██████  #FFFCF7   Warm Cream bg        │
│  ██████  #1A1A1A   Near-Black text      │
│  ██████  #666666   Secondary text       │
│                                         │
│  ██████  #C0392B   Editorial Red        │
│                                         │
│  Palette is intentionally minimal.      │
│  Typography provides all the visual     │
│  richness this design needs.            │
│                                         │
└─────────────────────────────────────────┘
```

**Usage rules:**
- Warm cream background (`#FFFCF7`) — pure white is too clinical for long reading sessions
- Accent (editorial red) used ONLY for: article category labels, link hover states, pull quote borders
- Near-black text (`#1A1A1A`) instead of true black — softer on the eyes for long-form reading
- No background color sections — whitespace and typography create all visual rhythm
- Horizontal rules (`<hr>`) use a 1px near-black line, not gray

---

## Typography

**Font stack:**
```css
--font-display: 'Playfair Display', Georgia, serif;
--font-body: 'Source Serif Pro', Georgia, 'Times New Roman', serif;
--font-sans: 'Inter', -apple-system, sans-serif; /* UI elements only */
--font-mono: 'JetBrains Mono', Consolas, monospace;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| Display | Display Serif | 72px | 700 | 1.05 | Feature article hero |
| H1 | Display Serif | 48px | 700 | 1.1 | Article title |
| H2 | Display Serif | 32px | 700 | 1.2 | Major sections |
| H3 | Display Serif | 24px | 600 | 1.25 | Subsections |
| Deck | Body Serif | 22px | 400 | 1.5 | Article subtitle/deck |
| Lead | Body Serif | 20px | 400 | 1.7 | First paragraph |
| Body | Body Serif | 18px | 400 | 1.8 | Article text |
| Caption | Sans | 13px | 400 | 1.5 | Image captions, bylines |
| Overline | Sans | 11px | 600 | 1.4 | Category labels (uppercase, 0.12em tracking) |
| Code | Mono | 15px | 400 | 1.6 | Code blocks |
| Pull Quote | Body Serif | 28px | 400 italic | 1.4 | Pull quotes |

**Typography notes:**
- Body text at 18px with 1.8 line height — optimized for sustained reading
- **Reading measure: `max-width: 65ch`** — this is NON-NEGOTIABLE for readability
- Display serif (Playfair) for headlines only; body serif (Source Serif Pro) for everything else
- Sans-serif (Inter) reserved for UI chrome: navigation, buttons, metadata, captions
- Drop caps on feature articles: `::first-letter` at 4.5em, float left

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Playfair Display | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Playfair+Display) |
| Source Serif Pro | Adobe Fonts (Adobe original) | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/source-serif) \| [Google Fonts](https://fonts.google.com/specimen/Source+Serif+4) \| [GitHub](https://github.com/adobe-fonts/source-serif) |
| Inter | Adobe Fonts | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/inter) \| [Google Fonts](https://fonts.google.com/specimen/Inter) |
| JetBrains Mono | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) \| [GitHub](https://github.com/JetBrains/JetBrainsMono) |

*Note:* Source Serif Pro is now published as **Source Serif 4** on Google Fonts, but the Adobe Fonts version retains the original naming. Both are the same typeface family by Frank Griesshammer (Adobe). *Adobe Fonts alternative for Playfair Display:* [Lora](https://fonts.adobe.com/fonts/lora) — similar transitional serif with elegant display qualities. Also on [Google Fonts](https://fonts.google.com/specimen/Lora).

---

## Spacing & Layout

**Spacing scale:** 8, 16, 24, 32, 48, 80, 120px

**Grid:**

| Breakpoint | Layout | Content Width | Margins |
|------------|--------|---------------|---------|
| Mobile (<768px) | Full width | 100% | 24px |
| Tablet (768-1024px) | Centered | 65ch | 48px (auto) |
| Desktop (1024-1440px) | Centered | 65ch | auto (large) |
| Wide (>1440px) | Asymmetric | 65ch body, 960px with sidebar | auto |

**Layout pattern:** Content-centered single column. Article body is always `max-width: 65ch` and horizontally centered. On wide screens, an asymmetric layout with a generous left margin creates elegance. Sidenotes/footnotes float to the right on wide screens (200px wide, right-margin positioned).

**Vertical rhythm:**
- Between paragraphs: 1.5x body line height (27px)
- Before H2: 80px
- Before H3: 48px
- Between article sections: 80px (with optional horizontal rule)
- Image margin: 48px top and bottom

---

## Component Styling

### Article Structure

```
OVERLINE (category)
HEADLINE (H1)
DECK (subtitle)
BYLINE + DATE + READ TIME
─── (rule) ───
LEAD IMAGE + CAPTION
LEAD PARAGRAPH (larger, styled differently)
BODY TEXT
  ├── Pull Quote
  ├── Image + Caption
  ├── Code Block
  └── Sidenote
AUTHOR BIO
RELATED ARTICLES
```

### Text Treatments

```css
/* Drop cap */
.article__body > p:first-of-type::first-letter {
  font-family: var(--font-display);
  font-size: 4.5em;
  float: left;
  line-height: 0.8;
  padding-right: 12px;
  padding-top: 4px;
  color: var(--text-primary);
}

/* Pull quote */
.pullquote {
  font-family: var(--font-body);
  font-size: 28px;
  font-style: italic;
  line-height: 1.4;
  color: var(--text-primary);
  border-left: 3px solid var(--accent);
  padding-left: 24px;
  margin: 48px 0;
  max-width: 55ch;
}

/* Byline */
.byline {
  font-family: var(--font-sans);
  font-size: 13px;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

/* Image caption */
.caption {
  font-family: var(--font-sans);
  font-size: 13px;
  font-style: italic;
  color: var(--text-secondary);
  margin-top: 12px;
}
```

### Navigation

```css
.header {
  height: 56px;
  background: transparent;
  border-bottom: 1px solid var(--border-default);
  padding: 0 48px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.header__logo {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 700;
  color: var(--text-primary);
}
.header__nav-item {
  font-family: var(--font-sans);
  font-size: 13px;
  color: var(--text-secondary);
  text-decoration: none;
}
.header__nav-item:hover {
  color: var(--accent);
}
/* Navigation hides on scroll down, reappears on scroll up */
```

### Links

```css
.article a {
  color: var(--text-primary);
  text-decoration: underline;
  text-decoration-color: var(--accent);
  text-decoration-thickness: 1px;
  text-underline-offset: 3px;
  transition: text-decoration-color 200ms ease;
}
.article a:hover {
  text-decoration-color: var(--text-primary);
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Reading progress bar | Width grows with scroll | Continuous | linear |
| Article image | Slight parallax on scroll | Continuous | linear |
| Navigation | Hide on scroll down, show on scroll up | 300ms | ease |
| Pull quote | Fade in on scroll into view | 400ms | ease-out |
| Link hover | Underline color transition | 200ms | ease |
| Related article card | Subtle rise on hover | 200ms | ease |
| Share menu | Fade in | 150ms | ease |

**Motion philosophy:** Minimal and purposeful. The reading experience should be undisturbed. Progress bar and parallax are the only scroll-linked animations. No page transitions, no card flip effects, no attention-competing motion.

**Reading progress bar:**
```css
.progress-bar {
  position: fixed;
  top: 0;
  left: 0;
  height: 2px;
  background: var(--accent);
  z-index: 100;
  /* width updated via JS based on scroll position */
}
```

---

## Asset Guidelines

**Photography:** High-quality editorial photography. Can bleed full-width or extend beyond the 65ch content column. Every image MUST have a caption and credit line. Photo style: documentary, well-composed, high contrast. No stock photography.

**Iconography:** Minimal — only for UI controls (search, menu, share, close). Feather icons, 18px, 1.5px stroke. Text-secondary color.

**Illustration:** Occasional data visualizations and diagrams within articles. Clean, minimal style with the accent color. No decorative illustration.

**Section dividers:** Three options (use consistently within an article):
1. Simple `<hr>` — 1px near-black, 48px margin
2. Triple asterisk: `* * *` centered, text-tertiary, 48px margin
3. Numbered sections: overline-styled numbers

---

## Implementation Checklist

- [ ] **Body text at 18px minimum** — never smaller for article content
- [ ] **Line height 1.8 for body text** — generous for sustained reading
- [ ] **Max-width: 65ch for body content** — NON-NEGOTIABLE
- [ ] Warm cream background (#FFFCF7)
- [ ] Two serif families: Playfair Display (headlines) + Source Serif Pro (body)
- [ ] Sans-serif (Inter) used ONLY for UI chrome, never for article content
- [ ] Reading progress bar at page top
- [ ] All images have captions and credits
- [ ] Pull quotes styled with accent border-left
- [ ] Navigation hides on scroll down
- [ ] Drop cap on feature article first paragraph
- [ ] Footnotes/sidenotes work on wide screens (float right)
- [ ] Estimated read time displayed in byline area
- [ ] Print stylesheet: removes navigation, expands images, shows URL for links
- [ ] Color contrast: 1A1A1A on FFFCF7 = 15.8:1 (exceeds AAA)

---

*Derived from: [editorial.md](../editorial.md)*
*Example #4 of 10 — See [README.md](README.md) for full series*
