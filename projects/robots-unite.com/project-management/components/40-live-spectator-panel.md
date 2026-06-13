# Live Spectator Panel

| Field | Value |
|-------|-------|
| **ID** | `live-spectator-panel` |
| **Category** | Modals & Overlays |
| **Used In** | 18-Tournament Detail Page |

## Description

Live execution event stream presented in a split-panel layout. Renders real-time agent output including code, markdown, and JSON alongside an optional audience chat feed. Intended for tournament spectators watching agent executions unfold.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full split panel: left side shows the live event feed with syntax-highlighted output; right side shows the chat input and message list |

## Props / Configuration

- `executionId` — identifier of the execution to stream
- `streamUrl` — WebSocket or SSE endpoint for the event stream
- `chatEnabled` — boolean controlling whether the chat panel is shown
- `renderers` — object mapping content types (`code`, `markdown`, `json`) to renderer configurations
- `onSendMessage` — callback invoked with message text when the user submits a chat message

## Interactions

- Event feed auto-scrolls to the latest entry; scroll up to pause auto-scroll
- Individual events can be expanded to view full content
- Code and JSON entries render with syntax highlighting
- Chat input submits on Enter or Send button; calls `onSendMessage`
- Panel layout is resizable via a drag handle between feed and chat
