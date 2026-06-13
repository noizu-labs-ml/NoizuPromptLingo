# Share Dialog

| Field | Value |
|-------|-------|
| **ID** | `share-dialog` |
| **Type** | Modal |
| **Category** | Social |
| **User Stories** | US-003, US-010, US-039, US-092 |

## Description

Unified share dialog for builds, replays, and highlights. Generates share links with embedded overlay presets and configurable expiry.

## Key Components

- **Share Link Generator** — Unique URL per shared item with Open Graph preview (US-039, US-092)
- **Overlay Preset Selector** — Choose which decision overlay filters are encoded in share link (US-039)
- **Start Timestamp Selector** — Choose replay start point in share link (US-039)
- **Expiry Controls** — 7-day default with permanent option for creator profiles (US-092)
- **Native Share Sheet** — OS-native sharing with caption and referral link (US-010)
- **Obfuscation Toggle** — Hide core logic as "black box" nodes when sharing builds (US-003)

## Interactions

- Generate shareable link
- Configure overlay presets and start time
- Set expiry duration
- Share via native OS share sheet
- Toggle build obfuscation

## Navigation

- Accessible from: Battle Replay Viewer, Post-Battle Screen, Laboratory, Fighter Studio
- Links to: Web Replay Viewer (via generated link)
