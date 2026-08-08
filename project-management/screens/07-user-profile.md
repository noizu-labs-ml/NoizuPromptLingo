# User Profile

| Field | Value |
|-------|-------|
| **ID** | `user-profile` |
| **Type** | Settings |
| **Category** | Core Shell |
| **User Stories** | US-052, US-094 |

## Description

Personal account settings at `/app/profile` where a user manages their own display details and display preferences, independent of any single organization. Includes the accessibility theme toggle.

## Key Components

- **Profile Details Form** — name, avatar, contact fields (US-052)
- **Theme Selector** — switches between the default and High-Contrast Nocturne theme (US-094)
- **Account Security Panel** — connected identity/provider info (read-only, sourced from OIDC)
- **Save Confirmation Toast** — confirms profile updates persisted

## Interactions

- User edits a field on the Profile Details Form and saves → Save Confirmation Toast appears (US-052)
- User toggles the Theme Selector → theme applies immediately across the app shell without a reload (US-094)

## Navigation

- Accessible from: app-shell user menu, available from any authenticated screen
- Links to: none (terminal settings screen); back-navigation returns to the prior screen
