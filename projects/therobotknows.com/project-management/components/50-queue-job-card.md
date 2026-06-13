# Queue Job Card

| Field | Value |
|-------|-------|
| **ID** | `queue-job-card` |
| **Category** | Generation |
| **Used In** | S-12 Generation Studio (queue sidebar), S-13 Generation History |

## Description

Card representing a single item in the generation queue. Displays the prompt excerpt, generation type, current status badge, a progress bar for in-flight jobs, and a cancel button for pending or processing jobs.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-line row with type badge, truncated prompt, status badge, and cancel icon — used in the studio sidebar queue list |
| **Expanded** | Full card with prompt excerpt (3 lines), progress bar, elapsed time, and labeled cancel button — used on the dedicated queue management screen |

## Props / Configuration

- `jobId` — Unique ID of the queue job
- `promptExcerpt` — First ~120 characters of the submitted prompt
- `generationType` — Type label (e.g., "Scene", "NPC", "World Lore")
- `status` — `"pending"` | `"processing"` | `"completed"` | `"failed"` | `"cancelled"`
- `progress` — Integer 0–100; shown only when `status === "processing"`
- `queuePosition` — Integer position in queue; shown only when `status === "pending"`
- `elapsedSeconds` — Seconds since job started; shown during processing
- `errorMessage` — Error string rendered when `status === "failed"`
- `variant` — `"compact"` | `"expanded"` (default: `"compact"`)
- `onCancel` — Callback invoked when user clicks cancel; receives `jobId`
- `onRetry` — Callback invoked on failed job retry button click

## Interactions

- Status badge uses semantic colors: grey (pending), blue (processing), green (completed), red (failed), muted (cancelled)
- Progress bar animates smoothly as `progress` prop updates via real-time subscription
- Cancel button is present only for `pending` and `processing` states; confirmation is not required (undo available via toast)
- Failed jobs show an error message row and a Retry button that re-enqueues the job with the same parameters
- Completed jobs in the studio sidebar queue become clickable links navigating to the generation result card
- Queue position indicator updates in real time as preceding jobs complete
