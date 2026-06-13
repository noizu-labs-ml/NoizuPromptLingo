# Weight Slider

| Field | Value |
|-------|-------|
| **ID** | `weight-slider` |
| **Category** | Input & Forms |
| **Used In** | 69-Eval Rubric Builder, 71-A/B Test Manager |

## Description

Set of linked sliders that must sum to 100%, used for traffic splits and rubric dimensions

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Compact slider row with percentage labels |
| **Expanded** | Full sliders with labels and validation |

## Props / Configuration

- `items` — array of {id, label, value}
- `onChange` — callback
- `mustSumTo` — number
- `minValue` — number

## Interactions

- drag slider adjusts others proportionally
- type exact percentage
- validation enforces sum constraint
