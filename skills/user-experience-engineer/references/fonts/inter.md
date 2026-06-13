---
name: "Inter"
slug: inter
category: sans-serif
designer: "Rasmus Andersson"
foundry: "Independent (open-source)"
year: 2017
adobe_fonts: true
google_fonts: false
open_source: true
license: "OFL"
classification: "neo-grotesque"
tone:
  - neutral
  - clinical
  - trustworthy
use_cases:
  - ui
  - dashboards
  - body-text
  - developer-tools
  - design-systems
notable_users:
  - Figma
  - GitHub
  - Linear
  - Mozilla
  - Unity
  - Vercel
  - Notion
---

# Inter

## Identity

| Field | Detail |
|---|---|
| **Designer** | Rasmus Andersson |
| **Foundry** | Independent (open-source) |
| **Year** | 2017 (v1.0); v4.0 with variable font 2023 |
| **Classification** | Neo-grotesque |
| **Adobe Fonts** | Yes — included with Creative Cloud; 54 styles for sync and web use |

---

## Character

Inter is the closest thing the web has to an invisible typeface. It does not announce itself. It does not have opinions about your brand. It was designed for one purpose — to disappear at small sizes on glowing screens — and it executes that purpose with the discipline of a Swiss engineer.

Its x-height is tall, almost aggressively so. Apertures are wide and open. Letterforms are tightly optimized: the lowercase `l`, `1`, and capital `I` are all disambiguated (with slashed zero as an OpenType feature), making it unusually legible in dense UI contexts. The tail on the `a` is functional rather than expressive. Nothing about the letter shapes is trying to charm you.

At display sizes Inter can feel slightly mechanical — the same rationalism that makes it sharp at 12px reads as cold at 48px. This is a font that works for applications, not magazine spreads.

---

## Best Use Cases

- **UI / Product interfaces** — its primary purpose; excellent for labels, inputs, navigation, data tables
- **Developer tooling** — code documentation, dashboards, terminal-adjacent UIs
- **Design systems** — legible at every weight from extralight to black, consistent rhythm
- **Small-print legal / settings text** — open counters survive aggressive compression
- **Data display** — tabular numerals available; works in dense grids

Avoid for: luxury branding, expressive editorial headers, print work above headline size.

---

## Tone / Mood

Neutral. Clinical. Trustworthy. The visual equivalent of "sensible defaults." It reads as competent and invisible — which in UI design is the highest praise.

---

## Demographics & Industries

Inter has essentially colonized developer-first SaaS. If a startup was founded after 2019 and raised a Series A, there is a reasonable chance their product UI uses Inter. It is the default choice when a team has no dedicated typographer and needs something that won't embarrass them.

**Industries:** SaaS, developer tools, fintech, productivity, open-source projects, government digital services.

---

## Notable Users

- **Figma** — used Inter as its UI font (partially designed alongside it); Figma's blog documents the relationship
- **GitHub** — brand and interface typography
- **Linear** — flagship product UI
- **Mozilla** — brand identity
- **Unity** — brand and UI
- **Vercel** — product UI and promoted as default in Next.js `next/font`
- **Notion** — interface typeface
- **GitLab**, **NASA**, **ISO** — web presence
- **elementary OS** — system UI font

---

## Pairing Recommendations

| Partner | Role | Notes |
|---|---|---|
| **Fraunces** | Display / hero serif | High contrast with Inter's austerity |
| **Source Serif 4** | Body serif | Open-source sibling energy; Adobe Fonts |
| **Geist Mono** | Code / monospace | Shares the developer-tool aesthetic |
| **Playfair Display** | Editorial headers | Creates product + editorial hierarchy |
| **IBM Plex Serif** | Long-form text | Both designed for screens; cohesive |

---

## Strengths

- **Screen optimization** is unmatched at small sizes — tall x-height, open apertures, and disambiguated glyphs make it genuinely more legible than Helvetica or Roboto in UI contexts
- **Variable font axis** covers weight and optical size in one file
- **OpenType feature set** is unusually deep: slashed zero, tabular numerals, case-sensitive punctuation, old-style figures, contextual alternates
- **Language coverage** spans 140+ languages
- **Zero cost** — OFL license; no licensing negotiation ever
- **54 styles** — from Thin (100) to Black (900) with matching italics; every weight you will ever need exists

---

## Weaknesses

- **Personality vacuum** at display sizes — needs a strong partner to give a layout emotional texture
- **Overused** — in 2025, Inter is the "Helvetica of SaaS"; audiences can subconsciously read it as generic
- **Italic is mechanical** — drawn rather than calligraphic; loses expressiveness in long-form reading
- **No true condensed** — the compressed range is limited compared to Aktiv Grotesk's extended width axis

---

## Comparison to Similar Fonts

| Font | vs. Inter |
|---|---|
| **Roboto** | Roboto has slightly more humanist details (the bent-leg `k`, curved `R`); Inter is more systematically neutral. At equal sizes Inter wins on legibility metrics. |
| **IBM Plex Sans** | Plex carries more corporate character through its humanist underpinning — the open `g`, the angled cuts. Inter is more anonymous. Plex is better for brand; Inter is better for product UI. |
| **Neue Haas Grotesk** | NHG has the warmth and authority of its 1957 origins; it feels crafted rather than engineered. Inter is more mechanically consistent. NHG is better for prestige; Inter is better for scale. |

---

## CSS

```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
  'Helvetica Neue', Arial, sans-serif;
```

For variable font (preferred):
```css
font-family: 'Inter var', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
font-optical-sizing: auto;
```
