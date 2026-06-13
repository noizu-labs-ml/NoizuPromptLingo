# Hover Preview Popover

| Field | Value |
|-------|-------|
| **ID** | `hover-preview-popover` |
| **Category** | Overlays / Navigation |
| **Used In** | S06 Canon Entry Detail, S08 Knowledge Graph, S10 Search Results |

## Description

Floating card that appears on hover over entry links or graph nodes, giving a quick summary of the referenced canon entry without requiring navigation. Shows the entry type icon, title, type label, a truncated excerpt (2–3 lines), and an "Open" action button. Positioned dynamically to avoid viewport edges. Dismissed on mouse leave or focus loss.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Type icon + title + 2-line excerpt + "Open" link; ~280px wide; default |
| **Expanded** | Compact content + tags + last-modified date + relationship count; ~360px wide; used in graph nodes on click-hover |

## Props / Configuration

- `entryId` — String; used to fetch preview data if not pre-loaded
- `entryTitle` — String; entry title
- `entryType` — Entry type key for icon and color
- `excerpt` — String; truncated body text; component trims to ~160 characters
- `tags` — String array; shown in expanded variant
- `lastModified` — ISO date; shown in expanded variant
- `relationshipCount` — Number; count of linked entries; shown in expanded variant
- `href` — URL for the "Open" action
- `size` — `compact | expanded`
- `anchor` — Ref or coordinates of the triggering element; used for positioning

## Interactions

- Appears after a 300ms hover delay on the trigger element to prevent accidental flicker
- 150ms grace period on mouse leave before dismiss; allows cursor to move into the popover
- "Open" button navigates to entry detail; also accessible via keyboard Tab within popover
- Popover is keyboard-reachable: Tab from the trigger link moves focus into the popover
- Escape key dismisses the popover and returns focus to the trigger
- Renders via a portal to avoid z-index stacking issues within prose containers
