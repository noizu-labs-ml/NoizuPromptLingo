# Space Detail

| Field | Value |
|-------|-------|
| **ID** | `space-detail` |
| **Type** | Primary |
| **Category** | Spaces |
| **User Stories** | US-005, US-006, US-010, US-083, US-092 |

## Description

Individual space landing page. Shows pinned resources, featured threads, thread list, space metadata (description, rules, links). Displays empty state when no threads exist. Includes archived state variant.

## Key Components

- **Space header** — Name, description, visibility badge, member count (US-005)
- **Pinned resources section** — Max 5 pinned resources displayed prominently (US-010)
- **Featured threads section** — Max 3 featured threads highlighted (US-010)
- **Thread list** — Paginated list of threads within the space (US-010)
- **Community Rules card** — Markdown-rendered rules for the space (US-005)
- **External links sidebar** — Up to 5 external links related to the space (US-005)
- **"Create first thread" CTA** — Empty state prompt when no threads exist (US-010)
- **"Join this space" prompt** — Displayed for non-members viewing the space (US-006)
- **"(Archived)" badge** — Read-only banner when space is archived (US-092)
- **Space tags/categories** — Tags describing the space topic or theme (US-083)

## Interactions

- Browse threads in the space
- View pinned resources
- Click featured threads to read
- Read community rules
- Follow external links
- Start a new thread (members only)

## Navigation

- Accessible from: Spaces Directory (10), Homepage (06), Search Results (31), Explore Spaces (07)
- Links to: Thread View (17), Thread Creation (18), Resource Detail (26), Space Settings (13)
