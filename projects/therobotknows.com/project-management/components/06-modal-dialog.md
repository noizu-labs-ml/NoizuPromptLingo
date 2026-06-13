# Modal Dialog

| Field | Value |
|-------|-------|
| **ID** | modal-dialog |
| **Type** | Layout |
| **Category** | Layout |
| **Screen Usage** | Password Reset, Version History, Collaborators Panel, etc.

## Description

Accessible modal overlay with focus trap and responsive sizing.

## Size Variants

- Small — Simple confirmations (300px)
- Medium — Form modals (500px)
- Large — Complex panels (800px)
- Fullscreen — Immersive views

## Props

- `isOpen` — Modal visibility state
- `onClose` — Close handler
- `title` — Modal heading
- `showCloseButton` — Display close button
- `closeOnBackout` — Click outside to close
- `closeOnEscape` — Escape key to close
- `size` — Modal size variant
- `footer` — Footer content/actions

## Interactions

- Focus trap inside modal content
- Focus returns to trigger on close
- Backdrop click closes (if enabled)
- Escape key closes (if enabled)
- Animation on open/close
- Prevents body scroll when open

## Accessibility

- Dialog with `role="dialog"` or `role="alertdialog"`
- `aria-modal="true"`
- `aria-labelledby` and `aria-describedby`
- Escapable and focus management
- Keyboard navigation through content