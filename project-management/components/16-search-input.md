# Search Input

| Field | Value |
|-------|-------|
| **ID** | `search-input` |
| **Category** | Forms |
| **Used In** | S07 Global Search, S04 Canon List (inline search), S11 Session Companion (quick reference lookup) |

## Description

Styled text input for search queries with a leading search icon, optional keyboard shortcut badge, type-ahead suggestion dropdown, and a clear button that appears once the field has content. Can operate in global (full-page results) or inline (filters a local list) mode.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact; embedded within a list header or filter bar |
| **Expanded** | Prominent center-aligned bar; used on the dedicated Global Search page |

## Props / Configuration

- `value` — Controlled input value
- `onChange` — Callback fired on each keystroke with the new value
- `onSearch` — Callback fired on `Enter` or suggestion selection with the final query string
- `placeholder` — Placeholder text (default: `Search…`)
- `suggestions` — Array of `{ label, type, href }` objects for the type-ahead dropdown
- `onSuggestionSelect` — Callback fired when a suggestion is clicked or keyboard-selected
- `shortcutHint` — Keyboard shortcut label shown inside the input (e.g., `⌘K`); omit to hide
- `loading` — Boolean; shows a spinner inside the input while suggestions are being fetched
- `autoFocus` — Boolean; focuses the input on mount

## Interactions

- Clicking the input or pressing the global shortcut (`⌘K` / `Ctrl+K`) opens and focuses the field
- Type-ahead suggestions appear in a dropdown after a 200ms debounce; navigable with arrow keys
- Pressing `Enter` without a selected suggestion fires `onSearch` with the raw query
- Pressing `Escape` clears the input and closes the suggestion dropdown
- Clear button (`×`) appears when `value` is non-empty; clicking it resets value and refocuses the input
- Selected suggestion type is shown as a label prefix in the suggestion row (e.g., "Character", "Location")
