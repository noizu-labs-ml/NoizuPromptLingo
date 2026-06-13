---
name: "Georgia"
slug: georgia
category: core
designer: "Matthew Carter"
foundry: "Microsoft Corporation"
year: 1993
adobe_fonts: false
google_fonts: false
open_source: false
license: "commercial"
classification: "old-style"
tone:
  - warm
  - intellectual
  - editorial
use_cases:
  - long-form-reading
  - body-text
  - email-newsletters
  - digital-books
notable_users:
  - The New York Times
  - The Washington Post
  - Wikipedia
---

# Georgia

## Overview

| Field | Detail |
|-------|--------|
| **Designer** | Matthew Carter; hinting by Thomas Rickner |
| **Foundry/Source** | Microsoft Corporation |
| **Year** | 1993 (designed); 1996 (released via Core Fonts for the Web) |
| **Classification** | Old-style serif, screen-optimized |
| **Availability** | Bundled with Windows, macOS; part of Microsoft's Core Fonts for the Web (1996); universal web-safe |

## Character

Georgia is an old-style serif engineered from the pixel up for screen legibility — the rare case of a typeface designed specifically for digital display before web design existed as a profession. It has a large x-height, open counters, generous letter spacing, and reduced stroke contrast compared to Times New Roman, all deliberately chosen to maintain clarity at 72–96 DPI. Despite its screen origins, it carries genuine warmth and elegance, evoking 19th-century Scotch Roman designs rather than newspaper efficiency.

## Best Use Cases

- Long-form web reading (editorial, blog, news articles)
- Body text on content-heavy websites
- Email newsletters and HTML emails
- Digital books and reading interfaces
- Anywhere Times New Roman is needed but screen legibility matters

## Tone / Mood

Warm, intellectual, editorial, trustworthy. More approachable than Times New Roman, more traditional than a humanist sans-serif.

## Demographics

Journalists, bloggers, editorial designers, news sites. The backbone font of the early-to-mid web publishing era (2000–2015). Readers who associate it with quality long-form content.

## Notable Users

The New York Times (replaced Times New Roman for digital in 2007), The Washington Post, The Guardian, countless blogs and news sites during the 2000s, Apple's Notes app (in early versions), Wikipedia (long-time default serif), many email clients.

## Pairing Recommendations

- **With sans-serifs:** Verdana (complementary Carter design), Arial, or system-ui for headings
- **For editorial contrast:** Pair with a condensed grotesque (Franklin Gothic, Impact) for headlines
- **Modern pairings:** Lato or Open Sans for digital-first editorial
- **Avoid:** Mixing with other screen-optimized serifs (Merriweather, Lora) — too similar in purpose

## Strengths

- Purpose-built screen legibility — outstanding at 12–18px
- Warm character distinguishes it from cold newspaper serifs
- Universal availability — zero download cost
- Exceptionally well-hinted at key body-text sizes

## Weaknesses

- At high resolutions (Retina, 4K) the pixel-level hinting optimizations become less relevant and sharper serifs compete more favorably
- Heavier stroke weight can feel dense in light UI contexts
- Strong associations with 2000s-era web make it feel dated in some contexts

## History and Context

Virginia Howlett of Microsoft's Typography group commissioned Matthew Carter in 1993 to create a serif companion to Verdana. Carter drew inspiration from Scotch Roman designs of the 19th century but rebuilt each letterform around the binary pixel grid of mid-1990s monitors. Thomas Rickner's pixel-level hinting ensured each glyph at critical sizes mapped cleanly to screen pixels. Released November 1, 1996, as part of Core Fonts for the Web. For over a decade it was the default serif of the internet. The New York Times' 2007 switch from Times New Roman to Georgia for digital was a landmark moment, validating screen-first typography as a serious discipline.

## CSS

```css
font-family: Georgia, "Times New Roman", Times, serif;
```
