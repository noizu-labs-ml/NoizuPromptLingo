# Rich Text Editor

| Field | Value |
|-------|-------|
| **ID** | `rich-text-editor` |
| **Category** | Input & Forms |
| **Used In** | 11-PRD Editor, 18-Wireframe Editor, 24-Agent Development |

## Description

Per-section rich-text editor with formatting toolbar, inline annotations, and "Restore Original" option. Used for PRD editing, wireframe annotations, and code review comments.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-line with expand trigger |
| **Expanded** | Multi-line with formatting toolbar |
| **Full Page** | Document-mode with sidebar |

## Props / Configuration

- `content` — Initial content (markdown or rich text)
- `originalContent` — For "Restore Original" comparison
- `annotations` — Array of pinned annotation objects
- `readOnly` — Boolean
- `toolbar` — Array of enabled formatting options

## Interactions

- Click to enter edit mode
- Formatting via toolbar or keyboard shortcuts
- "Restore Original" reverts section with confirmation
- Annotations are click-to-add/edit/remove
