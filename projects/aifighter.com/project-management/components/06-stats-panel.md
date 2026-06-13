# Stats Panel

| Field | Value |
|-------|-------|
| **ID** | `stats-panel` |
| **Category** | Data Display |
| **Used In** | 03-Post-Battle Screen, 07-Laboratory, 24-Fighter Win-Rate Analytics, 06-Ranked Arena |

## Description

Tabular/visual display of fighter performance metrics including win/loss/draw rates, matchup breakdowns by archetype, actions-per-second, and confidence histograms. Supports CSV download.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Key stats summary line showing win rate, record, and primary metric |
| **Expanded** | Full panel with charts, matchup breakdown tables, and histograms |

## Props / Configuration

- `stats` — Metrics data object (win/loss/draw counts, APS, confidence distributions)
- `breakdownType` — Breakdown grouping: `archetype` or `elo-band`
- `sampleSizeGate` — Minimum match count required before displaying stats
- `downloadable` — Enables CSV export button
- `refreshInterval` — Data staleness interval in seconds

## Interactions

- View aggregate stats and visual charts
- Drill into matchup breakdowns by archetype or ELO band
- Download stats as CSV file
- Filter displayed data by time period
