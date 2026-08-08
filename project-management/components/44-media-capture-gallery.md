# Media Capture Gallery

| Field | Value |
|-------|-------|
| **ID** | `media-capture-gallery` |
| **Category** | Domain-Specific |
| **Used In** | 39-browser-relay-gallery |

## Description

A thumbnail grid of Playwright-driven browser-relay captures (screenshots and recordings) from automated agent browser sessions, with inline video playback and per-capture metadata (timestamp, originating session, target URL). Single screen, but the combination of a media grid, an embedded video player, and agent-session provenance metadata is distinct enough from the generic Card Grid to warrant its own component.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Thumbnail grid only |
| **Expanded** | Selected capture opened full-size, or in the Recording Player for video, with its Capture Metadata Panel |

## Props / Configuration

- `captures` — screenshots/recordings with type, timestamp, originating session, target URL
- `onOpenCapture`

## Interactions

- User clicks a thumbnail → opens the full-size image, or the Recording Player for a video capture
- User filters via an attached Search & Filter Bar → grid narrows to a specific session's captures
