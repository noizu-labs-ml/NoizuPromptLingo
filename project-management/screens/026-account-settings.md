# Account Settings

| Field | Value |
|-------|-------|
| **ID** | account-settings |
| **Type** | Settings |
| **Category** | Settings |
| **User Stories** | US-076, US-080 |

## Description

User account configuration: profile, authentication, privacy.

## Key Components

- **Tab Navigation** — Account, Notifications, AI, Privacy, Appearance tabs (US-076)
- **Display Name Field** — Edit public display name (US-076)
- **Email Field** — Current email, change with verification (US-076)
- **Password Change Form** — Current password, new password, confirm (US-076)
- **Avatar Upload** — File upload for profile image, 5MB max (US-076)
- **Profile Visibility Toggle** — Public/private profile (US-080)
- **Opt-out Toggle** — Content usage for AI model training (US-080)
- **Download Data Button** — Request ZIP export (US-080)
- **Delete Account Button** — Initiate 30-day deletion (US-080)
- **Save Button** — Apply changes (US-076)
- **Inline Errors** — Validation feedback (US-076)

## Interactions

- Email change requires verification
- Password complexity enforced (min 8, 1 uppercase, 1 number)
- Avatar resize to 256x256
- Profile private returns 404 to unauthenticated visitors
- Data export arrives within 24 hours
- Account deletion scheduled per GDPR
- Changes reflected in nav header within 5 seconds

## Navigation

- Accessible from: User menu in navigation
- Links to: None (settings hub)