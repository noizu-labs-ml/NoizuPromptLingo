---
id: US-060
title: "Create Personal Collection"
slug: "create-personal-collection"
personas: [P-001, P-008, P-002]
epic: "Collections & Lists"
priority: "must-have"
complexity: "M"
tags: [collections, personal, curation, user-generated, bookmarks]
---

# US-060: Create Personal Collection

## User Story

**As a** community curator (P-008),
**I want to** create a named personal collection of websites from the directory,
**So that** I can organize my discoveries into themed lists I can reference and share.

## Acceptance Criteria

- [ ] Given I am logged in and viewing any site detail page or search results, when I click "Add to Collection", then I am prompted to select an existing collection or create a new one
- [ ] Given I choose to create a new collection, when I enter a name and optional description and confirm, then the collection is created and the current site is added as its first entry
- [ ] Given I navigate to my profile or collections page, when it loads, then all my collections are listed with name, site count, and creation date
- [ ] Given I create a collection, when the creation is confirmed, then the default visibility is set to "private" (shareable link required to view)
- [ ] Given I have reached a collection site limit (e.g., 200 sites per collection on free tier), when I attempt to add another site, then I am shown an upgrade prompt or told to remove a site first

## Notes

Collections are the primary user retention loop — they give both casual browsers and power curators a reason to return. Privacy default to "private" avoids accidental public exposure. Related: US-061 (add/remove sites), US-062 (share collection), US-072 (subscription tiers).
