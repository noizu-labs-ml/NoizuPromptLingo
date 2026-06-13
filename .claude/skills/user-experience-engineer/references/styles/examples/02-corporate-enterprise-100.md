# Style Guide: Ipso The Lorem — Client Gateway

> Trust-forward interface for an enterprise RFP response and client onboarding portal.

**Style System:** Corporate Enterprise 100%
**Source Spec:** [corporate-enterprise.md](../corporate-enterprise.md)
**Scenario:** Fortune 500 client-facing portal

---

## Scenario

Ipso The Lorem needs a **Client Gateway** — a portal where enterprise prospects submit RFPs, review proposals, sign contracts, and onboard onto Ipso's services. The audience is procurement officers, CTOs, and VP-level decision-makers at Fortune 500 companies.

These buyers are risk-averse. They need to feel that Ipso is **established, secure, and professional** before committing six-figure engagements. The visual language must signal institutional trust, not startup energy. Every pixel should say: "We've done this before. Your data is safe with us."

Corporate Enterprise is the clear fit: navy blue authority, serif headline gravitas, conservative radii, trust badges, and deliberate interactions that feel considered rather than hasty.

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #FFFFFF;
  --bg-section: #F8FAFC;
  --bg-elevated: #FFFFFF;

  /* Text */
  --text-primary: #1E293B;
  --text-secondary: #475569;
  --text-tertiary: #94A3B8;

  /* Borders */
  --border-default: #E2E8F0;
  --border-strong: #CBD5E1;

  /* Primary — Deep Navy (authority, trust) */
  --primary: #1E3A5F;
  --primary-hover: #162D4A;
  --primary-light: #EFF6FF;

  /* Accent — Muted Gold (premium, established) */
  --accent: #B8860B;
  --accent-light: #FEF9E7;

  /* Semantic */
  --success: #16A34A;
  --warning: #D97706;
  --error: #DC2626;
  --info: #2563EB;
}
```

```
┌─────────────────────────────────────────┐
│  CLIENT GATEWAY PALETTE                 │
├─────────────────────────────────────────┤
│                                         │
│  ██████  #FFFFFF   Background           │
│  ██████  #F8FAFC   Section bg           │
│                                         │
│  ██████  #1E293B   Text Primary         │
│  ██████  #475569   Text Secondary       │
│                                         │
│  ██████  #1E3A5F   Primary (Navy)       │
│  ██████  #B8860B   Accent (Gold)        │
│                                         │
└─────────────────────────────────────────┘
```

**Usage rules:**
- Light mode only (enterprise audiences expect it; dark mode signals "developer tool")
- Navy appears on: header bar, primary buttons, sidebar active states
- Gold accent used sparingly: premium badges, featured proposal highlights, hover underlines
- Gray section backgrounds (`--bg-section`) alternate with white to create visual rhythm without color
- No saturated colors outside semantic contexts

---

## Typography

**Font stack:**
```css
--font-heading: 'Merriweather', Georgia, 'Times New Roman', serif;
--font-body: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| Display | Serif | 40px | 700 | 1.2 | Landing hero (rare) |
| H1 | Serif | 32px | 700 | 1.25 | Page titles |
| H2 | Serif | 24px | 700 | 1.3 | Section headers |
| H3 | Sans | 20px | 600 | 1.35 | Card titles |
| H4 | Sans | 16px | 600 | 1.4 | Subsections |
| Body Large | Sans | 18px | 400 | 1.7 | Lead paragraphs |
| Body | Sans | 16px | 400 | 1.7 | Default text |
| Body Small | Sans | 14px | 400 | 1.6 | Metadata |
| Caption | Sans | 12px | 500 | 1.5 | Table headers, labels |
| Overline | Sans | 11px | 600 | 1.4 | Category labels (uppercase, 0.08em tracking) |

