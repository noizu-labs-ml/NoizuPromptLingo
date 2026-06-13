---
name: "Iosevka"
slug: iosevka
category: monospace
designer: "Belleve Invis"
foundry: "Community / Individual"
year: 2015
adobe_fonts: false
google_fonts: false
open_source: true
license: "OFL"
classification: "coding-mono"
tone:
  - hacker
  - configurable
  - precise
use_cases:
  - power-user-editors
  - narrow-viewport-terminals
  - neovim
  - data-tables
notable_users: []
---

# Iosevka

## Identity

| Field | Value |
|-------|-------|
| **Name** | Iosevka |
| **Designer** | Belleve Invis (be5invis) |
| **Foundry** | Community / individual |
| **Year** | 2015; active development continues through 2025 |
| **Classification** | Coding Mono — configurable, narrow, build-from-source |
| **License** | SIL Open Font License 1.1 (free) |

## Availability

- **Adobe Fonts** — no
- **Google Fonts** — no (pre-built releases only via GitHub; no CDN)
- **Direct download** — [github.com/be5invis/Iosevka](https://github.com/be5invis/Iosevka) (releases), or build custom from source
- **Nerd Fonts** — yes, included in the Nerd Fonts collection

## Character

Iosevka occupies a unique position: it is the most configurable coding font in existence — generated from source code using a declarative build system that allows per-glyph variant selection. Want `a` to look like Consolas but `g` to look like Input Mono? Configure it. Want a zero with a dot? A zero with a slash? A reverse slash? Iosevka has all of them. The default letterforms are narrow and tall — significantly more condensed than JetBrains Mono — which makes Iosevka the preferred choice for developers who want more characters per line without reducing font size. Nineteen predefined stylistic sets mimic the aesthetics of popular fonts (Andale Mono, Consolas, Menlo, etc.) for developers who want Iosevka's rendering quality with a familiar glyph set.

## Ligatures

Ligations are supported in all monospace subfamilies and assigned to the `calt` feature. Iosevka's ligation system is itself configurable — the build system lets you specify exactly which ligatures to enable, disable, or remap. The default ligation set covers standard coding operators:

- Equality: `==`, `===`, `!=`, `!==`
- Arrows: `->`, `=>`, `<-`, `<=>`
- Comparisons: `>=`, `<=`, `>>`, `<<`
- Misc: `//`, `/*`, `*/`, `...`, `::`

Unlike other fonts, the ligature set is a variable in the build, not a fixed feature.

## Best Use Cases

- Power users who want precise control over every glyph variant
- Developers who work with narrow viewport constraints and want maximum character density
- Terminal emulators where a narrow font enables wider code views
- Neovim and Emacs users who configure every detail of their environment
- Data tables and log viewers where narrow pitch fits more columns
- Building a custom font variant for a developer product or design system

## Tone / Mood

Hacker, maximalist-configurability, precision-obsessed. Iosevka is the font for developers who configure everything. It does not have a strong aesthetic personality out of the box because its personality is that it has no fixed personality — it becomes whatever you configure it to be. The default builds are narrow, slightly cold, and precise.

## Demographics

- Neovim and Emacs users (heavy configuration community)
- Linux power users and tiling window manager devotees (i3, sway, Hyprland)
- Developers who build dotfiles as a hobby
- Haskell, Rust, and functional programming communities
- Developers working on small monitors or split-screen configurations who need narrow fonts

## Notable Users / Defaults

- Default font in no major product — this is a deliberate personal choice font
- Heavily represented in r/unixporn and similar aesthetic communities
- The Iosevka Comfy derivative (Protesilaos Stavrou) is used in the Modus themes for Emacs
- Available in most Nerd Fonts distributions

## Pairing Recommendations

| Role | Recommended Pairing |
|------|---------------------|
| Body prose | Inter, Noto Sans (neutral, to not fight Iosevka's neutral) |
| UI chrome | Inter, Roboto |
| Display heading | Space Grotesk, Sora |
| Docs site | Inter + Iosevka (clean, configurable, free stack) |

## Strengths

- Most customizable coding font in existence — 143 configurable characters, 19 stylistic sets
- Narrow default pitch maximizes character density
- Six monospace subfamilies (sans, slab) × three spacing variants (Default, Term, Fixed)
- Quasi-proportional variants (Aile, Etoile) extend the family to body text use
- Variable font with weight and slant axes
- SIL OFL — free forever, including custom builds

## Weaknesses

- The build-from-source customization workflow has a steep learning curve
- No Google Fonts or Adobe Fonts distribution — manual install or build
- The narrow default may be too condensed for some users without adjustment
- Weak brand identity — it is the font that has no look until you give it one
- Character differentiation depends heavily on which variant choices you make

## Distinguishing Features

- Uniquely configurable `0` — slashed, dotted, reversed, hollow, and more
- `l` — can be configured to have a serif, a curve, a hook, or resemble other fonts
- `I` — variants with serifs, without serifs, with top serifs only
- `1` — multiple variants (serif, no serif, curved)
- The narrow default spacing is Iosevka's most immediately recognizable property
- Stylistic set `ss01` mimics Andale Mono, `ss03` mimics Consolas, `ss09` mimics Source Code Pro

## CSS Snippet

```css
/* Pre-built release variant (e.g. Iosevka Term) */
font-family: 'Iosevka', 'Iosevka Term', 'JetBrains Mono', ui-monospace,
             'SF Mono', 'Menlo', 'Consolas', monospace;
font-feature-settings: 'liga' 1, 'calt' 1;
/* Variable font axes */
/* font-variation-settings: 'wght' 400; */
```
