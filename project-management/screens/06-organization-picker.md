# Organization Picker

| Field | Value |
|-------|-------|
| **ID** | `organization-picker` |
| **Type** | Dashboard |
| **Category** | Core Shell |
| **User Stories** | US-037, US-046 |

## Description

Post-login landing surface at `/app` and `/app/organizations` listing every organization the authenticated user belongs to, and offering the entry point to register a brand-new organization. Typically the first screen returning users see after SSO completes.

## Key Components

- **Organization Card Grid** — one card per org the user can access (US-046)
- **Create Organization Button** — launches new-org registration (US-037)
- **Org Search/Filter Bar** — narrows the list for users belonging to many orgs
- **Recent Activity Snippet** — per-card summary of recent sessions/tickets

## Interactions

- User clicks an org card → routes into that org's Dashboard (17) (US-046)
- User clicks "Create Organization" → inline form collects name/key prefix, then creates and enters the new org (US-037)

## Navigation

- Accessible from: SSO Callback (03) on first login, app-shell org-switcher from any authenticated screen
- Links to: Org Dashboard (17), new-org creation flow
