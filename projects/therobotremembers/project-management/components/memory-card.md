---
id: component-memory-card
name: "Memory Card"
used_in: [screen-memory-explorer, screen-recall-console, screen-memory-graph, screen-guardian-alerts]
---

# Memory Card

## Purpose
The primary display unit for a memory entry. Shows a content preview, emotional state badge, weight indicator, lifecycle state, age, and key metadata. Used in grids, lists, and detail panels throughout the application. Designed to convey the "texture" of a memory — not just what it says, but how it felt when it was formed.

## Props/Inputs
- `id`: string -- Memory UUID
- `content`: string -- Full memory content text
- `summary`: string -- Compressed summary (used when space is limited)
- `contentType`: enum (episodic | semantic | procedural) -- Memory type
- `emotionalMetadata`: EmotionalMetadata -- Full emotional state object
- `createdAt`: datetime -- Formation timestamp
- `decayWeight`: float (0.0 to 1.0) -- Current decay weight
- `recallCount`: int -- Number of times recalled
- `state`: enum (active | decaying | archived | quarantined | pruned) -- Lifecycle state
- `domain`: string -- Session domain at formation
- `associationCount`: int -- Number of association edges
- `compartment`: string -- Access compartment (optional display)
- `variant`: enum (compact | standard | expanded) -- Display variant (default: standard)
- `relevanceScore`: float (optional) -- Relevance score when shown in recall results
- `resonanceScore`: float (optional) -- Emotional resonance score when shown in recall results

## Visual Description

### Standard Variant (default)
```
+--------------------------------------------------+
|  [EmotionBadge: frustrated]    episodic   2d ago  |
|                                                    |
|  "Postgres deadlock during migration. Advisory     |
|   locks held across transactions causing..."       |
|                                                    |
|  Weight: ████████░░ 0.82    Recalls: 4             |
|  Domain: debugging    Associations: 7              |
+--------------------------------------------------+
```

- **Card dimensions**: Responsive, min-width 280px, max-width 400px. Height adjusts to content.
- **Border**: 1px solid, color = faded version of the emotion badge color. Left border 3px solid in the emotion badge color.
- **Background**: White (light mode) / gray-900 (dark mode). Subtle opacity reduction as `decayWeight` decreases (opacity = 0.5 + 0.5 * decayWeight).
- **Content preview**: First 120 characters of `content` (or `summary` if variant is compact). Ellipsis if truncated.
- **Weight bar**: Horizontal progress bar. Green (> 0.7), amber (0.3-0.7), red (< 0.3). Shows numeric value.
- **Content type tag**: Small pill badge (episodic = blue, semantic = purple, procedural = green).
- **Lifecycle state indicator**: If state is not `active`, show a state badge in the top-right (decaying = amber pulse, archived = grey, quarantined = red border, pruned = strikethrough).

### Compact Variant
Single line: `[EmotionBadge] "Summary text..." | w: 0.82 | 2d ago`
Used in lists and sidebar panels.

### Expanded Variant
Standard card plus: full metadata table (all emotional values, contextual metadata, collaborators, environment), association list (top 5 by weight), and action buttons (Reinforce, Denforce, View in Graph, Edit).

## Interaction
- **Click** (standard/compact): Navigate to `/memories/:id`
- **Hover** (standard): Slight elevation shadow. Show full content if truncated.
- **Right-click**: Context menu: Reinforce, Denforce, View in Graph, Copy ID, View in Timeline
- **Long press / Shift+click** (expanded): Toggle selection for batch operations
