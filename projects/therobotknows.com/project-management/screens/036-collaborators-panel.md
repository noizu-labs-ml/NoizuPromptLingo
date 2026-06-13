# Collaborators Panel

| Field | Value |
|-------|-------|
| **ID** | collaborators-panel |
| **Type** | Modal |
| **Category** | Collaboration |
| **User Stories** | US-091, US-092 |

## Description

Manage universe collaborators with roles and permissions.

## Key Components

- **Invite Form** — Email input, role selector (Viewer/Editor/Co-owner), Send button (US-091)
- **Collaborator List** — Name, role, join date, last active (US-091, US-092)
- **Role Description** — What each role can do (US-092)
- **Change Role Button** — Modify collaborator role (US-092)
- **Remove Button** — Remove collaborator from universe (US-091)
- **Invite Status Badges** — Pending, Accepted, Expired (US-091)
- **Resend Invite Button** — For expired or pending invites (US-091)
- **Permission Matrix** — Role vs permission reference grid (US-092)

## Interactions

- Invitation email includes universe name and inviter
- New users directed to sign-up flow
- Pending invites expire after 7 days
- Role changes take effect immediately
- Removed collaborators invalidated from active sessions
- Downgrade shows read-only banner in active sessions

## Navigation

- Accessible from: Universe Settings (Collaborators)
- Links to: None