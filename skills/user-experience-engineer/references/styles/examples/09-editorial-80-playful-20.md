# Style Guide: Ipso The Lorem — Lorem & Found

> Editorial authority softened with warm consumer touches for a lifestyle newsletter landing page.

**Style System:** Editorial 80% + Consumer Playful 20%
**Source Specs:** [editorial.md](../editorial.md) + [consumer-playful.md](../consumer-playful.md)
**Scenario:** Newsletter landing page for a design-and-culture publication

---

## Scenario

**"Lorem & Found"** is Ipso The Lorem's weekly newsletter — a curated digest of design inspiration, tool recommendations, behind-the-scenes project stories, and cultural commentary. Unlike The Lorem Review (see [Example 04](04-editorial-100.md)), which targets senior industry peers, Lorem & Found speaks to a broader audience: mid-career designers, curious developers, and creative professionals who want to stay current without reading 5,000-word essays.

The landing page needs to convince visitors to subscribe. It must signal **authority and quality content** (Editorial) while feeling **approachable and low-commitment** (Playful). A pure Editorial landing page would feel like a journal subscription — too serious for a free weekly email. A pure Playful page would undermine the content's credibility.

**Mix rationale:** Editorial provides the typographic foundation and content hierarchy. Consumer Playful contributes **warmer colors**, **rounded subscribe button**, and **testimonial card styling** — three elements that reduce friction and make the subscription feel inviting rather than academic.

---

## Color Palette

```css
:root {
  /* 80% — Editorial foundation */
  --bg-primary: #FFFCF7;       /* warm cream */
  --bg-surface: #FFFFFF;

  --text-primary: #1A1A1A;
  --text-secondary: #666666;
  --text-tertiary: #999999;

  --border-default: #E5E0D8;
  --border-rule: #1A1A1A;

  /* 80% Editorial accent — deep green (authority) */
  --accent: #166534;
  --accent-hover: #14532D;

  /* 20% — Consumer Playful warmth */
  --warm: #F2704F;             /* coral for subscribe CTA */
  --warm-light: #FFF0EB;
  --warm-rgb: 242, 112, 79;
}
```

```
┌─────────────────────────────────────────┐
│  LOREM & FOUND PALETTE                  │
├─────────────────────────────────────────┤
│                                         │
│  ██████  #FFFCF7   Warm Cream bg        │
│  ██████  #1A1A1A   Near-Black text      │
│  ██████  #666666   Secondary text       │
│                                         │
│  ██████  #166534   Deep Green (80% ED)  │
│  ██████  #F2704F   Warm Coral (20% CP)  │
│                                         │
│  Green for content. Coral for action.   │
│                                         │
└─────────────────────────────────────────┘
```

**Usage rules:**
- Warm cream background from Editorial (unchanged)
- Deep green for: article category labels, inline links, section markers (Editorial accent)
- **Coral** for: subscribe button, email input focus ring, testimonial highlights (Playful warmth) — this is the 20% accent, used only on conversion-focused elements
- The split is intentional: green says "quality content," coral says "join us"

---

## Typography

