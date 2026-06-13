# Roles & Permissions

| Field | Value |
|-------|-------|
| **ID** | `roles-and-permissions` |
| **Type** | Settings |
| **Category** | Collaboration |
| **User Stories** | US-091, US-092 |

## Description

Dedicated configuration screen for universe owners and co-owners to define role capabilities and review the full permission matrix. Surfaces what each built-in role (Viewer, Editor, Co-owner) can and cannot do, and allows per-universe overrides where the plan tier supports them. Separates the concern of *who has a role* (handled in Collaborators Panel) from *what each role means*.

## Key Components

- **Role Tabs** — Tab strip: Viewer | Editor | Co-owner | (Custom, if plan supports) (US-092)
- **Permission Matrix Table** — Rows are permission actions (View Entries, Edit Entries, Add Entries, Delete Entries, Run Generation, Manage Collaborators, Change Settings, Delete Universe); columns are roles; cells are checkboxes or lock icons for non-editable built-ins (US-092)
- **Role Description Card** — Prose summary of the selected role's intended use and scope (US-092)
- **Custom Role Builder** — Name field + permission checkbox grid for plan tiers with custom roles; Save / Discard buttons (US-092)
- **Invite Quick-Link** — "Invite collaborators using these roles" button linking to Collaborators Panel (US-091)
- **Unsaved Changes Banner** — Sticky warning when a custom role has been modified but not saved (US-092)
- **Reset to Defaults Button** — Restores built-in role permissions to platform defaults; requires confirmation (US-092)

## Interactions

- Switching tabs updates the Permission Matrix and Role Description Card
- Built-in role checkboxes are read-only (lock icon with tooltip explaining they are platform-defined)
- Custom role checkboxes are editable; changes require explicit Save
- Saving a custom role immediately propagates to all collaborators currently assigned that role
- Reset to Defaults triggers a confirmation dialog before applying
- Invite Quick-Link opens Collaborators Panel as an overlay, retaining Roles & Permissions in background

## Navigation

- Accessible from: Universe Settings (Collaboration section), Collaborators Panel (Manage Roles link)
- Links to: Collaborators Panel
