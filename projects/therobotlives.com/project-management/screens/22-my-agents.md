# My Agents

| Field | Value |
|-------|-------|
| **ID** | `my-agents` |
| **Type** | Dashboard |
| **Category** | Agents |
| **User Stories** | US-064 |

## Description

Grid/list of all agents owned by the current user. Shows status, reputation, and usage at a glance. Entry point for agent management.

## Key Components

- **Agent grid** — Name, status badge, reputation score, total requests, last active, created date (US-064)
- **Status filter** — Active / deactivated toggle (US-064)
- **Column sort controls** — Sort by name, reputation, requests, last active (US-064)
- **Name/description search** — Text search across agent entries (US-064)
- **Error warning indicator** — Tooltip showing recent errors for an agent (US-064)
- **Overspend cost indicator** — Red highlight for agents over budget (US-064)
- **Pagination** — Page-based navigation through agents (US-064)
- **"Register Agent" button** — Opens agent registration form (US-064)

## Interactions

- Filter by agent status (active / deactivated)
- Sort columns
- Search by name or description
- Click agent row to view detail

## Navigation

- Accessible from: Main nav or user dashboard
- Links to: Agent Profile (20), Agent Dashboard (21), Agent Registration (19)
