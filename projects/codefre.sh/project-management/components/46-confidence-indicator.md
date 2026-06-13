# Confidence Indicator

| Field | Value |
|-------|-------|
| **ID** | `confidence-indicator` |
| **Category** | AI-Specific |
| **Used In** | 09-Run Detail, 16-Review Queue, 17-Review Detail, 36-Freeball Confidence Histogram |

## Description

Visual representation of a confidence score (0.0-1.0) from the freeball runner. Shown as a numeric value with color coding (red < 0.3, amber 0.3-0.7, green > 0.7). Used in review queues for prioritization and in run detail for freeball step quality assessment.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Numeric value with color dot in table cells |
| **Compact** | Numeric value + progress bar in detail views |

## Props / Configuration

- `value` — Confidence score (0.0-1.0)
- `thresholds` — Color breakpoints { low, medium, high }
- `showBar` — Whether to display as progress bar

## Interactions

- Passive display
- Hover for tooltip explaining what the confidence represents
- In queue context: used for sort/filter ordering
