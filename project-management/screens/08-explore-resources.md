# Explore Resources

| Field | Value |
|-------|-------|
| **ID** | `explore-resources` |
| **Type** | Primary |
| **Category** | Home & Discovery |
| **User Stories** | US-043, US-078 |

## Description

Resources discovery page for browsing top prompts, skills, and MCP configs by popularity. Supports type filtering and sort options.

## Key Components

- **Category tabs (Prompts, Skills, MCP Configs)** — Switches resource type filter (US-043)
- **Resource cards (name, type, author, fork count, creation date)** — Core browse unit for each resource (US-078)
- **Sort options (Most Forked, Most Viewed)** — Reorders results by popularity metric (US-078)
- **Hover preview card (description, owner, fork count)** — Expanded metadata on hover without navigation (US-043)
- **Empty state per category** — Shown when a category has no matching resources (US-043)

## Interactions

- Select category tab → filter
- Sort by metric
- Hover card → preview
- Click → resource detail

## Navigation

- Accessible from: Main nav "Explore → Resources"
- Links to: Resource Detail (26)
