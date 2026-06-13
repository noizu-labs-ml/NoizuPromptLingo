# Template Card

| Field | Value |
|-------|-------|
| **ID** | `template-card` |
| **Category** | Cards & Tiles |
| **Used In** | 21-Template Library, 44-Checklist Library, 64-Prompt Template Library |

## Description

Reusable template preview card showing name, type, usage count, and quick-apply action

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Name + type badge + usage count |
| **Expanded** | Card with preview, description, and apply button |

## Props / Configuration

- `name` — string
- `type` — project|document|checklist|prompt
- `usageCount` — number
- `description` — string
- `versionCount` — number

## Interactions

- click to preview
- apply/fork action
- edit template
- view version history
