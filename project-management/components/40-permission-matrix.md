# Permission Matrix

| Field | Value |
|-------|-------|
| **ID** | `permission-matrix` |
| **Category** | Input & Forms |
| **Used In** | 54-Agent Roles & Permissions, 59-Custom Agent Builder, 64-Prompt Template Library |

## Description

Grid of resource types × actions with toggle cells for configuring access permissions

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full grid with row/column headers and toggles |

## Props / Configuration

- `resources` — array of resource types
- `actions` — array of action types
- `permissions` — current state matrix
- `onChange` — callback
- `scope` — workspace|project|item

## Interactions

- toggle individual cells
- select full row/column
- scope selector changes context
- immediate effect with confirmation
