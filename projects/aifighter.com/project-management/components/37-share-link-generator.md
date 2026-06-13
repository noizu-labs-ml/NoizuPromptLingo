# Share Link Generator

| Field | Value |
|-------|-------|
| **ID** | `share-link-generator` |
| **Category** | Input & Forms |
| **Used In** | 23-Share Dialog |

## Description

Generates unique shareable URLs for builds, replays, and highlights. Configures overlay presets, start timestamps, and expiry duration. Generates Open Graph thumbnail previews.

## Size Variants

| Variant | Description |
|---------|-------------|
| Expanded | Full share configuration panel |

## Props / Configuration

- `contentType` — `build` | `replay` | `highlight`
- `overlayPreset` — Encoded filter state for the shared view
- `startTimestamp` — Replay start point in milliseconds
- `expiry` — Link expiry duration (7-day default, permanent option)
- `ogPreview` — Open Graph thumbnail image data

## Interactions

- Generate shareable link
- Configure overlay preset, start timestamp, and expiry duration
- Copy generated link to clipboard
- Share via native OS share sheet
