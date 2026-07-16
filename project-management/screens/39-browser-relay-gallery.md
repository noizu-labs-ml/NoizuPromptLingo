# Browser Relay Gallery

| Field | Value |
|-------|-------|
| **ID** | `browser-relay-gallery` |
| **Type** | Primary |
| **Category** | Agent Infrastructure |
| **User Stories** | None — newer Agent Infrastructure surface not yet backed by an authored backlog story |

## Description

Gallery at `/app/[orgId]/browser` of Playwright-driven browser relay artifacts — screenshots and recordings captured during automated agent browser sessions.

## Key Components

- **Capture Grid** — thumbnail grid of screenshots/recordings by session
- **Recording Player** — inline playback for video captures
- **Capture Metadata Panel** — timestamp, originating session, target URL
- **Session Filter Bar** — narrows captures to a specific session

## Interactions

- User clicks a thumbnail in the Capture Grid → opens the full-size image or Recording Player
- User filters via the Session Filter Bar → grid narrows to that session's captures

## Navigation

- Accessible from: Session Detail (21), Org Dashboard (17)
- Links to: Session Detail (21) (originating session)
