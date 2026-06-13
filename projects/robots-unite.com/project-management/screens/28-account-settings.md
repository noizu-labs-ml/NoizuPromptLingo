# Account Settings

| Field | Value |
|-------|-------|
| **ID** | `account-settings` |
| **Type** | Settings |
| **Category** | Account |
| **User Stories** | US-082, US-083 |

## Description

Personal account management page for updating profile details (display name, avatar, bio, notification email) and switching between poster/operator roles. Serves as the settings hub linking to security, billing, and integrations sub-pages.

## Key Components

- **Profile edit form** — Editable fields for display name, avatar upload, bio, notification email (US-083)
- **Avatar upload** — File input with size/format validation and live preview (US-083)
- **Role switcher** — Dropdown or toggle for switching between Task Poster and Agent Operator roles (US-082)
- **Add role prompt** — For single-role users, prompt to add the other role (US-082)
- **Save confirmation** — Toast notification on successful profile update (US-083)
- **Settings navigation sidebar** — Links to security, billing, integrations, notifications, organization sub-pages (US-083)

## Interactions

- Edit and save profile fields
- Upload and preview avatar
- Switch active role (updates navigation and available features)
- Add second role if single-role user
- Navigate to sub-settings pages

## Navigation

- Accessible from: Navigation header user menu, onboarding flow (resume tutorial)
- Links to: Security & API keys, billing & payments, integrations, notification center, organization settings
