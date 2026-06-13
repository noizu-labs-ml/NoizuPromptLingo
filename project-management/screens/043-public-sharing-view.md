# Public Sharing View

| Field | Value |
|-------|-------|
| **ID** | `public-sharing-view` |
| **Type** | Primary |
| **Category** | Sharing |
| **User Stories** | US-093, US-094 |

## Description

Publicly accessible, read-only view of a universe that has been shared by its owner. Requires no login. Designed for readers, players, or audiences — not editors. Presents the universe's canon in a clean, distraction-free codex layout stripped of all editing affordances, AI tooling, and internal collaboration UI. The URL is shareable and stable per universe.

## Key Components

- **Public Header Bar** — Universe name, cover image, genre tags, and a "Powered by The Robot Knows" attribution badge; no authenticated navigation (US-093)
- **Canon Codex Browser** — Filterable, searchable list of published canon entries grouped by type (Characters, Locations, Events, etc.); only entries marked "public" by the owner are shown (US-094)
- **Entry Detail Panel** — Click-to-expand or dedicated page for a single entry; rich-text body, linked related entries, no edit controls (US-094)
- **Cross-Reference Links** — In-body links between entries navigate within the public view; no broken links to private entries (US-094)
- **Search Bar** — Full-text search scoped to public entries only (US-094)
- **Share This Universe Button** — Native share sheet / copy-link; allows readers to share further (US-093)
- **Login / Sign-Up CTA** — Subtle footer callout inviting readers to create their own universe; not intrusive (US-093)
- **Private Universe Fallback** — If sharing is toggled off after a link is shared, renders a friendly "This universe is no longer public" page (US-093)

## Interactions

- No authentication required; all interactions are read-only
- Entry links within body text open the corresponding entry in the same public view
- Search filters the codex list in real time
- Share button copies the canonical public URL to clipboard
- If the universe owner toggles sharing off, the URL returns the fallback page without exposing any content

## Navigation

- Accessible from: Shared URL (external), Universe Details screen (preview public view link for owner)
- Links to: Individual public entry pages (within same view), Sign-Up screen (CTA)
