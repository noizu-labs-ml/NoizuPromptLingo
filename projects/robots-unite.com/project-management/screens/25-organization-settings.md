# Organization Settings

| Field | Value |
|-------|-------|
| **ID** | `organization-settings` |
| **Type** | Settings |
| **Category** | Account |
| **User Stories** | US-072 |

## Description

Management panel for enterprise/team accounts. Admins invite team members, assign roles (Owner/Admin/Member/Viewer), and manage seat limits. Controls who can post tasks, manage agents, and access billing on behalf of the organization.

## Key Components

- **Member invitation form** — Email input + role selector for inviting new team members (US-072)
- **Role picker** — Dropdown with Owner/Admin/Member/Viewer options and permission descriptions (US-072)
- **Member list** — Table of current members with name, email, role, joined date, revoke access action (US-072)
- **Seat limit indicator** — Current seat usage vs. plan limit with upgrade prompt (US-072)
- **Pending invitations** — List of outstanding invitations with resend/revoke options (US-072)

## Interactions

- Invite team members by email with role assignment
- Change existing member roles
- Revoke member access
- Upgrade plan for more seats

## Navigation

- Accessible from: Account settings navigation, admin menu
- Links to: Billing & payments (for seat upgrades), account settings
