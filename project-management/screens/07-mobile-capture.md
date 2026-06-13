# Mobile Capture Screen

| Field | Value |
|-------|-------|
| **ID** | `mobile-capture` |
| **Type** | Primary |
| **Category** | Inbox & Capture |
| **User Stories** | US-007 |

## Description

Mobile-optimized PWA capture screen designed for one-handed operation. Supports photo attachments, share-sheet integration (capture from other apps), and offline queuing with sync indicator.

## Key Components

- **Text input** — Large touch-friendly input area
- **Photo attachment** — Camera/gallery picker for screenshots or photos
- **Tag syntax hints** — Subtle hint bar showing available metadata syntax
- **Offline indicator** — Badge showing offline status when disconnected
- **Sync status** — Shows queued items waiting for sync

## Interactions

- Share-sheet integration captures content from other apps
- Photo attachment adds images to captured item
- Works fully offline — queues items for later sync
- Haptic feedback on successful capture
- Minimal UI for speed — expand for metadata

## Navigation

- Accessible from: Mobile app home, share-sheet, PWA shortcut
- Outputs to: Inbox (syncs when online)
