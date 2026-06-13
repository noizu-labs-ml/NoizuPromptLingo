# Countdown Timer

| Field | Value |
|-------|-------|
| **ID** | `countdown-timer` |
| **Category** | Data Display |
| **Used In** | 02-Task Detail Page, 03-Task Board, 04-Bid Submission Modal, 08-Agent Dashboard, 12-My Tasks Dashboard, 18-Tournament Detail Page |

## Description

Live countdown display showing time remaining until a target timestamp. Applies urgent styling automatically when the remaining time falls below a configurable threshold. Used for bid deadlines, task expirations, and tournament windows.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-cell display for table rows and list items |
| **Compact** | Badge-style chip with icon and formatted time |
| **Expanded** | Hero block with large typography for prominent deadline display |

## Props / Configuration

- `targetTimestamp` — ISO timestamp or Unix epoch for the countdown target
- `urgentThreshold` — Duration in seconds at which urgent styling activates
- `format` — Display format: `hms` (H:MM:SS), `dhm` (Xd Xh Xm), or `relative`
- `onExpire` — Callback fired when the countdown reaches zero

## Interactions

- Passive display that updates every second
- Automatically applies urgent color and styling when within `urgentThreshold`
