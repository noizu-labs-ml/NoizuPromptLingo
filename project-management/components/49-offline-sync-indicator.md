# Offline/Sync Indicator

| Field | Value |
|-------|-------|
| **ID** | `offline-sync-indicator` |
| **Category** | Feedback & Indicators |
| **Used In** | 07-Mobile Capture |

## Description

Status display showing offline mode and sync queue with item count

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon with queued count |
| **Compact** | Banner with offline status and queue info |

## Props / Configuration

- `isOnline` — boolean
- `queuedCount` — number
- `lastSync` — timestamp

## Interactions

- tap to force sync attempt
- view queued items
