# Style Guide: derobot.is — Nocturne Venture

> Dark, typographic, confident. The robots build. The robots share.

**Style System:** Nocturne (80%) + Bold Expressive (20%)
**Source:** `README.md` Visual Direction section
**Scenario:** Corporate landing page for an AI-native venture lab — serving builders, investors, and collaborators

---

## Scenario

derobot.is is the roof over an 11-product portfolio. It's not a SaaS, not a consumer app — it's the visible operating system for a venture lab. The visual identity must communicate:

1. **Technical credibility** — this team builds real things
2. **Intentional portfolio** — deliberate spread of bets, not random projects
3. **Operational clarity** — a visible process, not vaporware
4. **Confidence without arrogance** — direct, slightly irreverent, never corporate

The audience is three-fold: potential users discovering a product, collaborators/co-founders evaluating the operation, and investors assessing the portfolio. All three need to see competence in under 5 seconds.

---

## Color Palette

```css
:root {
  /* ── Surfaces ── */
  --bg-primary:       #09090B;   /* Page background — near-black, warm zinc */
  --bg-surface:       #18181B;   /* Cards, elevated sections */
  --bg-surface-hover: #1F1F23;   /* Card hover state */
  --bg-overlay:       #09090Bcc; /* Modal/drawer backdrop (80% opacity) */

  /* ── Text ── */
  --text-primary:     #FAFAFA;   /* Headings, key content, hero text */
  --text-secondary:   #A1A1AA;   /* Body text, descriptions, metadata */
  --text-tertiary:    #71717A;   /* Captions, disabled labels */
  --text-inverse:     #09090B;   /* Text on accent backgrounds */

  /* ── Accents ── */
  --accent-cyan:      #22D3EE;   /* Primary accent — the robot signal */
  --accent-cyan-dim:  #22D3EE33; /* Glow effects, subtle backgrounds */
  --accent-violet:    #A78BFA;   /* Secondary accent — links, alt actions */
  --accent-violet-dim:#A78BFA33; /* Hover backgrounds, tags */

  /* ── Borders ── */
  --border-subtle:    #27272A;   /* Card borders, dividers */
  --border-focus:     #22D3EE;   /* Focus rings, active states */

  /* ── States ── */
  --state-success:    #34D399;   /* Live product indicators */
  --state-warning:    #FBBF24;   /* Validation stage */
  --state-error:      #F87171;   /* Killed / shelved products */
  --state-info:       #60A5FA;   /* Concept stage */
}
```

### Swatch Reference

