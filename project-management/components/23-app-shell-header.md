# App Shell Header

| Field | Value |
|-------|-------|
| **ID** | `app-shell-header` |
| **Category** | Navigation & Layout |
| **Used In** | 06-organization-picker, 07-user-profile, 08-mcp-api-keys-setup, 09-admin-home |

## Description

The persistent authenticated-app top bar — org switcher, user menu, and (for platform admins) the admin entry point. Present on every authenticated screen; the screens above are where it's explicitly named as the access point into org-switching, the user menu, or admin.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Persistent top bar across all authenticated routes |

## Props / Configuration

- `currentOrg` — active org context, drives the org switcher
- `showAdminEntry` — visible only to platform admins
- `userMenuItems` — profile, MCP keys, sign out, etc.

## Interactions

- User opens the org switcher → picks a different org, routing into that org's Dashboard
- User opens the user menu → navigates to Profile, MCP API Keys & Setup, or signs out
- Platform admins see and can click an admin entry point → routes to Admin Home
