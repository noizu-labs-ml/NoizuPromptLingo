# Methodology Selector

| Field | Value |
|-------|-------|
| **ID** | `methodology-selector` |
| **Category** | Domain-Specific |
| **Used In** | 12-Project Creation Wizard |

## Description

Card-based picker for project methodologies (Scrum, Kanban, Waterfall, hybrid) with visual previews

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dropdown selector with badge display |
| **Expanded** | Card grid with descriptions and previews |

## Props / Configuration

- `options` — array of {id, name, description, preview}
- `selected` — current methodology
- `onChange` — callback

## Interactions

- click card to select
- hover for methodology preview
- view what board layout will look like
