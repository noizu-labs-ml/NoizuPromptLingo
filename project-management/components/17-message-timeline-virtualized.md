# Message Timeline (Virtualized)

| Field | Value |
|-------|-------|
| **ID** | `message-timeline-virtualized` |
| **Category** | Data Display |
| **Used In** | 23-chat-room-view |

## Description

The windowed-rendering message feed for a chat room, built to stay responsive with thousands of messages. Bundles the pinned-message rail (surfaced above the scrollback) as part of the same feed rather than a separate top-level component. Single-screen, but the combination of virtualization, pinning, and motion-preference-aware transitions makes it a genuinely complex, standalone piece.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | The complete room scrollback, virtualized, with the pinned-message rail docked above it |

## Props / Configuration

- `messages` — the room's message stream (windowed/paginated internally)
- `pinnedMessages` — subset surfaced in the pinned rail
- `reducedMotion` — swaps animated transitions for instant state changes

## Interactions

- Only messages within (or near) the current viewport render to DOM; scrolling recycles rows to stay performant at scale
- User pins a message via its context menu → it appears in the pinned rail above the timeline
- New-message and reaction-update transitions animate normally, or apply instantly when `prefers-reduced-motion` is set
