# Settings Hub

| Field | Value |
|-------|-------|
| **ID** | `settings` |
| **Type** | Settings |
| **Category** | Settings |
| **User Stories** | US-071, US-075, US-088, US-100 |

## Description

Centralized settings page with sidebar navigation across categories. Manages account, profile, notifications, privacy, API keys, danger zone, and theme preferences.

## Key Components

- **Settings Sidebar** — Category navigation (Account, Profile, Notifications, Privacy, API Keys, Danger Zone) (US-071)
- **Category Highlight** — Active state indicator (US-071)
- **Theme Selector** — Light, Dark, High Contrast (US-100)
- **Delete Account** — Multi-step confirmation flow (US-075)
- **Create Organization** — Org creation form (US-088)
- **Avatar Dropdown** — Quick access to Settings, Profile, Logout (US-071)

## Interactions

- Navigate categories via sidebar; change theme; manage account; delete account with confirmation

## Navigation

- Accessible from: Avatar dropdown on any page → "Settings"
- Links to: Notification Settings (42), Privacy Settings (43), Edit Profile (37), Organization Profile (44)
