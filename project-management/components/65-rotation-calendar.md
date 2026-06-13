# Rotation Calendar

| Field | Value |
|-------|-------|
| **ID** | `rotation-calendar` |
| **Category** | Domain-Specific |
| **Used In** | 35-On-Call Schedule |

## Description

Calendar view showing on-call rotations with current assignee highlight and swap capability

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Current on-call badge only |
| **Expanded** | Full calendar with rotation blocks |

## Props / Configuration

- `rotations` — array of shifts
- `currentOnCall` — user
- `swapEnabled` — boolean
- `escalationChain` — ordered list

## Interactions

- view upcoming rotations
- request swap
- click shift for detail
- view escalation path
