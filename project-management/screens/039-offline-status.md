# Offline Status Banner

| Field | Value |
|-------|-------|
| **ID** | offline-status |
| **Type** | Modal |
| **Category** | Accessibility & Performance |
| **User Stories** | US-098 |

## DescriptionOffline mode status indicator and pending sync queue UI.

## Key Components

- **Offline Indicator** | Shows when internet disconnected (US-098)
- **Pending Sync Count** | Number of changes waiting to sync (US-098)
- **Sync Queue List** | Entries with pending sync status (US-098)
- **Sync Now Button** | Manual sync trigger (US-098)
- **Conflict Resolution Dialog** | Side-by-side version comparison (US-098)
- **Version Selector** — Choose which version to keep or merge (US-098)
- **Sync Status** | Connected, Syncing, Offline (US-098)

## Interactions

- Indicator shows connectivity state
- Changes stored in IndexedDB pending-sync queue
- Visual indicator marks pending entries
- Auto-sync when connection restored
- Conflicts require manual resolution
- Choose Keep Mine, Keep Theirs, or Merge

## Navigation

- Accessible from: All screens when offline
- Links to: None (status overlay)