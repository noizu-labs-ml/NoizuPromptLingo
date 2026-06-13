# Keyboard Shortcut Hint

| Field | Value |
|-------|-------|
| **ID** | `keyboard-shortcut-hint` |
| **Category** | Navigation / UI Chrome |
| **Used In** | S-04 Canon List (search input), S-08 Sidebar Navigation items, S-12 Generation Studio toolbar buttons |

## Description

Small inline badge rendering the keyboard shortcut associated with a UI action. Uses platform-aware modifier key symbols (⌘ on macOS, Ctrl on Windows/Linux). Appears adjacent to the action label or inside a tooltip.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Rendered directly beside a label or inside a button, using styled `<kbd>` elements — standard usage |

## Props / Configuration

- `shortcut` — Shortcut descriptor string or structured object: `{ modifier?: string[], key: string }`
  - Example string: `"⌘K"` or `"Ctrl+K"`
  - Example object: `{ modifier: ["meta"], key: "k" }` — rendered with platform-appropriate symbol
- `platform` — `"mac"` | `"windows"` | `"auto"` (default: `"auto"` — detected from navigator.platform)
- `size` — `"sm"` | `"md"` (default: `"sm"`)
- `muted` — Boolean; renders in lower-contrast style when the hint is secondary information (default: false)

## Interactions

- Non-interactive by default — pure display component with no click handling
- When rendered inside a tooltip, the hint appears on a second line below the action description
- Platform detection maps `meta` modifier to ⌘ on macOS and `Ctrl` on Windows/Linux; `alt` maps to ⌥ on macOS
- Multi-key chords are rendered as separate `<kbd>` elements joined by `+` (e.g., `⌘` `+` `Shift` `+` `K`)
- Visually uses a monospace or semi-condensed font, a light border, and a slightly inset shadow to mimic physical key caps
- Hidden from screen readers via `aria-hidden="true"` — the shortcut is conveyed through the parent element's accessible description instead
- Respects the user's `prefers-reduced-motion` and high-contrast mode settings via theme tokens
