# Inline Entry Link

| Field | Value |
|-------|-------|
| **ID** | `inline-entry-link` |
| **Category** | Rich Text / Navigation |
| **Used In** | S06 Canon Entry Detail, S14 Session Log, S11 Generation Results |

## Description

Clickable inline reference to another canon entry embedded within rich text prose. Rendered as styled anchor text with a subtle entry-type color underline and a type icon prefix. Hovering triggers the Hover Preview Popover (component 37). Clicking navigates to the entry detail page. Auto-detected from `[[Entry Name]]` wiki-link syntax in the rich text editor, or manually inserted via the editor toolbar.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon + linked text within prose flow; the only applicable variant |

## Props / Configuration

- `entryId` — String; the referenced canon entry's ID
- `entryTitle` — String; display text for the link (may differ from canonical title if aliased)
- `entryType` — Entry type key; used to determine icon and underline color
- `href` — URL to the entry detail page
- `previewEnabled` — Boolean; when false suppresses the hover popover; defaults to true
- `broken` — Boolean; when true renders the link in a muted error state indicating the target entry no longer exists

## Interactions

- Hover (after 300ms delay) triggers `hover-preview-popover` anchored below the link text
- Popover dismisses on mouse leave with a 150ms grace period to allow cursor movement into popover
- Click navigates to entry detail; modifier+click opens in new tab
- When `broken` is true, hover shows tooltip "Entry not found — it may have been deleted"; clicking opens a "Find replacement" dialog
- In the rich text editor, right-click on the link shows a context menu: "Edit link", "Remove link", "Open entry"
- Rendered with `role="link"` and `aria-label="{entryTitle} ({entryType})"` for screen readers
