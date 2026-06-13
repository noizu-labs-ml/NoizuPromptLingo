# Member Management

| Field | Value |
|-------|-------|
| **ID** | `member-management` |
| **Category** | Input & Forms |
| **Used In** | 24-Organization Settings |

## Description

Member list with role management and invite workflow. Shows current members with email, role, and join date. Includes invite form with email input and role picker (admin, editor, viewer).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full section within Organization Settings |

## Props / Configuration

- `members` — Array of { email, name, role, joinedAt }
- `onInvite` — Callback with email and role
- `onRoleChange` — Callback when a member's role is changed
- `onRemove` — Callback when a member is removed
- `roles` — Available roles (admin, editor, viewer)

## Interactions

- View member list
- Invite new members via email + role picker
- Change existing member roles
- Remove members
