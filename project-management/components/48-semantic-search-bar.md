# Semantic Search Bar

| Field | Value |
|-------|-------|
| **ID** | `semantic-search-bar` |
| **Category** | AI-Specific |
| **Used In** | 22-OTel Span Search |

## Description

Free-text natural language search input that uses embedding-based similarity to find relevant OTel spans. Results ranked by similarity score. Can be combined with structured attribute filters for hybrid search.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single search input bar with "semantic" indicator badge |

## Props / Configuration

- `query` — Current search text
- `onSearch` — Callback to execute semantic search
- `combinedWithFilters` — Whether results intersect with attribute filters
- `resultsSortBy` — similarity | timestamp

## Interactions

- Type natural language query
- Submit to search by semantic similarity
- Results ranked by similarity score
- Combine with structured attribute filters
