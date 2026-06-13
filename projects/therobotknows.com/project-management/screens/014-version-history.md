# Version History Sidebar

| Field | Value |
|-------|-------|
| **ID** | version-history |
| **Type** | Modal |
| **Category** | Canon |
| **User Stories** | US-025, US-018 |

## Description

Sidebar panel showing edit history with preview and restore capability.

## Key Components

- **Version List** — All saved versions with timestamp, author, change summary (US-025)
- **Diff Preview** — Side-by-side comparison of selected vs current version (US-025)
- **Field Highlighting** — Highlighted changes between versions (US-025)
- **Restore Button** — Restore selected version (US-025)
- **Author Indicator** — Human editor or AI Agent name (US-025)
- **Close Button** — Dismiss sidebar (US-025)

## Interactions

- Clicking version shows diff preview
- Restore reverts content and creates new version record
- Author distinguished between human and AI edits
- Soft-deleted entries recoverable via history
- History for free-tier may prune records older than 90 days

## Navigation

- Accessible from: Canon Entry Detail (action button)
- Links to: Canon Entry Detail (on restore)