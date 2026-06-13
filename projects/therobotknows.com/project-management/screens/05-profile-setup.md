# Profile Setup Screen

| Field | Value |
|-------|-------|
| **ID** | profile-setup |
| **Type** | Primary |
| **Category** | Authentication |
| **User Stories** | US-004 |

## Description

First-run profile configuration for display name, avatar, and creative role.

## Key Components

- **Display Name Field** — Text input for display name (US-004)
- **Avatar Upload** — File upload for profile image (max 256x256) (US-004)
- **Role Selector** — Dropdown: Novelist, Game Master, Narrative Designer, Podcaster, Worldbuilder, Other (US-004)
- **Save Button** — Continue to app (US-004)
- **Skip Button** — Use default avatar and generic role (US-004)
- **Preview** — Avatar preview and initials fallback (US-004)

## Interactions

- User must complete after registration
- Avatar automatically resized to 256x256
- Original images discarded after resize
- Role selection pre-selects templates in universe creation
- Can be changed later in Account Settings
- Redirects to Dashboard on save or skip

## Navigation

- Accessible from: Email verification (on success), OAuth callback
- Links to: Dashboard (on completion)