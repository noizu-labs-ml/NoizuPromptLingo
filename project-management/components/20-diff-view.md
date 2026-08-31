# 20: Diff View

| Field | Value |
|-------|-------|
| ID | CMP-20 |
| Category | Tables & Lists |
| Surfaces | web |
| Used In | SCR-05 |

## Description
Side-by-side comparison shell used by Thread Editor: a read-only OriginalPane (source messages with selection checkboxes) and a draggable, inline-editable EditedPane (the working draft). Also reused by Version Timeline (CMP-16) to diff two saved versions.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Edit mode | OriginalPane vs. live EditedPane draft |
| Version-compare mode | Two saved versions, both read-only |

## Props / Configuration
- `original` — message array
- `edited` — message array (draft or a saved version)
- `selection` — set of selected original-message indices
- `mode` — `"edit" \| "compare"`

## Interactions
- Checkbox-select in OriginalPane enables Collapse/Remove/Reorder actions in EditToolbar (CMP-21)
- Drag-and-drop reorder within EditedPane (edit mode only — compare mode is fully read-only)
