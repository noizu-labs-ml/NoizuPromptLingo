# Improvise Panel

| Field | Value |
|-------|-------|
| **ID** | `improvise-panel` |
| **Category** | Session Companion |
| **Used In** | S-15 Session Companion (Improvise Mode) |

## Description

Floating quick-generation panel for live session use. Accepts a freeform prompt, automatically includes relevant canon context from the active universe, submits to the generation queue, and displays the result inline without navigating away from the session view.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed to a single-line prompt input with a send button; result appears below as an expandable row |
| **Expanded** | Full panel with prompt input, context indicators, result area, and action buttons — can be pinned open |

## Props / Configuration

- `universeId` — Active universe whose canon is used as generation context
- `sessionId` — Current session note ID; used to attach generated content to the session
- `defaultPrompt` — Pre-filled prompt text (e.g., from selected text in session notes)
- `contextEntries` — Array of entry IDs automatically selected as context; user can add/remove
- `isPinned` — Boolean; when true the panel stays open after generation completes
- `variant` — `"compact"` | `"expanded"` (default: `"compact"`)
- `onGenerate` — Callback invoked with prompt and context entry IDs when user submits
- `onPromote` — Callback invoked when user promotes inline result to canon
- `onPin` — Callback toggling pinned state

## Interactions

- Panel is triggered by a floating action button in the session companion; can also be opened via keyboard shortcut ⌘G
- Prompt input supports multi-line text; submits on ⌘Enter or clicking the Send button
- Context chip row shows auto-selected entries (based on recent session content); chips are removable and additional entries can be added via a search dropdown
- While generation is processing, the result area shows a streaming text animation as tokens arrive
- Completed result renders with a Promote button (creates a canon candidate) and a Copy button
- Compact variant collapses back to single-line after result is dismissed; expanded variant stays open if pinned
- Clicking outside the panel in compact mode dismisses it; pinned panels ignore outside clicks
