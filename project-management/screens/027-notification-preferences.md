# Notification Preferences

| Field | Value |
|-------|-------|
| **ID** | notification-preferences |
| **Type** | Settings |
| **Category** | Settings |
| **User Stories** | US-077 |

## Description

Configure email and in-app notifications per category.

## Key Components

- **Category Toggles** — Collaborator edits, consistency checks, AI generation complete, comments/mentions, billing alerts (US-077)
- **Email vs In-App** — Separate toggles per category (US-077)
- **Disable All** | Turn off both email and in-app per category (US-077)
- **Save Button** — Apply preferences (US-077)
- **Preview Section** — Example notifications for each category (US-077)

## Interactions

- Disabling email still sends in-app notification
- Disabling both sends nothing
- Notifications delivered within 60 seconds of event
- Bulk edits limited to one email per category per 15 min per universe
- Preferences persisted per user

## Navigation

- Accessible from: Account Settings (Notifications tab)
- Links to: None