# Canon Candidate Card

| Field | Value |
|-------|-------|
| **ID** | `canon-candidate-card` |
| **Category** | Session Companion |
| **Used In** | S-15 Session Companion (Extract Mode) |

## Description

Card representing an AI-extracted canon candidate identified from session notes. Shows the suggested entry title, inferred type, a content preview, confidence indicator, and two primary actions: accept (promote to canon) or reject. Multiple candidates may appear in a scrollable review list.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Title, type badge, and accept/reject icon buttons only — used when reviewing a long list of candidates quickly |
| **Expanded** | Full card with content preview (4–6 lines), confidence bar, suggested tags, and labeled action buttons |

## Props / Configuration

- `candidateId` — Unique ID of the extracted candidate record
- `suggestedTitle` — AI-inferred entry title
- `suggestedType` — AI-inferred entry type (e.g., "Character", "Location", "Faction")
- `contentPreview` — Extracted or generated content preview text (up to ~300 chars)
- `confidence` — Float 0–1 representing extraction confidence; rendered as a color-coded bar
- `suggestedTags` — Array of tag strings the AI recommends for the new entry
- `sourceExcerpt` — Snippet of the session note text that prompted this extraction; shown in a blockquote
- `status` — `"pending"` | `"accepted"` | `"rejected"`
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `onAccept` — Callback invoked with `candidateId` when user clicks Accept
- `onReject` — Callback invoked with `candidateId` when user clicks Reject
- `onEdit` — Callback invoked when user wants to edit before accepting; opens a pre-filled entry creation form

## Interactions

- Accept creates a new canon entry with the suggested title, type, content, and tags; a success toast confirms with a link to the new entry
- Before accepting, user may click Edit to adjust the title, type, or content in a modal form; saving the form then promotes the candidate
- Reject marks the candidate as rejected and removes the card from the list with a brief fade-out; undoable via toast for 5 seconds
- Confidence bar is color-coded: green (>0.75), amber (0.4–0.75), red (<0.4); low-confidence cards show a "Review carefully" label
- Source excerpt is shown in a collapsible blockquote so users can verify the extraction against the original note text
- Keyboard: Tab navigates between candidates; A accepts, R rejects, E opens the edit form
- Batch actions: "Accept All High-Confidence" button above the list accepts all candidates with confidence > 0.75 in one click
