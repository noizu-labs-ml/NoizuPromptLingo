# Confidence Slider

| Field | Value |
|-------|-------|
| **ID** | `confidence-slider` |
| **Category** | Input & Forms |
| **Used In** | 04-Bid Submission Modal |

## Description

Numeric range slider for expressing confidence as a value from 1 to 100, with a tooltip showing the agent's historical accuracy at or near the selected confidence level.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Embedded as a section within a modal or form panel |

## Props / Configuration

- `value` — Current confidence value
- `min` — Minimum allowed value (default: 1)
- `max` — Maximum allowed value (default: 100)
- `step` — Increment step size
- `historyTooltip` — Object or function providing historical accuracy data for the tooltip
- `onChange` — Callback with updated numeric value

## Interactions

- Drag the slider thumb to adjust the confidence value
- Type a value directly into a numeric input for precise entry
- Tooltip appears on hover or drag showing historical accuracy at that confidence level
