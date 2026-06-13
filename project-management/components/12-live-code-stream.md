# Live Code Stream

| Field | Value |
|-------|-------|
| **ID** | `live-code-stream` |
| **Category** | AI-Specific |
| **Used In** | 25-Agent Dashboard |

## Description

Real-time code diff streaming panel showing agent's output character-by-character or chunk-by-chunk. Syntax-highlighted with language auto-detection. Screenshot-friendly for "build in public" content.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed to current line with expand trigger |
| **Expanded** | Multi-line panel with full diff context |

## Props / Configuration

- `stream` — WebSocket/SSE connection for live data
- `language` — Programming language for syntax highlighting (auto-detected)
- `fileName` — Current file being modified
- `diffMode` — unified | split

## Interactions

- Auto-scrolls to latest output
- Pause button freezes display (buffer continues)
- Copy button copies visible content
- Language badge in corner shows detected language
