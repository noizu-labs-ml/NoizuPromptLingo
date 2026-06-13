# Season Progress Tracker

| Field | Value |
|-------|-------|
| **ID** | `season-progress-tracker` |
| **Category** | Data Display |
| **Used In** | 06-Ranked Arena, 15-Season Summary |

## Description

Visual tracker showing current season rank progression through tiers (Bronze–Neural), countdown timer, and reward previews at each tier threshold.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Rank badge and countdown timer only |
| **Compact** | Tier ladder with current position indicator |
| **Expanded** | Full rewards preview showing unlocks at each tier threshold |

## Props / Configuration

- `currentTier` — Current rank tier name (Bronze through Neural)
- `seasonEndDate` — Target date for countdown timer calculation
- `rewards` — Mapping of tier thresholds to reward definitions
- `battlesCompleted` — Battle count used to show progress toward next tier

## Interactions

- View progression position on tier ladder
- Preview rewards unlocked at upcoming tier thresholds
- View live countdown to season end