```
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ #09090B  │ │ #18181B  │ │ #FAFAFA  │ │ #A1A1AA  │
│ bg       │ │ surface  │ │ text-pri │ │ text-sec │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ #22D3EE  │ │ #A78BFA  │ │ #27272A  │ │ #71717A  │
│ cyan     │ │ violet   │ │ border   │ │ tertiary │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ #34D399  │ │ #FBBF24  │ │ #F87171  │ │ #60A5FA  │
│ success  │ │ warning  │ │ error    │ │ info     │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

### Usage Rules

- **Cyan (#22D3EE)** is the primary accent. Use for: CTAs, active navigation, interactive element highlights, the "robot signal" across the page. Never use as a text color on dark backgrounds smaller than 16px — it's a signal color, not a reading color.
- **Violet (#A78BFA)** is the secondary accent. Use for: links in body text, secondary buttons, category tags, hover states where cyan is the resting state. It provides warmth against the cold cyan.
- **Surface (#18181B)** is the card color. Every card sits on surface, never on bg-primary. This creates the only elevation layer — there is no z-3, z-4. Two layers: page and card.
- **Border (#27272A)** is always 1px solid. No border-radius larger than 8px anywhere. The aesthetic is precise, not friendly.

### Contrast Verification

| Pair | Ratio | WCAG |
|------|-------|------|
| text-primary on bg-primary | 19.4:1 | AAA |
| text-secondary on bg-primary | 7.2:1 | AAA |
| text-tertiary on bg-primary | 4.6:1 | AA (large text only) |
| accent-cyan on bg-primary | 11.3:1 | AAA |
| accent-violet on bg-primary | 6.5:1 | AA |
| accent-cyan on bg-surface | 10.1:1 | AAA |
| text-inverse on accent-cyan | 8.6:1 | AAA |

---

## Typography

### Font Stack

```css
:root {
  --font-display: 'Syne', system-ui, sans-serif;
  --font-body:    'Geist', 'Inter', system-ui, sans-serif;
  --font-mono:    'JetBrains Mono', 'Fira Code', monospace;
}
```

**Why Syne?** It has optical weight — geometric but with a humanist skeleton that gives character at display sizes. It says "designed with intent" without shouting "look at my font." The variable weight axis (400–800) means one file covers every heading level.

**Why Geist?** Vercel's house font. Clean, tall x-height, excellent at small sizes on dark backgrounds. If unavailable, Inter is the fallback — same metrics, similar feel.

**Why JetBrains Mono?** It's the portfolio's data voice. Category tags, status badges, domain names, metrics — all monospace. JetBrains Mono's ligatures are disabled; we want the raw characters.

### Type Scale

| Level | Font | Size | Weight | Line Height | Letter Spacing | Use |
|-------|------|------|--------|-------------|----------------|-----|
| **Display** | Syne | 4rem / 64px | 800 | 1.0 | -0.03em | Hero headline only |
| **H1** | Syne | 2.5rem / 40px | 700 | 1.1 | -0.02em | Section titles (Portfolio, Process, About) |
| **H2** | Syne | 1.75rem / 28px | 600 | 1.2 | -0.01em | Subsection heads, card group labels |
| **H3** | Syne | 1.25rem / 20px | 600 | 1.3 | 0 | Card titles (product names) |
| **Body** | Geist | 1rem / 16px | 400 | 1.6 | 0 | Paragraphs, descriptions |
| **Body Small** | Geist | 0.875rem / 14px | 400 | 1.5 | 0 | Card descriptions, secondary content |
| **Label** | JetBrains Mono | 0.75rem / 12px | 500 | 1.4 | 0.05em | Category tags, status badges, domains |
| **Caption** | Geist | 0.75rem / 12px | 400 | 1.4 | 0.02em | Footer text, legal disclaimers |

### Font Loading

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

Geist is loaded from `@vercel/font` or self-hosted. It is not on Google Fonts.

---

## Spacing

### Tokens

```css
:root {
  --space-1:  0.25rem;   /*  4px */
  --space-2:  0.5rem;    /*  8px */
  --space-3:  0.75rem;   /* 12px */
  --space-4:  1rem;      /* 16px */
  --space-5:  1.5rem;    /* 24px */
  --space-6:  2rem;      /* 32px */
  --space-8:  3rem;      /* 48px */
  --space-10: 4rem;      /* 64px */
  --space-12: 6rem;      /* 96px */
  --space-16: 8rem;      /* 128px */
}
```

### Application

| Context | Token | Value | Rule |
|---------|-------|-------|------|
| Page max-width | — | 1280px | Centered, with `--space-5` horizontal padding |
| Section gap | `--space-12` | 96px | Between hero, portfolio, process, about, contact |
| Section internal padding | `--space-8` | 48px | Top/bottom within sections |
| Card grid gap | `--space-5` | 24px | Between portfolio cards |
| Card internal padding | `--space-5` | 24px | Content within cards |
| Component gap | `--space-3` | 12px | Between related elements (icon + label) |
| Element gap | `--space-2` | 8px | Between text lines, tight groupings |

### Grid

Portfolio section uses a responsive bento grid:

| Breakpoint | Columns | Card Span |
|------------|---------|-----------|
| < 640px | 1 | Full width |
| 640–1024px | 2 | 1 col each |
| > 1024px | 3 | 1 col each, category headers span full |

Hero, Process, About, Contact, and Footer are single-column, full-width within the page container.

---

## Components

### Portfolio Card

The primary interactive element on the page. Each card represents one product.

```
┌─────────────────────────────────────────────┐
│  ┌─────────────┐                             │
│  │ GAMING / AI │  ← category tag (mono, dim) │
│  └─────────────┘                             │
│                                              │
│  AI Fighter                    ← H3, Syne   │
│  aifighter.com                 ← mono, cyan  │
│                                              │
│  Mobile game with neural-net   ← body small  │
│  powered fighters                            │
│                                              │
│  → Explore ──────────────────  ← link, cyan  │
│                                              │
└─────────────────────────────────────────────┘
```

**Specs:**
- Background: `--bg-surface`
- Border: 1px solid `--border-subtle`
- Border radius: 8px
- Padding: `--space-5`
- Hover: border transitions to `--accent-cyan-dim`, subtle translate-y -2px
- Category tag: `--font-mono`, `--text-tertiary`, uppercase, `--space-1` bottom margin
- Product name: `--font-display`, `--text-primary`, H3 size
- Domain: `--font-mono`, `--accent-cyan`, 14px
- Description: `--font-body`, `--text-secondary`, body-small size
- Link: `--accent-cyan`, no underline, arrow prefix `→`

### Hero Section

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                                                         │
│       derobot.is                ← Display, Syne 800    │
│                                                         │
│       AI-native venture lab.    ← H2, Syne 600, cyan   │
│       The robot builds.                                 │
│       The market decides.       ← Body, Geist, dimmed  │
│                                                         │
│       [ Explore the portfolio ] ← Primary CTA button   │
│                                                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Specs:**
- Full viewport height on desktop, auto on mobile (min 80vh)
- Vertically centered content
- "derobot.is" in Display size, `--text-primary`
- Subtitle in H2 size, `--accent-cyan`
- Tagline in Body size, `--text-secondary`
- CTA button: see Button spec below
- No background image, no gradients, no particles. Just type and space.

### Button

Two variants only.

**Primary:**
- Background: `--accent-cyan`
- Text: `--text-inverse` (`#09090B`)
- Font: `--font-body`, 16px, weight 500
- Padding: `--space-3` vertical, `--space-5` horizontal
- Border-radius: 6px
- Hover: brightness(1.1), subtle scale(1.02)
- No box-shadow

