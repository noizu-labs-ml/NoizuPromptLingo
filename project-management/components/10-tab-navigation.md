# Tab Navigation

| Field | Value |
|-------|-------|
| **ID** | `tab-navigation` |
| **Category** | Navigation & Layout |
| **Used In** | S12 Settings (Account / Notifications / AI / Privacy / Appearance), S15 Admin Panel (Users / Billing / Audit) |

## Description

Horizontal tab bar used to switch between peer views within the same page context. Tabs update the visible content panel without a full page navigation. Supports an optional badge count on individual tabs.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Underline-style tabs flush with page content; minimal height |
| **Compact** | Pill/chip-style tabs for use inside cards or sidebars |

## Props / Configuration

- `tabs` — Array of `{ id: string, label: string, badge?: number, disabled?: boolean }` objects
- `activeTab` — ID of the currently selected tab
- `onChange` — Callback fired with the new tab ID on selection
- `variant` — `underline` (default) | `pill`
- `fullWidth` — Boolean; stretches tabs to fill container width

## Interactions

- Clicking a tab sets it as active and swaps the content panel below; URL hash or query param updates to reflect the active tab for deep-linking
- Disabled tabs are visually dimmed and non-interactive
- Badge counts render as a small numeric pill on the tab label
- Arrow key navigation moves focus between tabs; `Enter` or `Space` activates the focused tab (ARIA `tablist` pattern)
- On overflow (many tabs on narrow viewport), tabs scroll horizontally with left/right arrow buttons appearing at edges
