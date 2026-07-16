# Admin: Organizations

| Field | Value |
|-------|-------|
| **ID** | `admin-organizations` |
| **Type** | Dashboard |
| **Category** | Platform Admin |
| **User Stories** | US-056 |

## Description

Platform-wide organization directory at `/app/admin/orgs` for listing and searching every org on the platform, used by admins investigating or supporting a specific tenant.

## Key Components

- **Organization Search Table** — searchable/sortable list of all orgs (US-056)
- **Org Status Badge** — active/suspended/trial state per row (US-056)
- **Org Quick-View Drawer** — summary panel without leaving the list

## Interactions

- Admin searches/filters the Organization Search Table → results narrow live (US-056)
- Admin clicks a row → Org Quick-View Drawer opens with key metadata

## Navigation

- Accessible from: Admin Home (09) sidebar
- Links to: Org Dashboard (17) for the selected org (admin view context)
