---
name: "Satoshi"
slug: satoshi
category: sans-serif
designer: "Deni Anggara"
foundry: "Indian Type Foundry (ITF)"
year: 2021
adobe_fonts: false
google_fonts: false
open_source: true
license: "ITF Free Font License"
classification: "geometric"
tone:
  - modern
  - authoritative
  - clean
use_cases:
  - saas-ui
  - startup-landing-pages
  - brand-identity
  - app-interfaces
notable_users: []
---

# Satoshi

## Identity

| Field | Detail |
|---|---|
| **Name** | Satoshi |
| **Designer** | Deni Anggara |
| **Foundry** | Indian Type Foundry (ITF) / Fontshare |
| **Year** | 2021 |
| **License** | ITF Free Font License (free personal & commercial) |
| **Adobe Fonts** | No — Fontshare exclusive |

## Classification

Swiss-style modernist sans-serif. Geometric skeleton with grotesk finishing details. Variable weight axis. Sits in the "neo-grotesque with geometric precision" family alongside GT Walsheim and Neue Haas Grotesk.

## Character

Satoshi is defined by productive tension: the lowercase `a` and `g` are double-storey by default (humanist signal) but offer single-storey alternates via OpenType (geometric option). This duality is its personality — systematic and clean from a distance, but with small decisions that reward close reading. The play between rounded shapes and sharp angular details gives it a crisp authority that's warmer than Inter but more disciplined than Plus Jakarta Sans. Ten arrow glyphs and geometric shape characters signal its design-tool and tech-product native context.

## Best Use Cases

- SaaS product UI and dashboard interfaces
- Startup landing pages and marketing sites
- Brand identity systems for digital-native companies
- App interfaces where the font needs to carry both body and headline
- Design system "default sans" for teams wanting personality beyond Inter

## Tone / Mood

Modern, authoritative, clean. Slight warmth prevents clinical feeling. Tech-forward without being developer-eccentric. Works for B2B and consumer equally.

## Demographics

- **Industries**: SaaS, fintech, productivity tools, design tools, digital agencies
- **Audiences**: Design-literate professionals; startup audiences; digital product users

## Notable Users

One of Fontshare's most-downloaded fonts, with widespread adoption in independent SaaS and product work from 2022 onward. Heavily used in Framer and Webflow templates. Named after the pseudonym of Bitcoin's creator — carries subtle associations with the digital-native / crypto ecosystem without being as overtly "crypto" as Space Grotesk.

## Pairing Recommendations

| Role | Recommendation |
|---|---|
| Display accent | Clash Display, Cabinet Grotesk |
| Serif contrast | Fraunces, Instrument Serif |
| Body companion | Can serve as its own body font at Regular/Medium |
| Monospace | JetBrains Mono, Fira Code |

Satoshi is one of the few display-leaning free fonts that can credibly carry body copy without a companion sans.

## Variable Font Axes

| Axis | Tag | Range | Notes |
|---|---|---|---|
| Weight | `wght` | 300–900 | Light through Black |
| Italic | `ital` | 0–1 | Separate italic variable file |

Static family: 10 styles (5 weights × Roman/Italic). Variable covers full 300–900 range in both upright and italic.

## Strengths

- Full weight range including Black (900) — supports extreme display use
- Full italic coverage at all weights
- OpenType alternates give design flexibility (single/double storey `a`, `g`)
- 10 directional arrows and geometric shapes built in — useful for product UI
- Variable files available for both Roman and Italic axes
- Free for commercial use under ITF license

## Weaknesses

- Not on Google Fonts or Adobe Fonts; requires Fontshare CDN or self-hosting
- Satoshi's popularity means it no longer reads as "distinctive" in startup-saturated markets
- Italic is interpolated rather than drawn; lacks calligraphic personality
- Name association with cryptocurrency may carry unwanted connotations in some markets

## CSS Snippet

```css
/* Fontshare CDN */
@import url('https://api.fontshare.com/v2/css?f[]=satoshi@300,400,500,700,900&display=swap');

/* Self-hosted variable font */
@font-face {
  font-family: 'Satoshi';
  src: url('/fonts/Satoshi-Variable.woff2') format('woff2');
  font-weight: 300 900;
  font-style: normal;
  font-display: swap;
}

@font-face {
  font-family: 'Satoshi';
  src: url('/fonts/Satoshi-VariableItalic.woff2') format('woff2');
  font-weight: 300 900;
  font-style: italic;
  font-display: swap;
}

/* Usage — display heading */
.hero-heading {
  font-family: 'Satoshi', 'DM Sans', ui-sans-serif, system-ui, sans-serif;
  font-weight: 700;
  font-size: clamp(2.5rem, 6vw, 5rem);
  letter-spacing: -0.03em;
}

/* Alternate: single-storey a/g for more geometric feel */
.geometric-variant {
  font-feature-settings: 'ss01' 1;
}
```
