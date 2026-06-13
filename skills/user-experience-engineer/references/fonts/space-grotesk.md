---
name: "Space Grotesk"
slug: space-grotesk
category: sans-serif
designer: "Florian Karsten"
foundry: "Florian Karsten Typefaces"
year: 2018
adobe_fonts: true
google_fonts: true
open_source: true
license: "OFL"
classification: "geometric"
tone:
  - techy
  - precise
  - quirky
use_cases:
  - hero-headlines
  - developer-tools
  - fintech
  - portfolio-sites
notable_users: []
---

# Space Grotesk

## Identity

| Field | Detail |
|---|---|
| **Name** | Space Grotesk |
| **Designer** | Florian Karsten |
| **Foundry** | Florian Karsten Typefaces (Brno, Czech Republic) |
| **Year** | 2018 (derived from Space Mono, 2016, Colophon Foundry) |
| **License** | SIL Open Font License |
| **Adobe Fonts** | Yes — available as "Space Grotesk Variable" |

## Classification

Geometric display sans-serif. Neo-grotesque with idiosyncratic monospace-derived details. Variable weight axis.

## Character

Space Grotesk carries the structural DNA of a monospace typeface — stiff terminals, quirky ink traps, and slight mechanical awkwardness — but repackaged into proportional spacing. The result is a sans that feels simultaneously engineered and slightly eccentric. It reads as technically confident without being cold. The letter `G` lacks a spur; the `a` is double-storey; numerals have an old-style warmth. There is an underlying tension between systematic rigor and playful irregularity that makes it memorable at display sizes.

## Best Use Cases

- Hero headlines on developer tools, SaaS dashboards, and fintech interfaces
- Branding for tech startups that want personality beyond Inter or DM Sans
- Section headers in design documentation or technical editorial
- Portfolio sites for engineers, designers, or creative technologists
- Cryptocurrency and Web3 interfaces (high existing adoption)

## Tone / Mood

Techy, precise, slightly quirky. Not cold — has warmth from the monospace heritage. Confident without arrogance. Sits between editorial and utilitarian.

## Demographics

- **Industries**: Developer tools, fintech, Web3/crypto, SaaS, creative agencies
- **Audiences**: Technical users, design-forward founders, developers with aesthetic sense

## Notable Users

Widely adopted across Web3 and developer-tool ecosystems. Used in numerous crypto/DeFi product interfaces and open-source project sites. Frequently seen on Dribbble/Behance in SaaS and dashboard explorations. The Fontshare Satoshi pairing is a dominant pattern in independent product design.

## Pairing Recommendations

| Role | Recommendation |
|---|---|
| Body / UI | Inter, DM Sans, IBM Plex Sans |
| Contrast serif | Fraunces, Lora, Playfair Display |
| Mono companion | Space Mono (its own parent), JetBrains Mono |

Space Grotesk and Space Mono together create a visually coherent family for code-heavy editorial contexts.

## Variable Font Axes

| Axis | Tag | Range | Notes |
|---|---|---|---|
| Weight | `wght` | 300–700 | Light through Bold |

No width or italic axis. Italics not included — a notable limitation for body use.

## Strengths

- Immediately distinctive at large sizes
- Strong brand recall; avoids the "generic sans" trap
- Variable font available (single file deployment)
- Free under SIL OFL; Adobe Fonts availability for Creative Cloud users
- Excellent numerals for data contexts

## Weaknesses

- No italic styles — limits editorial/body use
- Weight range stops at 700; no Black/ExtraBlack for extreme display use
- Quirks can read as "off-brand" in conservative contexts (finance, legal, enterprise)
- Heavy adoption in crypto/Web3 may carry unwanted associations

## CSS Snippet

```css
/* Self-hosted variable font */
@font-face {
  font-family: 'Space Grotesk';
  src: url('/fonts/SpaceGrotesk-Variable.woff2') format('woff2');
  font-weight: 300 700;
  font-display: swap;
}

/* Google Fonts */
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap');

/* Usage */
.display-heading {
  font-family: 'Space Grotesk', 'DM Sans', ui-sans-serif, system-ui, sans-serif;
  font-weight: 600;
  font-size: clamp(2rem, 5vw, 4rem);
  letter-spacing: -0.02em;
}
```
