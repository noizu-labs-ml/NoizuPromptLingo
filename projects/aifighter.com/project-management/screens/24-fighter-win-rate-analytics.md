# Fighter Win-Rate Analytics

| Field | Value |
|-------|-------|
| **ID** | `fighter-win-rate-analytics` |
| **Type** | Primary |
| **Category** | Analytics |
| **User Stories** | US-049 |

## Description

Per-fighter analytics showing win rate breakdown segmented by opponent ELO delta bands with sample size gates and drill-down to recent matches.

## Key Components

- **Win Rate by ELO Band Table** — Segmented by ±100/200/300 ELO delta (US-049)
- **Sample Size Gate** — Minimum 5 matches to show stats per band (US-049)
- **Band Drill-Down** — Expand band to see recent individual matches (US-049)
- **Live Update Indicator** — Shows data is current (US-049)

## Interactions

- View win rates across ELO bands
- Drill into specific bands to see match history
- Monitor live data updates

## Navigation

- Accessible from: Ranked Arena (fighter slot), Fighter Studio
- Links to: Post-Battle Screen (specific match), Battle Replay Viewer
