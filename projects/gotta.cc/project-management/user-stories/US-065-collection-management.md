---
id: US-065
title: "Collection Management: Rename, Delete, Reorder"
slug: "collection-management"
personas: [P-008, P-001, P-002]
epic: "Collections & Lists"
priority: "should-have"
complexity: "M"
tags: [collections, manage, rename, delete, reorder]
---

# US-065: Collection Management: Rename, Delete, Reorder

## User Story

**As a** community curator (P-008),
**I want to** rename, delete, and reorder my collections and their contents,
**So that** I can maintain well-organized, intentionally sequenced lists over time.

## Acceptance Criteria

- [ ] Given I am on my collections management page, when I click "Rename" on a collection, then an inline edit field appears and I can update the name and save
- [ ] Given I want to delete a collection, when I click "Delete" and confirm the prompt, then the collection is permanently removed including all site entries and follower associations
- [ ] Given a collection has followers, when I attempt to delete it, then a warning is shown indicating the number of followers who will lose access
- [ ] Given I am viewing a collection's site list, when I drag-and-drop a site card to a new position, then the order is saved and reflected when the collection is viewed by others
- [ ] Given I want to reorder my top-level collection list, when I drag collections into a new order, then that order is persisted and reflected on my public profile page

## Notes

Drag-and-drop reordering may degrade to up/down arrow buttons on mobile. Deleting a collection with followers should be a soft-delete (grace period) or require explicit "I understand" confirmation to avoid accidental loss. Related: US-060 (create collection), US-061 (add/remove sites), US-066 (export).
