# Card Grid

| Field | Value |
|-------|-------|
| **ID** | `card-grid` |
| **Category** | Cards & Tiles |
| **Used In** | 01-landing-page, 06-organization-picker, 18-projects-list |

## Description

A responsive grid of summary cards for entity collections that read better as tiles than table rows — organizations, projects, marketing feature pillars. Each card surfaces a name plus a short status/activity summary.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dense grid, name + single status line per card |
| **Expanded** | Grid with a recent-activity snippet or richer summary per card |

## Props / Configuration

- `items` — entities to render as cards
- `cardContent` — which summary fields render per card (status, activity snippet, icon)
- `onCardClick` — navigates into the selected entity

## Interactions

- User clicks a card → routes into that entity's detail/dashboard screen
- Grid reflows responsively as viewport width changes
