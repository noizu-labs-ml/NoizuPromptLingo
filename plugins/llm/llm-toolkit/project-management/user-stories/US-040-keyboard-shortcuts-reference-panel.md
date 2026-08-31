---
id: US-040
title: "Keyboard shortcuts reference panel"
slug: keyboard-shortcuts-reference-panel
personas: [P-001, P-007]
epic: "Accessibility & i18n"
priority: should-have
complexity: low
tags: [accessibility, keyboard-nav, help]
---

# US-040: Keyboard Shortcuts Reference Panel

## User Story

**As a** solo power-user developer
**I want to** press `?` anywhere in the web UI and see a panel listing all available keyboard shortcuts, grouped by context
**So that** I can learn and use shortcuts for search, thread viewing, and browsing without digging through documentation

## Acceptance Criteria

- **Given** I am anywhere in the web UI (not focused in a text input)
  **When** I press `?`
  **Then** a modal/panel opens listing all keyboard shortcuts grouped by context (Search, Thread Viewer, Browse)

- **Given** the shortcuts panel is open
  **When** I press `Escape` or click outside it
  **Then** it closes and returns focus to where it was before opening

- **Given** I am focused inside a text input (e.g. the search bar)
  **When** I type `?` as a literal character
  **Then** the shortcuts panel does NOT open, since `?` is valid input text in that context

- **Given** Jamie is unfamiliar with the tool
  **When** they open the shortcuts panel for the first time
  **Then** each shortcut is listed with a short plain-language description of what it does, not just the raw key combination

## Notes
Marcus benefits from having a fast reference while relying heavily on keyboard-driven workflows across CLI and web; Jamie benefits from discoverability of an otherwise-hidden feature set. Should-have and low complexity — a static/derived list of already-implemented shortcuts (including `?` itself) surfaced in one panel, contingent on US-037's keyboard nav being in place first.
