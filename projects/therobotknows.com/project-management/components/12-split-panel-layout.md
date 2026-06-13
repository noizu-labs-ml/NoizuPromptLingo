# Split Panel Layout

| Field | Value |
|-------|-------|
| **ID** | `split-panel-layout` |
| **Category** | Navigation & Layout |
| **Used In** | S04 Canon List + Detail, S07 Search + Preview, S11 Session Companion |

## Description

Resizable two-panel layout with a left list/nav panel and a right detail/content panel separated by a draggable divider. Supports collapsing either panel to give full width to the other. Persists panel width ratio to user preferences.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Both panels visible with configurable split ratio |
| **Full Page** | One panel collapsed; the other fills the full content area |

## Props / Configuration

- `leftPanel` — React node rendered in the left panel
- `rightPanel` — React node rendered in the right panel
- `defaultSplit` — Initial width ratio as a decimal (e.g., `0.35` for 35/65 split)
- `minLeftWidth` — Minimum pixel width for the left panel (default: `240`)
- `minRightWidth` — Minimum pixel width for the right panel (default: `360`)
- `persistKey` — Local storage key for persisting the user's preferred split ratio
- `collapseSide` — Which side can be collapsed: `left` | `right` | `both` | `none`
- `onSplitChange` — Callback fired with the new ratio after drag ends

## Interactions

- Dragging the divider bar resizes both panels simultaneously; resize is constrained by `minLeftWidth` / `minRightWidth`
- Double-clicking the divider resets to `defaultSplit`
- Collapse toggle button on the divider bar fully hides the specified panel with an animated transition
- On viewports narrower than `768px`, layout automatically switches to a single-panel mode with back navigation to return to the list
- Keyboard: `Ctrl+[` / `Ctrl+]` nudge the split by 5% increments when the divider is focused
