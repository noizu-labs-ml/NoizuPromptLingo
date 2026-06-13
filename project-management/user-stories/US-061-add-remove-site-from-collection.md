---
id: US-061
title: "Add and Remove Sites from Collection"
slug: "add-remove-site-from-collection"
personas: [P-001, P-008, P-002]
epic: "Collections & Lists"
priority: "must-have"
complexity: "S"
tags: [collections, add, remove, manage, bookmarks]
---

# US-061: Add and Remove Sites from Collection

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** add and remove individual sites from my collections,
**So that** my lists stay curated and reflect only what I actually recommend.

## Acceptance Criteria

- [ ] Given I am viewing a site detail page and I have at least one collection, when I open the "Add to Collection" menu, then all my collections are listed with a checkmark on those already containing this site
- [ ] Given I click a checked collection in the "Add to Collection" menu, when confirmed, then the site is removed from that collection
- [ ] Given I am viewing my collection management page, when I click "Remove" next to a site in the list, then the site is removed from the collection without a full page reload
- [ ] Given a site is removed from a collection, when the operation completes, then an undo option is available for 10 seconds
- [ ] Given I add a site already in a collection, when I attempt the add, then the UI prevents duplicates and shows "Already in [collection name]"

## Notes

The "Add to Collection" affordance should be discoverable on site cards in search results and category browse pages, not only on the full detail page. Related: US-060 (create collection), US-065 (collection management).
