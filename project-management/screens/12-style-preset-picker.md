# Style Preset Picker

| Field | Value |
|-------|-------|
| **ID** | `style-preset-picker` |
| **Type** | Primary |
| **Category** | Draft Phase |
| **User Stories** | INK-021, INK-022 |

## Description

First step of Draft phase. AI recommends a style preset based on the pitch/PRD, or user manually browses a gallery of 6 presets. Each preset shows live preview swatches.

## Key Components

- **AI Recommendation Panel** — Ranked preset list with rationale per recommendation (INK-021)
- **Preset Gallery** — 6 cards (Minimal Tech, Corporate Enterprise, Consumer Playful, Editorial, Bold Expressive, Nocturne) with live swatches, type samples, spacing rhythm (INK-022)
- **Preview Panel** — Full preview of selected preset's visual system (INK-022)

## Interactions

- AI recommendation highlighted at top with one-click accept
- Gallery cards are selectable; clicking shows full preview
- "Accept" on any preset advances to Color Palette Editor
- "Browse All" expands from AI recommendation to full gallery

## Navigation

- Accessible from: PRD Editor "Complete Sketch", Dashboard "Continue" on Draft:Style project
- Links to: Color Palette Editor
