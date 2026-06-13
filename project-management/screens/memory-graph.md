---
id: screen-memory-graph
title: "Association Graph"
route: /memories/graph
personas: [persona-the-weaver, persona-the-archivist, persona-the-dreamer]
priority: must-have
---

# Association Graph

## Purpose
Force-directed graph visualization of the memory association web. This is the system's signature view — it makes the free-association network visible and navigable. Operators use it to understand how memories cluster, identify isolated nodes, discover unexpected associations, and debug the Weaver's link-building behavior.

## Layout

```
+------------------------------------------------------------------+
|  Graph Controls Toolbar                                           |
|  [Zoom +/-] [Fit] [Center] [Reset] | Color by: [Emotion|Domain|  |
|  Age|Weight] | Edge filter: [All|Semantic|Emotional|Temporal|     |
|  Causal|Co-occurrence] | Min weight: [slider 0.0-1.0]            |
+------------------------------------------------------------------+
|                                                                    |
|  Force-Directed Graph Canvas (full remaining viewport)            |
|                                                                    |
|       ○──────○                                                     |
|      / \    / \         ○                                          |
|     ○   ○──○   ○───────○                                          |
|      \       \ /       /                                           |
|       ○───────○───────○                                            |
|                \                                                   |
|                 ○──○                                               |
|                                                                    |
+-------------------------------+------------------------------------+
|  Selected Node Detail Panel   |  (only visible when node selected) |
|  [MemoryCard - expanded]      |  Connections: {n} edges            |
|  [EmotionBadge]               |  Strongest: {memory title, w=0.9} |
|  Weight: ████████░░ 0.82      |  [View Detail] [Reinforce]        |
|  Formed: 2025-12-23 02:34     |  [View Subgraph] [Highlight Path] |
+-------------------------------+------------------------------------+
```

## Key Components
- **Graph Canvas**: WebGL-rendered force-directed graph (e.g., using `@react-sigma/core` or `d3-force` with canvas renderer). Nodes are memories; edges are association links. The graph runs a force simulation with configurable physics (repulsion, attraction by edge weight, gravity toward center).
- **Node Rendering**: Circle nodes. Size proportional to `decay_weight`. Color mapped by the active color mode (emotion → valence spectrum, domain → categorical palette, age → blue-to-red gradient, weight → green-to-grey).
- **Edge Rendering** (uses `component-association-edge`): Lines between nodes. Opacity and thickness proportional to edge weight. Color by edge type when edge filter is active.
- **Graph Controls Toolbar**: Zoom, fit-to-view, center on selection, reset physics. Color mode selector. Edge type filter (show only specific edge types). Minimum weight slider (hide edges below threshold).
- **Selected Node Detail Panel**: Appears when a node is clicked. Shows the memory card, emotion badge, connection count, strongest connections, and action buttons.

## Interactions
- **Click node** → Select node. Highlight its edges. Open detail panel. Connected nodes pulse briefly.
- **Double-click node** → Navigate to `/memories/:id`
- **Click edge** → Show edge detail tooltip (type, weight, created by, reason)
- **Drag node** → Pin the node in place (manual layout override). Drag again to unpin.
- **Scroll/pinch** → Zoom in/out
- **Shift + click two nodes** → Highlight shortest weighted path between them
- **"View Subgraph" button** → Filter graph to show only the selected node and its N-hop neighborhood (configurable, default 2)
- **"Highlight Path" button** → Enter path mode: click another node to show the association path between them
- **Search overlay** → Type to search within visible graph. Matching nodes pulse and camera pans to the cluster.

## Data Requirements
- `GET /api/v1/memories` with `include=associations` — returns memories with edge lists
- For large graphs (>500 nodes): server-side graph sampling. Request a subgraph centered on a seed memory or the most connected cluster.
- `GET /api/v1/memories/:id/path/:target_id` — for path highlighting
- WebSocket subscription for real-time edge/node additions (new memories, new links)

## States
- **Empty state**: "No memories stored yet. As the system forms memories and builds associations, the graph will appear here."
- **Loading state**: Spinner centered on canvas. Progress indicator for large graph loads ("Loading 1,247 nodes...").
- **Sparse graph** (< 10 nodes): Disable force simulation, use simple circular layout. Note: "The association web is still forming."
- **Large graph** (> 1000 nodes): Auto-enable server-side sampling. Show cluster-level overview with drill-down. Warning: "Showing sampled view. Click a cluster to expand."
- **Error state**: Overlay on canvas with error message and retry button.
