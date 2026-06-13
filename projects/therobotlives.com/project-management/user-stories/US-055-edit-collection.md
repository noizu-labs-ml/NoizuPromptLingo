---
id: US-055
title: "Rename and Edit Collection"
slug: "edit-collection"
personas: [P-001, P-002]
epic: "Bookmarking & Collections"
priority: "could-have"
complexity: "S"
tags: [bookmarking, collections, management]
---

# US-055: Rename and Edit Collection

## User Story

**As a** Prompt Engineer Power User (P-001) or AI/ML Engineer (P-002),
**I want to** edit collection name, description, and metadata,
**So that** I can keep my bookmark organization accurate and reflective of its evolving purpose.

## Acceptance Criteria

- [ ] Given a collection exists, when I edit its name, then the name updates across all views (collection list, collection view, breadcrumb navigation)
- [ ] Given a collection description is empty, when I add one, then the description displays in collection cards and collection header
- [ ] Given a collection has bookmarks, when I rename it, then all bookmarks remain in the collection (no data loss)
- [ ] Given two collections with similar names, when I edit one, then validation prevents creating duplicate names
- [ ] Given a collection edit is in progress, when I cancel, then all changes are discarded and original state is preserved

## Notes

Edit should include collection icon/color selection for visual organization. Consider adding tags to collections for cross-cutting categorization (could-have feature).