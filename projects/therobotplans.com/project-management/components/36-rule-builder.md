# Rule Builder

| Field | Value |
|-------|-------|
| **ID** | `rule-builder` |
| **Category** | Input & Forms |
| **Used In** | 10-Smart Lists, 45-Checklist Enforcement Settings, 58-Agent Notification Settings |

## Description

Visual query/rule builder with field/operator/value rows and boolean logic nesting

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full rule builder with add/remove/nest controls |

## Props / Configuration

- `rules` — array of condition objects
- `fields` — available field definitions
- `operators` — per-field operators
- `onChange` — callback
- `allowNesting` — boolean

## Interactions

- add/remove rule rows
- nest with AND/OR groups
- live preview of matching results
- drag to reorder rules
