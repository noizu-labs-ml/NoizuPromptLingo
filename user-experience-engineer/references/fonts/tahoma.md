---
name: "Tahoma"
slug: tahoma
category: core
designer: "Matthew Carter"
foundry: "Microsoft Corporation"
year: 1994
adobe_fonts: false
google_fonts: false
open_source: false
license: "commercial"
classification: "humanist"
tone:
  - efficient
  - professional
  - compact
use_cases:
  - desktop-ui
  - compact-navigation
  - dense-ui-components
  - legacy-windows-apps
notable_users:
  - Windows XP
  - Yahoo
---

# Tahoma

## Overview

| Field | Detail |
|-------|--------|
| **Designer** | Matthew Carter |
| **Foundry/Source** | Microsoft Corporation |
| **Year** | 1994 (designed); 1995 (released with Windows 95) |
| **Classification** | Humanist sans-serif (narrow variant) |
| **Availability** | Bundled with Windows 95 and later; Office; macOS (limited); web-safe on Windows |

## Character

Tahoma is Verdana's more disciplined sibling — same humanist DNA, considerably less horizontal sprawl. Where Verdana was engineered to maximize legibility through generous spacing and wide characters, Tahoma tightened those proportions for UI efficiency: smaller counters, tighter letter spacing, narrower overall width. The result is a typeface that performs well in dense interface environments — menus, dialogs, toolbars — without sacrificing the screen-legibility principles Carter brought to all his Microsoft work.

## Best Use Cases

- Desktop UI text (historically; Windows 2000/XP default)
- Compact navigation and labels
- Dense UI components (data tables, form labels)
- System interfaces requiring Unicode coverage
- Legacy Windows application styling

## Tone / Mood

Efficient, professional, compact, workmanlike. Neither warm nor cold — purely functional.

## Demographics

Windows users from the 2000s. Corporate desktop application users. Any interface designed for Windows 2000, XP, or Server 2003, where Tahoma was the default UI font. IT professionals who still encounter it in enterprise software.

## Notable Users

Windows 2000, Windows XP, Windows Server 2003 (default UI font for all three), many enterprise Windows applications, Microsoft Office dialogs. Yahoo used Tahoma as its primary typeface for many years.

## Pairing Recommendations

- **As UI font:** Pairs with Times New Roman or Georgia for document content within applications
- **Modern equivalent:** Segoe UI (Windows Vista+) replaced it for system UI; use Segoe UI or system-ui instead in modern contexts
- **For historical accuracy:** Pair with the Windows XP era color palette when recreating that aesthetic
- **Alternative:** Verdana for more open spacing; Calibri for document body

## Strengths

- Excellent Unicode coverage for its era — broader than Verdana
- Narrow metrics save horizontal space compared to Verdana
- Clean rendering in Windows GDI contexts
- Well-hinted for ClearType rendering

## Weaknesses

- Not bundled on macOS by default — requires separate installation or relies on Arial fallback
- Overshadowed by Segoe UI on modern Windows
- Limited typographic personality — purely functional
- Tighter spacing reduces readability in long-form text compared to Verdana

## History and Context

Matthew Carter designed Tahoma concurrently with Verdana in 1994, initially as a narrower companion face for Windows 95. The name is derived from a Native American word for Mount Rainier. Microsoft shipped it as the default UI font for Windows 95 and then promoted it to the primary system font for Windows 2000 and Windows XP, where it appeared in every title bar, menu, dialog, and tooltip. For millions of users from 2001–2007, Tahoma was the visual texture of their computer interface. Windows Vista replaced it with Segoe UI, beginning Tahoma's gradual fade from the default stack. Its legacy is primarily in the enterprise software that was designed for Windows XP and never visually updated.

## CSS

```css
/* Windows-primary; use system-ui for cross-platform equivalence */
font-family: Tahoma, Geneva, Verdana, sans-serif;
```
