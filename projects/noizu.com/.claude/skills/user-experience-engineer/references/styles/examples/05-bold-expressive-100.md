# Style Guide: Ipso The Lorem — CTRL+Z

> Rule-breaking showcase microsite that demonstrates creative capability through the interface itself.

**Style System:** Bold Expressive 100%
**Source Spec:** [bold-expressive.md](../bold-expressive.md)
**Scenario:** Annual creative showcase and award submission microsite

---

## Scenario

Once a year, Ipso The Lorem publishes **CTRL+Z** — a microsite showcasing their most experimental client work. It's named for the "undo" shortcut because the featured projects are the ones where the team threw out conventional approaches and started over. The site itself is submitted for design awards (Awwwards, FWA, CSS Design Awards).

The audience is the creative industry: other agencies, design directors, potential high-end clients who value boldness, and award juries. This is Ipso's permission slip to break every rule — the site IS the portfolio piece.

Bold Expressive is the only viable choice. The interface must be as daring as the work it showcases. Extreme type scale, unexpected layouts, cursor interactions, scroll-triggered reveals, and a deliberate rejection of safe design patterns.

**Caveat:** Every rule broken here is intentional and documented. Bold Expressive without discipline is chaos. With discipline, it's art.

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #0A0A0A;
  --bg-surface: #141414;

  /* Text */
  --text-primary: #F5F5F5;
  --text-secondary: #888888;
  --text-dim: #444444;

  /* Accent — Electric Cyan (attention, future) */
  --accent: #00FFEE;
  --accent-rgb: 0, 255, 238;

  /* Secondary — Signal Magenta (energy, disruption) */
  --secondary: #FF00AA;
  --secondary-rgb: 255, 0, 170;

  /* No semantic colors — this site doesn't have forms, errors, or success states */
}
```

```
┌─────────────────────────────────────────┐
│  CTRL+Z PALETTE                         │
├─────────────────────────────────────────┤
│                                         │
│  ██████  #0A0A0A   Black void           │
│  ██████  #F5F5F5   Near-white text      │
│                                         │
│  ██████  #00FFEE   Electric Cyan        │
│  ██████  #FF00AA   Signal Magenta       │
│                                         │
│  Two neon accents on black.             │
│  Nothing else. The work provides        │
│  all the color this site needs.         │
│                                         │
└─────────────────────────────────────────┘
```

**Usage rules:**
- Dark mode only (dramatic, gallery-like)
- Cyan for: navigation active states, project numbers, cursor effect
- Magenta for: hover states, featured project highlight, footer CTA
- Never use both neon colors adjacent to each other — one per visual zone
- Client work imagery provides all color variety; the shell stays monochrome + neon
- Gradients allowed: cyan-to-magenta for one hero moment per page (max one)

---

## Typography

**Font stack:**
```css
--font-display: 'Monument Extended', 'Arial Black', sans-serif;
--font-body: 'Sohne', 'Inter', -apple-system, sans-serif;
--font-mono: 'JetBrains Mono', Consolas, monospace;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| Hero | Display | 160px+ | 800 | 0.9 | Site title, one per page |
| Project Title | Display | 80px | 700 | 0.95 | Project names |
| Section | Display | 48px | 700 | 1.0 | Section dividers |
| Body Large | Body | 22px | 400 | 1.6 | Project descriptions |
| Body | Body | 16px | 400 | 1.6 | Detail text |
| Caption | Mono | 12px | 400 | 1.4 | Credits, metadata, counters |
| Counter | Mono | 14px | 400 | 1.0 | Project numbers (e.g., "01/") |

