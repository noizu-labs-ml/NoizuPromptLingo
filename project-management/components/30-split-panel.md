# Split Panel Layout

| Field | Value |
|-------|-------|
| **ID** | `split-panel` |
| **Category** | Navigation & Layout |
| **Used In** | 03-Time Blocking, 08-Personal Lists, 13-Kanban Board, 39-Wiki Editor, 43-Knowledge Search, 62-Prompt Comparison |

## Description

Two-panel layout with resizable divider, typically list-on-left detail-on-right or sidebar+main

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Horizontal split with draggable divider |
| **Full_Page** | Full-page split layout |

## Props / Configuration

- `leftContent` — component
- `rightContent` — component
- `defaultSplit` — ratio
- `resizable` — boolean
- `collapsible` — sides

## Interactions

- drag divider to resize
- collapse side panel
- responsive stacking on mobile
