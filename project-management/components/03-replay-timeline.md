# Replay Timeline

| Field | Value |
|-------|-------|
| **ID** | `replay-timeline` |
| **Category** | Navigation & Layout |
| **Used In** | 02-Battle Replay Viewer, 27-Web Replay Viewer |

## Description

Horizontal timeline scrubber for battle replays with frame-by-frame stepping, bookmark markers, playback speed controls, and current frame/timestamp display.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Minimal controls for web viewer: scrubber, play/pause, and timestamp only |
| **Expanded** | Full controls with bookmark markers, speed selector, and frame step buttons |

## Props / Configuration

- `totalFrames` — Total frame count for the replay
- `currentFrame` — Currently active frame index
- `bookmarks` — Named marker definitions with frame positions
- `playbackSpeed` — Speed multiplier (0.25x–2x)
- `reducedMotion` — When true, disables playback and enables frame-step only mode

## Interactions

- Drag scrubber to seek to any frame
- Click bookmark markers to jump to named moments
- Step frame forward or backward with step buttons
- Select playback speed from speed control
- Long-press scrubber to create a new bookmark at current frame
