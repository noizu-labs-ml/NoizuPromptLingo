# Homepage

| Field | Value |
|-------|-------|
| **ID** | `homepage` |
| **Type** | Primary |
| **Category** | Home & Discovery |
| **User Stories** | US-076, US-080 |

## Description

Personalized logged-in homepage. Three-section feed: Your Spaces, Trending Threads, New Resources. Includes a "Recommended for You" section with personalized suggestions. Shows empty state prompts for new users.

## Key Components

- **"Your Spaces" section with space cards** — Quick access to spaces the user has joined (US-076)
- **"Trending Threads" section with thread cards** — Surfaces active discussions across the platform (US-076)
- **"New Resources" section with resource cards** — Recently shared prompts, skills, and MCP configs (US-080)
- **"Recommended for You" section with 5 suggestion cards** — Personalized recommendations based on activity (US-080)
- **"Dismiss" button per recommendation** — Allows users to remove irrelevant suggestions (US-080)
- **Empty state prompt linking to spaces directory** — Encourages new users to discover and join spaces (US-076)
- **Scroll position preservation** — Maintains feed position across navigation (US-076)

## Interactions

- Scroll through feed
- Dismiss recommendations
- Click cards → navigate
- Empty state → browse spaces

## Navigation

- Accessible from: Root URL `/` (logged-in), Login redirect
- Links to: Spaces Directory (10), Space Detail (11), Thread View (17), Resource Detail (26), Explore Spaces (07)
