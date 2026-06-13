# Filter Bar

| Field | Value |
|-------|-------|
| **ID** | `filter-bar` |
| **Category** | Navigation & Layout |
| **Used In** | 01-Today Dashboard, 05-Inbox, 11-Archive, 13-Kanban Board, 15-Portfolio Dashboard, 21-Template Library, 24-Bug SLA Dashboard, 25-Root Cause Dashboard, 27-Pipeline Status, 28-Environment Dashboard, 34-SLO Dashboard, 43-Knowledge Search, 44-Checklist Library, 48-OKR Hierarchy, 55-Agent Audit Log, 63-Prompt Tagging, 70-Eval Dashboard |

## Description

Horizontal bar of filter controls (dropdowns, toggles, search) that narrow displayed content

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact chip-based active filters |
| **Compact** | Single row of filter dropdowns |
| **Expanded** | Multi-row with advanced filter options |

## Props / Configuration

- `filters` — array of filter definitions
- `activeFilters` — current state
- `onChange` — callback
- `showClear` — boolean
- `presets` — saved filter sets

## Interactions

- select filter values
- clear all filters
- save filter as preset
- keyboard shortcut to focus
