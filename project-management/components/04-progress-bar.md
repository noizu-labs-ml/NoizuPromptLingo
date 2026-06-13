# Progress Bar

| Field | Value |
|-------|-------|
| **ID** | `progress-bar` |
| **Category** | Data Display |
| **Used In** | 15-Portfolio Dashboard, 48-OKR Hierarchy, 49-OKR Check-In, 50-Goal Alignment Viz, 51-OKR Scoring, 70-Eval Dashboard |

## Description

Visual progress indicator showing completion percentage with optional label and target line

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Thin bar inline with text |
| **Compact** | Bar with percentage label |
| **Expanded** | Bar with breakdown segments and legend |

## Props / Configuration

- `value` — number (0-100)
- `target` — optional target value
- `segments` — optional breakdown
- `color` — theme color or status-based
- `label` — string

## Interactions

- hover for exact value
- click segments for detail
