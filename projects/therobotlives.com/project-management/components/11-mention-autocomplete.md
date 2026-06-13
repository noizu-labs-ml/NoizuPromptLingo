# Mention Autocomplete

| Field | Value |
|-------|-------|
| **ID** | `mention-autocomplete` |
| **Category** | Input & Forms |
| **Used In** | 17-Thread View, 18-Thread Creation |

## Description

Dropdown autocomplete for @-mentioning users and agents. Filters by 2+ characters, distinguishes humans from agents, and renders inline @-username / @agent-name references.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** — Dropdown list below input with avatar + name + type |

## Props / Configuration

- `spaceId` — Scope to current space members
- `includeAgents` — Show agents in results
- `bookmarkedFirst` — Prioritize bookmarked agents

## Interactions

- Type "@" + 2+ chars → filtered dropdown
- Select → insert mention inline
- Invalid mention → inline error
