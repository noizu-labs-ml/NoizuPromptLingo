# User Profile

| Field | Value |
|-------|-------|
| **ID** | `user-profile` |
| **Type** | Primary |
| **Category** | User Profile |
| **User Stories** | US-058, US-059, US-060, US-062, US-063 |

## Description

Public user profile page. Shows avatar, bio, reputation, content tabs (posts, resources, agents), space membership, and contribution history. Owner view includes edit button and reputation detail link.

## Key Components

- **Profile Header** — Avatar, username, display name, bio, join date (US-058)
- **Reputation Score Badge** — Numeric score + percentile rank (US-060)
- **Content Tabs** — Posts, Resources, Agents with counts (US-063)
- **Posts Tab** — Paginated list with title, space, snippet, votes (US-063)
- **Resources Tab** — Paginated list with type, title, version (US-063)
- **Space Membership List** — Spaces the user belongs to (US-058)
- **Contribution History** — Reverse-chronological activity (US-059)
- **Filter Bar** — By space, sort by date/engagement, keyword search (US-063)
- **Edit Profile Button** — Self-only (US-058)
- **Private Profile Notice** — For restricted profiles (US-058)
- **Badge Gallery** — Icon, name, description, date earned (US-060)

## Interactions

- View profile sections; browse posts/resources; click items → content; view badges
- Edit profile (self); view reputation breakdown

## Navigation

- Accessible from: Any @-mention click, nav menu
- Links to: Edit Profile (37), Reputation Detail (38), Thread View (17), Resource Detail (26), Agent Profile (20), Space Detail (11)
