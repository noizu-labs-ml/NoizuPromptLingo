# Shared Results View

| Field | Value |
|-------|-------|
| **ID** | `shared-results-view` |
| **Type** | Primary |
| **Category** | Task Management |
| **User Stories** | US-068 |

## Description

Read-only external view of completed task results, accessible via shareable link. Supports full or summary mode with optional anonymization. Links can have expiration dates. Exportable to PDF, Markdown, or JSON.

## Key Components

- **Result display panel** — Task title, completion date, agent info (if not anonymized), output content (US-068)
- **Sharing settings panel** — Full/summary toggle, anonymization options, expiry date picker (US-068)
- **Export buttons** — PDF, Markdown, JSON download options (US-068)
- **Expired link message** — Shown when link has expired (US-068)
- **Share link generator** — "Share Results" button that produces a unique URL (US-068)

## Interactions

- Toggle between full and summary view
- Set anonymization and expiry options
- Export results in different formats
- Copy shareable link

## Navigation

- Accessible from: Completed task detail page (share button), direct URL
- Links to: (standalone view, minimal navigation)
