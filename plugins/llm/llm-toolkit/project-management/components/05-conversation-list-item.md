# 05: Conversation List Item (Card / Row)

| Field | Value |
|-------|-------|
| ID | CMP-05 |
| Category | Cards & Tiles |
| Surfaces | web, cli-ink |
| Used In | SCR-01, SCR-02, SCR-03, SCR-16, SCR-17, SCR-18 |

## Description
The single most-reused unit in the product: a summary of one conversation (title, project badge, date, message count, tags, status badge, and optionally a first/last-message preview snippet). Renders as a card in dashboard/browse-grouped contexts (`ThreadCard`) and as a dense single-line row in list contexts (`ThreadRow`); the CLI-ink `ConversationRow` is the terminal equivalent of the Row variant.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Card | Grouped/browse dashboard contexts — more visual weight, preview snippet shown |
| Row | Dense list contexts (Project Detail, flat Explore) — one line, minimal chrome |
| Compact (cli-ink) | `ConversationRow` — single terminal line: title, project, date, message count |

## Props / Configuration
- `conversation` — `{ id, title, projectPath, messageCount, startedAt, updatedAt, status, tags, firstMessage?, lastMessage? }`
- `previewMode` — `"both" \| "first" \| "last" \| "none"` — controls which message preview(s) render
- `selected` — boolean — multi-select state for bulk actions (archive/tag/rehome)

## Interactions
- Click/Enter navigates to Thread Viewer (SCR-04 / SCR-19)
- Selection checkbox (web BulkActionBar contexts) or `Space` (cli-ink) toggles multi-select for bulk operations
