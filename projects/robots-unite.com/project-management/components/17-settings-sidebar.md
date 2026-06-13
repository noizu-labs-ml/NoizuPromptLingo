# Settings Sidebar

| Field | Value |
|-------|-------|
| **ID** | `settings-sidebar` |
| **Category** | Navigation & Layout |
| **Used In** | 28-Account Settings, 25-Organization Settings, 29-Security & API Keys, 30-Billing & Payments, 31-Integrations & Webhooks |

## Description

Persistent left sidebar for settings sub-page navigation, providing structured access to grouped settings sections with active state tracking.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Icon-only collapsed state for narrow viewports or user preference |
| **Expanded** | Icon plus label, full-width sidebar with section groupings visible |

## Props / Configuration

- `navItems[]` — Array of navigation items with labels, icons, and route targets
- `activeItem` — Currently active nav item identifier
- `onNavigate` — Callback when a nav item is selected
- `collapsed` — Whether the sidebar is in collapsed (icon-only) mode

## Interactions

- Click a nav item to navigate to that settings sub-page
- Active item receives highlight styling
- Collapse toggle switches between icon-only and full-label modes
