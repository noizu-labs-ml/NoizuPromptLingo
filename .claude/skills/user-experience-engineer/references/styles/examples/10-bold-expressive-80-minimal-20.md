# Style Guide: Ipso The Lorem — The Rough Cut

> Bold rule-breaking grounded by minimal tech's structural discipline for an experimental portfolio.

**Style System:** Bold Expressive 80% + Minimal Tech 20%
**Source Specs:** [bold-expressive.md](../bold-expressive.md) + [minimal-tech.md](../minimal-tech.md)
**Scenario:** Portfolio site showcasing Ipso's most experimental client work

---

## Scenario

**"The Rough Cut"** is Ipso The Lorem's portfolio site for work that doesn't fit Client Gateway's buttoned-up case studies. These are the experimental projects: generative art installations, unconventional product prototypes, design system overhauls with bold visual directions. The clients gave Ipso permission to push boundaries, and the portfolio site should reflect that.

Unlike CTRL+Z (see [Example 05](05-bold-expressive-100.md)), which is a once-a-year award-submission spectacle, The Rough Cut is a permanent portfolio. It needs to be **navigable, linkable, and functional enough that a potential client can browse it casually** — not just an art piece to scroll through once.

This creates a tension: Bold Expressive's chaos vs. real-world usability. That's where the 20% Minimal Tech comes in.

**Mix rationale:** Bold Expressive provides the visual audacity (extreme type scale, dark palette, unconventional layout). Minimal Tech contributes **structural navigation**, **systematic spacing within project pages**, and **functional component styling** — the invisible scaffolding that makes bold design usable.

This is a **tension pairing** — the two styles have opposing philosophies (break rules vs. follow rules). It works by giving each style a clear domain: Expressive owns the visual layer, Minimal Tech owns the functional layer.

---

## Color Palette

```css
:root {
  /* 80% — Bold Expressive foundation */
  --bg-primary: #0A0A0A;
  --bg-surface: #141414;
  --bg-elevated: #1E1E1E;

  --text-primary: #F0F0F0;
  --text-secondary: #888888;
  --text-dim: #444444;

  /* Expressive accent — Acid Green */
  --accent: #B8FF00;
  --accent-rgb: 184, 255, 0;

  /* 20% — Minimal Tech systematic tokens */
  --border-default: #2A2A2A;
  --focus-ring: rgba(184, 255, 0, 0.3);

  /* Minimal Tech semantic colors (for functional elements only) */
  --success: #4ADE80;
  --error: #F87171;
  --info: #60A5FA;
}
```

```
┌─────────────────────────────────────────┐
│  THE ROUGH CUT PALETTE                  │
├─────────────────────────────────────────┤
│                                         │
│  ██████  #0A0A0A   Black void           │
│  ██████  #F0F0F0   Near-white text      │
│                                         │
│  ██████  #B8FF00   Acid Green           │
│                                         │
│  Single neon accent on black.           │
│  20% MT provides the border and         │
│  focus tokens that BE doesn't define.   │
│                                         │
└─────────────────────────────────────────┘
```

**Usage rules:**
- Dark mode only (Bold Expressive foundation)
- Acid green for: project numbers, active nav state, hover highlights
- **Minimal Tech contribution:** border tokens and focus ring definitions. Bold Expressive specs don't define systematic border/focus patterns — they're ad hoc. MT's `--border-default` and `--focus-ring` tokens bring consistency to interactive elements without softening the visual impact.

---

## Typography

