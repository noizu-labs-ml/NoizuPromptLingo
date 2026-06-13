# Style Guide: Ipso The Lorem — Join the Draft

> Warm, approachable interface for a talent recruitment site targeting junior designers.

**Style System:** Consumer Playful 100%
**Source Spec:** [consumer-playful.md](../consumer-playful.md)
**Scenario:** Talent recruitment site for new grads and career changers

---

## Scenario

Ipso The Lorem is hiring. Their recruitment site, **"Join the Draft"** (a play on "rough draft" → "we'll draft you onto the team"), targets junior designers and recent design school graduates. The audience is 22-28 year olds exploring their first agency role.

This audience expects **warmth, personality, and a sense of fun**. A corporate careers page would feel alienating. The site should signal: "We're a creative team that doesn't take ourselves too seriously, but we do take our work seriously." It should feel like an invitation, not an application portal.

Consumer Playful delivers: rounded corners, vibrant but warm colors, bento grid layout for showcasing team culture, micro-interactions that reward exploration, and a tone that's friendly without being juvenile.

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #FFFAF5;
  --bg-surface: #FFFFFF;
  --bg-elevated: #FFFFFF;

  /* Text */
  --text-primary: #2D2A26;
  --text-secondary: #6B6560;
  --text-tertiary: #A39E98;

  /* Borders */
  --border-default: #E8E2DB;

  /* Primary — Warm Coral (energy, approachability) */
  --primary: #F2704F;
  --primary-dark: #D95A3A;
  --primary-light: #FFF0EB;
  --primary-rgb: 242, 112, 79;

  /* Secondary — Soft Lavender (creativity) */
  --secondary: #A78BFA;
  --secondary-light: #F3EFFE;

  /* Accent — Mint (freshness, new beginnings) */
  --accent: #34D399;
  --accent-light: #ECFDF5;

  /* Semantic */
  --success: #22C55E;
  --warning: #FBBF24;
  --error: #F87171;
  --info: #60A5FA;
}
```

```
┌─────────────────────────────────────────┐
│  JOIN THE DRAFT PALETTE                 │
├─────────────────────────────────────────┤
│                                         │
│  ██████  #FFFAF5   Warm White bg        │
│  ██████  #2D2A26   Warm Black text      │
│                                         │
│  ██████  #F2704F   Coral (Primary)      │
│  ██████  #A78BFA   Lavender (Secondary) │
│  ██████  #34D399   Mint (Accent)        │
│                                         │
└─────────────────────────────────────────┘
```

**Usage rules:**
- Light mode only (warm, inviting — dark mode would undermine the approachability signal)
- Three-color system: coral leads, lavender and mint support
- Coral for primary CTAs and active states
- Lavender for secondary elements (tags, category labels, background tints on culture cards)
- Mint for success states and "you're on the right track" encouragement moments
- Background has a warm off-white tint (`#FFFAF5`) — pure white would feel clinical

---

## Typography

**Font stack:**
```css
--font-heading: 'Plus Jakarta Sans', -apple-system, sans-serif;
--font-body: 'Plus Jakarta Sans', -apple-system, sans-serif;
```

| Level | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| Display | 56px | 800 | 1.1 | Hero headline |
| H1 | 40px | 700 | 1.15 | Page titles |
| H2 | 32px | 700 | 1.2 | Section headers |
| H3 | 24px | 600 | 1.25 | Card titles |
| H4 | 18px | 600 | 1.3 | Subsections |
| Body Large | 18px | 400 | 1.6 | Lead paragraphs |
| Body | 16px | 400 | 1.6 | Default text |
| Body Small | 14px | 400 | 1.5 | Captions |
| Caption | 12px | 500 | 1.4 | Tags, metadata |

