# Capacity Adjuster

| Field | Value |
|-------|-------|
| **ID** | `capacity-adjuster` |
| **Category** | Input & Forms |
| **Used In** | 14-Sprint Planning |

## Description

Team capacity configuration with per-member availability sliders and PTO/holiday inputs

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Summary bar showing total capacity |
| **Expanded** | Per-member availability configuration |

## Props / Configuration

- `members` — array of team members
- `defaultCapacity` — hours
- `overrides` — per-member adjustments
- `onChange` — callback

## Interactions

- adjust per-member availability
- mark PTO/holidays
- total recalculates live
