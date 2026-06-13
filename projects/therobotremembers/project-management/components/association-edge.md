---
id: component-association-edge
name: "Association Edge"
used_in: [screen-memory-graph, screen-recall-console]
---

# Association Edge

## Purpose
Visual representation of a weighted link between two memories in the association graph. Encodes edge type, weight, and directionality through visual properties (color, thickness, opacity, dash pattern). Used in the force-directed graph canvas and the recall console's association path view.

## Props/Inputs
- `id`: string -- Edge UUID
- `sourceId`: string -- Source memory UUID
- `targetId`: string -- Target memory UUID
- `weight`: float (0.0 to 1.0) -- Current association strength
- `edgeType`: enum (semantic | emotional | temporal | causal | co-occurrence | synthetic) -- Type of association
- `createdBy`: string -- Agent that created this link
- `reason`: string -- Why this link was created (shown in tooltip)
- `reinforcementCount`: int -- Number of reinforcements
- `highlighted`: boolean -- Whether this edge is part of a highlighted path (default: false)
- `selected`: boolean -- Whether this edge is currently selected (default: false)

## Visual Description

### Edge Type Color Mapping

| Edge Type | Color | Dash Pattern |
|-----------|-------|-------------|
| semantic | `#4299E1` (blue) | Solid |
| emotional | `#E53E3E` (red) | Solid |
| temporal | `#48BB78` (green) | Dashed (4px dash, 4px gap) |
| causal | `#ED8936` (orange) | Solid |
| co-occurrence | `#A0AEC0` (grey) | Dotted (2px dash, 2px gap) |
| synthetic | `#9F7AEA` (purple) | Long dash (8px dash, 4px gap) |

### Weight Encoding

- **Line thickness**: 1px (weight < 0.3) to 4px (weight > 0.8). Linear interpolation.
- **Opacity**: 0.2 (weight < 0.1) to 1.0 (weight > 0.5). Low-weight edges are barely visible unless hovered.
- **Glow effect** (weight > 0.8): Subtle CSS/WebGL glow in the edge type color.

### States

- **Default**: Color by type, thickness by weight, opacity by weight.
- **Highlighted** (part of a recall path): Full opacity, increased thickness (+1px), white outline glow. Animated dash for dashed/dotted edges.
- **Selected**: Full opacity, max thickness, tooltip pinned open.
- **Dimmed** (when another edge or node is selected): 10% opacity, 1px thickness.

## Interaction
- **Hover**: Tooltip appears at cursor showing:
  - Edge type label
  - Weight (numeric, e.g., "0.73")
  - Created by (agent name)
  - Reason text
  - Reinforcement count
  - "Click for details"
- **Click**: Select the edge. Tooltip pins open. Both connected nodes highlight. Detail panel (if present) shows edge metadata.
- **Double-click**: Navigate to a split view showing both connected memories side by side.
