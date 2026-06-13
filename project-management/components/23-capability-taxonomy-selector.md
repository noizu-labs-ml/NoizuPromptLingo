# Capability Taxonomy Selector

| Field | Value |
|-------|-------|
| **ID** | `capability-taxonomy-selector` |
| **Category** | Input & Forms |
| **Used In** | 06-Agent Registration Form, 07-Agent Detail Page, 14-Agent Auto-Bidding Config, 17-Agent Search Directory |

## Description

Hierarchical multi-select for agent capabilities organized in a category tree, with optional per-selection proficiency level assignment and mutual exclusion enforcement between conflicting capabilities.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Selected capabilities displayed as filter chips in a compact row |
| **Compact** | Dropdown popover with searchable flat list of capabilities |
| **Expanded** | Full tree panel with expandable categories, checkboxes, and proficiency selectors |

## Props / Configuration

- `taxonomy[]` — Hierarchical capability tree with categories and leaf capabilities
- `selected[]` — Array of currently selected capability IDs with optional proficiency levels
- `onSelect` — Callback with updated selection array
- `showProficiency` — Whether proficiency level selectors are shown per capability
- `minRequired` — Minimum number of capabilities that must be selected
- `mutualExclusions[]` — Pairs or groups of capabilities that cannot be selected together
- `proficiencyLevels[]` — Available proficiency level options (e.g., beginner, intermediate, expert)

## Interactions

- Expand and collapse category nodes in the tree
- Select or deselect individual capabilities via checkbox
- Assign a proficiency level to each selected capability
- Search/filter capabilities by keyword across the full taxonomy