**Font stack:**
```css
/* 80% — Bold Expressive */
--font-display: 'Monument Extended', 'Arial Black', sans-serif;
--font-body: 'Sohne', 'Inter', sans-serif;

/* 20% — Minimal Tech: functional text */
--font-mono: 'JetBrains Mono', Consolas, monospace;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| Hero | Display | 120px+ | 800 | 0.9 | Site title |
| Project Title | Display | 64px | 700 | 0.95 | Project names (index page) |
| Project Title (detail) | Display | 48px | 700 | 1.0 | Project page header |
| Section | Display | 36px | 700 | 1.05 | Section dividers |
| Body | Body | 17px | 400 | 1.65 | Project descriptions |
| Body Small | Body | 14px | 400 | 1.5 | Detail text |
| **Nav Label** | **Mono** | **13px** | **400** | **1.4** | **Navigation items** |
| **Metadata** | **Mono** | **12px** | **400** | **1.4** | **Dates, tags, counters** |
| Caption | Mono | 11px | 400 | 1.3 | Credits |

**Typography notes:**
- Display and body fonts from Bold Expressive (unchanged)
- **The 20% element:** Monospace for navigation labels and metadata. Bold Expressive typically uses display type for everything (including nav), creating an all-or-nothing hierarchy. MT's mono brings **legibility and system** to functional text. Navigation in JetBrains Mono reads as "interface" while headlines in Monument Extended read as "art" — the contrast is productive.

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Monument Extended | Pangram Pangram Foundry | Paid (commercial license) | [pangram.co](https://pangrampangram.com/products/monument-extended) |
| Sohne | Klim Type Foundry | Paid (commercial license) | [klim.co.nz](https://klim.co.nz/retail-fonts/soehne/) |
| JetBrains Mono | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) \| [GitHub](https://github.com/JetBrains/JetBrainsMono) |

*Adobe Fonts alternatives:*
- **Monument Extended →** [Acumin Pro Extra Condensed](https://fonts.adobe.com/fonts/acumin) (Adobe original, similar architectural presence in uppercase at extreme sizes). Free alternative: [Bebas Neue](https://fonts.google.com/specimen/Bebas+Neue).
- **Sohne →** [Neue Haas Grotesk](https://fonts.adobe.com/fonts/neue-haas-grotesk) (the typeface Helvetica derives from — same precision and clarity). Free alternative: [Inter](https://fonts.google.com/specimen/Inter).

---

## Spacing & Layout

### Bold Expressive (80%): Visual Sections

Project index page and project hero sections use Bold Expressive's compositional spacing — no grid, asymmetric, full-bleed imagery, intentional overlap.

```css
.project-hero {
  height: 80vh;
  display: grid;
  grid-template-columns: 1fr 1fr;
  position: relative;
  overflow: hidden;
}
/* Overlap: title bleeds into the image area */
.project-hero__title {
  position: relative;
  z-index: 2;
  margin-right: -20%;
}
```

### Minimal Tech (20%): Content Sections

Once you scroll past the hero into a project's details (description, process, outcomes), **Minimal Tech's 8px grid takes over**:

```css
.project-content {
  max-width: 800px;
  margin: 0 auto;
  padding: 64px 32px;
}
.project-content > * + * {
  margin-top: 24px;  /* MT systematic spacing */
}
.project-content > h2 + * {
  margin-top: 16px;
}
.project-content > * + h2 {
  margin-top: 48px;
}
```

**The split:** Visual sections (heroes, index, transitions) follow Bold Expressive's compositional approach. Content sections (text, specs, credits) follow Minimal Tech's grid. The transition between these two modes IS the design — controlled tension.

---

## Component Styling

### Navigation (20% Minimal Tech Influence)

```css
/* MT-influenced structured navigation (replacing BE's scattered/hidden nav) */
.nav {
  position: fixed;
  top: 0;
  left: 0;
  width: 240px;
  height: 100vh;
  padding: 32px 24px;
  background: var(--bg-primary);
  border-right: 1px solid var(--border-default); /* MT: systematic border */
  z-index: 50;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.nav__item {
  font-family: var(--font-mono);   /* MT: mono for nav labels */
  font-size: 13px;
  color: var(--text-dim);
  padding: 8px 12px;
  border-radius: 4px;              /* MT: small, consistent radius */
  transition: color 150ms ease, background 150ms ease;  /* MT: 150ms timing */
}
.nav__item:hover {
  color: var(--text-secondary);
  background: var(--bg-elevated);
}
.nav__item--active {
  color: var(--accent);
  background: rgba(var(--accent-rgb), 0.08);
}
.nav__counter {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--text-dim);
  margin-right: 8px;
}
```

### Project Cards (Index Page) — Bold Expressive

```css
.project-card {
  position: relative;
  overflow: hidden;
  cursor: pointer;
}
.project-card__media {
  width: 100%;
  height: 60vh;
  object-fit: cover;
  transition: transform 600ms cubic-bezier(0.16, 1, 0.3, 1);
}
.project-card:hover .project-card__media {
  transform: scale(1.05);
}
.project-card__title {
  font-family: var(--font-display);
  font-size: 64px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: -0.03em;
  position: absolute;
  bottom: 32px;
  left: 32px;
  color: var(--text-primary);
  text-shadow: 0 2px 20px rgba(0, 0, 0, 0.5);
}
```

### Buttons (Blended)

```css
/* BE shape + MT interactivity */
.btn-primary {
  background: transparent;
  color: var(--text-primary);
  padding: 12px 24px;
  border: 1px solid var(--text-primary);     /* BE: outline style */
  font-family: var(--font-mono);             /* MT: mono for button labels */
  font-size: 13px;
  font-weight: 400;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  transition: all 150ms ease;                /* MT: 150ms timing */
}
.btn-primary:hover {
  background: var(--accent);
  color: var(--bg-primary);
  border-color: var(--accent);
}
.btn-primary:focus-visible {
  outline: 2px solid var(--accent);          /* MT: systematic focus ring */
  outline-offset: 2px;
}
```

### Contact Form (20% Minimal Tech)

```css
/* When bold sites need functional forms, MT provides the patterns */
.input {
  background: var(--bg-surface);
  color: var(--text-primary);
  font-family: var(--font-mono);
  font-size: 14px;
  padding: 12px 16px;
  border: 1px solid var(--border-default);
  border-radius: 4px;
  transition: border-color 150ms ease;
}
.input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--focus-ring);
  outline: none;
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing | Source |
|---------|--------|----------|--------|--------|
| Project image hover | Slow scale (1.05) | 600ms | cubic-bezier(0.16, 1, 0.3, 1) | BE |
| Hero text | Parallax offset on scroll | Continuous | linear | BE |
| Page transition | Clip-path reveal | 800ms | ease-in-out | BE |
| Nav item hover | Color + bg fade | 150ms | ease | MT |
| Button hover | Fill transition | 150ms | ease | MT |
| Input focus | Border + shadow | 150ms | ease | MT |
| Form submit | Subtle success indicator | 300ms | ease-out | MT |

