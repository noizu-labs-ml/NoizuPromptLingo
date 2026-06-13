---
name: "Cabinet Grotesk"
slug: cabinet-grotesk
category: sans-serif
designer: "Shiva Nallaperumal"
foundry: "Indian Type Foundry (ITF)"
year: 2021
adobe_fonts: false
google_fonts: false
open_source: true
license: "ITF Free Font License"
classification: "grotesque"
tone:
  - constructed
  - authoritative
  - sophisticated
use_cases:
  - brand-identity
  - headers
  - e-commerce
  - editorial
notable_users: []
---

# Cabinet Grotesk

## Identity

| Field | Detail |
|---|---|
| **Name** | Cabinet Grotesk |
| **Designer** | Shiva Nallaperumal (initial), completed by Indian Type Foundry team |
| **Foundry** | Indian Type Foundry (ITF) |
| **Year** | 2017 (Fontstore), 2021 (Fontshare) |
| **License** | ITF Free Font License (free personal & commercial) |
| **Adobe Fonts** | No — Fontshare exclusive |

## Classification

Contemporary sans-serif with visible stroke contrast. Sits between geometric and humanist — the contrast most prominent in stroke connections creates a "pinched" quality at heavier weights. Display-leaning at Bold/ExtraBold; functional at Regular/Medium.

## Character

Cabinet Grotesk earns its name: it has a slight formal quality, like a well-made piece of furniture — constructed, proportionate, with visible craft in the joints. The stroke contrast that differentiates it from other free grotesques becomes most visible and most interesting at heavy weights, where the "pinched" connections give it an almost calligraphic undertone. This makes it visually distinctive at display sizes without veering into decorative territory. At Regular, it is a clean, capable sans. At ExtraBold, it has presence.

The double-storey `a` and `g` add legibility signals; single-storey alternates via OpenType give designers a more geometric option. Nineteen ligatures and case-sensitive punctuation reflect serious typographic engineering.

## Best Use Cases

- Brand identity systems that want a distinctive sans without full display eccentricity
- Section headers and subheadings where some visual personality is welcome
- E-commerce and product marketing pages
- Packaging and editorial layouts
- Strong at medium-large heading hierarchy (H2–H4 range) where it complements a more expressive H1

## Tone / Mood

Constructed, authoritative, slightly sophisticated. Has more character than a utility sans but remains professional. Sits between "clean startup" and "editorial quality." Works for lifestyle, fashion, and premium tech brands.

## Demographics

- **Industries**: E-commerce, fashion, lifestyle brands, premium consumer products, design studios
- **Audiences**: Consumers who value craft; design-literate professionals; brands positioned above utility

## Notable Users

Widely used in brand identity and e-commerce design work shared on Fontshare and Behance. Popular in Framer and Webflow community templates for premium-tier product pages. Often paired with Satoshi or General Sans for the body/display split.

## Pairing Recommendations

| Role | Recommendation |
|---|---|
| Body companion | Satoshi, General Sans (similar ITF aesthetic) |
| Serif contrast | Fraunces, Cormorant Garamond |
| More aggressive display | Clash Display (same foundry, higher contrast) |
| Monospace | JetBrains Mono, Fira Code |

Cabinet Grotesk and Satoshi are a natural ITF family pairing — both from Indian Type Foundry, complementary weights and proportions.

## Variable Font Axes

Cabinet Grotesk does not include a variable font file. Static family only.

| Weight | Style |
|---|---|
| Thin (100) | |
| ExtraLight (200) | |
| Light (300) | |
| Regular (400) | |
| Medium (500) | |
| SemiBold (600) | |
| Bold (700) | |
| ExtraBold (800) | |

No italic styles — a notable limitation for editorial or body use.

## Strengths

- Visible stroke contrast creates genuine differentiation from commodity grotesques
- 8-weight range from Thin to ExtraBold; excellent coverage for hierarchical design
- 19 ligatures and case-sensitive punctuation — typographic quality signals
- OpenType alternates (single/double storey) give design flexibility
- Distinctive at heavy weights without sacrificing legibility
- Free for commercial use

## Weaknesses

- No variable font file — requires loading multiple static weights for a full range
- No italic styles — limits body copy use
- Weight capped at ExtraBold (800); no Black for maximum display impact
- Not on Google Fonts or Adobe Fonts; Fontshare CDN or self-hosting required
- The distinctive stroke contrast can look slightly dated in highly minimal design contexts

## CSS Snippet

```css
/* Fontshare CDN */
@import url('https://api.fontshare.com/v2/css?f[]=cabinet-grotesk@400,500,700,800&display=swap');

/* Self-hosted static */
@font-face {
  font-family: 'Cabinet Grotesk';
  src: url('/fonts/CabinetGrotesk-Regular.woff2') format('woff2');
  font-weight: 400;
  font-display: swap;
}

@font-face {
  font-family: 'Cabinet Grotesk';
  src: url('/fonts/CabinetGrotesk-Bold.woff2') format('woff2');
  font-weight: 700;
  font-display: swap;
}

@font-face {
  font-family: 'Cabinet Grotesk';
  src: url('/fonts/CabinetGrotesk-Extrabold.woff2') format('woff2');
  font-weight: 800;
  font-display: swap;
}

/* Display heading */
.section-heading {
  font-family: 'Cabinet Grotesk', 'DM Sans', ui-sans-serif, system-ui, sans-serif;
  font-weight: 700;
  font-size: clamp(1.75rem, 4vw, 3.5rem);
  letter-spacing: -0.02em;
}

/* Single-storey alternates */
.geometric-mode {
  font-feature-settings: 'ss01' 1;
}
```
