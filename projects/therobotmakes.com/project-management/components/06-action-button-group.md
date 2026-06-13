# Action Button Group

| Field | Value |
|-------|-------|
| **ID** | `action-button-group` |
| **Category** | Input & Forms |
| **Used In** | 08-Pitch Refinement, 09-Persona Curation, 10-Story Curation, 16-Style Guide Revision, 20-Mockup Viewer |

## Description

Grouped action buttons for Accept/Reject/Regenerate or Accept/Reject/Refine patterns. Primary action is emphasized, destructive actions have confirmation. Consistent across all curation screens.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon buttons in a row (for tight spaces) |
| **Compact** | Labeled buttons in a horizontal group |

## Props / Configuration

- `actions` — Array of {label, variant: primary|secondary|destructive, icon, onClick}
- `layout` — horizontal | vertical
- `requireConfirmation` — Array of action indices that need confirmation dialog

## Interactions

- Primary action (Accept) is visually emphasized
- Destructive actions (Reject) show confirmation if configured
- Disabled state when processing
