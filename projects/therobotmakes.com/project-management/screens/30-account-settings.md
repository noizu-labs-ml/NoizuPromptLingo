# Account Settings

| Field | Value |
|-------|-------|
| **ID** | `account-settings` |
| **Type** | Settings |
| **Category** | Platform |
| **User Stories** | INK-089, INK-090, INK-091, INK-092, INK-096 |

## Description

Account configuration hub covering API keys (BYOK), connected accounts (GitHub/Google), data export, team workspace management, and account deletion. Sections organized by risk level with "Danger Zone" at bottom.

## Key Components

- **API Key Manager** — Provider list with status, add/edit/delete form, masked display, "Test Key" validation (INK-089)
- **Connected Accounts** — GitHub/Google integration cards with OAuth connect/disconnect, "Push to GitHub" unlock (INK-090)
- **Data Export** — "Download All Projects" button with async generation and email notification (INK-091)
- **Team Workspace** — Member list, invite by email, role assignment (Owner/Editor/Viewer), project move between workspaces (INK-096)
- **Danger Zone** — Account deletion with email-type-to-confirm, data export reminder, irreversibility warning (INK-092)

## Interactions

- API keys: add → masked display → "Test Key" validates connectivity → cost savings estimate shown in Ink phase
- Connected accounts: OAuth connect/disconnect; re-auth if token expired
- Data export: click → async generation → email notification on ready
- Team: invite → role select → accept flow
- Delete: type email to confirm → data export prompt → subscription auto-cancel → permanent deletion

## Navigation

- Accessible from: Settings nav, user avatar dropdown
- Links to: OAuth providers (external), Download files, Team invite emails
