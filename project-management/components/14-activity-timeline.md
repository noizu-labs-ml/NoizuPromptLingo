# Activity Timeline

| Field | Value |
|-------|-------|
| **ID** | `activity-timeline` |
| **Category** | Data Display |
| **Used In** | 06-organization-picker, 09-admin-home, 17-org-dashboard, 25-tickets-list, 33-agent-personas-management |

## Description

A reverse-chronological feed of recent activity, scoped to whatever entity it's embedded in — an org card's recent snippet, cross-org admin audit activity, a dashboard's cross-entity feed, a ticket queue's activity stream, or a persona's journal. The persona journal variant additionally accepts new entries via an attached composer rather than being purely read-only.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | One-line "most recent activity" snippet (e.g. on an org card) |
| **Compact** | Short scrollable feed embedded in a dashboard or sidebar |
| **Expanded** | Full feed with a composer for adding entries (persona journal) |

## Props / Configuration

- `entries` — timestamped activity/journal entries
- `composable` — shows a composer for appending new entries (journal use case)
- `scope` — the entity this feed is filtered to

## Interactions

- New activity appends to the top of the feed as it occurs
- Where `composable` is set, the user (or an agent) submits an entry via the composer and it's appended immediately
- User scans the feed without opening individual referenced entities, or clicks an entry to navigate to its source
