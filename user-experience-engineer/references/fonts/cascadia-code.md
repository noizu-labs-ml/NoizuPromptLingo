---
name: "Cascadia Code"
slug: cascadia-code
category: monospace
designer: "Aaron Bell"
foundry: "Microsoft"
year: 2019
adobe_fonts: false
google_fonts: false
open_source: true
license: "OFL"
classification: "coding-mono"
tone:
  - modern
  - approachable
  - cross-platform
use_cases:
  - windows-terminal
  - vs-code
  - powershell
  - cli-tools
notable_users:
  - Windows Terminal
  - VS Code
  - Azure DevOps
---

# Cascadia Code

## Identity

| Field | Value |
|-------|-------|
| **Name** | Cascadia Code |
| **Designer** | Aaron Bell (Saja Typeworks) |
| **Foundry** | Microsoft |
| **Year** | 2019; major 2024 update (2404.03) |
| **Classification** | Coding Mono / Terminal Mono |
| **License** | SIL Open Font License 1.1 (free) |

## Availability

- **Adobe Fonts** — no
- **Google Fonts** — no
- **Direct download** — [github.com/microsoft/cascadia-code](https://github.com/microsoft/cascadia-code); also bundled with Windows Terminal and VS Code

## Character

Cascadia Code is Microsoft's contribution to the coding font landscape — practical, well-made, and tightly integrated into the Windows developer ecosystem. It was designed from the ground up for Windows Terminal and VS Code, with a character that sits between friendly and professional. The letterforms are slightly rounded with humanist touches that soften the mechanical precision of older terminal fonts, making long sessions less fatiguing. It has more warmth than Consolas (which it was designed to complement and eventually succeed) while remaining clearly in the "engineering tool" category. Cascadia Code communicates: modern Windows development, cross-platform tooling, and Microsoft's renewed investment in developer experience. The cursive italic option gives it a secondary personality closer to Operator Mono for those who want it.

## Ligatures

Full coding ligature support in the "Code" variants (non-ligature "Mono" variants also ship):

- Equality: `==`, `===`, `!=`, `!==`, `:=`
- Arrows: `->`, `=>`, `-->`, `<-`, `<=>`
- Comparisons: `>=`, `<=`, `<>`, `>>`, `<<`
- Functional: `|>`, `<|`, `::`
- Stylistic sets for italic cursor alternates and additional glyph variants

Variants in the distribution:
- `Cascadia Code` — full ligatures
- `Cascadia Mono` — no ligatures
- `Cascadia Code NF` — with full Nerd Fonts glyph set (9209 glyphs, as of 2024)
- `Cascadia Mono NF` — no ligatures + Nerd Fonts

The 2024 release added 1140 new glyphs including legacy computing symbols, making it one of the most complete coding fonts for terminal use.

## Best Use Cases

- Windows Terminal (the native home; ships bundled)
- VS Code (bundled, frequently set as default)
- PowerShell and CMD sessions with a modern font
- Cross-platform CLI tools targeting Windows developer audiences
- Terminals with powerline prompts and icon-heavy shells (via NF variant)
- Developer documentation on Microsoft-centric platforms

## Tone / Mood

Modern, approachable, cross-platform pragmatic. Signals a developer working in the Microsoft ecosystem who has upgraded beyond Consolas. The cursive italic option adds personality for those who want it. Not as opinionated as Operator Mono; not as purely engineered as JetBrains Mono — a friendly middle ground.

## Demographics

- Windows developers (primary audience)
- VS Code users (Cascadia Code ships with VS Code)
- PowerShell users and DevOps engineers on Windows
- .NET, Azure, and Microsoft toolchain developers
- Developers who want Nerd Fonts compatibility without a separate download

## Notable Users / Defaults

- Default font in Windows Terminal
- Bundled with VS Code (available in settings without install)
- Used in Microsoft developer documentation and tutorials
- Adopted by Azure portal and Azure DevOps for code display

## Pairing Recommendations

| Role | Recommended Pairing |
|------|---------------------|
| Body prose | Segoe UI Variable, Inter |
| UI chrome | Segoe UI Variable (Microsoft's native stack) |
| Display heading | Segoe UI Display, Inter |
| Docs site | Segoe UI Variable + Cascadia Code (the native Windows stack) |

## Strengths

- Ships with Windows Terminal and VS Code — zero installation friction on Windows
- Nerd Fonts variant (NF) bundles all 9209 icon glyphs natively (2024+)
- 1140 legacy computing symbols added in 2024 (sextants, octants, segmented digits)
- Cursive italic option for those who want Operator Mono-style italics
- `Code` and `Mono` variants for ligature preference
- Actively maintained by Microsoft with regular releases

## Weaknesses

- Not on Google Fonts or Adobe Fonts — manual install needed outside Windows/VS Code
- Less expressive character than Berkeley Mono or Operator Mono for aesthetic-focused use
- The Microsoft association may feel out of place in non-Windows contexts
- Variable font capabilities are more limited than Iosevka or Berkeley Mono v2
- Character differentiation, while good, is not exceptional

## Distinguishing Features

- `0` — slashed zero
- `1` — flat top with base serif; clear distinction from `l`
- `l` — curved tail
- `I` — serifs top and bottom
- Cursive italic (`PL` / italic weight): genuine alternate letterforms for `f`, `k`, `y`, `z` — not just slanted roman
- Legacy computing symbols (box drawing, Braille, segmented displays) are the most complete of any font in this survey

## CSS Snippet

```css
font-family: 'Cascadia Code', 'Cascadia Mono', 'JetBrains Mono', ui-monospace,
             'Consolas', 'SF Mono', 'Menlo', monospace;
font-feature-settings: 'liga' 1, 'calt' 1;
/* For cursive italics (stylistic set 1): */
/* font-feature-settings: 'liga' 1, 'calt' 1, 'ss01' 1; */
```
