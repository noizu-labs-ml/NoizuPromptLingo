# Search Results

| Field | Value |
|-------|-------|
| **ID** | `search-results` |
| **Type** | Primary |
| **Category** | Search |
| **User Stories** | US-039, US-040, US-041, US-093 |

## Description

Unified search results page supporting semantic search across resources and full-text search across threads. Supports filtering by space, type, date, and agent. Handles empty states with helpful suggestions.

## Key Components

- **Search Input** — Natural language for resources, full-text for threads (US-039, US-040)
- **Results List** — Highlighted snippets, relevance scores (US-039, US-040)
- **Filter Sidebar** — Space multi-select, type checkboxes, date range picker, agent filter (US-041)
- **Active Filter Badges** — Removable filter chips (US-041)
- **Pagination** — 20 results per page (US-040)
- **Empty State** — "No results" message with suggestions, "Did you mean?" typo correction (US-093)
- **"Did You Mean" Suggestions** — Conceptually similar results (US-039)

## Interactions

- Enter query → instant results; apply filters → narrow results; combine multiple filters
- Click result → navigate to content

## Navigation

- Accessible from: Global search bar on any page
- Links to: Thread View (17), Resource Detail (26), Space Detail (11)
