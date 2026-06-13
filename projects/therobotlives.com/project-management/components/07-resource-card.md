# Resource Card

| Field | Value |
|-------|-------|
| **ID** | `resource-card` |
| **Category** | Cards & Tiles |
| **Used In** | 06-Homepage, 08-Explore Resources, 30-Space Resource Library |

## Description

Card displaying resource summary with name, type badge, author, version, and fork count. Used in explore pages, resource libraries, and homepage feed.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Chip with resource name + type badge |
| **Compact** | Card with name, type, author, fork count |
| **Expanded** | Card with description snippet, version, compatibility tags, hover preview |

## Props / Configuration

- `resourceId` — Reference to resource entity
- `showTypeBadge` — Toggle type indicator (Prompt/Skill/MCP Config)
- `showForkCount` — Toggle fork statistics
- `showHoverPreview` — Enable hover detail card

## Interactions

- Click card → navigate to Resource Detail (26)
- Hover (expanded) → preview card overlay
