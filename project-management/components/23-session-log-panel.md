# Session Log Panel

| Field | Value |
|-------|-------|
| **ID** | `session-log-panel` |
| **Category** | Forms |
| **Used In** | S11 Session Companion |

## Description

Chronological freeform notes area for capturing in-session writing decisions, plot points, and ideas. Each note block is timestamped on creation. The panel auto-saves continuously and provides per-block controls to extract a note directly into a new or existing canon entry.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full panel occupying the right side of the Session Companion split layout |
| **Compact** | Collapsed drawer anchored to the bottom of the screen; click to expand |

## Props / Configuration

- `sessionId` — ID of the current session; used for auto-save scoping
- `entries` — Array of `{ id, content, createdAt, extractedToEntryId? }` log entry objects
- `onAddEntry` — Callback fired with new entry text when the user submits a note
- `onUpdateEntry` — Callback fired with `{ id, content }` when an existing note is edited
- `onDeleteEntry` — Callback fired with entry `id` when a note is deleted
- `onExtractToCanon` — Callback fired with `{ logEntryId, targetEntryId? }` when the extract action is triggered; opens the entry-selection modal if `targetEntryId` is not provided
- `autoSaveIntervalMs` — Auto-save debounce interval in milliseconds (default: `1500`)
- `saving` — Boolean; shows a subtle "Saving…" indicator in the panel header

## Interactions

- New notes are added via a textarea at the bottom of the panel; pressing `Enter` (or clicking "Add Note") appends a timestamped block at the end of the log
- Existing note blocks are inline-editable on click; changes are debounced and auto-saved
- Each note block shows a hover action bar with Edit, Extract to Canon, and Delete icons
- "Extract to Canon" opens a modal to select an existing entry to append the note to, or create a new entry pre-filled with the note content; on success the note block shows an "Extracted → [Entry Name]" link badge
- Extracted notes are visually distinguished (e.g., italic or dimmed) but remain in the log for reference
- Auto-save state is shown in the panel header: idle / saving / saved / error
- Session log is scoped to the active universe and session date; previous sessions are accessible via a date picker in the panel header
