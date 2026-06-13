# Universe Details

| Field | Value |
|-------|-------|
| **ID** | `universe-details` |
| **Type** | Primary |
| **Category** | Universe |
| **User Stories** | US-010, US-012, US-013, US-014 |

## Description

Read-focused landing screen for a single universe, displaying its metadata, description, and key stats before the user commits to entering the full editor or settings. Acts as a "splash" view between the global dashboard and the deep workspace — useful for orienting collaborators and owners alike when switching universes.

## Key Components

- **Universe Header** — Name, cover image/banner, genre tags, and created/last-modified dates (US-012)
- **Description Panel** — Full universe description text with rich-text rendering; truncated at 400 chars with "Read more" expand (US-012)
- **Stats Strip** — Entry counts by type (Characters, Locations, Events, Factions, Items) as labeled chips (US-012)
- **Collaborators Preview** — Avatar stack of active collaborators with count badge; links to Collaborators Panel (US-010)
- **Access Level Badge** — Owner / Co-owner / Editor / Viewer indicator for the current user (US-010)
- **Primary Actions Bar** — "Open Universe" (enters Overview Dashboard), "Settings" (Universe Settings), overflow menu with Duplicate and Delete (US-010, US-013, US-014)
- **Duplicate Dialog** — Inline confirmation modal prompting for new name before duplicating (US-014)
- **Delete Confirmation** — Destructive-action modal requiring the user to type the universe name to confirm (US-013)
- **Public Share Status** — Pill indicating whether the universe is publicly shared; links to sharing settings (US-010)

## Interactions

- "Open Universe" navigates to Universe Overview Dashboard
- "Settings" navigates to Universe Settings screen
- Duplicate triggers inline dialog; on confirm, creates copy and redirects to the new universe's Details screen
- Delete requires typed confirmation; on confirm, soft-deletes and returns user to global Dashboard
- Clicking collaborator avatars opens Collaborators Panel modal
- Public status pill opens Privacy Settings if owner, otherwise is read-only

## Navigation

- Accessible from: Global Dashboard (universe card click), Universe Creation Wizard (completion), Universe Settings (back link)
- Links to: Universe Overview Dashboard, Universe Settings, Collaborators Panel, Privacy Settings, Global Dashboard (post-delete)
