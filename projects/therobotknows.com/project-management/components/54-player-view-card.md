# Player View Card

| Field | Value |
|-------|-------|
| **ID** | `player-view-card` |
| **Category** | Entry Display |
| **Used In** | S-19 Player-Facing View, S-20 Reader Codex |

## Description

Read-only entry card that renders only player-visible content, suppressing all sections, fields, and blocks marked as GM-only or spoiler-flagged. Presents a clean, narrative-friendly layout suitable for sharing with players or publishing publicly.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Title, type icon, and visible summary only — used in list/grid views within the reader codex |
| **Expanded** | Full visible content including sections, tags, and relationships that have player visibility — used on the entry detail page |

## Props / Configuration

- `entryId` — ID of the canon entry to render
- `entryData` — Full entry data object; component filters fields client-side based on visibility flags
- `visibilityLevel` — `"player"` | `"public"` — determines which content tiers are shown
- `showRelationships` — Boolean; renders the visible relationship list when true (default: true)
- `showTags` — Boolean; renders tags that are not marked GM-only (default: true)
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `readingMode` — Boolean; applies larger font, wider line-height, and removes UI chrome for immersive reading

## Interactions

- GM-only sections are completely absent from the DOM — not hidden with CSS — to prevent source inspection leaks
- Spoiler-flagged content blocks are replaced with a `[Spoiler Hidden]` placeholder; no reveal affordance
- Relationships list shows only entries where both the relationship and the linked entry have player-visible status
- Read-only; no edit, delete, or status-change controls are rendered
- Clicking a relationship chip in expanded variant navigates to the linked entry's player view card
- Reading mode toggle (available in the reader codex toolbar) applies globally to all player view cards on screen
- Print stylesheet renders the expanded variant cleanly without sidebar or navigation chrome
