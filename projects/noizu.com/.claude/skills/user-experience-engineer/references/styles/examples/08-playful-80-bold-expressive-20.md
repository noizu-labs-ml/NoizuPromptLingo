# Style Guide: Ipso The Lorem — The Annual

> Playful foundation with surprising expressive moments for an internal culture celebration.

**Style System:** Consumer Playful 80% + Bold Expressive 20%
**Source Specs:** [consumer-playful.md](../consumer-playful.md) + [bold-expressive.md](../bold-expressive.md)
**Scenario:** Internal culture site and annual holiday party invitation

---

## Scenario

Every December, Ipso The Lorem hosts **"The Annual"** — their holiday party and year-in-review celebration. The internal microsite serves as: party invitation with RSVP, year-in-review highlights, team superlative awards, and a photo gallery from the past year.

The audience is Ipso's own team — 45 people who already know the brand. They don't need trust signals or technical credibility. They need **fun, delight, and genuine surprise**. The site should feel like unwrapping a gift: warm and inviting on the surface, with unexpected moments that make people smile.

**Mix rationale:** Consumer Playful provides the warm, approachable base (rounded corners, vibrant colors, bouncy animations). Bold Expressive adds **moments of spectacle** — an oversized hero treatment, one cursor interaction, and a section transition that breaks the grid — injecting surprise without destabilizing the friendly foundation.

This is a **novel pairing** (not listed as compatible or risky in SKILL.md). It works here because both styles share a willingness to be fun — Playful through warmth, Expressive through audacity. The risk (chaos) is managed by limiting Expressive to 3 specific moments.

---

## Color Palette

```css
:root {
  /* 80% — Consumer Playful foundation */
  --bg-primary: #FFF7F0;
  --bg-surface: #FFFFFF;

  --text-primary: #2D2A26;
  --text-secondary: #6B6560;
  --text-tertiary: #A39E98;

  --border-default: #E8E2DB;

  /* Playful warm palette */
  --primary: #E85D3A;          /* Warm red-orange (festive) */
  --primary-dark: #CC4D2E;
  --primary-light: #FFF0EB;
  --primary-rgb: 232, 93, 58;

  --secondary: #2AAA6B;        /* Forest green (holiday) */
  --secondary-light: #E8F8F0;

  --tertiary: #D4A843;         /* Gold (celebration) */
  --tertiary-light: #FFF8E7;

  /* Semantic */
  --success: #22C55E;
  --error: #F87171;

  /* 20% — Bold Expressive neon moment */
  --neon: #FFE500;             /* Electric yellow — used for ONE hero element */
  --neon-rgb: 255, 229, 0;
}
```

**Usage rules:**
- Light warm background (Playful foundation) — this is a celebration, not a nightclub
- Red-orange + forest green + gold = holiday palette without being literally Christmas-themed
- **Neon yellow** appears ONLY in the hero section (Bold Expressive moment) — nowhere else on the site
- Three Playful colors can be used on cards, tags, backgrounds, buttons
- Neon yellow against the warm cream would burn eyes — it appears on a temporary dark panel only

---

## Typography

**Font stack:**
```css
/* 80% — Consumer Playful */
--font-heading: 'Plus Jakarta Sans', sans-serif;
--font-body: 'Plus Jakarta Sans', sans-serif;

/* 20% — Bold Expressive: hero display only */
--font-display: 'Clash Display', 'Arial Black', sans-serif;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| **Hero** | **Display** | **96px** | **700** | **0.95** | **"THE ANNUAL" title (one instance)** |
| H1 | Heading | 40px | 700 | 1.15 | Page section titles |
| H2 | Heading | 28px | 700 | 1.2 | Card headers |
| H3 | Heading | 20px | 600 | 1.25 | Subsections |
| Body | Body | 16px | 400 | 1.6 | Default text |
| Body Small | Body | 14px | 400 | 1.5 | Captions |
| Caption | Body | 12px | 500 | 1.4 | Metadata, photo credits |

**Typography notes:**
- **The 20% element:** Clash Display at 96px for the site's title — dramatically larger and more impactful than anything Playful would produce on its own. Used exactly once.
- Everything else is Plus Jakarta Sans (Consumer Playful). The display font's job is to create one "wow" moment, then step aside.

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Plus Jakarta Sans | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Plus+Jakarta+Sans) |
| Clash Display | Fontshare (Indian Type Foundry) | Free for personal + commercial | [Fontshare](https://www.fontshare.com/fonts/clash-display) |

*Adobe Fonts alternatives:*
- **Plus Jakarta Sans →** [DM Sans](https://fonts.adobe.com/fonts/dm-sans) — similarly rounded, warm personality
- **Clash Display →** [Bebas Neue](https://fonts.adobe.com/fonts/bebas-neue) ([Google Fonts](https://fonts.google.com/specimen/Bebas+Neue)) — free all-caps display with strong presence. Or [Acumin Pro Wide](https://fonts.adobe.com/fonts/acumin) for a wider display face with more weight options.

---

## Spacing & Layout

**Spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96px (Consumer Playful — unchanged)

**Grid:** Identical to [Example 03 (Join the Draft)](03-consumer-playful-100.md) — bento grid for photo gallery, standard column grid for content sections.

**Layout exception (20% Bold Expressive):** The hero section breaks the grid. "THE ANNUAL" text spans edge-to-edge with no margins, sitting on a dark panel (#1A1A1A) that interrupts the warm cream. This is the only section that doesn't follow the Playful grid — it's a Bold Expressive full-bleed moment.

---

## Component Styling

### Buttons

Identical to [Example 03 (Join the Draft)](03-consumer-playful-100.md) — pill-shaped, coral primary, translateY hover. Consumer Playful controls all button styling.

### Form Inputs (RSVP Form)

Identical to Example 03 — 2px borders, 12px radius, warm focus states.

### Cards — Award Cards

```css
/* Consumer Playful base */
.card--award {
  background: var(--bg-surface);
  border-radius: 16px;
  padding: 32px;
  text-align: center;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.06);
  transition: transform 300ms ease, box-shadow 300ms ease;
}
.card--award:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px -4px rgba(0, 0, 0, 0.1);
}

