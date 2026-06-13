# Generation Result Card

| Field | Value |
|-------|-------|
| **ID** | `generation-result-card` |
| **Category** | Generation |
| **Used In** | S-12 Generation Studio, S-13 Generation History |

## Description

Card displaying a completed AI generation. Shows the generation title, type badge, text excerpt, token cost, number of canon sources consulted, and three primary actions: promote to canon, regenerate with same parameters, or discard.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Title, type badge, status, and action icons only — used in history list view |
| **Expanded** | Full card with excerpt (up to 8 lines), cost and source metadata, and labeled action buttons |

## Props / Configuration

- `generationId` — Unique ID of the generation record
- `title` — Auto-generated or user-specified title for the output
- `type` — Generation type (e.g., "Character", "Scene", "Lore Fragment")
- `excerpt` — First ~400 characters of generated text; truncated with "Read more" affordance
- `tokenCost` — Integer token count consumed; rendered with cost estimate in parentheses
- `sourceCount` — Number of canon entries used as context
- `status` — `"completed"` | `"promoted"` | `"discarded"`
- `createdAt` — ISO timestamp of generation completion
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `onPromote` — Callback invoked when user clicks Promote; receives `generationId`
- `onRegenerate` — Callback invoked when user clicks Regenerate
- `onDiscard` — Callback invoked when user clicks Discard

## Interactions

- Promote action opens a modal to confirm entry type, title, and target universe before creating a canon entry from the generation
- Regenerate re-submits the same prompt and context configuration to the generation queue
- Discard marks the generation as discarded and collapses/removes the card with a brief fade-out; undoable via toast for 5 seconds
- Clicking the excerpt text expands it to full content in a modal or inline reader
- Source count is a link; clicking it opens a panel listing the canon entries that were injected as context
- Promoted and discarded states render the card in a muted style with a status badge replacing the action buttons