**Typography treatments:**
- **Extreme scale contrast:** 160px display next to 12px caption — the contrast IS the design
- **Negative letter-spacing** on display type: `-0.04em` for tight, impactful headlines
- **Uppercase display type** — Monument Extended in caps creates architectural presence
- **Vertical text** for section labels: `writing-mode: vertical-rl` (sidebar markers)
- **Text clipping:** project hero images masked by display text (CSS `background-clip: text`)

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Monument Extended | Pangram Pangram Foundry | Paid (commercial license) | [pangram.co](https://pangrampangram.com/products/monument-extended) |
| Sohne | Klim Type Foundry | Paid (commercial license) | [klim.co.nz](https://klim.co.nz/retail-fonts/soehne/) |
| JetBrains Mono | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) \| [GitHub](https://github.com/JetBrains/JetBrainsMono) |

*Adobe Fonts alternatives:*
- **Monument Extended →** [Acumin Pro Extra Condensed](https://fonts.adobe.com/fonts/acumin) (Adobe original, extended/condensed widths available, similar architectural presence in uppercase). Also consider [Bebas Neue](https://fonts.adobe.com/fonts/bebas-neue) ([Google Fonts](https://fonts.google.com/specimen/Bebas+Neue)) for a free all-caps display option.
- **Sohne →** [Neue Haas Grotesk](https://fonts.adobe.com/fonts/neue-haas-grotesk) (the typeface Helvetica was based on — same Klim-influenced clarity). Or use [Inter](https://fonts.adobe.com/fonts/inter) as a free drop-in that preserves the geometric precision.

---

## Spacing & Layout

**Spacing:** Irregular. Unlike all other styles, Bold Expressive does NOT use a rigid spacing scale. Spacing is compositional — determined by visual balance, not mathematical consistency.

**Layout principles:**
- **No grid** — elements are positioned for visual impact, not alignment
- **Full-bleed sections** — projects span the entire viewport
- **Intentional overlap** — text overlaps images; images bleed off-screen
- **Asymmetry** — nothing is centered unless the centering itself is dramatic
- **Extreme negative space** — 40-50% of the viewport can be empty (the void is the design)

**Scroll behavior:** Scroll-snap sections. Each project occupies a full viewport height. Horizontal scroll for project detail galleries.

```css
.showcase {
  scroll-snap-type: y mandatory;
  overflow-y: scroll;
  height: 100vh;
}
.project-section {
  scroll-snap-align: start;
  height: 100vh;
  position: relative;
  overflow: hidden;
}
```

---

## Component Styling

### Navigation

```css
/* Numbered, minimal, fixed right edge */
.nav {
  position: fixed;
  right: 32px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 50;
  display: flex;
  flex-direction: column;
  gap: 24px;
}
.nav__item {
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-dim);
  writing-mode: vertical-rl;
  transition: color 300ms ease;
}
.nav__item:hover { color: var(--accent); }
.nav__item--active { color: var(--accent); }

/* Top bar: just the logo and a menu trigger */
.topbar {
  position: fixed;
  top: 0;
  width: 100%;
  padding: 24px 32px;
  display: flex;
  justify-content: space-between;
  z-index: 50;
  mix-blend-mode: difference; /* ensures visibility over any background */
}
```

### Project Cards (Full-Viewport Sections)

```css
.project {
  height: 100vh;
  display: grid;
  grid-template-columns: 1fr 1fr;
  position: relative;
}
.project__media {
  overflow: hidden;
}
.project__media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 600ms cubic-bezier(0.16, 1, 0.3, 1);
}
.project:hover .project__media img {
  transform: scale(1.05);
}
.project__info {
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 64px;
}
.project__number {
  font-family: var(--font-mono);
  font-size: 14px;
  color: var(--accent);
  margin-bottom: 24px;
}
.project__title {
  font-family: var(--font-display);
  font-size: 80px;
  font-weight: 700;
  letter-spacing: -0.04em;
  text-transform: uppercase;
  line-height: 0.95;
  color: var(--text-primary);
}
```

### Cursor

```css
/* Custom cursor — circle that follows mouse with lag */
.cursor {
  position: fixed;
  width: 24px;
  height: 24px;
  border: 1px solid var(--accent);
  border-radius: 50%;
  pointer-events: none;
  z-index: 999;
  transition: transform 100ms ease-out, width 300ms ease, height 300ms ease;
  mix-blend-mode: difference;
}
.cursor--hover {
  width: 64px;
  height: 64px;
  background: rgba(var(--accent-rgb), 0.1);
}
/* Hide default cursor */
* { cursor: none; }
/* Restore for interactive elements on touch devices */
@media (hover: none) { * { cursor: auto; } .cursor { display: none; } }
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Project image | Slow scale on hover | 600ms | cubic-bezier(0.16, 1, 0.3, 1) |
| Project title | Staggered letter reveal on scroll | 800ms | ease-out |
| Section transition | Scroll-snap | 300ms | browser default |
| Cursor | Follow with lag | 100ms | ease-out |
| Cursor on hover | Scale up + fill | 300ms | ease |
| Hero text | Parallax offset | Continuous | linear |
| Gallery | Horizontal drag-to-scroll | Physics-based | momentum |
| Page load | Black → reveal wipe | 1200ms | cubic-bezier(0.77, 0, 0.175, 1) |
| Navigation dots | Color transition | 300ms | ease |

**Motion philosophy:** Motion is part of the design, not an enhancement. The loading reveal, the cursor interaction, the scroll-triggered text reveals — these ARE the experience. More animation than any other style, but every piece is choreographed.

**Performance note:** Heavy animation budget. Ensure 60fps by using `transform` and `opacity` only for animated properties. Will-change on scroll-triggered elements. Test on mid-range devices.

---

## Asset Guidelines

**Photography/Video:** Project work imagery is the star. Full-bleed, high-resolution, cinematic crop. Video is acceptable and encouraged for motion-heavy projects. Autoplay (muted) on desktop; static poster on mobile.

**Iconography:** None. No icons anywhere. Text labels and custom cursor handle all interaction signifiers.

**Illustration:** None — the client work IS the visual content.

**Logo:** "CTRL+Z" in Monument Extended, all caps, tracked wide (+0.08em). White on black, or with accent glow (`text-shadow: 0 0 40px rgba(var(--accent-rgb), 0.5)`).

---

## Accessibility Accommodations

Bold Expressive requires explicit accessibility provisions that other styles build in by default:

- **Custom cursor:** Falls back to default cursor on touch devices and when `prefers-reduced-motion` is set
- **Scroll-snap:** Respects keyboard navigation (arrow keys, tab)
- **Text contrast:** Cyan on black = 16.7:1, magenta on black = 4.6:1 (AA for large text only — magenta is used exclusively on display-size type)
- **Reduced motion:** All scroll effects, parallax, loading reveals, and staggered animations collapse to instant display. The site works as a static gallery.
- **Screen reader:** All project images have descriptive `alt` text. Navigation is semantic `<nav>` with proper landmarks. Skip-to-content link exists (visually hidden).

---

## Implementation Checklist

- [ ] Monument Extended loaded (or fallback to Arial Black)
- [ ] Custom cursor with touch-device fallback
- [ ] Scroll-snap sections at 100vh
- [ ] mix-blend-mode: difference on fixed navigation elements
- [ ] Cyan and magenta never adjacent — one accent per visual zone
- [ ] 60fps maintained for all scroll animations (GPU-accelerated transforms only)
- [ ] `prefers-reduced-motion` disables: cursor effects, parallax, reveal animations, staggered text
- [ ] All images have alt text
- [ ] Skip-to-content link exists
- [ ] Video autoplay is muted, with poster fallback on mobile
- [ ] Performance: Lighthouse >= 75 (lower threshold for this style — heavy assets)
- [ ] Tested on Safari, Chrome, Firefox (mix-blend-mode and scroll-snap vary)
- [ ] Mobile layout collapses to single-column, swipe gallery

---

*Derived from: [bold-expressive.md](../bold-expressive.md)*
*Example #5 of 10 — See [README.md](README.md) for full series*
