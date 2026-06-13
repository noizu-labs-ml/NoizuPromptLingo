# Typeahead Selector

| Field | Value |
|-------|-------|
| **ID** | `typeahead-selector` |
| **Category** | Input & Forms |
| **Used In** | 02-Graph Editor, 04-Prompt Library, 05-Prompt Detail, 08-Run List, 12-Rubric Detail, 14-Persona Detail, 15-Run Trigger Modal, 19-Dataset Detail, 20-Flagged Captures Library |

## Description

Search-as-you-type dropdown for selecting entities (prompts, agents, scripts, personas, rubrics). Shows recent/frequent picks, supports version pinning, and can be configured for single or multi-select.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line input that expands a dropdown on focus (used in filter bars) |
| **Expanded** | Full panel with search, recent items, and categorized results (used in prompt picker) |

## Props / Configuration

- `entityType` — What kind of entity to search (prompt, agent, script, persona, rubric, dataset)
- `multiSelect` — Allow multiple selections
- `versionPinning` — Show version selector alongside entity
- `placeholder` — Input placeholder text
- `recentItems` — Show recently used items before typing
- `onSelect` — Callback with selected entity (and version if pinned)

## Interactions

- Type to search; results appear after 2+ characters
- Click or arrow-key to select from dropdown
- Clear selection with X button
- Pin to specific version via version sub-dropdown
