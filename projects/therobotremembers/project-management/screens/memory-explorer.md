---
id: screen-memory-explorer
title: "Memory Explorer"
route: /memories/explorer
personas: [persona-the-archivist, persona-the-curator, persona-the-guardian]
priority: must-have
---

# Memory Explorer

## Purpose
The primary memory browsing interface. Operators use this screen to search, filter, browse, and manage memories in the system. It provides full-text search combined with emotional, temporal, and contextual filters — reflecting the system's core principle that memories are retrievable by the shape of their formation moment, not just their content.

## Layout

```
+------------------------------------------------------------------+
|  [Search bar: full-text query]                    [View: Grid|List] |
+------------------------------------------------------------------+
|  Filter Panel (collapsible left sidebar)  |  Memory Card Grid      |
|                                           |                        |
|  Emotional Filters                        |  [MemoryCard]  [MC]    |
|    Valence slider: -1.0 ──── 1.0          |  [MC]          [MC]    |
|    Arousal slider:  0.0 ──── 1.0          |  [MC]          [MC]    |
|    Dominance slider: 0.0 ──── 1.0         |  [MC]          [MC]    |
|    Frustration: 0.0 ──── 1.0              |  [MC]          [MC]    |
|                                           |                        |
|  Hormone Filters                          |                        |
|    Cortisol:  0.0 ──── 1.0                |                        |
|    Dopamine:  0.0 ──── 1.0                |                        |
|    Oxytocin:  0.0 ──── 1.0                |                        |
|    Serotonin: 0.0 ──── 1.0                |                        |
|                                           |                        |
|  Contextual Filters                       |                        |
|    Content type: [episodic|semantic|proc]  |                        |
|    Domain: [dropdown]                     |                        |
|    Time of day: [morning|afternoon|...]   |                        |
|    Season: [spring|summer|autumn|winter]  |                        |
|    Date range: [from] - [to]              |                        |
|    Collaborator: [multi-select]           |                        |
|                                           |                        |
|  Lifecycle Filters                        |                        |
|    State: [active|decaying|archived|...]  |  ──────────────────    |
|    Weight range: 0.0 ──── 1.0             |  [Pagination / Load    |
|    Compartment: [dropdown]                |   More]                |
+-------------------------------------------+------------------------+
|  Status bar: Showing {n} of {total} | Avg weight: {w} | Filters: {count} active  |
+------------------------------------------------------------------+
```

## Key Components
- **Search Bar**: Full-text search with typeahead suggestions from recent queries. Supports quoted phrases and boolean operators (AND, OR, NOT).
- **Filter Panel**: Collapsible left sidebar. Emotional filters use range sliders. Contextual filters use dropdowns and date pickers. All filters are AND-combined. Each active filter shows as a removable chip above the results.
- **Memory Card Grid** (uses `component-memory-card`): Responsive grid of memory cards. Each card shows content preview, emotion badge, weight indicator, and age. Cards are clickable to navigate to `/memories/:id`.
- **View Toggle**: Switch between card grid and compact list view.
- **Sort Controls**: Sort by relevance (default when searching), creation date, decay weight, recall count, or emotional valence.
- **Pagination**: Infinite scroll with "Load More" fallback. Shows count of results.

## Interactions
- **Search** → Debounced full-text query (300ms) triggers re-fetch of results
- **Filter change** → Immediate re-fetch with all active filters applied
- **Click memory card** → Navigate to `/memories/:id`
- **Hover memory card** → Show expanded preview with full emotional metadata
- **Right-click memory card** → Context menu: Reinforce, Denforce, View in Graph, Copy ID
- **Clear all filters** → Reset to default (all memories, sorted by creation date)
- **Export** → Download filtered results as JSON or CSV

## Data Requirements
- `GET /api/v1/memories` with query params for all filter dimensions
- Full-text search via vector similarity (content embedding) combined with attribute filtering (Postgres metadata)
- Pagination via cursor-based pagination (not offset)
- Aggregation endpoint for status bar metrics (total count, avg weight)

## States
- **Empty state**: "No memories yet. Memories appear here as the system observes and stores new experiences." with illustration.
- **No results**: "No memories match your filters. Try broadening your search." with suggestions to remove specific filters.
- **Loading state**: Skeleton cards in the grid while fetching. Filter panel remains interactive.
- **Error state**: Inline error banner above results. Retry button. Filter panel remains accessible for query adjustment.
