---
id: screen-memory-timeline
title: "Memory Timeline"
route: /memories/timeline
personas: [persona-the-archivist, persona-the-curator, persona-the-dreamer]
priority: should-have
---

# Memory Timeline

## Purpose
Chronological view of memories with an emotional color overlay. The timeline reveals temporal patterns — bursts of activity, emotional shifts, seasonal recurrences — that are invisible in the card grid or graph views. The Dreamer uses this view to validate consolidation decisions; operators use it to understand the system's "life history."

## Layout

```
+------------------------------------------------------------------+
|  Timeline Controls                                                |
|  Zoom: [Hour|Day|Week|Month|Year] | Filter: [Domain ▼] [Mood ▼]  |
|  [Collaborator ▼] | Show: [All types|Episodic|Semantic|Procedural]|
+------------------------------------------------------------------+
|  Emotional Heatmap Strip (horizontal, scrollable)                 |
|  ┌────────────────────────────────────────────────────────────┐   |
|  │ ████ ████ ██████████ ████ ██ ████████ ██████ ████ ██ ████ │   |
|  │ blue  blue  red     green  blue  orange  green  red  blue │   |
|  │ Dec 1      Dec 8     Dec 15     Dec 22     Dec 29          │   |
|  └────────────────────────────────────────────────────────────┘   |
+------------------------------------------------------------------+
|  Timeline Body (vertical, scrollable, synced with heatmap)        |
|                                                                    |
|  ── Dec 23, 2025 ──────────────────────────────────────────       |
|  │                                                                 |
|  ├── 02:34 AM  [EmotionBadge: frustrated]                         |
|  │   "Postgres deadlock during migration..."                      |
|  │   weight: 0.82 | domain: debugging | 4 associations            |
|  │                                                                 |
|  ├── 02:51 AM  [EmotionBadge: focused]                            |
|  │   "Root cause: advisory locks held across transactions"        |
|  │   weight: 0.90 | domain: debugging | 7 associations            |
|  │                                                                 |
|  ├── 03:15 AM  [EmotionBadge: relieved]                           |
|  │   "Fix: sequential migration runner with lock timeout"         |
|  │   weight: 0.95 | domain: debugging | 5 associations            |
|  │                                                                 |
|  ── Dec 22, 2025 ──────────────────────────────────────────       |
|  │                                                                 |
|  (continues...)                                                    |
+------------------------------------------------------------------+
```

## Key Components
- **Timeline Controls**: Time zoom (hour/day/week/month/year granularity), domain filter, mood filter (positive/negative/neutral), collaborator filter, content type filter.
- **Emotional Heatmap Strip**: Horizontal strip synced with the timeline scroll position. Each segment represents a time bucket colored by the average emotional valence of memories in that bucket (blue = negative, grey = neutral, green = positive, red = high arousal + negative). Clicking a heatmap segment scrolls the timeline to that period.
- **Timeline Body**: Vertical timeline with date headers. Each memory entry shows timestamp, emotion badge, content preview (first ~80 chars), weight bar, domain tag, and association count. Entries are grouped by day.
- **Emotion Badge** (uses `component-emotion-badge`): Color-coded badge next to each entry showing the dominant emotional state at formation.
- **Consolidation Markers**: Visual indicators where the Dreamer has consolidated memories. Shows the source memories and the resulting composite.

## Interactions
- **Click memory entry** → Navigate to `/memories/:id`
- **Hover memory entry** → Expand to show full metadata preview, association list
- **Click heatmap segment** → Scroll timeline to that time period and highlight memories in that bucket
- **Zoom control** → Change granularity of heatmap and grouping of timeline entries
- **Filter change** → Re-render timeline with filtered memories; heatmap recalculates
- **Scroll timeline** → Heatmap cursor follows to show current position
- **"Jump to date" button** → Date picker to jump to a specific date

## Data Requirements
- `GET /api/v1/memories` with date range, sorted by `created_at` descending
- Heatmap aggregation endpoint: `GET /api/v1/memories/emotional-heatmap?start=...&end=...&bucket_size=day` returning average valence per bucket
- Lazy loading: fetch memories in date-range chunks as the user scrolls

## States
- **Empty state**: Empty timeline with "No memories recorded yet" centered. Heatmap strip is blank.
- **Loading state**: Skeleton entries in the timeline body. Heatmap shows loading shimmer.
- **Single day loaded**: Show that day's memories with a note: "Scroll down or use date picker to explore more."
- **Error state**: Inline error at the top of the timeline body. Heatmap shows last-known state with dimmed opacity.
