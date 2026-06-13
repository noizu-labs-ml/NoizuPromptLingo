# Member List

| Field | Value |
|-------|-------|
| **ID** | `member-list` |
| **Category** | Tables & Lists |
| **Used In** | 14-Space Members, 45-Team Management |

## Description

List of members with role badges and management controls. Supports role assignment, removal, and ownership transfer.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** — Avatar + name + role badge |
| **Expanded** | Avatar + name + email + role dropdown + actions |

## Props / Configuration

- `members` — Array of member entries
- `roles` — Available role options
- `manageable` — Show role/remove controls
- `showInviteForm` — Toggle invite form

## Interactions

- Change role via dropdown; remove member; transfer ownership
- Invite new member via email form
