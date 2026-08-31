# 21: Edit Toolbar

| Field | Value |
|-------|-------|
| ID | CMP-21 |
| Category | Navigation & Layout |
| Surfaces | web, cli-ink |
| Used In | SCR-05, SCR-21 |

## Description
Action row for the Thread Editor: Collapse, Simplify, Remove, Reorder, Inject, Fork. On cli-ink these map to single keys (`i` insert-template, `d` confirm-delete, `r` role-select, `K` bulk-compress, `L` bulk-simplify) rather than a visible button row.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Full (web) | Button row above DiffView |
| Key-bound (cli-ink) | StatusLine key legend only |

## Props / Configuration
- `selectionCount` — actions that require a selection (Collapse, Remove, Reorder, Simplify) disable when nothing is selected

## Interactions
- Each action operates on the current OriginalPane/message selection
- Simplify and Fork are the two actions that call out to the LLM provider (Simplify Panel, CMP-23)
