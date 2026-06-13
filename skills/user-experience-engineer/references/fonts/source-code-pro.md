---
name: "Source Code Pro"
slug: source-code-pro
category: monospace
designer: "Paul D. Hunt"
foundry: "Adobe Systems"
year: 2012
adobe_fonts: true
google_fonts: true
open_source: true
license: "OFL"
classification: "coding-mono"
tone:
  - neutral
  - professional
  - institutional
use_cases:
  - design-system-documentation
  - api-documentation
  - code-samples
  - ide-configurations
notable_users:
  - Atom
  - Adobe
---

# Source Code Pro

## Identity

| Field | Value |
|-------|-------|
| **Name** | Source Code Pro |
| **Designer** | Paul D. Hunt |
| **Foundry** | Adobe Systems |
| **Year** | 2012; variable font version 2018 |
| **Classification** | Coding Mono — neutral sans |
| **License** | SIL Open Font License 1.1 (free) |

## Availability

- **Adobe Fonts** — yes, included with Creative Cloud subscriptions
- **Google Fonts** — yes, free
- **Direct download** — [github.com/adobe-fonts/source-code-pro](https://github.com/adobe-fonts/source-code-pro)

## Character

Source Code Pro is the stalwart of the Adobe type ecosystem — clean, conservative, and deliberately unassuming. It was designed to complement Source Sans Pro (Adobe's UI and prose typeface), making it the natural mono counterpart in unified design systems. The letterforms are geometric sans-serif with careful attention to UI legibility rather than coding expressiveness. It does not have a strong personality; that is intentional. Source Code Pro signals professionalism, stability, and institutional trust. It feels at home in technical documentation, API references, and design system codebases. It is the font of a well-run engineering organization.

## Ligatures

Limited. Source Code Pro does not prioritize programming ligatures. What it does provide:

- `fi` and `fl` typographic ligatures (enabled via `liga`)
- No coding operator ligatures by default
- Alternates for `l` (lowercase L) and `1` via character variants (`cv` features)
- Powerline symbols included in the distribution

For a ligature-forward experience, this is not the right choice. For purity and unambiguous operator rendering, this is a strength.

## Best Use Cases

- Design system documentation where the mono must match a Source Sans Pro body
- Technical reference docs and API documentation
- Code samples in marketing materials and developer portals
- IDE configurations in Creative Cloud-centric organizations
- Situations where a neutral, non-opinionated mono is required

## Tone / Mood

Neutral, professional, institutional. Adobe's aesthetic DNA — clean lines, careful spacing, zero personality. Conveys reliability over excitement. Appropriate for enterprise documentation and formal technical publications.

## Demographics

- Adobe Creative Cloud users and designers using Adobe Fonts
- Technical writers and documentation teams
- Design systems practitioners working with the Source superfamily
- macOS users who encounter it as a bundled system option via Adobe

## Notable Users / Defaults

- Atom text editor (was the default coding font)
- Many Adobe product documentation sites
- Various GitHub README badges and documentation themes
- Frequently used in academic and technical writing templates

## Pairing Recommendations

| Role | Recommended Pairing |
|------|---------------------|
| Body prose | Source Sans Pro, Source Serif Pro |
| UI chrome | Source Sans Pro |
| Display heading | Source Sans Pro (the full Source superfamily coheres well) |
| Docs site | Source Sans Pro + Source Code Pro (Adobe's native stack) |

## Strengths

- Perfect family cohesion with Source Sans Pro and Source Serif Pro
- Available on both Adobe Fonts and Google Fonts — maximum design system flexibility
- 7 weights + variable font axes (weight, italic) — comprehensive range
- Extremely neutral; does not impose a style on surrounding text
- TrueType hinting quality is excellent at small sizes
- Well-tested in print and screen contexts

## Weaknesses

- No coding ligatures — may feel underpowered next to Fira Code or JetBrains Mono
- The neutrality can read as bland in developer tools where personality matters
- Less distinctive character differentiation than purpose-built coding fonts
- Less active development than JetBrains Mono or Iosevka
- The 2012 design shows its age compared to newer entries

## Distinguishing Features

- `0` — dotted zero (distinguishes from `O` without slash)
- `1` — flat top with base serif; less distinctive at a glance than JetBrains Mono's `1`
- `l` — curved with a rounded bottom; distinguishable but subtle
- `I` — serifs on top and bottom
- Overall: character differentiation is adequate, not exceptional

## CSS Snippet

```css
font-family: 'Source Code Pro', 'JetBrains Mono', ui-monospace,
             'SF Mono', 'Menlo', 'Consolas', 'Liberation Mono', monospace;
font-feature-settings: 'liga' 1, 'calt' 1;
```
