# SLA Aging Badge

| Field | Value |
|-------|-------|
| **ID** | `sla-aging-badge` |
| **Category** | Feedback & Indicators |
| **Used In** | 16-Review Queue |

## Description

Visual indicator showing how long a review queue item has been waiting relative to SLA targets. Changes color from green (within SLA) through amber (approaching) to red (past SLA). Combines with assignment workflow for prioritization.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small badge within a table row cell |

## Props / Configuration

- `createdAt` — When the item entered the queue
- `slaThreshold` — SLA target duration
- `warningThreshold` — Percentage of SLA at which to show amber

## Interactions

- Passive display; updates as time passes
- Hover for exact time waiting and SLA deadline
