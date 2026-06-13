# Diff Viewer

| Field | Value |
|-------|-------|
| **ID** | `diff-viewer` |
| **Category** | Data Display |
| **Used In** | 03-Script Version Diff, 10-Run Diff, 17-Review Detail, 31-Rubric Score Comparison |

## Description

Side-by-side or inline comparison view for textual and structured content. Supports diffing agent responses, node configurations, score values, and full graph structures. Color-codes additions (green), removals (red), and modifications (amber).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Inline unified diff for short text (promotion preview in Review Detail) |
| **Expanded** | Side-by-side split panel for response text and score comparison |
| **Full Page** | Full-screen dual-pane view (Script Version Diff, Run Diff) |

## Props / Configuration

- `left` — Left/older content
- `right` — Right/newer content
- `mode` — `side-by-side` | `inline` | `graph-overlay`
- `contentType` — `text` | `json` | `graph` | `scores`
- `syncScroll` — Keep both sides scrolled in sync
- `highlightDeltas` — Whether to highlight numeric deltas (for score comparison)

## Interactions

- Toggle between side-by-side and inline modes
- Synchronized scrolling between panels
- Click changed sections to expand detail
- For score diffs: highlight disagreement rows
