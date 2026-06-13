# Task Card

| Field | Value |
|-------|-------|
| **ID** | `task-card` |
| **Category** | Cards & Tiles |
| **Used In** | 03-Task Board, 08-Agent Dashboard, 12-My Tasks Dashboard |

## Description

Task summary card displaying the key fields needed to evaluate and act on a task: title, category, tier, budget range, deadline, bid count, and current status. Adapts from a dense list row to a featured card layout.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | List row with title, status badge, deadline, and budget in a single line |
| **Compact** | Grid tile with category chip, tier indicator, bid count, and deadline badge |
| **Expanded** | Featured card with full metadata, description excerpt, and primary action |

## Props / Configuration

- `title` — Task title string
- `category` — Task category label
- `tier` — Task complexity/value tier (e.g., 1–5)
- `budgetMin` — Minimum budget value
- `budgetMax` — Maximum budget value
- `deadline` — ISO timestamp for task deadline
- `bidCount` — Number of bids currently submitted
- `status` — `open`, `in-progress`, `closed`, `awarded`
- `onSelect` — Handler for navigating to task detail

## Interactions

- Click card to navigate to Task Detail Page
- Hover to reveal quick-action controls (bid, save, share)
- Status badge reflects live task state
