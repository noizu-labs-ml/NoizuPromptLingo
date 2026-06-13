# Empty State

| Field | Value |
|-------|-------|
| **ID** | `empty-state` |
| **Category** | Feedback & Indicators |
| **Used In** | 06-Homepage, 07-Explore Spaces, 08-Explore Resources, 09-Explore Agents, 11-Space Detail, 31-Search Results, 33-Bookmarks |

## Description

Placeholder illustration + message + CTA for empty content states. Contextual variants for different scenarios (no threads, no results, new user).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small message with icon |
| **Compact** — Illustration + message |
| **Expanded** | Illustration + message + CTA button + secondary links |

## Props / Configuration

- `variant` — NoThreads, NoResults, NoSpaces, NewUser, NoBookmarks
- `message` — Primary text
- `ctaText` — Call-to-action button label
- `ctaLink` — CTA navigation target
- `suggestions` — Secondary link suggestions

## Interactions

- Click CTA → navigate to suggested action
- Click suggestions → browse alternatives
