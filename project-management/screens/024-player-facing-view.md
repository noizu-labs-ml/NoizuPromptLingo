# Player-Facing View

| Field | Value |
|-------|-------|
| **ID** | player-facing-view |
| **Type** | Primary |
| **Category** | Session |
| **User Stories** | US-065, US-067 |

## Description

Read-only, spoiler-filtered view shared with players.

## Key Components

- **Universe Header** — Title, description (US-065)
- **Entry List** — Player-visible entries only (US-065)
- **Entry Visibility Badge** — Player-visible indicator (US-065)
- **GM-only Sections** — Hidden completely from view (US-065)
- **Session Handouts Section** — Shared session entries (US-067)
- **Handout Cards** — Session name, timestamp, content (US-067)
- **No Account Notice** — Read-only indication for anonymous viewers (US-065)
- **Revoked Notice** — Access denial message for retracted links (US-067)

## Interactions

- Players can read entries, no editing
- GM-only sections hidden without placeholder
- Handouts appear in real-time as shared
- Retracted entries disappear within 30 seconds
- Spoiler-flagged entries excluded entirely
- Session handouts clearly labeled
- No account creation required

## Navigation

- Accessible from: Session Companion (shareable link), Public Universe URL
- Links to: Canon Entry Detail (player-visible only)