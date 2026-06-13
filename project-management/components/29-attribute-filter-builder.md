# Attribute Filter Builder

| Field | Value |
|-------|-------|
| **ID** | `attribute-filter-builder` |
| **Category** | Input & Forms |
| **Used In** | 22-OTel Span Search, 32-Auto-Flag Rules |

## Description

Dynamic form for building key-value-operator filter conditions. Each condition specifies an attribute key, operator (equals, contains, presence, numeric range), and value. Conditions combine with AND logic. Used for OTel span queries and auto-flagging rule definitions.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Stacked condition rows with add/remove buttons |

## Props / Configuration

- `conditions` — Array of { key, operator, value }
- `operators` — Available operators (equals, contains, presence, gt, lt, range)
- `keySuggestions` — Autocomplete for known attribute keys
- `onConditionsChange` — Callback when conditions are modified

## Interactions

- Add new condition row
- Select key (with autocomplete), operator, and value
- Remove individual conditions
- Clear all conditions
