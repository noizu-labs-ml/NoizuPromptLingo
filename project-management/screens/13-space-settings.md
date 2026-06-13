# Space Settings

| Field | Value |
|-------|-------|
| **ID** | `space-settings` |
| **Type** | Settings |
| **Category** | Spaces |
| **User Stories** | US-008, US-009, US-082, US-083, US-085, US-086, US-087 |

## Description

Comprehensive space settings panel for space owners and moderators. Manages visibility, moderation rules, metadata (description, rules, links), tags, ownership transfer, archiving, and template duplication.

## Key Components

- **Visibility dropdown** — Public / Restricted / Private selector (US-082)
- **Moderation toggles** — Require approval for threads, auto-hide reported posts (US-008, US-009)
- **Moderator list** — Add/remove moderators with role management (US-008)
- **Markdown description editor** — 500 character limit for space description (US-083)
- **Community rules markdown editor** — Editable rules displayed on space detail (US-083)
- **External links section** — Max 5 links with URL and label fields (US-083)
- **Tag management** — Autocomplete-powered tag editing (US-083)
- **"Transfer Ownership" button** — Triggers confirmation requiring "TRANSFER" text input (US-085)
- **"Archive Space" button** — Confirmation dialog before archiving (US-086)
- **"Duplicate as Template" button** — Creates a copy as a reusable template (US-087)
- **Fork count display** — Shows how many times space has been forked (US-087)

## Interactions

- Change visibility, description, rules, links, and tags
- Save changes
- Transfer ownership (with "TRANSFER" text confirmation)
- Archive or unarchive the space
- Duplicate the space as a template

## Navigation

- Accessible from: Space Detail (11) for owners/moderators
- Links to: Space Detail (11), Space Members (14), Space Analytics (15)
