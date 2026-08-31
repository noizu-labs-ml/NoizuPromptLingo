# 38: Selectable List

| Field | Value |
|-------|-------|
| ID | CMP-38 |
| Category | Tables & Lists |
| Surfaces | cli-ink, tui-ratatui |
| Used In | SCR-16, SCR-17, SCR-18, SCR-19, SCR-21, SCR-23, SCR-24, SCR-25, SCR-26, SCR-27, SCR-36, SCR-37 |

## Description
The foundational keyboard-navigable list primitive underlying nearly every terminal screen in both the CLI-ink interactive app and skill-manage's ratatui TUI: cursor-based focus (`j`/`k`/arrows), optional multi-select, and a consistent row-rendering contract that CMP-05 (Conversation List Item), tag rows, dataset rows, prompt rows, and skill-manage catalog rows all plug into.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Single-select | Browse/navigate lists (Explore, Projects, Tags, Prompts, Datasets) |
| Multi-select | Thread Editor message selection, bulk operations |
| Grouped | Explore grouped-by-project mode, interleaving Group Header (CMP-08) rows with item rows |

## Props / Configuration
- `items` — row data array
- `cursor` — focused index
- `selected` — set of selected indices (multi-select variant)
- `renderRow` — per-surface row renderer (ConversationRow, tag row, catalog row, etc.)

## Interactions
- `↑↓` / `j k` move the cursor; `Enter` activates the focused row
- `Space` toggles selection in multi-select contexts
- Scroll position and cursor persist across re-renders triggered by background data refresh
