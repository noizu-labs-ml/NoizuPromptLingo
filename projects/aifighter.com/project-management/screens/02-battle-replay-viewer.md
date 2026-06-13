# Battle Replay Viewer

| Field | Value |
|-------|-------|
| **ID** | `battle-replay-viewer` |
| **Type** | Primary |
| **Category** | Core Gameplay |
| **User Stories** | US-002, US-021, US-022, US-026, US-034, US-046, US-069, US-074, US-081, US-082, US-092, US-096 |

## Description

Full-featured replay player showing completed battles with decision overlay, bookmarks, annotations, speed controls, and export capabilities. Supports accessibility via VoiceOver live regions and reduced motion.

## Key Components

- **Replay Timeline Scrubber** — Frame-by-frame scrubber with bookmark markers and timestamp display (US-002, US-034)
- **Decision Overlay Panel** — Toggleable per-node confidence scores with category filtering (US-002, US-022)
- **Bookmark Manager** — Long-press to create named bookmarks with 280-char annotations (US-021)
- **Playback Speed Controls** — 0.25x/0.5x/1x/2x speed selector with frame-step buttons (US-034)
- **Screenshot Export with UI Skins** — Export replay frames with selectable skin presets (Dark/Light/Minimal), resolution options, and optional credit display (US-026)
- **Export Controls** — MP4 export with overlay, share link generation, web player link (US-046, US-081, US-092)
- **Theater Mode Toggle** — Hides HUD chrome for clean recording, retains overlay + health bars (US-082)
- **Commentary Recording Panel** — In-app audio recording with frame-synced controls (US-096)
- **VoiceOver Live Regions** — Accessible battle state announcements with verbosity setting (US-069)
- **Reduced Motion View** — Frame-by-frame step view replacing animations (US-074)

## Interactions

- Scrub through replay frame by frame or at variable speed
- Toggle decision overlay on/off/filtered by node category
- Create, name, and annotate bookmarks on timeline
- Export as MP4, shareable link, or screenshot
- Enable theater mode for streaming
- Record audio commentary synced to frames

## Navigation

- Accessible from: Post-Battle screen, Match History, Replay Theater, Tournament Bracket, Notifications
- Links to: Share dialog, Export queue, Fighter Studio (via decision overlay)
