# Role / Option Card

| Field | Value |
|-------|-------|
| **ID** | `role-card` |
| **Category** | Cards & Tiles |
| **Used In** | 27-Onboarding Flow, 34-Data Export |

## Description

Selectable card for discrete option choices, operating with radio or multi-select behavior. Used in onboarding to select user role and in export flows to select format or scope options.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Two-up selector layout with icon, label, and selected state ring |
| **Expanded** | Feature card with icon, label, description, and feature list |

## Props / Configuration

- `label` — Primary option label
- `description` — Supporting description text
- `icon` — Icon displayed alongside the label
- `selected` — Whether this option is currently selected
- `disabled` — Whether the option is unavailable for selection
- `onSelect` — Handler called when the card is activated
- `multiSelect` — When true, allows concurrent selection with other cards

## Interactions

- Click to select; deselects other cards when in radio mode
- Renders a distinct active state (border highlight, fill, or checkmark) when selected
