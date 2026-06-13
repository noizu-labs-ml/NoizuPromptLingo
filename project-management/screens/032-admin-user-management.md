# Admin User Management

| Field | Value |
|-------|-------|
| **ID** | admin-user-management |
| **Type** | Primary |
| **Category** | Admin |
| **User Stories** | US-084 |

## Description

Admin interface for searching, viewing, and managing user accounts.

## Key Components

- **Search Input** — Search by email or username (US-084)
- **User List** — Results with status, plan, creation date, last login (US-084)
- **User Detail View** — Account information, activity section (US-084)
- **Suspend Account Button** | Lock user out immediately (US-084)
- **Plan Selector** — Change user plan tier (US-084)
- **Grant Admin Role Toggle** — Add admin access with audit log (US-084)
- **Activity Feed** — Last 50 actions with timestamps (US-084)
- **Bulk Export Button** — CSV export of users (US-084)

## Interactions

- Search results appear within 500ms
- Suspended users immediately logged out
- Plan changes take effect immediately
- Admin role changes write to audit log
- Activity feed shows logins, generations, edits

## Navigation

- Accessible from: Admin Dashboard (Users link)
- Links to: User Detail View