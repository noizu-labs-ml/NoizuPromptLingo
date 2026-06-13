# Canon Entry Detail

| Field | Value |
|-------|-------|
| **ID** | canon-entry-detail |
| **Type** | Primary |
| **Category** | Canon |
| **User Stories** | US-016, US-017, US-021, US-022, US-023, US-024, US-025, US-030, US-038, US-046, US-074 |

## Description

Full view of a canon entry with rich text, inline links, and actions.

## Key Components

- **Entry Header** — Title, type icon, status badge, last edited timestamp, editor (US-024)
- **Status Selector** — Dropdown: Canon/Draft/Generated with confirmation (US-024)
- **Rich Text Display** — Formatted prose for biography, description, history (US-021)
- **Inline Links** — Clickable links to other canon entries, broken link indicators (US-022)
- **Entry Type Fields** — Type-specific fields from template (e.g., Character: species, affiliation) (US-020)
- **Tags Panel** — Display and manage entry tags (US-023)
- **Relations Panel** — List of linked entries with relationship types (US-022)
- **Sources Panel** — For AI-generated entries: source citations with tooltips (US-038)
- **Actions Bar** — Edit, Delete, View Version History, Promote to Canon (US-017, US-018, US-025, US-046)
- **Suggested Connections Sidebar** — AI-suggested related entries (US-074)
- **Unsaved Changes Indicator** — Badge and browser warning on navigation (US-017)

## Interactions

- Edit mode enables in-place editing of all fields
- Clicking inline links navigates to target entry
- Status change to Canon asks for confirmation
- Edit creates new version in history
- Delete shows broken references warning
- Suggested connections can be accepted or dismissed

## Navigation

- Accessible from: Canon Editor List, Knowledge Graph (node click), Generation History (promoted entries)
- Links to: Other canon entries (inline links), Version History, Knowledge Graph