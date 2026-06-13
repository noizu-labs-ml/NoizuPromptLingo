# SLO Card

| Field | Value |
|-------|-------|
| **ID** | `slo-card` |
| **Category** | Cards & Tiles |
| **Used In** | 34-SLO Dashboard |

## Description

Service Level Objective card with target, current value, error budget gauge, and burn rate

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | SLO name + gauge mini |
| **Expanded** | Full card with target, current, gauge, and burn rate |

## Props / Configuration

- `name` — string
- `target` — number
- `current` — number
- `errorBudgetRemaining` — number
- `burnRate` — number

## Interactions

- click for detailed breakdown
- configure alert thresholds
