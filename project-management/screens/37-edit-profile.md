# Edit Profile

| Field | Value |
|-------|-------|
| **ID** | `edit-profile` |
| **Type** | Settings |
| **Category** | User Profile |
| **User Stories** | US-061 |

## Description

Profile editing form. Allows changing display name, username, bio, avatar, location, and website links. Validates username uniqueness and provides confirmation for username changes.

## Key Components

- **Display Name Input** — Editable name (US-061)
- **Username Input** — With uniqueness validator (US-061)
- **Bio Textarea** — Markdown editor (US-061)
- **Avatar Upload** — With crop/rotate processing (US-061)
- **Location Input** — Optional (US-061)
- **Website Links** — Multiple URL inputs (US-061)
- **Confirmation Dialog** — For username change (US-061)
- **Org Badge Toggle** — Show/hide org affiliation (US-061)

## Interactions

- Edit fields; upload/resize avatar; validate username; save changes

## Navigation

- Accessible from: User Profile (36) for self, avatar dropdown
- Links to: User Profile (36)
