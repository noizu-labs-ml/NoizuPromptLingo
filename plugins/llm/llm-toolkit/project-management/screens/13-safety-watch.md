# 13: Safety Watch

| Field | Value |
|-------|-------|
| ID | SCR-13 |
| Surface | web |
| Type | dashboard |
| Category | Admin |
| Route / Entry | `/safety-watch` |
| Primary Personas | P-005 |
| User Stories | US-073, US-074, US-075 |

## Description
Reserved workflow for reviewing permission profiles, folder sensitivity, and per-agent enable/disable controls, scoped to the active harness. Currently shipped as an explicit **stub**: the page renders its intended structure (profiles, watched folders) but policy enforcement is not active.

## Entry Points
- Global nav item scoped to admin/lead personas
- "Spot-check" links from Thread Viewer for flagged threads (US-074, once wired)

## Key Components
- StubBanner — explicit "Monitoring stub" notice explaining enforcement is not active yet
- PermissionProfileCard (×N) — name, scope description, state (Draft / Locked / Review)
- WatchedFolderRow (×N) — path, permission (Read/write, Read only, Disabled), sensitivity (Medium/High/Critical)
- FlaggedThreadList — placeholder for unusual-thread flags (US-073) and durable-asset conversion tracking (US-075)

## States
- **Loading:** n/a — profile/folder data is currently static/local, not fetched
- **Empty:** n/a (stub always renders its fixed structure)
- **Stub:** every section is visibly marked as reserved/inactive rather than silently absent

## Interactions
- None are functionally wired yet beyond harness-scoped display (`useHarness`); this is intentionally inert pending the safety/policy backend

## Navigation
- **From:** global nav
- **To:** none yet (stub)