**Motion split:** Visual/showcase animations follow Bold Expressive (slow, dramatic, scroll-linked). Functional interactions follow Minimal Tech (fast, subtle, 150ms). Users experience spectacle when browsing, efficiency when interacting.

---

## Asset Guidelines

**Photography/Video:** Client work imagery is the star (same as CTRL+Z). Full-bleed, high-res, cinematic. Video for motion projects. Project imagery provides all color.

**Iconography:** None in visual sections. Minimal Tech Lucide icons (16px, 1.5px stroke) in the navigation sidebar and contact form only.

**Illustration:** None.

**Logo:** "THE ROUGH CUT" in Monument Extended, uppercase, tracked. Acid green on black. Smaller than CTRL+Z's treatment — this is a permanent site, not a one-time event.

---

## Mixing Notes

### Elements Carrying the 20% Minimal Tech Accent (5 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Navigation** | BE's hidden/scattered nav → MT's sidebar with mono labels, borders, 4px radius, 150ms transitions | A permanent portfolio needs findable navigation. CTRL+Z (Example 05) could hide nav because it was a scroll-through experience. The Rough Cut has 15+ projects — users need to jump between them. MT's sidebar pattern solves this without feeling generic because the mono type + acid green active state preserves the bold aesthetic. |
| **Content section spacing** | BE's compositional (irregular) spacing → MT's 8px grid with systematic margins | Project description text needs to be readable. Bold layout works for heroes and transitions, but once users are reading about process and outcomes, predictable spacing aids comprehension. The switch from chaotic to systematic mid-page creates a rhythm: spectacle → information → spectacle. |
| **Button interactivity** | BE's invert-on-hover → MT's 150ms border/fill transition with focus ring | Buttons in Bold Expressive often lack proper focus states and accessible transitions. MT's systematic approach ensures keyboard navigability and instant feedback. The BE outline-to-fill aesthetic is preserved; MT contributes the timing and focus ring. |
| **Form styling** | (BE doesn't define forms) → MT input patterns with mono type | Bold Expressive specs don't include form patterns because showcase sites rarely have forms. The Rough Cut needs a contact form. Importing MT's input styling wholesale avoids inventing form patterns that might clash. |
| **Metadata typography** | Display type for everything → Mono for dates, tags, counters | Bold Expressive uses display type even for small text, which at 12px becomes illegible. MT's monospace provides a functional small-text system that reads clearly and creates visual hierarchy (display = art, mono = data). |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| MT's color palette (replacing neon with indigo) | Would neuter the Bold Expressive identity entirely. Acid green IS the visual personality. Replacing it with corporate indigo would make this a dark-mode dashboard, not a portfolio. |
| MT's type scale (replacing extreme sizes with MT's conservative scale) | Bold Expressive's extreme scale contrast (120px next to 12px) is a core design feature. Flattening it to MT's functional scale would remove the visual interest entirely. |
| Grid-based project index | BE's full-bleed stacked projects create drama. A neat card grid would make it look like every other portfolio site. The index should feel curated and intentional, not like a Dribbble gallery. |
| MT dark mode palette exactly (replacing #0A0A0A with #0B0B0F) | The difference is negligible. Kept BE's pure #0A0A0A because it's marginally more dramatic (true-er black). Not a meaningful distinction, but held for principle: the 80% style's foundation values take precedence. |
| Dual-mode (dark + light) | Bold Expressive demands dark mode for dramatic contrast. Adding a light mode would require redesigning every visual element and would produce a different site entirely. |

---

## Implementation Checklist

- [ ] Monument Extended (display) + Sohne (body) + JetBrains Mono (nav/meta)
- [ ] Sidebar navigation with mono labels, borders, 4px radius (MT influence)
- [ ] Nav items use 150ms transitions (MT timing)
- [ ] All interactive elements have visible focus rings (MT)
- [ ] Project hero sections use BE layout (full-bleed, overlap, asymmetry)
- [ ] Project content sections switch to MT spacing (8px grid, systematic margins)
- [ ] Buttons: outline style (BE) with 150ms fill transition and focus ring (MT)
- [ ] Contact form uses MT input patterns with mono typography
- [ ] Acid green accent — single color, no secondary
- [ ] Dark mode only
- [ ] `prefers-reduced-motion`: disables parallax, page transitions, image scale effects
- [ ] Screen reader: semantic nav, alt text on all project images, skip-to-content link
- [ ] Contrast: #F0F0F0 on #0A0A0A = 18.1:1 (exceeds AAA); acid green on black = 14.8:1

---

*Derived from: [bold-expressive.md](../bold-expressive.md) + [minimal-tech.md](../minimal-tech.md)*
*Example #10 of 10 — See [README.md](README.md) for full series*
