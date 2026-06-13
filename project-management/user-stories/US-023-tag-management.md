---
id: US-023
title: "Tag Management on Canon Entries"
slug: "tag-management"
personas: [P-003, P-005]
epic: "Canon Editor — Core"
priority: "should-have"
complexity: "M"
tags: [canon, tags, filtering, organization]
---

# US-023: Tag Management on Canon Entries

## User Story

**As a** narrative designer (P-003),
**I want to** create, assign, and filter entries by custom tags,
**So that** my three-writer team can organize entries by narrative arc, region, and development status without needing a rigid folder hierarchy.

## Acceptance Criteria

- [ ] Given I am editing a canon entry, when I type in the Tags field, then I see autocomplete suggestions from existing tags in the universe alongside an option to "Create tag: {typed text}."
- [ ] Given I create a new tag, when it is saved, then it is available for autocomplete in all other entries within the same universe.
- [ ] Given I am in the Canon Editor list view, when I click a tag in the filter bar, then the entry list is filtered to show only entries carrying that tag; multiple tags apply as an AND filter.
- [ ] Given I rename a tag in the Tags Management panel (universe settings), when the rename saves, then the new name is applied to all entries bearing the old tag with no broken references.

## Notes

Tags are universe-scoped, not global. Tags must support multi-word values and emoji. Related: US-016 (create entry), US-024 (entry status — "canon/generated" is a status, not a tag). Rename propagation must be atomic.
