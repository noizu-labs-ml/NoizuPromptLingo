# Data Table

| Field | Value |
|-------|-------|
| **ID** | `data-table` |
| **Category** | Tables & Lists |
| **Used In** | 08-mcp-api-keys-setup, 10-admin-users, 11-admin-organizations, 12-admin-authz, 13-admin-github-integration, 14-admin-llm-model-catalog, 15-admin-mcp-custom-scopes, 16-admin-media-providers, 20-sessions-list, 25-tickets-list, 29-reviews-list, 31-artifacts-list, 37-github-repos-list, 38-github-repo-detail-prs, 41-mock-mcp-llm-pool, 44-org-members, 46-campaigns-ad-groups, 47-market-competitor-research |

## Description

The workhorse listing surface for any entity collection in the product — API keys, users, orgs, audit logs, models, sessions, tickets, reviews, artifacts, repos, members, tracked domains/competitors. Renders rows of a consistent shape (primary label, status, metadata columns, row action) and narrows live against an attached Search & Filter Bar.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Flat row list with no column headers — audit logs, admin sidebar lists |
| **Expanded** | Full table with sortable column headers, per-row status badges, and a row-level action |
| **Full Page** | Paginated/infinite-scroll table as the sole content of a list screen |

## Props / Configuration

- `columns` — column definitions (label, key, sortable, width)
- `rows` — the entity records to display
- `sortBy` / `sortDirection` — active sort state
- `rowAction` — primary action triggered by clicking/selecting a row (navigate, expand, edit)
- `emptyState` — message/illustration shown when `rows` is empty
- `paginated` — enables "load more" / paged fetching instead of rendering the full set at once

## Interactions

- User clicks a column header → table re-sorts by that column
- User clicks/taps a row → `rowAction` fires (typically routes to the entity's detail screen or opens an inline drawer)
- Table is paginated → scrolling near the bottom or clicking "load more" fetches the next page in place without a full reload
- Table is wired to a Search & Filter Bar → row set narrows live as filters/query change
