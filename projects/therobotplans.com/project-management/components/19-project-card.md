# Project Card

| Field | Value |
|-------|-------|
| **ID** | `project-card` |
| **Category** | Cards & Tiles |
| **Used In** | 15-Portfolio Dashboard |

## Description

Project summary card with name, health indicator, methodology badge, progress bar, and deadline

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Name + health dot + progress bar |
| **Expanded** | Full card with all indicators and actions |

## Props / Configuration

- `name` — string
- `health` — green|yellow|red
- `methodology` — string
- `progress` — number
- `nextMilestone` — date
- `riskScore` — number

## Interactions

- click to navigate to project board
- click health for breakdown
- hover for summary tooltip