**Ghost:**
- Background: transparent
- Text: `--accent-cyan`
- Border: 1px solid `--border-subtle`
- Same padding and radius as primary
- Hover: background `--accent-cyan-dim`, border `--accent-cyan`

### Process Section

Four horizontal steps connected by lines. On mobile, vertical.

```
┌──────┐     ┌──────┐     ┌──────┐     ┌──────┐
│      │ ──→ │      │ ──→ │      │ ──→ │      │
│CONCEPT│     │VALID.│     │ BUILD│     │SCALE │
│      │     │      │     │      │     │      │
└──────┘     └──────┘     └──────┘     └──────┘
 Domain       Landing      Full         Real
 + README     + Ads        product      users
              + KPIs                    + revenue
```

**Specs:**
- Each step: `--bg-surface` card, 1px border
- Step title: `--font-display`, H3, `--text-primary`
- Step details: `--font-body`, body-small, `--text-secondary`
- Connector lines: 2px solid `--border-subtle`, with `→` glyph in `--accent-cyan`
- On scroll into view: steps fade in sequentially (200ms stagger)

### Category Header

Used above groups in the portfolio grid.

```
GAMING ──────────────────────────────────
```

- Font: `--font-mono`, 12px, weight 500, uppercase
- Color: `--text-tertiary`
- Right side: 1px line `--border-subtle` extending to edge
- Margin bottom: `--space-4`

### Contact Section

Minimal. Form or mailto — TBD per README open questions.

- Section title: H1
- Subtitle: Body, `--text-secondary`
- If form: two inputs (name, message) + submit button (primary)
- Input: `--bg-surface` background, 1px `--border-subtle`, `--text-primary` value, `--text-tertiary` placeholder
- Input focus: border `--border-focus` (cyan), no glow/shadow

### Footer

```
┌─────────────────────────────────────────────────────────┐
│  derobot.is                    Product links (mono)     │
│  Based in the Netherlands.     ← caption, tertiary      │
│  Pending legal entity.                                  │
└─────────────────────────────────────────────────────────┘
```

- Top border: 1px solid `--border-subtle`
- Padding: `--space-8` vertical
- Two-column: brand left, links right (stack on mobile)
- All text: caption size, `--text-tertiary`
- Links: `--accent-violet` on hover

---

## Motion

| Element | Trigger | Effect | Duration | Easing |
|---------|---------|--------|----------|--------|
| Portfolio card | Hover | translate-y: -2px, border-color transition | 200ms | ease-out |
| Portfolio card | Hover | border → `--accent-cyan-dim` | 200ms | ease-out |
| Process steps | Scroll into view | opacity 0→1, translate-y 16px→0 | 400ms | ease-out |
| Process steps | Scroll into view | 200ms stagger between steps | — | — |
| Hero content | Page load | opacity 0→1 | 600ms | ease-out |
| Hero CTA | Page load | 300ms delay after hero text | 400ms | ease-out |
| Button (primary) | Hover | brightness(1.1), scale(1.02) | 150ms | ease-out |
| Links | Hover | color transition | 150ms | ease-out |

**Rules:**
- `prefers-reduced-motion: reduce` → disable all transforms, keep opacity transitions only
- No parallax. No scroll hijacking. No auto-playing anything.
- Motion communicates state changes, never decorates.

---

## Iconography

