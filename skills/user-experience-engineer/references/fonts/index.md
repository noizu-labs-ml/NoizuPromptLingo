# Font Reference Index

A reference library for web typography decisions. Files cover display, UI-specialty, and trending font families commonly considered for modern web and product design.

---

## Files in This Directory

### Sans-Serif (Geometric / Neo-Grotesque)

| File | Font | Classification | Tone Keywords | Adobe Fonts | Source |
|---|---|---|---|---|---|
| [dm-sans.md](dm-sans.md) | DM Sans | Low-contrast geometric sans | Neutral, functional, legible | Yes | Google Fonts |
| [general-sans.md](general-sans.md) | General Sans | Rationalist grotesque | Clean, versatile, orderly | No | Fontshare |
| [plus-jakarta-sans.md](plus-jakarta-sans.md) | Plus Jakarta Sans | Geometric humanist sans | Friendly, open, trustworthy | No | Google Fonts |
| [satoshi.md](satoshi.md) | Satoshi | Swiss modernist sans | Authoritative, modern, crisp | No | Fontshare |
| [switzer.md](switzer.md) | Switzer | Neo-grotesque (Swiss tradition) | Rational, precise, institutional | No | Fontshare |

### Sans-Serif (Display / Expressive)

| File | Font | Classification | Tone Keywords | Adobe Fonts | Source |
|---|---|---|---|---|---|
| [cabinet-grotesk.md](cabinet-grotesk.md) | Cabinet Grotesk | Contrast grotesque | Constructed, sophisticated, premium | No | Fontshare |
| [clash-display.md](clash-display.md) | Clash Display | Grotesque display | Bold, editorial, confident | No | Fontshare |
| [space-grotesk.md](space-grotesk.md) | Space Grotesk | Geometric display (mono-derived) | Techy, quirky, distinctive | Yes | Google Fonts |

### Sans-Serif (Paired System)

| File | Font | Classification | Tone Keywords | Adobe Fonts | Source |
|---|---|---|---|---|---|
| [instrument-sans-serif.md](instrument-sans-serif.md) | Instrument Sans + Serif | Variable sans + condensed display serif | Precise, elegant, editorial | No | Google Fonts |

### Serif (Variable Display)

| File | Font | Classification | Tone Keywords | Adobe Fonts | Source |
|---|---|---|---|---|---|
| [fraunces.md](fraunces.md) | Fraunces | Variable display serif (Old Style) | Warm, expressive, editorial | Yes | Google Fonts |

### Monospace

| File | Font | Classification | Tone Keywords | Adobe Fonts | Source |
|---|---|---|---|---|---|
| [jetbrains-mono.md](jetbrains-mono.md) | JetBrains Mono | Code monospace | Technical, precise, developer | Yes | Google Fonts |

---

## Quick-Reference: Adobe Fonts Availability

| Font | Adobe Fonts | Notes |
|---|---|---|
| DM Sans | Yes | Listed as "DM Sans" |
| Fraunces | Yes | Listed as "Fraunces Variable" |
| Space Grotesk | Yes | Listed as "Space Grotesk Variable" |
| JetBrains Mono | Yes | — |
| Satoshi | No | Fontshare only |
| General Sans | No | Fontshare only |
| Cabinet Grotesk | No | Fontshare only |
| Clash Display | No | Fontshare only |
| Switzer | No | Fontshare only |
| Plus Jakarta Sans | No | Google Fonts / self-hosted only |
| Instrument Sans | No | Google Fonts / self-hosted only |
| Instrument Serif | No | Google Fonts / self-hosted only |

---

## 2025–2026 Web Font Trends

### Variable Fonts Are Now Mandatory Best Practice

Variable fonts have graduated from technical curiosity to production requirement. A single `.woff2` variable file serves the entire weight/width/style range, eliminating multiple HTTP requests and reducing total font payload significantly. The impact on Core Web Vitals (LCP, CLS) is measurable. As of 2025, using static font files for a multi-weight stack is a considered anti-pattern in performance-conscious teams.

Key variable axes in active use:
- `wght` — weight range (nearly universal)
- `opsz` — optical size (DM Sans, Fraunces; auto-adjusts for body vs. display)
- `wdth` — width / condensed (Instrument Sans; enables typographic density without separate fonts)
- `SOFT`, `WONK` — custom axes (Fraunces; expressive quality not available elsewhere)

