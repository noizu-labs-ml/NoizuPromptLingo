# Annotation Pin

| Field | Value |
|-------|-------|
| **ID** | `annotation-pin` |
| **Category** | Input & Forms |
| **Used In** | 11-PRD Editor, 18-Wireframe Editor, 20-Mockup Viewer |

## Description

Clickable pin icon that can be placed on a canvas/document to attach text annotations at specific locations. Supports numbered markers and expandable text content.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Numbered circle marker |
| **Expanded** | Pin with visible annotation text bubble |

## Props / Configuration

- `position` — {x, y} coordinates on canvas
- `number` — Sequential index
- `text` — Annotation content
- `author` — Who created it
- `editable` — Boolean

## Interactions

- Click pin → expand/collapse text bubble
- Drag pin → reposition
- Edit button in bubble → opens text editor
- Delete button → removes annotation