**Typography notes:**
- Single typeface (Plus Jakarta Sans) — its rounded terminals naturally communicate friendliness
- Heavier display weights (700-800) allowed for headlines — conveys energy
- Emoji in body copy is acceptable and encouraged for team bios and culture content

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Plus Jakarta Sans | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Plus+Jakarta+Sans) \| [GitHub](https://github.com/nicholasjconn/plus-jakarta-sans) |

*Adobe Fonts alternative:* [DM Sans](https://fonts.adobe.com/fonts/dm-sans) has similarly rounded terminals and a warm personality. Also available on [Google Fonts](https://fonts.google.com/specimen/DM+Sans).

---

## Spacing & Layout

**Spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96px

**Grid:**

| Breakpoint | Columns | Gutter | Margin | Max Width |
|------------|---------|--------|--------|-----------|
| Mobile (<768px) | 4 | 16px | 16px | 100% |
| Tablet (768-1024px) | 8 | 20px | 32px | 100% |
| Desktop (1024-1440px) | 12 | 24px | 48px | 100% |
| Wide (>1440px) | 12 | 24px | 48px | 1280px |

**Layout pattern:** Single-column marketing flow on landing pages. Bento grid for team/culture showcase sections (variable cell sizes: 1x1, 2x1, 1x2, 2x2 with 16px gaps and 16px border-radius on cells).

---

## Component Styling

### Buttons

```css
.btn-primary {
  background: var(--primary);
  color: #FFFFFF;
  padding: 14px 28px;
  border-radius: 9999px; /* pill shape */
  font-size: 16px;
  font-weight: 600;
  border: none;
  transition: transform 200ms ease, box-shadow 200ms ease;
}
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(242, 112, 79, 0.25);
}
.btn-primary:active { transform: translateY(0) scale(0.97); }
.btn-primary:focus-visible {
  outline: 2px solid var(--primary);
  outline-offset: 3px;
}

.btn-secondary {
  background: rgba(var(--primary-rgb), 0.08);
  color: var(--primary);
  padding: 14px 28px;
  border-radius: 9999px;
  font-size: 16px;
  font-weight: 600;
  border: none;
  transition: background 200ms ease;
}
.btn-secondary:hover { background: rgba(var(--primary-rgb), 0.15); }

.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  padding: 14px 20px;
  border-radius: 9999px;
  font-size: 16px;
  font-weight: 500;
  border: none;
}
.btn-ghost:hover { color: var(--primary); }
```

### Form Inputs

```css
.input {
  background: var(--bg-surface);
  color: var(--text-primary);
  padding: 14px 16px;
  border: 2px solid var(--border-default);
  border-radius: 12px;
  font-size: 16px;
  transition: border-color 200ms ease, box-shadow 200ms ease;
}
.input:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 4px rgba(var(--primary-rgb), 0.1);
  outline: none;
}
.input::placeholder { color: var(--text-tertiary); }
.input--error {
  border-color: var(--error);
  box-shadow: 0 0 0 4px rgba(248, 113, 113, 0.1);
}
```

### Cards

```css
.card {
  background: var(--bg-surface);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.06);
  transition: transform 300ms ease, box-shadow 300ms ease;
}
.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px -4px rgba(0, 0, 0, 0.1);
}

/* Culture bento card with tinted background */
.card--culture {
  background: var(--secondary-light);
  border-radius: 16px;
  padding: 32px;
  box-shadow: none;
}
.card--culture.mint { background: var(--accent-light); }
.card--culture.coral { background: var(--primary-light); }
```

### Navigation

```css
.header {
  background: var(--bg-primary);
  height: 72px;
  padding: 0 48px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid var(--border-default);
}
.nav-item {
  color: var(--text-secondary);
  font-size: 15px;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 9999px;
  transition: color 200ms ease, background 200ms ease;
}
.nav-item:hover {
  color: var(--primary);
  background: var(--primary-light);
}

/* Mobile: bottom tab bar */
@media (max-width: 768px) {
  .tab-bar {
    position: fixed;
    bottom: 0;
    height: 64px;
    background: var(--bg-surface);
    border-radius: 24px 24px 0 0;
    box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.08);
  }
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Button hover | Rise + shadow | 200ms | ease |
| Button press | Scale down (0.97) | 100ms | ease |
| Card hover | Rise + shadow expand | 300ms | ease |
| Card entrance | Slide up + fade in | 400ms | cubic-bezier(0.16, 1, 0.3, 1) |
| Page hero | Staggered text reveal | 600ms total | ease-out |
| Bento cells | Staggered fade in | 100ms stagger | ease-out |
| Application submitted | Confetti burst | 1200ms | spring |
| Form step transition | Slide left + fade | 300ms | ease-in-out |
| Hover on team photo | Slight scale (1.03) | 300ms | ease |

**Motion philosophy:** Motion as personality. Animations should feel bouncy and alive — spring physics, slight overshoots on card entrances, and celebratory moments (confetti on application submit). Everything respects `prefers-reduced-motion`.

---

## Asset Guidelines

**Photography:** Real team photos — candid moments, collaborative settings, natural lighting. Warm color grading. Diverse representation. No stock photography. No suits or formal settings. Team members should look like people you'd want to work with.

**Iconography:** Rounded/soft style, 2px stroke weight, filled variants acceptable for emphasis. Can use multiple colors from the palette. 24px default size.

**Illustration:** Hand-drawn or flat vector style. Uses the full color palette. Appears in: empty states, loading screens, section dividers, 404 page. Should feel sketchy and human, not corporate.

**Logo:** "Join the Draft" wordmark in coral on warm-white, or white on coral for CTA sections. Playful lettering, not the main Ipso corporate logo.

---

## Implementation Checklist

- [ ] Plus Jakarta Sans loaded with weights: 400, 500, 600, 700, 800
- [ ] Three-color system: coral, lavender, mint — all used intentionally
- [ ] Border-radius minimum 12px (16px for cards, pill for buttons)
- [ ] Warm off-white background (#FFFAF5), not pure white
- [ ] Bento grid with variable cell sizes on culture sections
- [ ] Mobile bottom tab bar replaces header nav
- [ ] All animations have `prefers-reduced-motion` fallbacks
- [ ] Confetti animation on successful application submit
- [ ] Touch targets >= 48px on mobile
- [ ] Form inputs have visible 2px borders (not 1px)
- [ ] Real photography — no stock images
- [ ] Color contrast meets WCAG AA: text-primary on bg-primary = 12.8:1

---

*Derived from: [consumer-playful.md](../consumer-playful.md)*
*Example #3 of 10 — See [README.md](README.md) for full series*
