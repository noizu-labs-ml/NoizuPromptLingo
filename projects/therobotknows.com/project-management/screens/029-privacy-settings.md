# Privacy Settings

| Field | Value |
|-------|-------|
| **ID** | privacy-settings |
| **Type** | Settings |
| **Category** | Settings |
| **User Stories** | US-080 |

## Description

Data privacy controls and account deletion.

## Key Components

- **Profile Visibility Toggle** — Public/private profile (US-080)
- **Content Opt-out Toggle** — Use my content for AI model training (US-080)
- **Data Download Button** | Request ZIP export (US-080)
- **Download Progress** | Status indicator for export preparation (US-080)
- **Delete Account Button** | Initiate 30-day deletion (US-080)
- **Delete Account Confirmation** | Type email to confirm, warning text (US-080)
- **Collaborator Warning** | Notice about universe ownership transfer (US-080)
- **Policy Links** — Links to Privacy Policy, Terms of Service (US-080)

## Interactions

- Profile private returns 404 to unauthenticated users
- Opt-out persisted to account, honored in training pipelines
- Data export arrives within 24 hours
- Account deletion scheduled per GDPR Article 17
- Collaborators notified of ownership transfer
- Cancellation available within 30-day window

## Navigation

- Accessible from: Account Settings (Privacy tab)
- Links to: None