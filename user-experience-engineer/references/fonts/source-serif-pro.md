---
name: "Source Serif Pro"
slug: source-serif-pro
category: serif
designer: "Frank Grießhammer"
foundry: "Adobe"
year: 2014
adobe_fonts: true
google_fonts: true
open_source: true
license: "OFL"
classification: "transitional"
tone:
  - neutral
  - professional
  - trustworthy
use_cases:
  - long-form-body-text
  - ui-typography
  - multilingual-publishing
  - documentation
notable_users:
  - Adobe
  - Wikipedia
---

# Source Serif Pro (Source Serif 4)

## Identity

| Field | Detail |
|-------|--------|
| **Designer** | Frank Grießhammer |
| **Foundry** | Adobe |
| **Year** | 2014 (v1), 2017 (v2 with Cyrillic/Greek), 2022 (Source Serif 4 variable) |
| **Adobe Fonts** | Yes — included with all Creative Cloud subscriptions |
| **Weights** | ExtraLight (200) through Black (900) as variable; also Roman and Italic across 6 named weights with 5 optical sizes |

## Classification

**Humanist Transitional Serif.** Source Serif Pro bridges Renaissance warmth and eighteenth-century rationalism. Its moderate stroke contrast, open apertures, and subtly bracketed serifs place it closer to Transitional models (Baskerville lineage) while retaining humanist proportions inherited from the broader Source family's design philosophy.

## Character

Source Serif Pro is the workhorse's workhorse — quietly competent, never showy, and deeply at ease with volume. It was built to accompany Source Sans Pro, and that relationship shows: both share proportional DNA that makes mixed-family layouts feel effortlessly unified. The italic is warm without being calligraphic. At display sizes, the optical Display variant gains confidence and open spacing; at Caption sizes it tightens for small-print legibility. It has no affectations — no dramatic didone contrast, no precious Old Style eccentricities — which makes it approachable across cultural contexts and use-case registers.

## Best Use Cases

- **Long-form body text** on screen and in print — technical documentation, editorial articles, annual reports
- **UI typography** where a serif adds formality without imposing personality
- **Multilingual publishing** — robust Latin, Cyrillic, and Greek coverage
- **Open-source projects and documentation sites** that need quality without licensing cost
- Pairing with Source Sans Pro or Source Code Pro in Adobe-ecosystem design systems

## Tone and Mood

Neutral, professional, accessible. It reads as trustworthy rather than authoritative, literate rather than academic. Neither cold nor warm — functionally temperature-neutral. This is its strength and, in branding contexts requiring strong personality, its limitation.

## Demographics and Industries

- **Tech companies** using it for documentation (GitHub, developer portals)
- **Academic and non-profit publishing** attracted by its open-source license
- **Government and civic design** — institutional legibility
- **Adobe-native designers** building cohesive Source family stacks
- Widely adopted in **UX writing** and **content design** communities

## Notable Users

- Adobe itself (documentation, developer resources)
- Wikipedia (considered for body text; used in some contexts)
- Various open-source documentation sites (GitBook, MkDocs themes)
- Mozilla design system adjacent usage

## Pairing Recommendations

| Role | Pairing |
|------|---------|
| **System sans** | Source Sans Pro (designed to match) |
| **Humanist sans** | Inter, IBM Plex Sans |
| **Geometric sans** | Nunito (for warmer UIs) |
| **Mono** | Source Code Pro (cohesive system) |
| **Contrast pair** | Aktiv Grotesk, Neue Haas Grotesk |

## Strengths

- Variable font with weight and optical size axes — flexible without multiple file overhead
- Excellent screen rendering at small sizes
- Open source (SIL OFL) — no licensing friction
- Strong multilingual support across Latin, Cyrillic, Greek
- Designed to harmonize with Source Sans and Source Code — complete system available

## Weaknesses

- Lacks typographic personality for premium editorial or high-fashion branding
- Display sizes are refined but not dramatically expressive
- Less distinctive than commissioned serifs — may read as "default" in some contexts
- Not the strongest choice for print-only contexts where higher contrast would aid legibility

## Comparison

| Font | Relationship |
|------|-------------|
| **Freight Text** | More personality, warmer Dutch-inspired warmth; better for premium editorial; not open-source |
| **Lora** | Similarly screen-optimized; more calligraphic warmth; narrower weight range |
| **Minion Pro** | More historically grounded (Renaissance), richer italic, stronger print heritage; but less suited for UI |

## CSS Snippet

```css
/* Adobe Fonts (Typekit) embed */
font-family: "source-serif-pro", "Source Serif 4", Georgia, "Times New Roman", serif;

/* Variable font (Google Fonts / self-hosted) */
font-family: "Source Serif 4", Georgia, serif;
font-optical-sizing: auto;
font-weight: 400; /* 200–900 */
font-style: normal;
```
