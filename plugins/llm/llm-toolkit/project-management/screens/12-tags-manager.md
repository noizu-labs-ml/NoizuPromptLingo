# 12: Tags Manager

| Field | Value |
|-------|-------|
| ID | SCR-12 |
| Surface | web |
| Type | settings |
| Category | Admin |
| Route / Entry | `/tags` |
| Primary Personas | P-005, P-001 |
| User Stories | US-061, US-067 |

## Description
Central registry of tag metadata (color, description) and usage counts across all conversations. Lets a team standardize tag color/meaning rather than letting free-text tags drift, and surfaces bulk-tag entry points.

## Entry Points
- Global nav "Tags"
- Tag-chip "manage" affordance from Thread Viewer / Browse

## Key Components
- TagEntryRow — tag name, color swatch (from `COLOR_PRESETS`), description, usage count, "has metadata" indicator
- ColorPicker — preset color swatches (cyan/green/orange/purple/pink/gold/red/blue)
- TagEditForm — inline edit of description/color for an existing tag
- CreateTagDialog

## States
- **Loading:** skeleton rows while conversations + tag-metadata endpoints resolve
- **Empty:** "No tags yet" — tags typically originate from tagging a conversation elsewhere first
- **Error:** inline banner on save failure

## Interactions
- Editing color/description on a tag that has no explicit metadata record yet creates one on save
- Usage count is derived by cross-referencing tag metadata against tags actually present on conversations
- Bulk-tag entry point (US-067) links into Browse/Explore with multi-select active

## Navigation
- **From:** global nav
- **To:** SCR-01 Explore (bulk-tag flow)