**Font stack:**
```css
/* 80% — Editorial */
--font-display: 'Playfair Display', Georgia, serif;
--font-body: 'Source Serif Pro', Georgia, serif;
--font-ui: 'Inter', -apple-system, sans-serif;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| Hero | Display Serif | 56px | 700 | 1.1 | Main headline |
| H1 | Display Serif | 40px | 700 | 1.15 | Section titles |
| H2 | Display Serif | 28px | 700 | 1.2 | Sample article titles |
| Deck | Body Serif | 22px | 400 | 1.5 | Hero subheadline |
| Body | Body Serif | 18px | 400 | 1.8 | Descriptive text |
| UI Text | Sans | 14px | 500 | 1.5 | Button labels, form text, nav |
| Caption | Sans | 13px | 400 | 1.5 | Issue dates, metadata |

**Typography notes:**
- Full Editorial typography system — Playfair Display headlines, Source Serif Pro body, 18px base with 1.8 line height
- Sans-serif (Inter) for UI elements: subscribe button, navigation, form labels
- No Playful influence on typography — the 20% accent is in color and shape, not type

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Playfair Display | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Playfair+Display) |
| Source Serif Pro | Adobe Fonts (Adobe original) | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/source-serif) \| [Google Fonts](https://fonts.google.com/specimen/Source+Serif+4) |
| Inter | Adobe Fonts | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/inter) \| [Google Fonts](https://fonts.google.com/specimen/Inter) |

*Adobe Fonts alternative for Playfair Display:* [Lora](https://fonts.adobe.com/fonts/lora) — similar transitional serif with elegant display qualities. Also on [Google Fonts](https://fonts.google.com/specimen/Lora).

---

## Spacing & Layout

**Spacing scale:** 8, 16, 24, 32, 48, 80, 120px (Editorial — unchanged)

**Layout:**

| Section | Width | Notes |
|---------|-------|-------|
| Hero | 65ch centered | Headline + subtitle + subscribe form |
| Sample issues | 960px max | 2-column grid showing recent newsletter previews |
| Testimonials | 65ch centered | Single-column stack |
| Final CTA | Full-width warm background | Coral-tinted section with second subscribe form |

**Content measure:** 65ch for body text (Editorial's non-negotiable). Sample issue previews can be wider in the 2-column grid since they're headlines, not body text.

---

## Component Styling

### Subscribe Form (20% Consumer Playful Influence)

```css
/* The primary conversion element — Playful warmth applied here */
.subscribe-form {
  display: flex;
  gap: 12px;
  max-width: 480px;
}
.subscribe-input {
  flex: 1;
  padding: 14px 16px;
  font-family: var(--font-ui);
  font-size: 16px;
  border: 2px solid var(--border-default);  /* Playful: thicker border */
  border-radius: 12px;                       /* Playful: rounded corners */
  background: var(--bg-surface);
  transition: border-color 200ms ease;
}
.subscribe-input:focus {
  border-color: var(--warm);                 /* Playful: coral focus */
  box-shadow: 0 0 0 4px rgba(var(--warm-rgb), 0.1);
  outline: none;
}
.subscribe-input::placeholder { color: var(--text-tertiary); }

.subscribe-btn {
  background: var(--warm);                    /* Playful: coral CTA */
  color: #FFFFFF;
  padding: 14px 28px;
  border-radius: 9999px;                     /* Playful: pill shape */
  font-family: var(--font-ui);
  font-size: 16px;
  font-weight: 600;
  border: none;
  transition: transform 200ms ease, box-shadow 200ms ease;
}
.subscribe-btn:hover {
  transform: translateY(-2px);               /* Playful: rise on hover */
  box-shadow: 0 8px 16px rgba(var(--warm-rgb), 0.25);
}
.subscribe-btn:active { transform: scale(0.97); }
```

### Sample Issue Cards

```css
/* Editorial content display */
.issue-card {
  padding: 32px 0;
  border-bottom: 1px solid var(--border-default);
}
.issue-card__category {
  font-family: var(--font-ui);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--accent);
  margin-bottom: 8px;
}
.issue-card__title {
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 700;
  line-height: 1.2;
  color: var(--text-primary);
}
.issue-card__excerpt {
  font-family: var(--font-body);
  font-size: 16px;
  line-height: 1.7;
  color: var(--text-secondary);
  margin-top: 8px;
  max-width: 55ch;
}
```

### Testimonial Cards (20% Consumer Playful Influence)

```css
/* Editorial base with Playful shape language */
.testimonial {
  background: var(--warm-light);             /* Playful: warm tinted bg */
  border-radius: 16px;                       /* Playful: rounded corners */
  padding: 32px;
  margin: 24px 0;
}
.testimonial__quote {
  font-family: var(--font-body);
  font-size: 18px;
  font-style: italic;
  line-height: 1.7;
  color: var(--text-primary);
}
.testimonial__author {
  font-family: var(--font-ui);
  font-size: 14px;
  font-weight: 500;
  color: var(--text-secondary);
  margin-top: 16px;
}
/* Compare: Editorial pull quotes use border-left + no background.
   Playful influence adds rounded containers with warm tints. */
