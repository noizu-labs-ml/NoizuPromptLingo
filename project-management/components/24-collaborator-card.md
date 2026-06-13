# Collaborator Card

| Field | Value |
|-------|-------|
| **ID** | `collaborator-card` |
| **Category** | Forms |
| **Used In** | S13 Collaborators Panel |

## Description

User card displayed in the collaborators management panel. Shows the collaborator's avatar, display name, email, role badge, join date, and last-active timestamp. Provides inline controls to change the collaborator's role or remove them from the universe.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single horizontal row with avatar, name, role badge, last active, and action icons; used in the collaborators list |

## Props / Configuration

- `collaborator` — User object: `{ id, name, email, avatarUrl, role, joinedAt, lastActiveAt }`
- `role` — Current role: `owner` | `editor` | `viewer`; drives badge color and available actions
- `availableRoles` — Array of roles the current user is permitted to assign
- `onRoleChange` — Callback fired with `{ collaboratorId, newRole }` on role selection
- `onRemove` — Callback fired with `collaboratorId` when the remove action is confirmed
- `isCurrentUser` — Boolean; hides change-role and remove controls for the viewer's own card
- `canManage` — Boolean; controls whether action controls are rendered (owners only)
- `loading` — Boolean; shows a spinner and disables controls while an action is in progress

## Interactions

- Role badge is a clickable dropdown (if `canManage` is true and `availableRoles` has options) that opens an inline role-selection menu
- Selecting a new role fires `onRoleChange` and optimistically updates the badge; reverts on API error with an error toast
- Remove button (trash icon) appears on hover for users the current user can manage; clicking opens a confirmation dialog before firing `onRemove`
- `isCurrentUser` cards show a "(You)" label suffix on the name and suppress management controls
- Owner cards show a crown icon next to the role badge and cannot be demoted or removed unless ownership is transferred
- Last-active timestamp renders as a relative time string (e.g., "3 days ago") with the absolute date in a tooltip
