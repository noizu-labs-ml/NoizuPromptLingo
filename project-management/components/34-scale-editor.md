# Scale Editor

| Field | Value |
|-------|-------|
| **ID** | `scale-editor` |
| **Category** | Domain-Specific |
| **Used In** | 12-Rubric Detail |

## Description

Configuration form for rubric scoring scales. Supports two modes: continuous (min/max numeric range) and ladder (ordered enum values with numeric mapping). Used when defining how a rubric's judge will output scores.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full form with mode toggle and type-specific inputs |

## Props / Configuration

- `scaleType` — `continuous` | `ladder`
- `continuousConfig` — { min, max, step }
- `ladderConfig` — Array of { label, numericValue, description }
- `onChange` — Callback when scale configuration changes

## Interactions

- Toggle between continuous and ladder modes
- For continuous: set min, max, and step values
- For ladder: add/remove/reorder enum rungs with labels and numeric mappings
- Preview how scores will appear
