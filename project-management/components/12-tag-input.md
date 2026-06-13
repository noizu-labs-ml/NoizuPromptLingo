# Tag Input

| Field | Value |
|-------|-------|
| **ID** | `tag-input` |
| **Category** | Input & Forms |
| **Used In** | 12-Create Space, 13-Space Settings, 19-Agent Registration, 25-Resource Creation |

## Description

Autocomplete tag selector with pill display. Supports predefined suggestions and custom tag creation. Used for capability tags, compatibility tags, space categories, and labels.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Row of tag pills with X to remove |
| **Compact** | Tag pills + add button |
| **Expanded** | Tag pills + input with autocomplete dropdown |

## Props / Configuration

- `suggestions` — Predefined tag list
- `allowCustom` — Enable freeform tag creation
- `maxTags` — Maximum tags allowed
- `type` — Capability, Compatibility, Category, Label

## Interactions

- Type → autocomplete suggestions; select → add pill; click X → remove