**Typography notes:**
- Serif headings convey authority; sans-serif body ensures readability at paragraph length
- Line height 1.7 throughout body copy — generous for comfortable reading
- Overlines (uppercase, tracked) used for section categorization (e.g., "PROPOSAL STATUS", "SECURITY")

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Merriweather | Adobe Fonts | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/merriweather) \| [Google Fonts](https://fonts.google.com/specimen/Merriweather) |
| Inter | Adobe Fonts | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/inter) \| [Google Fonts](https://fonts.google.com/specimen/Inter) |

---

## Spacing & Layout

**Spacing scale:** 4, 8, 16, 24, 32, 48, 64, 80, 120px

**Grid:**

| Breakpoint | Columns | Gutter | Margin | Max Width |
|------------|---------|--------|--------|-----------|
| Mobile (<768px) | 4 | 16px | 20px | 100% |
| Tablet (768-1024px) | 8 | 24px | 40px | 100% |
| Desktop (1024-1440px) | 12 | 32px | 64px | 100% |
| Wide (>1440px) | 12 | 32px | 80px | 1440px |

**Layout pattern:** Top nav (64px) with logo + primary navigation + user menu. Wider margins than Minimal Tech (enterprise content breathes more). Page content is single-column for proposal flows, sidebar + main for dashboard views.

---

## Component Styling

### Buttons

```css
.btn-primary {
  background: var(--primary);
  color: #FFFFFF;
  padding: 12px 24px;
  border-radius: 4px;
  font-family: var(--font-body);
  font-size: 14px;
  font-weight: 600;
  border: none;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  transition: background 200ms ease;
}
.btn-primary:hover { background: var(--primary-hover); }
.btn-primary:focus-visible {
  outline: 2px solid var(--primary);
  outline-offset: 2px;
}
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }

.btn-secondary {
  background: transparent;
  color: var(--primary);
  padding: 12px 24px;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 600;
  border: 2px solid var(--primary);
  transition: background 200ms ease;
}
.btn-secondary:hover { background: var(--primary-light); }

.btn-tertiary {
  background: transparent;
  color: var(--primary);
  padding: 12px 0;
  font-size: 14px;
  font-weight: 600;
  border: none;
  text-decoration: underline;
  text-underline-offset: 3px;
}
```

### Form Inputs

```css
.input {
  background: var(--bg-primary);
  color: var(--text-primary);
  padding: 12px 16px;
  border: 1px solid var(--border-default);
  border-radius: 4px;
  font-size: 16px;
  font-family: var(--font-body);
  line-height: 1.5;
  transition: border-color 200ms ease;
}
.input:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(30, 58, 95, 0.1);
  outline: none;
}
.input--error { border-color: var(--error); }

.label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 6px;
}
.label--required::after {
  content: ' *';
  color: var(--error);
}
```

### Cards

```css
.card {
  background: var(--bg-primary);
  border: 1px solid var(--border-default);
  border-radius: 8px;
  padding: 32px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
}
.card__header {
  border-bottom: 1px solid var(--border-default);
  padding-bottom: 16px;
  margin-bottom: 24px;
}
.card--featured {
  border-left: 4px solid var(--accent);
}
```

### Navigation

```css
.header {
  background: var(--primary);
  height: 64px;
  padding: 0 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.header__logo { color: #FFFFFF; font-family: var(--font-heading); font-weight: 700; }
.header__nav-item {
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
  font-weight: 500;
  padding: 8px 16px;
  transition: color 200ms ease;
}
.header__nav-item:hover { color: #FFFFFF; }
.header__nav-item--active {
  color: #FFFFFF;
  border-bottom: 2px solid var(--accent);
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Button hover | Background darken | 200ms | ease |
| Input focus | Border + shadow | 200ms | ease |
| Nav item hover | Color brighten | 200ms | ease |
| Card entrance | Fade in + slight rise | 300ms | ease-out |
| Dropdown open | Scale Y from top | 200ms | ease-out |
| Modal open | Fade overlay + scale dialog | 250ms | ease-out |
| Progress bar | Width transition | 400ms | ease-in-out |
| Status update | Background flash | 300ms | ease |

**Motion philosophy:** Deliberate and measured. Slower than Minimal Tech (200-300ms vs 150ms) to convey thoughtfulness. No bounces, no springs. Every transition should feel like a considered decision, not a quick reaction.

---

## Trust Elements

These are specific to enterprise contexts — not general components:

- **Security badges:** SOC 2 Type II, ISO 27001, GDPR — displayed in footer and security pages. Rendered in grayscale, not color.
- **Client logos:** "Trusted by" section with Fortune 500 logos. Grayscale, uniform height (32px), generous spacing.
- **Data points:** "Serving 200+ organizations", "99.99% uptime", "Bank-level encryption" — placed near CTAs and in header sub-navigation.
- **Testimonials:** Full name, title, company, and real photo. No anonymous quotes.

---

## Asset Guidelines

**Photography:** Professional headshots for team pages. Office/workspace imagery should be real (not stock), well-lit, muted tones. No lifestyle shots, no casual settings.

**Iconography:** Heroicons (outline style), 20px default, 1.5px stroke. Monochrome — navy or text-secondary. Used for navigation, status indicators, and form helpers.

**Illustration:** None. Enterprise portals don't use illustration — it undermines the seriousness signal. Use data visualizations where visual interest is needed.

**Logo:** Ipso The Lorem wordmark in navy on white, white on navy for header. Minimum clear space: 1x logo height on all sides.

---

## Implementation Checklist

- [ ] Serif headings (Merriweather) + sans body (Inter) — two distinct font families
- [ ] Navy primary + gold accent only — no other brand colors
- [ ] Border-radius capped at 8px (conservative)
- [ ] All form labels visible (no placeholder-only inputs)
- [ ] Required fields marked with asterisk
- [ ] Trust badges in footer
- [ ] Transitions at 200-300ms (deliberate pacing)
- [ ] Box shadows are subtle (max opacity 0.05)
- [ ] Color contrast meets WCAG AA: text-primary on white = 13.5:1
- [ ] Print stylesheet for proposal documents
- [ ] No auto-playing animations or carousels
- [ ] Session timeout warning at 15 minutes (enterprise security requirement)

---

*Derived from: [corporate-enterprise.md](../corporate-enterprise.md)*
*Example #2 of 10 — See [README.md](README.md) for full series*
