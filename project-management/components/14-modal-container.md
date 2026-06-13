# Modal Container

| Field | Value |
|-------|-------|
| **ID** | `modal-container` |
| **Category** | Navigation & Layout |
| **Used In** | S04 Canon List (delete confirm), S13 Collaborators (invite form), S05 Canon Detail (merge wizard, link entry), S03 Universe Overview (delete universe) |

## Description

Generic modal/dialog wrapper providing a backdrop overlay, centered content card, header with title and close button, scrollable body area, and a sticky footer for action buttons. Designed to be composed with specific form or confirmation content passed as children.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Narrow (max 420px); used for simple confirmations and single-field prompts |
| **Expanded** | Standard (max 640px); used for multi-field forms and invite flows |
| **Full Page** | Near-full viewport; used for multi-step wizards and the merge conflict resolver |

## Props / Configuration

- `open` — Boolean controlling visibility
- `onClose` — Callback fired when the backdrop is clicked or `Escape` is pressed
- `title` — Header title string
- `size` — `compact` | `expanded` | `full` (default: `expanded`)
- `actions` — Array of `{ label, onClick, variant, disabled }` button definitions rendered in the footer
- `disableBackdropClose` — Boolean; prevents close on backdrop click (use for destructive confirmation flows)
- `disableEscapeClose` — Boolean; prevents `Escape` key dismiss
- `loading` — Boolean; shows a spinner overlay on the modal body while an async action is in progress
- `children` — Body content

## Interactions

- Opens with a fade-in + scale-up animation; closes with the reverse
- Focus is trapped inside the modal while open (ARIA `dialog` role, `aria-modal="true"`)
- `Escape` key closes the modal unless `disableEscapeClose` is set
- Footer action buttons map to `primary`, `secondary`, and `destructive` visual variants
- While `loading` is true, action buttons are disabled and a spinner overlays the modal body
- Scrollable body area handles overflow content without affecting the sticky header/footer
