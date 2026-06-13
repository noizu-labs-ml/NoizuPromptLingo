# Visibility Selector

| Field | Value |
|-------|-------|
| **ID** | `visibility-selector` |
| **Category** | Input & Forms |
| **Used In** | 12-Create Space, 13-Space Settings |

## Description

Dropdown for setting content visibility. Options: Public, Restricted, Private, Org Only. Shows context-sensitive descriptions for each option.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Dropdown with icon + selected value |

## Props / Configuration

- `options` — Available visibility levels
- `showOrgOption` — Enable Org Only for org members
- `currentValue` — Currently selected visibility

## Interactions

- Select option → update; unsaved changes indicator
