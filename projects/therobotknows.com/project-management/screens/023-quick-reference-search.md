# Quick Reference Search Overlay

| Field | Value |
|-------|-------|
| **ID** | quick-reference-search |
| **Type** | Modal |
| **Category** | Session |
| **User Stories** | US-061, US-069 |

## Description

Focused search overlay for rapid canon lookup without navigation.

## Key Components

- **Search Input** — Query entry names, aliases, tags (US-061)
- **Results List** — Matching entries with name, type icon, 2-line excerpt (US-061)
- **Pinned Recents** — Recently accessed entries this session (US-061)
- **Entry Detail Panel** — Read-only side panel for selected result (US-061)
- **Close Button** — Dismiss search (US-061)
- **Keyboard Shortcut Indicator** — Shows hotkey (US-061)
- **Loading State** — Results loading indicator (US-061)

## Interactions

- Typing 3+ characters triggers search within 500ms
- Results show name, type, excerpt
- Selecting result opens read-only side panel
- Dismissing panel closes search
- Recently accessed entries pinned at top
- Escape closes search
- No navigation away from current view

## Navigation

- Accessible from: Session Companion, Canon Editor (keyboard shortcut)
- Links to: Canon Entry Detail (from side panel)