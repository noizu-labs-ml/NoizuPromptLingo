# Criteria List Editor

| Field | Value |
|-------|-------|
| **ID** | `criteria-list-editor` |
| **Category** | Domain-Specific |
| **Used In** | 12-Rubric Detail |

## Description

Ordered list editor for rubric criteria. Each criterion has label, description, weight, and optional model override. Supports reordering, adding/removing criteria, and per-criterion weight distribution.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Stacked criteria cards with inline editing |

## Props / Configuration

- `criteria` — Array of { label, description, weight, modelOverride }
- `onUpdate` — Callback when criteria are modified
- `totalWeight` — Validation that weights sum to expected value
- `allowModelOverride` — Whether per-criterion model selection is available

## Interactions

- Add new criterion
- Edit label, description, weight inline
- Reorder via drag handles
- Remove criteria
- Set optional model override per criterion
- Weight validation (visual indicator when weights don't sum correctly)