No icon library. The visual language is purely typographic.

- Navigation arrows: `→` (Unicode U+2192)
- Bullet points: `·` (middle dot)
- Process connectors: `→` or CSS-drawn lines
- If an icon is absolutely needed in future: Lucide (24px, 1.5px stroke, `--text-secondary`)

---

## Responsive Breakpoints

```css
/* Mobile-first */
--bp-sm:  640px;   /* 2-col grid, tighter spacing */
--bp-md:  768px;   /* Process section goes horizontal */
--bp-lg:  1024px;  /* 3-col portfolio grid */
--bp-xl:  1280px;  /* Max-width container reached */
```

| Element | Mobile (< 640px) | Tablet (640–1024px) | Desktop (> 1024px) |
|---------|------------------|---------------------|---------------------|
| Hero headline | 2.5rem | 3rem | 4rem |
| Portfolio grid | 1 col | 2 col | 3 col |
| Process steps | Vertical stack | Vertical stack | Horizontal row |
| Section gap | `--space-8` | `--space-10` | `--space-12` |
| Card padding | `--space-4` | `--space-5` | `--space-5` |
| Page padding-x | `--space-4` | `--space-5` | `--space-5` |

---

## Accessibility

### Color

- All text meets WCAG AA minimum (4.5:1 for body, 3:1 for large text)
- Primary and secondary text on both bg-primary and bg-surface exceed AA
- Accent colors are never the sole indicator of state — always paired with text labels
- Tertiary text (#71717A) is reserved for decorative labels only, never for actionable content

### Focus

- All interactive elements have a visible focus ring: 2px solid `--border-focus` with 2px offset
- Focus ring uses `--accent-cyan` — high contrast against both surface colors
- Tab order follows visual order: hero CTA → portfolio cards (by grid position) → contact form → footer links

### Motion

- All animations respect `prefers-reduced-motion`
- No auto-playing content, no infinite loops
- Scroll-triggered animations use IntersectionObserver, not scroll position

### Semantics

- Portfolio cards: `<article>` with heading, `<a>` wrapping the entire card for click target
- Process steps: `<ol>` (ordered list — the pipeline has a sequence)
- Category headers: `<h2>` level within the portfolio `<section>`
- Contact form: proper `<label>` + `<input>` associations, `aria-required` on mandatory fields

---

## Do's and Don'ts

### Do

- Let the type do the work. Syne at display size is the hero, not a graphic.
- Use cyan sparingly. It's the signal — if everything is cyan, nothing is.
- Keep cards identical in structure. The portfolio reads as a system, not a collection.
- Leave generous whitespace between sections. The page breathes.
- Write copy in the brand voice: direct, competent, slightly irreverent.

### Don't

- Don't add gradients, glows, or neon effects. The aesthetic is matte and precise.
- Don't use more than two accent colors (cyan + violet). Introducing a third breaks the palette.
- Don't round corners beyond 8px. This isn't a consumer app.
- Don't add decorative illustrations or stock imagery. The robot is a linguistic character, not a visual one.
- Don't make the process section look like a progress bar. Everything is at Concept — that's honest.
- Don't use the word "disrupt," "synergy," "leverage," or "ecosystem." The brand voice is direct.

---

## Implementation Notes

### CSS Architecture

Single CSS file with custom properties at `:root`. No CSS-in-JS, no utility framework required (though Tailwind is fine if mapped to these tokens). The token names above are the contract — implementation can be Tailwind config, vanilla CSS, or the styleguide-engine YAML cascade.

### Dark Mode Only

There is no light mode. derobot.is is always dark. The `<html>` element carries no `data-theme` toggle. This simplifies the token set — every color is defined once.

### Font Performance Budget

| Resource | Size (woff2) | Load |
|----------|-------------|------|
| Syne Variable | ~45KB | preload, display=swap |
| Geist Variable | ~35KB | preload, display=swap |
| JetBrains Mono (400, 500) | ~40KB | display=swap (not preloaded) |
| **Total** | **~120KB** | Acceptable for a landing page |

### Build-Time Data

Portfolio card content is parsed from `projects/*/README.md` at build time. The style guide defines the visual treatment — the data source is the repo itself. No CMS, no API, no manual card maintenance.

---

## References

- [Syne on Google Fonts](https://fonts.google.com/specimen/Syne)
- [Geist Font](https://vercel.com/font)
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
- [Lucide Icons](https://lucide.dev) (only if needed)
- [WCAG Contrast Checker](https://webaim.org/resources/contrastchecker/)
