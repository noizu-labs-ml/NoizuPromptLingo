# Reader Codex View

| Field | Value |
|-------|-------|
| **ID** | reader-codex |
| **Type** | Primary |
| **Category** | Collaboration |
| **User Stories** | US-094 |

## Description

Public-facing, spoiler-safe codex for readers.

## Key Components

- **Universe Header** — Title, description, cover image (US-094)
- **Entry List** | Non-spoiler entries only (US-094)
- **Clean Layout** | No editing controls visible (US-094)
- **Spoiler Filters** | Hides entries with spoiler flag or unreleased status (US-094)
- **Release Horizon Badge** | Shows entries with future release dates (US-094)
- **Graph View** | Spoiler-filtered knowledge graph (US-094)
- **Search Bar** | Returns only non-spoiler results (US-094)
- **Broken Link Handler** | [Redacted] placeholder for hidden links (US-094)
- **Navigation** | Home, Codex, Graph, About (US-094)

## Interactions

- Server-enforced spoiler filtering
- Hidden entries never sent to client
- Release dates auto-hide past threshold
- Search filters out spoiler content
- Broken/hidden links replaced with placeholder
- No editing capabilities
- Open Graph tags for rich previews

## Navigation

- Accessible from: Public Universe URL (/u/{slug})
- Links to: Entry Detail (non-spoiler only), Public Graph