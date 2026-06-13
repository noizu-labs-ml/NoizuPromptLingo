# Search Results Screen

| Field | Value |
|-------|-------|
| **ID** | search-results |
| **Type** | Primary |
| **Category** | Search |
| **User Stories** | US-069, US-070, US-072 |

## Description

Search results display for full-text and semantic search queries.

## Key Components

- **Search Input** — Global keyword or concept query (US-069, US-070)
- **Search Type Toggle** — Full-text vs Semantic Search tabs (US-069, US-070)
- **Results List** — Matching entries ranked by relevance (US-069)
- **Result Cards** — Entry name, type, tags, 300-char excerpt, last-edited timestamp (US-069)
- **Highlighted Snippets** — Keyword highlighted in context (US-069)
- **Similarity Score** — For semantic: % match display (US-070)
- **Preview Panel** — Hover expansion with more details (US-072)
- **Filter Sidebar** — Type, tag, era filters (US-071)
- **No Results State** — Suggestion to check spelling/broaden search (US-069)
- **Clear Button** — Clear search and return to default view (US-069)

## Interactions

- Full-text returns exact matches, semantic returns meaning matches
- Phrase search with quotes matches exact phrase
- Hover shows rich preview
- Click result navigates to entry detail
- Filters update result set immediately
- Semantic results sorted by similarity score descending
- Background job re-embeds after entry save (5 min)

## Navigation

- Accessible from: Global search bar, Canon Editor
- Links to: Canon Entry Detail