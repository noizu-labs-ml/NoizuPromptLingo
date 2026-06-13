# Rank Tier Badge

| Field | Value |
|-------|-------|
| **ID** | `rank-tier-badge` |
| **Category** | Feedback & Indicators |
| **Used In** | 06-Ranked Arena, 08-Leaderboard Table (within 06), 14-Match Confirmation, 15-Season Summary, 18-Public Profile |

## Description

Visual badge displaying a player's ranked tier (Bronze through Neural) with appropriate color and icon. Used inline throughout the app wherever rank is shown.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small badge/chip for use in table rows and headers |
| **Compact** | Badge with ELO number displayed alongside tier icon |

## Props / Configuration

- `tier` — Rank tier enum (Bronze | Silver | Gold | Platinum | Diamond | Neural)
- `elo` — Numeric ELO rating
- `showElo` — Display numeric ELO alongside badge

## Interactions

- Static display (non-interactive)
