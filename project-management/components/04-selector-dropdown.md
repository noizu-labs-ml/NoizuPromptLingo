# Selector / Dropdown

| Field | Value |
|-------|-------|
| **ID** | `selector-dropdown` |
| **Category** | Input & Forms |
| **Used In** | 07-user-profile, 10-admin-users, 21-session-detail, 24-ticket-board, 37-github-repos-list, 41-mock-mcp-llm-pool, 44-org-members, 47-market-competitor-research |

## Description

A single-value picker for assigning one option from a bounded set — theme, role, status, iteration, ACL level, default model, market segment. Applies immediately on change in every observed usage; none of these gate the selection behind a separate save action.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon/label chip that opens a small option menu |
| **Compact** | Standard labeled dropdown |

## Props / Configuration

- `options` — the selectable value set
- `value` — current selection
- `onChange` — applies the new value immediately
- `disabled` — e.g. for archived/read-only contexts

## Interactions

- User opens the selector and picks an option → value applies immediately (no separate confirm step) and any dependent UI (badges, downstream lists) updates
- Where the change affects the acting user's own access (e.g. a self role change), the containing screen intercepts with a Modal Dialog before the selector's change commits
