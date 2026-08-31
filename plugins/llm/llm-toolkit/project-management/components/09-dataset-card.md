# 09: Dataset Card

| Field | Value |
|-------|-------|
| ID | CMP-09 |
| Category | Cards & Tiles |
| Surfaces | web, cli-ink |
| Used In | SCR-09, SCR-23 |

## Description
Summary card for one fine-tuning dataset: name, description, entry count, quality breakdown (via CMP-10 Quality Bar), last-updated timestamp.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Datasets List grid (web) |
| Row | Datasets List (cli-ink), dense terminal layout |

## Props / Configuration
- `name`, `description`
- `entryCount` — number
- `qualityBreakdown` — `{ gold, silver, bronze }` counts
- `updatedAt`

## Interactions
- Click/Enter navigates to Dataset Detail (SCR-10 / SCR-24)
