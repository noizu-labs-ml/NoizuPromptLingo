# Swimlane Toggle

| Field | Value |
|-------|-------|
| **ID** | `swimlane-toggle` |
| **Category** | Navigation & Layout |
| **Used In** | 13-Kanban Board |

## Description

Control that switches board grouping between different dimensions (assignee, priority, epic)

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Dropdown selector for grouping dimension |

## Props / Configuration

- `options` — array of grouping dimensions
- `selected` — current dimension
- `onChange` — callback

## Interactions

- select grouping to reorganize board
- instant re-render on change
