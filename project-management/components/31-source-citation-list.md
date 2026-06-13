# Source Citation List

| Field | Value |
|-------|-------|
| **ID** | `source-citation-list` |
| **Category** | AI Context / Attribution |
| **Used In** | S11 Generation Studio, S06 Generated Entry Detail, S16 Improvise Mode |

## Description

Ordered list of canon entries that were injected as context for an AI generation. Each row shows the entry title, type icon, a relevance score (0–100), a link to open the entry, and a remove button to exclude it from context before regenerating. In the generation studio this list is editable pre-generation; in entry detail it is read-only provenance.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Entry title + type icon + score pill; remove button appears on row hover; used in studio sidebar |
| **Expanded** | Title, type icon, score, short excerpt, remove button always visible; used in generated entry detail |

## Props / Configuration

- `citations` — Array of `{ id, title, entryType, relevanceScore, excerpt, href }`
- `editable` — Boolean; when true shows remove buttons and drag-to-reorder handles
- `onRemove` — Callback `(entryId: string) => void`; called when user removes a citation
- `onReorder` — Callback `(orderedIds: string[]) => void`; called after drag reorder
- `maxVisible` — Number; citations beyond this count are collapsed behind "Show more"; defaults to 5
- `size` — `compact | expanded`

## Interactions

- Each row title is a link opening the cited entry in a new tab or slide-over
- Remove button (×) calls `onRemove`; row animates out; list re-scores remaining entries
- In editable mode, rows have drag handles for manual reordering; `onReorder` fires on drop
- Relevance score pill color: green ≥70, amber 40–69, muted <40
- "Show more / Show less" toggle collapses rows beyond `maxVisible`
