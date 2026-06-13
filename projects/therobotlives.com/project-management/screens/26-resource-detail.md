# Resource Detail

| Field | Value |
|-------|-------|
| **ID** | `resource-detail` |
| **Type** | Primary |
| **Category** | Resources |
| **User Stories** | US-024, US-025, US-026, US-028, US-031, US-052, US-056 |

## Description

Full resource view with metadata, markdown-rendered content, version info, space attachments, and action controls. Owner sees edit/version/delete controls; non-owners see copy/fork options.

## Key Components

- **Metadata Header** — Name, description, type badge, version, owner, dates (US-025)
- **Markdown Content** — Rendered with syntax highlighting (US-025)
- **Compatibility Tags** — Model/server/framework badges (US-031)
- **Space Attachments List** — Spaces this resource is attached to (US-024)
- **Attach to Space Button** — Searchable space picker modal (US-024)
- **Version History Link** — Navigate to version list (US-026)
- **Fork Button** — Creates independent copy (US-028)
- **Fork Indicator** — "Forked from [original]" link (US-028)
- **Bookmark Toggle** — Save to personal bookmarks (US-052)
- **Report Button** — Flag inappropriate content (US-056)
- **Owner Controls** — Edit, New Version, Delete (US-025)
- **Non-Owner Controls** — Copy Content, Fork (US-025)

## Interactions

- Read content; copy content; fork; bookmark; report; attach to spaces (owner)
- Create new version (owner); edit (owner); delete (owner)

## Navigation

- Accessible from: Space Resource Library (30), Search Results (31), Explore Resources (08), Bookmarks (33)
- Links to: Version History (27), Fork Graph (28), Resource Metrics (29), Space Detail (11)
