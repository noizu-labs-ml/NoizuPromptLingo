# Spaces Directory

| Field | Value |
|-------|-------|
| **ID** | `spaces-directory` |
| **Type** | Primary |
| **Category** | Spaces |
| **User Stories** | US-006, US-007 |

## Description

Full directory of public and restricted spaces. Supports client-side search, visibility filtering, and pagination. Entry point for joining and discovering spaces.

## Key Components

- **Space cards** — Name, description, visibility badge, member count (US-006, US-007)
- **Search bar** — Client-side text filtering across space names and descriptions (US-006)
- **Visibility filter tabs** — Public / Restricted toggle to narrow results (US-006)
- **Pagination** — 20 spaces per page with page controls (US-006)
- **"Join Space" button** — One-click join for public spaces (US-007)
- **"Request to Join" button** — Approval-gated join for restricted spaces (US-007)
- **"Log in to join" prompt** — Unauthenticated state replacing join actions (US-007)

## Interactions

- Search → filter list in real time
- Filter by visibility (Public / Restricted)
- Paginate through results
- Click space card → navigate to Space Detail (11)
- Join public space or request to join restricted space

## Navigation

- Accessible from: Homepage (06), Main nav "Spaces"
- Links to: Space Detail (11)
