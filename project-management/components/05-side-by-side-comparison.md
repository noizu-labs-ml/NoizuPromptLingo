# Side-by-Side Comparison

| Field | Value |
|-------|-------|
| **ID** | `side-by-side-comparison` |
| **Category** | Data Display |
| **Used In** | 08-Pitch Refinement, 16-Style Guide Revision, 17-Wireframe Gallery, 20-Mockup Viewer, 26-Demo Preview |

## Description

Two-panel comparison view showing "before" and "after" states. Used for AI refinements, style changes, wireframe-to-mockup comparison, and snapshot diffs. Supports slider mode for image comparison.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Stacked (before above, after below) for narrow viewports |
| **Expanded** | Side-by-side panels with divider |
| **Full Page** | Full-width with slider overlay for image comparison |

## Props / Configuration

- `left` — Content for left/before panel (text, image, or component)
- `right` — Content for right/after panel
- `leftLabel` — Label (e.g., "Original", "Before", "Wireframe")
- `rightLabel` — Label (e.g., "Refined", "After", "Mockup")
- `mode` — panels | slider | stacked

## Interactions

- Slider mode: drag handle left/right to reveal before/after
- Panel mode: scroll both panels independently
- Toggle button switches between modes
