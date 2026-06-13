---
id: US-010
title: "Edit Universe Settings"
slug: "edit-universe-settings"
personas: [P-001, P-003]
epic: "Universe Management"
priority: "must-have"
complexity: "S"
tags: [universe, settings, configuration]
---

# US-010: Edit Universe Settings

## User Story

**As a** narrative designer (P-003),
**I want to** edit my universe's name, description, genre, tone, and visibility settings,
**So that** the platform's AI generation and consistency rules reflect the actual creative direction of the project.

## Acceptance Criteria

- [ ] Given I am on the Universe Overview, when I navigate to Universe Settings, then I can edit: name, description, genre tags (multi-select from a defined list), tone (dropdown: gritty, epic, whimsical, horror, etc.), and visibility (private/team).
- [ ] Given I save changes to genre or tone, when the save completes, then the new values are immediately reflected in the Generation Studio prompt defaults (US-015).
- [ ] Given I change the universe name, when the save completes, then all breadcrumbs, page titles, and sidebar references update within the current session.
- [ ] Given I attempt to leave the settings page with unsaved changes, when navigation is triggered, then a confirmation dialog asks "Discard changes?"

## Notes

Depends on US-009 (create universe). Genre/tone configuration is covered in more depth in US-015. Related: US-013 (delete universe), US-014 (duplicate universe).
