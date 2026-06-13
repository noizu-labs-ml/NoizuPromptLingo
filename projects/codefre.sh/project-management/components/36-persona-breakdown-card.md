# Persona Breakdown Card

| Field | Value |
|-------|-------|
| **ID** | `persona-breakdown-card` |
| **Category** | Cards & Tiles |
| **Used In** | 09-Run Detail, 27-Cohort Dashboard |

## Description

Card showing per-persona verdict and score breakdown for fan-out runs. Displays each persona's individual verdict, score, and pass/fail status for multi-persona test executions.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Small card with persona name + verdict badge per persona |
| **Expanded** | Full table with persona, verdict, score, duration per persona |

## Props / Configuration

- `personas` — Array of { name, verdict, score, duration }
- `onPersonaClick` — Callback to filter run steps by persona

## Interactions

- Click a persona row to filter the step list/conversation to that persona's steps
- Hover for score tooltip
