---
id: US-009
title: "Create a New Universe"
slug: "create-universe"
personas: [P-001, P-002, P-005]
epic: "Universe Management"
priority: "must-have"
complexity: "M"
tags: [universe, creation, core]
---

# US-009: Create a New Universe

## User Story

**As an** epic novelist (P-001),
**I want to** create a named universe project to contain all the canon for my fantasy series,
**So that** every character, location, and event lives in one organized place.

## Acceptance Criteria

- [ ] Given I am authenticated and on the Dashboard, when I click "New Universe," then I am presented with a creation form requiring a name (required, max 100 chars) and optional description (max 500 chars).
- [ ] Given I submit the creation form with a valid name, when the universe is saved, then I am redirected to the Universe Overview for the new universe.
- [ ] Given I attempt to create a universe with a duplicate name within my account, when the form is submitted, then an inline error reads "You already have a universe with this name."
- [ ] Given my plan limits universes (e.g., free tier = 1), when I attempt to create beyond the limit, then I see an upgrade prompt rather than the creation form.

## Notes

Depends on US-008 (verification). Feeds into US-011 (universe creation wizard) which wraps this with a guided multi-step flow. Related: US-012 (edit universe settings).
