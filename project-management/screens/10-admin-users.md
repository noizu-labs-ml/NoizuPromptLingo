# Admin: Users

| Field | Value |
|-------|-------|
| **ID** | `admin-users` |
| **Type** | Dashboard |
| **Category** | Platform Admin |
| **User Stories** | US-054, US-055 |

## Description

Platform-wide user management at `/app/admin/users` for suspending accounts and changing global roles, with a built-in guard against an admin locking themselves out of their own admin access.

## Key Components

- **User Search Table** — searchable/sortable list of all platform users
- **Suspend Account Toggle** — suspends/reinstates a user (US-054)
- **Global Role Selector** — changes a user's platform-wide role (US-055)
- **Self-Lockout Warning Modal** — blocks/confirms role changes that would remove the acting admin's own admin access (US-055)

## Interactions

- Admin toggles the Suspend Account Toggle → confirmation prompt, then the account is suspended immediately (US-054)
- Admin changes their own role via the Global Role Selector → Self-Lockout Warning Modal intercepts and requires explicit confirmation (US-055)

## Navigation

- Accessible from: Admin Home (09) sidebar
- Links to: individual user detail (inline expansion, same screen)
