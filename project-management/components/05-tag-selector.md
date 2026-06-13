# Tag Selector

| Field | Value |
|-------|-------|
| **ID** | tag-selector |
| **Type** | Complex |
| **Category** | Forms |
| **Screen Usage** | Canon Entry Detail, Search Results Filter |

## Description

Multi-select tag input with autocomplete and tag management.

## Size Variants

- Compact — Inline tag input
- Standard — Default form field
- Full — Tag management panel

## Props

- `value` — Array of selected tags
- `availableTags` — All tags in universe
- `placeholder` — Input placeholder
- `maxTags` — Maximum tags allowed
- `allowCreate` — Allow creating new tags
- `multiSelect` — Enable multi-tag selection
- `filterMode` — AND/OR logic for filters

## Interactions

- Autocomplete suggestions from existing tags
- "Create tag: {text}" option for new tags
- Multi-word and emoji support
- Tag displays with remove (×) button
- Multi-tag filter applies AND logic (toggle for OR)
- Universe-scoped, not global
- Batch rename updates all references

## Accessibility

- Input has `aria-expanded` state
- Tags in listbox with `role="option"`
- Remove buttons labeled "Remove {tag name}"
- Escape closes autocomplete