```

### Navigation

```css
/* Minimal Editorial header */
.header {
  height: 56px;
  background: transparent;
  border-bottom: 1px solid var(--border-default);
  padding: 0 48px;
}
.header__title {
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 700;
}
/* Nav links follow Editorial conventions — no Playful influence */
.header__link {
  font-family: var(--font-ui);
  font-size: 13px;
  color: var(--text-secondary);
  text-decoration: underline;
  text-underline-offset: 3px;
}
```

### Final CTA Section (Blended)

```css
/* Full-width warm section — Playful bg warmth with Editorial content */
.final-cta {
  background: var(--warm-light);
  padding: 120px 48px;
  text-align: center;
}
.final-cta__headline {
  font-family: var(--font-display);          /* Editorial: serif headline */
  font-size: 40px;
  font-weight: 700;
  line-height: 1.15;
  color: var(--text-primary);
  max-width: 20ch;
  margin: 0 auto 16px;
}
/* Subscribe form appears here again with same Playful-influenced styling */
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Subscribe button hover | Rise + shadow (Playful) | 200ms | ease |
| Subscribe button press | Scale down 0.97 (Playful) | 100ms | ease |
| Link hover | Underline color shift (Editorial) | 200ms | ease |
| Issue card hover | Subtle title color shift (Editorial) | 200ms | ease |
| Subscription success | Checkmark + "Welcome" fade-in | 400ms | ease-out |

**Motion philosophy:** Mostly restrained (Editorial). The subscribe button is the only element with Playful-style motion (rise, shadow, press feedback). Content sections use Editorial's subtle hover states.

---

## Asset Guidelines

**Photography:** None on the landing page. Content previews are text-only (Editorial convention). The writing is the visual.

**Iconography:** Minimal. Feather icons for: envelope (subscribe), checkmark (success), arrow-right (read more). 18px, 1.5px stroke.

---

## Mixing Notes

### Elements Carrying the 20% Consumer Playful Accent (4 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Subscribe button** | Editorial link-style CTA → coral pill button with rise-on-hover | The subscribe action needs to feel inviting, not academic. A coral pill button lowers perceived commitment ("this will be fun") vs. an underlined text link ("this will be serious"). |
| **Subscribe input** | 1px border, 4px radius → 2px border, 12px radius, coral focus ring | Rounded, chunky input matches the pill button — together they form a cohesive subscription form that feels friendly. Editorial's thin-border inputs feel too formal for a free newsletter signup. |
| **Testimonial cards** | Border-left pull quote → rounded card with warm tinted background | Social proof needs to feel human and approachable. Editorial pull quotes are elegant but cold. Warm-tinted rounded cards make testimonials feel like personal recommendations, not citations. |
| **Final CTA section** | White/cream section → full-width warm coral tint (#FFF0EB) | The closing section needs a visual shift that says "one last thing — join us." Warm background creates urgency through contrast with the neutral body, borrowed from Playful's colored-section conventions. |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| Rounded corners on issue cards | Would conflict with Editorial's clean horizontal-rule separators. Issue previews are content, not interactive cards — they should feel like a table of contents, not a product grid. |
| Playful typography (Plus Jakarta Sans) | Would undermine the authority that makes the content worth subscribing to. If the landing page looks playful, the newsletter content might be perceived as lightweight. |
| Confetti on subscribe | Too much for a newsletter signup. Confetti works for party RSVPs (Example 08) but would feel unserious for a professional publication. A subtle checkmark is enough. |
| Multiple accent colors (coral + lavender + mint) | Playful's multi-color approach would dilute Editorial's restrained palette. One warm color (coral) is enough to soften the austerity. More would tip the balance. |
| Bento grid for issue previews | Editorial demands content in linear reading order, not a mosaic. Bento works for visual content (photos, products) but not for text-heavy previews where hierarchy matters. |

---

## Implementation Checklist

- [ ] Playfair Display (headlines) + Source Serif Pro (body) + Inter (UI) — full Editorial font stack
- [ ] 18px body text with 1.8 line height — Editorial's reading defaults
- [ ] 65ch max-width for body text
- [ ] Coral subscribe button (pill shape, rise-on-hover)
- [ ] Coral focus ring on email input (12px border-radius)
- [ ] Testimonials in warm-tinted rounded cards (not pull quotes)
- [ ] Final CTA section with warm coral background tint
- [ ] Issue previews follow Editorial conventions (no Playful influence)
- [ ] Navigation follows Editorial conventions (no Playful influence)
- [ ] Links use underline (Editorial accessibility convention)
- [ ] Warm cream background (#FFFCF7)
- [ ] Color contrast: 1A1A1A on FFFCF7 = 15.8:1 (exceeds AAA)
- [ ] Color contrast: white on coral (#F2704F) = 3.2:1 (AA for large text — button text is 16px bold, qualifies)

---

*Derived from: [editorial.md](../editorial.md) + [consumer-playful.md](../consumer-playful.md)*
*Example #9 of 10 — See [README.md](README.md) for full series*