### The Shift Away from Google Fonts CDN

Self-hosted fonts are now used by over 71% of pages (HTTP Archive 2025). Exclusive self-hosting grew from ~30% in 2024 to ~34% in 2025. The primary driver: modern browser network state partitioning eliminates the cross-site caching benefit that originally justified third-party font CDNs. Loading `fonts.googleapis.com` now incurs the same cold-load penalty as a self-hosted font, but adds a third-party DNS lookup and potential privacy compliance surface (GDPR, EU court rulings on Google Fonts).

**Practical recommendation**: Download font files, subset to required languages with `pyftsubset` or Fontsource/NPM, serve from your own CDN. Use `font-display: swap` or `optional` depending on layout stability requirements.

### Adobe Fonts Occupies a Growing Niche

Adobe Fonts (~3.8% of desktop pages, up ~10% year-over-year) is the correct answer for Creative Cloud teams that need:
- Consistent font access across Illustrator, InDesign, Photoshop, and web
- Higher-quality commercial fonts without per-project licensing negotiations
- Automatic web font deployment from the Adobe CDN with Creative Cloud subscription

Adobe Fonts does not require GDPR-specific consent banners in most interpretations (processed under Adobe's DPA), unlike the Google Fonts CDN. For enterprise and agency workflows, this is a meaningful advantage.

### The Geometric Sans Saturation Problem

The 2020–2024 wave of Fontshare geometric sans fonts (Satoshi, Cabinet Grotesk, General Sans, Plus Jakarta Sans) has created market saturation. In startup and SaaS design, these fonts now signal "designed by a designer who uses Fontshare" rather than "considered typographic decision." 

Mitigation strategies:
- Use variable axes aggressively to create custom visual signatures within the font
- Pair geometric sans with an expressive serif (Fraunces, Cormorant, custom options) to elevate the overall system
- Consider licensed alternatives (GT America, Aktiv Grotesk, Matter, Neue Haas Grotesk) for premium brand work
- Self-host and subset to avoid the "Google Fonts in-browser indicator" in DevTools

### Expressive Serifs as Differentiators

Counter to the "everything is a geometric sans" trend, expressive serifs — particularly Fraunces and custom display serifs — are increasingly used as brand differentiators by teams that want to signal craft and editorial quality. The four-axis Fraunces represents the current technical frontier for free display typography.

### Performance Subsetting

For any font with broad language support loaded in a Latin-only context, subsetting is essential:

```bash
# Install fonttools
pip install fonttools brotli

# Subset to Latin + Latin Extended
pyftsubset font.woff2 \
  --unicodes="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD" \
  --flavor=woff2 \
  --output-file=font.latin.woff2
```

Typical savings: 60–80% reduction in file size for fonts with extended language coverage.

### Recommended Font Loading Pattern (2025+)

```html
<!-- 1. Preconnect to font origin if using CDN -->
<link rel="preconnect" href="https://your-cdn.com" crossorigin>

<!-- 2. Preload critical display font -->
<link rel="preload" href="/fonts/YourFont-Variable.woff2" 
      as="font" type="font/woff2" crossorigin>
```

```css
/* 3. Declare with font-display: swap for body; optional for non-critical */
@font-face {
  font-family: 'YourFont';
  src: url('/fonts/YourFont-Variable.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;  /* or 'optional' for strict CLS control */
}
```

---

## Common Pairing Patterns

| Use Case | Display | Body | Mono |
|---|---|---|---|
| Tech / SaaS | Space Grotesk | DM Sans or Satoshi | JetBrains Mono |
| Consumer startup | Plus Jakarta Sans | DM Sans | — |
| Editorial / media | Fraunces (italic) | General Sans or Switzer | — |
| Agency / creative | Clash Display | Satoshi | JetBrains Mono |
| Brand / premium | Instrument Serif | Instrument Sans | — |
| Swiss / institutional | Switzer Black | Switzer Regular | — |
| Expressive brand | Fraunces | Space Grotesk | JetBrains Mono |
| Full ITF system | Clash Display | Satoshi | — |
