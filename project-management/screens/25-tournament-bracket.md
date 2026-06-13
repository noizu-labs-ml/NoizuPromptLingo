# Tournament Bracket

| Field | Value |
|-------|-------|
| **ID** | `tournament-bracket` |
| **Type** | Primary |
| **Category** | Competitive |
| **User Stories** | US-033, US-085, US-099 |

## Description

Visual tournament bracket supporting 8/16/32 participants. Used by both educators (classroom tournaments) and streamers (community events). Supports public spectator URLs and OBS embed.

## Key Components

- **Bracket Display** — Single-elimination bracket with async auto-populated results (US-033, US-085)
- **Bracket Controls** — Pause/reset/advance controls for organizers (US-033)
- **Public Spectator Link** — Shareable read-only bracket URL, no login required (US-085)
- **OBS Embed URL** — Browser-source URL with configurable dimensions (US-099)
- **Reveal Schedule** — Configurable result reveal timing for suspense (US-085)
- **Replay Links** — Per-match replay links in bracket (US-033)
- **Neural Pathway Theme** — Dark background with green synapse lines (US-099)

## Interactions

- Create tournament with bracket size selection
- Seed participants
- Monitor live bracket progression
- Share public spectator link
- Configure OBS embed
- View replays for completed matches

## Navigation

- Accessible from: Education Portal, Streamer Dashboard, Community Hub
- Links to: Battle Replay Viewer (per-match), Public Spectator View
