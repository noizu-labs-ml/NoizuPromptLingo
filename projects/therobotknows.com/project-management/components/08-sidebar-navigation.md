# Sidebar Navigation

| Field | Value |
|-------|-------|
| **ID** | `sidebar-navigation` |
| **Category** | Navigation & Layout |
| **Used In** | All authenticated screens (Canon List, Canon Detail, Knowledge Graph, Generation Studio, Consistency Dashboard, Session Companion, Settings) |

## Description

Primary application navigation sidebar providing universe-level context switching, section links, and user/account access. Collapsible to an icon-only rail mode on smaller viewports. Persists across all post-auth screens.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full sidebar with icon + label for each nav item, universe name visible |
| **Compact** | Icon-only rail, labels appear as tooltips on hover |

## Props / Configuration

- `activeSection` — Currently selected section slug (e.g., `canon`, `graph`, `generation`, `consistency`, `session`, `settings`)
- `currentUniverse` — Universe object with `id`, `name`, `coverImageUrl`
- `universeList` — Array of accessible universes for the switcher dropdown
- `onUniverseChange` — Callback when user selects a different universe
- `collapsed` — Boolean controlling expanded vs. icon-rail mode
- `onToggleCollapse` — Callback to toggle collapsed state
- `userAvatarUrl` — Current user avatar for the bottom user menu trigger
- `notificationCount` — Badge count shown on relevant nav items

## Interactions

- Clicking the universe switcher area opens a dropdown listing all accessible universes with a "New Universe" option at the bottom
- Section links navigate to the corresponding top-level route and highlight the active item
- Collapse/expand toggle is a chevron button at the bottom of the rail; state is persisted to local storage
- User avatar at bottom opens a popover with Profile, Account Settings, and Sign Out links
- Notification badge on Session or Consistency items pulses when new issues are detected
- Keyboard: `Alt+1` through `Alt+6` activate each section in order
