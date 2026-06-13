# Entry Card

| Field | Value |
|-------|-------|
| **ID** | `entry-card` |
| **Category** | Forms |
| **Used In** | S04 Canon List, S07 Search Results, S03 Universe Overview (Recent Activity), S06 Knowledge Graph (node popover), S08 Suggested Connections |

## Description

Content card representing a single canon entry. Displays the entry type icon, name, status badge, associated tags, a short excerpt of the entry body, and a last-edited timestamp. Used in list rows within the split-panel layout and as standalone cards in search results.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-row list item with icon, name, status badge, and timestamp; used inside split-panel left column |
| **Compact** | Two-line card with excerpt truncated to one line; used in search result lists |
| **Expanded** | Full card with multi-line excerpt, tag chips, and last-edited metadata; used in grid or standalone results |

## Props / Configuration

- `entry` — Entry data object: `{ id, name, type, status, tags, excerpt, lastEditedAt, lastEditedBy }`
- `selected` — Boolean; highlights card as the active selection in a split-panel list
- `onClick` — Callback fired when the card is clicked
- `onTagClick` — Callback fired with a tag string when a tag chip is clicked (applies filter)
- `showExcerpt` — Boolean; controls excerpt visibility (default: `true` in expanded, `false` in inline)
- `showTags` — Boolean; controls tag chip visibility (default: `true` in expanded)
- `showLastEdited` — Boolean; controls timestamp visibility (default: `true`)
- `variant` — `inline` | `compact` | `expanded`

## Interactions

- Clicking the card fires `onClick` and, in a split-panel context, loads the entry detail in the right panel
- Clicking a tag chip fires `onTagClick` with the tag value to filter the parent list
- Status badge uses the `status-badge` component; color maps to entry status
- Type icon is a small colored icon from the entry type system (Character, Location, Event, etc.)
- Hovering reveals a quick-action icon row (Edit, Link, Delete) at the trailing edge; accessible via keyboard with `Tab` inside the card
- Long names are truncated with an ellipsis; full name shown in a tooltip on hover
