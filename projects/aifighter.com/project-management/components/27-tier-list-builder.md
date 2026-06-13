# Tier List Builder

| Field | Value |
|-------|-------|
| **ID** | `tier-list-builder` |
| **Category** | Domain-Specific |
| **Used In** | 07-Laboratory |

## Description

Drag-and-drop tier list tool with S/A/B/C/D rows. Users drag build cards into tiers, save drafts, and export the completed list as an image or shareable link.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Full builder interface with tier rows and build card pool |

## Props / Configuration

- `tiers` — Tier row definitions (labels, colors, order)
- `builds` — Available build cards for placement
- `savedDraft` — Draft state for restoring in-progress lists
- `published` — Whether the list is in published state

## Interactions

- Drag build cards into tier rows
- Reorder builds within a tier row
- Search and filter available builds
- Save current state as draft
- Publish tier list
- Export completed tier list as image
