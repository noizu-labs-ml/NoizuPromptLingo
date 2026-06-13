---
name: "Plus Jakarta Sans"
slug: plus-jakarta-sans
category: sans-serif
designer: "Gumpita Rahayu"
foundry: "Tokotype"
year: 2022
adobe_fonts: false
google_fonts: true
open_source: true
license: "OFL"
classification: "geometric"
tone:
  - friendly
  - open
  - modern
use_cases:
  - saas-landing-pages
  - consumer-apps
  - civic-branding
  - email-marketing
notable_users: []
---

# Plus Jakarta Sans

## Identity

| Field | Detail |
|---|---|
| **Name** | Plus Jakarta Sans |
| **Designer** | Gumpita Rahayu |
| **Foundry** | Tokotype |
| **Year** | 2020 (commissioned), 2022 (Google Fonts release) |
| **License** | SIL Open Font License |
| **Adobe Fonts** | No — Google Fonts / self-hosted only |

## Classification

Geometric sans-serif with humanist softness. Inspired by Neuzit Grotesk, Futura, and 1930s grotesque tradition. Variable font (weight axis). Stylistic alternates in three variants: Lancip (Sharp), Lurus (Straight), Lingkar (Swirl).

## Character

Originally designed for the Jakarta City of Collaboration government identity program, Plus Jakarta Sans carries a genuine civic warmth. The almost-monoline contrast and slightly tall x-height give it openness and approachability. The balanced spacing and open counters mean it holds up well in UI contexts — navigation labels, button text, form fields — while still being lively enough for marketing headers. Among geometric free fonts, it occupies the "friendly and trustworthy" quadrant rather than "edgy and technical." The three stylistic alternates (sharp points, straight terminals, swirl finishes) give designers meaningful expressive range within a single family.

## Best Use Cases

- SaaS and startup landing pages that need a friendly, professional tone
- Product UI for consumer-facing apps (fintech, health, education)
- Brand identity for civic, social impact, or mission-driven organizations
- Email marketing and newsletter design
- Mobile-first interfaces where the tall x-height aids small-screen readability

## Tone / Mood

Friendly, open, modern. Approachable authority. Feels trustworthy without being boring. Consumer-forward rather than developer-facing.

## Demographics

- **Industries**: Consumer SaaS, edtech, health tech, civic/nonprofit, fintech with consumer focus
- **Audiences**: General consumers, design-literate users, mobile-first audiences

## Notable Users

Used extensively in Webflow templates and Framer community templates. Popular default choice in Notion-adjacent productivity and documentation tool branding. High adoption in Southeast Asian startup ecosystems (reflects regional pride in the Jakarta origin). Consistent presence in "best Google Fonts 2025" roundups.

## Pairing Recommendations

| Role | Recommendation |
|---|---|
| Display accent | Fraunces (elegant contrast), Playfair Display |
| Technical companion | DM Mono, Space Mono |
| Heavier display | Cabinet Grotesk |
| Neutral body | DM Sans (similar energy, slightly smaller x-height) |

Pairs especially well with Fraunces — the editorial warmth of Fraunces' old-style serif contrasts beautifully with Jakarta Sans' crisp modernity.

## Variable Font Axes

| Axis | Tag | Range | Notes |
|---|---|---|---|
| Weight | `wght` | 200–800 | ExtraLight through ExtraBold |

16 static files total. Supports 62 languages including Cyrillic-ext and Vietnamese. Variable file covers the full weight range.

## Strengths

- Genuine warmth and friendliness that most geometric sans fonts lack
- Three stylistic alternate sets offer meaningful visual customization
- Tall x-height — excellent for small-size UI legibility
- Full SIL OFL license — no restrictions
- Strong multilingual support (62 languages)
- Performs well in both display and body copy contexts

## Weaknesses

- No italic styles — a significant gap for editorial or body use
- Shares the "popular startup font" space with Satoshi and DM Sans; can feel generic in saturated markets
- Not available on Adobe Fonts; requires Google Fonts or self-hosting
- The "friendly" tone is inappropriate for luxury, premium, or high-seriousness contexts
- Weight tops at 800; no Black weight for maximum display impact

## CSS Snippet

```css
/* Google Fonts — variable */
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@200..800&display=swap');

/* Self-hosted variable font */
@font-face {
  font-family: 'Plus Jakarta Sans';
  src: url('/fonts/PlusJakartaSans-Variable.woff2') format('woff2');
  font-weight: 200 800;
  font-style: normal;
  font-display: swap;
}

/* Usage */
.ui-label {
  font-family: 'Plus Jakarta Sans', 'DM Sans', ui-sans-serif, system-ui, sans-serif;
  font-weight: 500;
  font-size: 0.875rem;
  letter-spacing: 0.01em;
}

.hero-title {
  font-family: 'Plus Jakarta Sans', 'DM Sans', ui-sans-serif, system-ui, sans-serif;
  font-weight: 700;
  font-size: clamp(2rem, 5vw, 4.5rem);
  letter-spacing: -0.02em;
}

/* Stylistic alternates */
.sharp-variant   { font-feature-settings: 'ss01' 1; } /* Lancip  */
.straight-variant { font-feature-settings: 'ss02' 1; } /* Lurus   */
.swirl-variant   { font-feature-settings: 'ss03' 1; } /* Lingkar */
```
