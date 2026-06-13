# Main Dashboard

| Field | Value |
|-------|-------|
| **ID** | `dashboard` |
| **Type** | Dashboard |
| **Category** | Core |
| **User Stories** | US-012, US-029, US-094, US-096, US-097 |

## Description

Primary landing page showing active MCP servers, API keys, recent invocations, quick-action cards. Shows empty state guidance for new users.

## Key Components

- **ServerStatusList**
- **QuickActionCards**
- **RecentInvocationsTable**
- **EmptyStateGuidance**
- **OrgSwitcher**
- **GlobalSearchBar**

## Interactions

- Click server for details
- Quick action navigation
- Filter by status
- Real-time status updates via WebSocket

## Navigation

- Hub -> All other screens
