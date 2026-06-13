---
name: "JetBrains Mono"
slug: jetbrains-mono
category: monospace
designer: "Philipp Nurullin, Konstantin Bulenkov"
foundry: "JetBrains"
year: 2020
adobe_fonts: false
google_fonts: true
open_source: true
license: "OFL"
classification: "coding-mono"
tone:
  - professional
  - engineered
  - corporate
use_cases:
  - code-editors
  - terminal
  - documentation
  - data-tables
notable_users:
  - JetBrains IDEs
  - Replit
  - Gitpod
---

# JetBrains Mono

## Identity

| Field | Value |
|-------|-------|
| **Name** | JetBrains Mono |
| **Designer** | Philipp Nurullin, Konstantin Bulenkov |
| **Foundry** | JetBrains |
| **Year** | 2020 |
| **Classification** | Coding Mono |
| **License** | SIL Open Font License 1.1 (free) |

## Availability

- **Google Fonts** — yes, free
- **Adobe Fonts** — not in the standard Adobe Fonts library; install separately
- **Direct download** — [jetbrains.com/lp/mono](https://www.jetbrains.com/lp/mono/) and GitHub

## Character

JetBrains Mono projects authority without arrogance. Its letterforms are engineered rather than calligraphic — every design decision traces to a measurable reading-ergonomics rationale. The x-height is maximized so lowercase occupies the full cap-line range, meaning more visual information per pixel at small sizes. Letterforms are slightly condensed and tall, keeping line lengths predictable for developers accustomed to 80- or 120-character limits. The result reads as confident, purposeful, and slightly corporate — the font of a team that ships reliable software. It does not romanticize computing; it optimizes it.

## Ligatures

138 code-specific ligatures — among the most comprehensive sets of any coding font. All major operator sequences are covered:

- Equality: `==`, `===`, `!=`, `!==`
- Arrows: `->`, `=>`, `-->`, `<-`, `<=>`
- Comparisons: `>=`, `<=`, `<>`, `>>`
- Comments and punctuation: `//`, `/*`, `*/`, `/**`
- Functional: `|>`, `<|`, `::`

A `NL` (No Ligatures) variant ships for editors that cannot toggle OpenType features.

## Best Use Cases

- Primary coding font in any IDE or code editor
- Terminal emulators where character differentiation matters
- Documentation sites with inline code blocks
- Data tables with numeric columns (the tabular numerals are well-spaced)
- Agent output panels and CLI dashboards

## Tone / Mood

Professional, engineered, slightly corporate. Signals serious tooling rather than personal expression. Neutral enough to disappear while working.

## Demographics

- JetBrains IDE users (IntelliJ, PyCharm, WebStorm, GoLand, Rider — default in all)
- VS Code users seeking a first upgrade from the default font
- Developers who read JetBrains blog posts and tooling documentation

## Notable Users / Defaults

- Default font in all JetBrains IDEs
- Widely used in VS Code via settings
- Popular on Replit, Gitpod, and other cloud IDEs
- Frequently cited in "best coding fonts" lists in 2023–2026

## Pairing Recommendations

| Role | Recommended Pairing |
|------|---------------------|
| Body prose | Inter, JetBrains Sans |
| UI chrome | JetBrains Sans, IBM Plex Sans |
| Display heading | Anybody, Space Grotesk |
| Docs site | Inter + JetBrains Mono |

## Strengths

- Massive ligature set, well-tuned defaults
- 8 weights × 2 slants = 16 styles; covers any weight need
- Optimized x-height aids reading at 12–14 px
- Italic at 9° — subtle enough not to fight the roman
- Excellent hinting; renders well on Windows ClearType
- Completely free and open source

## Weaknesses

- Slightly tall letterforms can feel heavy in dense UIs
- The corporate origin can feel generic for personal projects
- Less distinctive than Berkeley Mono or Operator Mono if branding matters
- Not on Adobe Fonts (minor friction for Creative Cloud workflows)

## Distinguishing Features

- `0` — slashed zero by default
- `1` — flat top, serif on base; easily distinguished from `l` and `I`
- `l` — curved tail distinguishes it from `I`
- `I` — serifs on top and bottom
- `O` vs `0` — slash makes zero unambiguous
- Increased character height relative to width vs. competitors

## CSS Snippet

```css
font-family: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', ui-monospace,
             'SF Mono', 'Menlo', 'Consolas', 'Liberation Mono', monospace;
font-feature-settings: 'liga' 1, 'calt' 1;
```
