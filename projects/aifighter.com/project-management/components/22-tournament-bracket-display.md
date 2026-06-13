# Tournament Bracket Display

| Field | Value |
|-------|-------|
| **ID** | `tournament-bracket-display` |
| **Category** | Domain-Specific |
| **Used In** | 10-Education Portal, 25-Tournament Bracket |

## Description

Visual single-elimination bracket supporting 8, 16, or 32 participants with async result auto-population, replay links per match, and configurable reveal schedules. Embeddable as OBS browser source.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Small bracket overview (non-interactive summary) |
| **Expanded** | OBS-optimized embed view for streaming overlays |
| **Full Page** | Interactive bracket with organizer controls |

## Props / Configuration

- `bracketSize` — Number of participants (8 | 16 | 32)
- `participants` — Seeded participant list
- `results` — Match outcome data for auto-population
- `revealSchedule` — Timed reveal configuration per round
- `theme` — Visual styling (neural-pathway theme)
- `embedDimensions` — Aspect ratio for OBS embed (16:9 | 4:3)

## Interactions

- View bracket progression as results populate
- Click match cell to open associated replay
- Organizer controls: pause, reset, advance bracket
- Share public bracket link
