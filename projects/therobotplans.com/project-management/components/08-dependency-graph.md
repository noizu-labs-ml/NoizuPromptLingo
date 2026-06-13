# Dependency Graph

| Field | Value |
|-------|-------|
| **ID** | `dependency-graph` |
| **Category** | Data Display |
| **Used In** | 16-Gantt View, 20-Cross-Project Dependencies, 37-Anomaly Correlation, 50-Goal Alignment Viz, 60-Agent Collaboration Protocol |

## Description

Interactive node-link visualization showing relationships between entities with zoom/pan and path highlighting

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Interactive pannable graph in a panel |
| **Full_Page** | Full-screen graph with sidebar detail |

## Props / Configuration

- `nodes` — array of entities
- `edges` — array of relationships
- `highlightPaths` — critical/blocked paths
- `layout` — tree|radial|force
- `onNodeClick` — handler

## Interactions

- zoom/pan
- click node to navigate
- hover for tooltip
- filter nodes by type
- highlight critical paths