/* Tinted backgrounds for variety */
.card--award.red { background: var(--primary-light); }
.card--award.green { background: var(--secondary-light); }
.card--award.gold { background: var(--tertiary-light); }
```

### Hero Section (20% Bold Expressive Moment)

```css
.hero {
  background: #1A1A1A;
  min-height: 80vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  position: relative;
}
.hero__title {
  font-family: var(--font-display);
  font-size: clamp(48px, 12vw, 160px);
  font-weight: 700;
  color: var(--neon);
  text-transform: uppercase;
  letter-spacing: -0.03em;
  text-align: center;
  /* Neon glow effect */
  text-shadow:
    0 0 20px rgba(var(--neon-rgb), 0.4),
    0 0 60px rgba(var(--neon-rgb), 0.2);
}
.hero__subtitle {
  font-family: var(--font-body);
  font-size: 18px;
  color: #AAAAAA;
  margin-top: 16px;
  text-align: center;
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Button hover | Rise + shadow (Playful) | 200ms | ease |
| Card hover | Rise + shadow (Playful) | 300ms | ease |
| Card entrance | Staggered slide-up (Playful) | 400ms | spring |
| RSVP submit | Confetti burst (Playful) | 1200ms | spring |
| Photo gallery | Drag-to-scroll (Playful) | Physics | momentum |
| **Hero entrance** | **Title scales from 200% + fades in** | **1000ms** | **cubic-bezier(0.16, 1, 0.3, 1)** |
| **Hero scroll** | **Parallax offset + opacity fade** | **Continuous** | **linear** |
| **Section 3 transition** | **Grid items scatter-then-reform** | **800ms** | **spring** |

**Motion notes:**
- Most animations are Consumer Playful (bouncy, warm, celebratory)
- **Three Bold Expressive moments:** hero entrance (dramatic scale), hero parallax (scroll-linked), and one section transition where bento grid items scatter apart and reform into the next layout
- `prefers-reduced-motion` collapses all Bold Expressive animations to instant display; Playful animations reduce to subtle fades

---

## Asset Guidelines

**Photography:** Real team photos from the past year. Candid, warm, unposed. Displayed in a bento grid gallery with varied cell sizes. Photos can have a slight warm filter for cohesion.

**Iconography:** Rounded style (Playful). Custom emoji-style illustrations for team superlative awards (e.g., hand-drawn trophy, star, lightning bolt).

**Illustration:** Hand-drawn / flat vector (Playful). Holiday-themed but not literally Christmas — snowflakes, stars, streamers, party elements. Used in empty states and section dividers.

---

## Mixing Notes

### Elements Carrying the 20% Bold Expressive Accent (3 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Hero section** | Playful warm-cream bg → dark panel (#1A1A1A) with neon yellow text at 96-160px, text-shadow glow effect | The opening moment needs to feel like an event, not a webpage. The dark-panel-with-neon creates a "curtain rises" effect that Consumer Playful alone can't achieve. The contrast between dark hero and warm body creates narrative tension. |
| **Display typeface** | Plus Jakarta Sans → Clash Display for the title only | Clash Display's extended letterforms at large scale create architectural presence. Jakarta Sans, even at 96px, would feel friendly rather than spectacular. One display font for one moment. |
| **Section 3 transition** | Standard staggered fade → scatter-then-reform animation | A single surprise moment mid-scroll rewards visitors who keep exploring. The "scatter" effect is Bold Expressive's playfulness with physics — it feels like the cards are alive. Limited to one section so it stays delightful, not exhausting. |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| Custom cursor | Fun but impractical for a site with RSVP forms. Cursor effects conflict with form usability. |
| Neon color throughout | One neon moment is a surprise. Neon on every section is a rave. The team includes people of all ages and sensitivities. |
| Scroll-jacking | Would frustrate users trying to RSVP quickly. Bold Expressive scroll techniques work for portfolios, not for sites with functional goals. |
| Dark mode for entire site | The dark hero works as contrast. An entirely dark site would feel too intense for a holiday celebration — warm cream says "welcome." |
| More than 3 expressive moments | Three is the upper limit. More would shift the balance from "Playful with surprises" to "Expressive with warm spots" — inverting the intended ratio. |

---

## Implementation Checklist

- [ ] Clash Display loaded for hero only; Plus Jakarta Sans for everything else
- [ ] Dark hero panel with neon text-shadow glow
- [ ] Neon yellow (#FFE500) appears NOWHERE outside the hero section
- [ ] All other components follow Consumer Playful (pill buttons, rounded cards, warm palette)
- [ ] Bento grid gallery with team photos
- [ ] RSVP form functional and accessible (not obscured by animation)
- [ ] Confetti on RSVP submit
- [ ] Scatter-reform animation on section 3 only
- [ ] `prefers-reduced-motion`: hero appears instantly, scatter animation disabled, confetti disabled
- [ ] Touch targets >= 48px on mobile
- [ ] Hero text uses `clamp()` for responsive sizing
- [ ] Color contrast: neon yellow on #1A1A1A = 14.2:1 (exceeds AAA)

---

*Derived from: [consumer-playful.md](../consumer-playful.md) + [bold-expressive.md](../bold-expressive.md)*
*Example #8 of 10 — See [README.md](README.md) for full series*
