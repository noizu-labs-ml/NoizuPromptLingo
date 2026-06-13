# Knowledge Base Search

| Field | Value |
|-------|-------|
| **ID** | `knowledge-search` |
| **Type** | Primary |
| **Category** | Documentation & Wiki |
| **User Stories** | US-062 |

## Description

Full-text search across wiki pages, docs, runbooks, ADRs, and changelogs with relevance ranking, snippet previews, and deep-link to specific sections.

## Key Components

- **Search input** — Search bar with instant results
- **Result list with snippets** — Ranked results with highlighted context
- **Type filter** — Filter results by content type (wiki, ADR, runbook, etc.)
- **Project filter** — Scope search to specific projects
- **Date filter** — Narrow by creation or last-modified date
- **Deep-link to section** — Results link directly to the matching section

## Interactions

- Type to search with instant results (debounced)
- Click result to navigate directly to matching section
- Filter to narrow result set
- Recent searches shown on empty state
- Keyboard navigation through results

## Navigation

- Accessible from: Global search (Cmd+/), Documentation nav
- Links to: Wiki pages, ADRs, Runbooks, Deploy Changelogs
