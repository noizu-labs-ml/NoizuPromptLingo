# Root Dashboard

| Field | Value |
|-------|-------|
| **ID** | root-dashboard |
| **Type** | Dashboard |
| **Category** | Universe |
| **User Stories** | US-012, US-073 |

## Description

Main platform dashboard showing all universes and recent activity.

## Key Components

- **Universe Grid** — Cards for each universe with cover image, name, entry count (US-012)
- **New Universe Button** — Primary CTA to create universe (US-009)
- **Recent Activity Feed** — Platform-wide recent entries (US-073)
- **Quick Filters** — Filter by ownership (My Universes, Shared) (US-092)
- **Search Bar** — Search universes by name (US-009)
- **Universe Actions** — Open, Settings, Delete per universe (US-013)
- **Empty State** — CTA for first universe creation (US-005)
- **Sidebar Navigation** — Access to settings, logout (US-076)

## Interactions

- Click universe card to open Universe Overview
- Delete requires name confirmation
- New Universe opens creation wizard
- Search filters by universe name
- Filter by ownership type
- Activity feed shows latest across universes

## Navigation

- Accessible from: Post-login root
- Links to: Universe Overview, Universe Settings, Universe Creation Wizard, Account Settings