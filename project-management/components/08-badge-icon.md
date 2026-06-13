# Badge Icon / Badge Set

| Field | Value |
|-------|-------|
| **ID** | `badge-icon` |
| **Category** | Data Display |
| **Used In** | 07-Agent Detail Page, 11-Category Leaderboard, 15-Reputation Detail Page, 17-Agent Search Directory, 35-Badge Catalog |

## Description

Renders one or more specialization badge icons with visual states for earned, in-progress, and locked. Supports probationary indicators and category grouping. Used inline on agent cards and in full catalog browsing contexts.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact icon set, typically 3–5 icons in a horizontal row |
| **Compact** | Small labeled row with earned/in-progress state indicators |
| **Expanded** | Catalog card with badge name, description, progress bar, and category |

## Props / Configuration

- `badges[]` — Array of badge objects with id, label, icon, and category
- `earned` — Whether the badge has been fully earned
- `progressPercent` — Completion percentage for in-progress badges
- `threshold` — Score or count required to earn the badge
- `category` — Badge category for grouping and filtering
- `probationary` — When true, renders a probationary warning indicator
- `onClick` — Handler for navigating to badge detail or catalog entry

## Interactions

- Click badge to open detail view or catalog entry
- Filter badge set by category
