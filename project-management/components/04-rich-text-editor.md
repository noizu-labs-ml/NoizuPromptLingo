# Rich Text Editor

| Field | Value |
|-------|-------|
| **ID** | rich-text-editor |
| **Type** | Complex |
| **Category** | Editor |
| **Screen Usage** | Canon Entry Detail, Improvise Mode, Session Log |

## Description

WYSIWYG text editor with formatting toolbar, inline linking, and markdown export.

## Size Variants

- Compact — Sidebar editors
- Standard — Default article editor
- Fullscreen — Immersive writing mode

## Props

- `value` — Editor content (ProseMirror JSON / Markdown)
- `placeholder` — Placeholder text
- `disabled` — Read-only mode
- `toolbar` — Show/hide toolbar
- `maxLength` — Character limit
- `inlineLinking` — Enable [[ entry linking
- `toolbarButtons` — Array of enabled formatting options

## Interactions

- Floating toolbar with Bold, Italic, Underline, H2/H3, Lists, Blockquote, Link
- `[[` trigger or Link button opens entry search popover
- Paste strips to plain text with inline formatting preserved
- Mobile: toolbar collapses to overflow menu on keyboard
- Markdown output for export
- Auto-save on blur (configurable)

## Accessibility

- `role="textbox"` with `aria-multiline`
- Toolbar buttons have `aria-label`
- Keyboard shortcuts (Cmd+B, Cmd+I, etc.)
- Focus trap in fullscreen mode