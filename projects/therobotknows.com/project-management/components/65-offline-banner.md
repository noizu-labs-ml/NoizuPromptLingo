# Offline Banner

| Field | Value |
|-------|-------|
| **ID** | `offline-banner` |
| **Category** | System Status |
| **Used In** | All screens (conditional — rendered when network is unavailable) |

## Description

Persistent full-width banner affixed to the top of the viewport (below the main navigation) that appears when the app detects loss of network connectivity. Shows offline status, the number of locally queued writes pending sync, and a manual sync retry button.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-line banner with offline icon, short text, queue count badge, and sync button — standard usage |
| **Expanded** | Drops down to two lines when the queue count is high, adding a brief explanation of what is queued |

## Props / Configuration

- `isOffline` — Boolean; banner is only rendered when `true`
- `queuedWriteCount` — Number of pending local writes waiting to sync
- `lastSyncedAt` — ISO timestamp of the last successful sync; rendered as relative time
- `isSyncing` — Boolean; shows a spinner on the sync button during an active sync attempt
- `onRetrySync` — Callback invoked when user clicks the manual sync button
- `variant` — `"compact"` | `"expanded"` (default: `"compact"`)

## Interactions

- Banner slides down from below the navigation bar with a 150ms ease-in animation when `isOffline` becomes true
- Banner slides back up and unmounts when connectivity is restored; a brief "Back online — syncing" toast confirms reconnection
- Queue count badge updates in real time as the user performs write actions while offline
- Sync button is disabled and shows a spinner while `isSyncing` is true
- Clicking Retry Sync when already syncing has no additional effect
- If sync fails on retry, an inline error message replaces the sync button temporarily: "Sync failed — will retry automatically"
- Banner uses an amber/orange color treatment (not red) to indicate degraded state without implying a hard error
- Banner has `role="status"` for accessibility; screen readers announce connectivity changes
- Write actions performed while offline are queued in IndexedDB; banner count reflects the queue length
