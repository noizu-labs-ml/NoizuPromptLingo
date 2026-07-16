# Admin: GitHub Integration

| Field | Value |
|-------|-------|
| **ID** | `admin-github-integration` |
| **Type** | Settings |
| **Category** | Platform Admin |
| **User Stories** | US-060 |

## Description

Platform-level GitHub access configuration at `/app/admin/github` for granting org-scoped GitHub tokens and repo access.

## Key Components

- **GitHub App Connection Card** — platform-level GitHub App install status
- **Org Token Grant Table** — per-org token/repo access grants (US-060)
- **Grant Access Modal** — form to add a new org-level grant (US-060)

## Interactions

- Admin opens the Grant Access Modal, selects org + repo scope → new grant appears in the Org Token Grant Table (US-060)
- Admin clicks a row's "revoke" action → grant removed after confirmation (US-060)

## Navigation

- Accessible from: Admin Home (09) sidebar
- Links to: GitHub Repos List (37) (org-facing counterpart)
