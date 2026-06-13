---
name: "Clash Display"
slug: clash-display
category: display
designer: "Indian Type Foundry team"
foundry: "Indian Type Foundry (ITF)"
year: 2021
adobe_fonts: false
google_fonts: false
open_source: true
license: "ITF Free Font License"
classification: "geometric"
tone:
  - bold
  - confident
  - editorial
use_cases:
  - hero-headlines
  - poster-design
  - event-branding
  - marketing
  - social-media
notable_users: []
---

# Clash Display

## Identity

| Field | Detail |
|---|---|
| **Name** | Clash Display |
| **Designer** | Indian Type Foundry team |
| **Foundry** | Indian Type Foundry (ITF) |
| **Year** | 2021 (Fontshare release) |
| **License** | ITF Free Font License (free personal & commercial) |
| **Adobe Fonts** | No — Fontshare exclusive |

## Classification

Grotesque display sans-serif. Optimized for large sizes. Geometric structure with distinctive wide proportions and open apertures. Variable weight axis available.

## Character

Clash Display is built for one thing: presence. It is explicitly a display typeface — designed to perform at large sizes — and the design decisions reflect that priority. Wide letter spacing, open apertures, and a proportionally large x-height ensure that headlines set in Clash Display occupy space with confidence. The forms are clean but not sterile; there are subtle idiosyncrasies in the construction that prevent it from reading as generic grotesque.

The name is apt: when Clash Display appears in a composition, it announces itself. This directness is a strength in hero sections, poster design, and brand campaigns, and a liability anywhere text needs to recede. It is not a workhorse — it is a statement.

With six weights from ExtraLight to Bold (and a variable version), it covers a surprisingly nuanced range. The lighter weights at large sizes have an airy editorial quality; the heavier weights have punch.

## Best Use Cases

- Hero section headlines on marketing sites
- Poster and print design
- Event branding and campaign work
- Magazine-style editorial layouts
- Social media graphics and motion design
- Brand identity for bold, expressive companies

## Tone / Mood

Bold, confident, editorial. Wide-open and direct. Neither casual nor corporate — occupies the creative/expressive quadrant. High energy without being aggressive.

## Demographics

- **Industries**: Creative agencies, entertainment, fashion, music/culture, events, bold consumer brands
- **Audiences**: Design-literate consumers; brand campaigns targeting 18-35; creative industry professionals

## Notable Users

Used in independent design projects including Jesse Story branding, AI agent product interfaces, and sports/fitness brand campaigns documented on Fonts In Use. Widely used in Framer community templates for aggressive marketing layouts. Popular in Behance brand identity work from 2022–2025.

## Pairing Recommendations

| Role | Recommendation |
|---|---|
| Body companion | Satoshi (same ITF stable), General Sans |
| Serif contrast | Fraunces (editorial warmth), EB Garamond |
| Lighter display | Cabinet Grotesk (more restrained, same foundry) |
| Monospace accent | JetBrains Mono |

Clash Display + Satoshi is an ITF-native pairing that appears frequently in startup brand identity work — Clash for hero, Satoshi for everything else.

## Variable Font Axes

| Axis | Tag | Range | Notes |
|---|---|---|---|
| Weight | `wght` | 200–700 | ExtraLight through Bold |

Single variable axis. Variable file covers the full weight range in a single file. No italic variable — Clash Display has no italic styles whatsoever.

## Strengths

- Unambiguous display intent — extremely effective at large sizes
- Variable font file available (single file for full weight range)
- Wide proportions create strong presence in hero and poster contexts
- 135 language support — solid for international brand work
- Free for personal and commercial use under ITF license
- Complements Satoshi and Cabinet Grotesk for full ITF typographic system

## Weaknesses

- No italic styles at any weight — strictly for display/headline use
- Weight range tops at Bold (700); no Black or ExtraBlack for ultra-heavy display
- Completely unsuitable for body copy or small-size UI text
- Not on Google Fonts or Adobe Fonts — Fontshare or self-hosting only
- High visibility in the "creative startup" space may reduce distinctiveness in those markets
- Wide proportions require generous white space; fails in tight or text-dense layouts

## CSS Snippet

```css
/* Fontshare CDN */
@import url('https://api.fontshare.com/v2/css?f[]=clash-display@400,500,600,700&display=swap');

/* Self-hosted variable font */
@font-face {
  font-family: 'Clash Display';
  src: url('/fonts/ClashDisplay-Variable.woff2') format('woff2');
  font-weight: 200 700;
  font-style: normal;
  font-display: swap;
}

/* Hero heading */
.hero-title {
  font-family: 'Clash Display', 'Cabinet Grotesk', ui-sans-serif, system-ui, sans-serif;
  font-weight: 600;
  font-size: clamp(3rem, 8vw, 8rem);
  letter-spacing: -0.03em;
  line-height: 1.0;
}

/* Poster / campaign display */
.campaign-headline {
  font-family: 'Clash Display', ui-sans-serif, system-ui, sans-serif;
  font-weight: 700;
  font-size: clamp(4rem, 12vw, 12rem);
  line-height: 0.95;
  text-transform: uppercase;
  letter-spacing: -0.04em;
}
```
