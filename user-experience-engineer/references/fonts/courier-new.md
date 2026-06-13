---
name: "Courier New"
slug: courier-new
category: core
designer: "Howard Kettler"
foundry: "Monotype"
year: 1955
adobe_fonts: false
google_fonts: false
open_source: false
license: "commercial"
classification: "slab"
tone:
  - mechanical
  - retro
  - authoritative
use_cases:
  - code-blocks
  - screenplays
  - legal-documents
  - terminal-evocation
notable_users:
  - US State Department
---

# Courier New

## Overview

| Field | Detail |
|-------|--------|
| **Designer** | Howard "Bud" Kettler (original Courier, 1955); Adrian Frutiger (Selectric redesign); Courier New digitized by Monotype |
| **Foundry/Source** | IBM (original); Monotype (Courier New digital variant) |
| **Year** | 1955 (Courier); Courier New shipped with Windows 3.1 (1992) |
| **Classification** | Monospaced slab-serif (typewriter face) |
| **Availability** | Bundled with all Windows versions; macOS; universal web-safe; public domain design (IBM never trademarked "Courier") |

## Character

Courier New embodies the deliberate aesthetics of mechanical constraint. Every character occupies the same fixed width — a technical necessity of typewriter mechanics that became a visual language associated with drafts, code, authenticity, and the pre-digital document. Its slab serifs and even stroke weight evoke the ink ribbon impression of a Selectric typewriter. In contemporary contexts it reads simultaneously as retro and authoritative: the font of legal disclaimers, screenplay formatting, and source code.

## Best Use Cases

- Code and monospaced text blocks
- Screenplay formatting (industry standard at 12pt)
- Legal documents and contracts (traditional manuscript format)
- Terminal/command-line UI evocation in design
- Any context where equal-width characters are functionally required (tables, alignment)

## Tone / Mood

Mechanical, authentic, retro, authoritative. Evokes drafts, typewriters, unvarnished truth, and technical precision.

## Demographics

Developers (legacy; now largely replaced by coding-specific fonts), screenwriters, lawyers, academics submitting manuscripts. Appears in publishing submissions, film scripts, and any workflow inherited from the typewriter era.

## Notable Users

Hollywood screenwriting (Courier 12pt is the standard that defines a page-per-minute of screen time), legal contracts, manuscript submission guidelines from major publishers, early terminal interfaces. The US State Department used Courier New as its official font for diplomatic cables for decades (switched to Times New Roman in 2004).

## Pairing Recommendations

- **For editorial contrast:** Pair with a clean grotesque headline (Helvetica, Arial) to ground the retro mono in modernity
- **For code documentation:** Use as inline code within Georgia or system-ui body text
- **Modern alternative:** Fira Code, JetBrains Mono, or Source Code Pro for actual development contexts
- **Avoid:** Using as body text in any modern design context — spacing and width are punishing

## Strengths

- Universal availability — guaranteed on every OS
- Fixed-width metrics enable exact text alignment
- Strong cultural associations with drafts and unpolished authenticity
- Readable at 12pt in print, especially with generous line spacing

## Weaknesses

- Very poor screen rendering at small sizes — thin strokes disappear
- Excessively wide horizontal metrics for most modern use cases
- No ligatures, OpenType features, or language coverage beyond Latin
- "Default typewriter" aesthetic communicates lack of design intention in most contexts

## History and Context

Howard Kettler designed Courier for IBM's typewriter division in 1955, nearly naming it "Messenger" before settling on "Courier" for its connotations of dignity and reliability. IBM deliberately chose not to trademark the design, allowing every typewriter manufacturer to adopt it — cementing its status as the universal typewriter face. Adrian Frutiger later redesigned it for the IBM Selectric's interchangeable typeball mechanism. The digital version (Courier New) was digitized by Monotype for Microsoft and shipped with Windows 3.1 in 1992. The US State Department's 2004 abandonment of Courier New for Times New Roman made international news, measuring the cultural weight still attached to this humble typewriter face.

## CSS

```css
font-family: "Courier New", Courier, monospace;
```
