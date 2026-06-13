# Projects Dashboard

| Field | Value |
|-------|-------|
| **ID** | `projects-dashboard` |
| **Type** | Dashboard |
| **Category** | Platform |
| **User Stories** | INK-069, INK-070, INK-071, INK-072, INK-073, INK-088 |

## Description

Central hub showing all user projects as cards with phase progress, agent status, and quick actions. Primary navigation surface after login. Includes empty state for new users and search/filter for power users.

## Key Components

- **Project Card Grid** — Cards showing title, phase, step, agent status, last edited (INK-069)
- **Phase Progress Bar** — 4-segment indicator (Sketch/Draft/Ink/Publish) per card with locked phase icons (INK-070)
- **Quick Action Menu** — "Continue" primary CTA + kebab menu (Duplicate/Export/Archive/Delete) (INK-071)
- **New Project Button** — Always-visible "+ New Project" card with upgrade prompt on free-tier limit (INK-072)
- **Search and Filter Bar** — Real-time search + phase/status filter chips (INK-073)
- **Empty State** — Illustrated zero-state with quick-start CTA and example template card (INK-088)

## Interactions

- Cards sorted by last edited (most recent first) by default
- Click card "Continue" → routes to current step of that project
- Kebab menu actions trigger confirmation dialogs
- Search debounces input, filters apply immediately
- "+ New Project" routes to Project Type Selector or Pitch Input

## Navigation

- Accessible from: Login (redirect), top nav from any authenticated page
- Links to: Any project phase/step, Project Type Selector, Settings, Billing
