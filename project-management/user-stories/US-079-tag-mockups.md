---
id: US-079
title: "Tag mockups with custom labels"
slug: "tag-mockups"
personas: [P-003, P-002, P-001]
epic: "Search & Discovery"
priority: "should-have"
complexity: "S"
tags: [tags, organization, discovery]
---

# US-079: Tag mockups with custom labels

## User Story

**As a** UX Designer (P-003),
**I want to** tag mockups with custom labels,
**So that** I can organize and retrieve them by project phase, component type, or any dimension meaningful to my workflow.

## Acceptance Criteria

- [ ] Given I am viewing a mockup detail page, when I add a tag, then the tag is saved and immediately visible on the mockup
- [ ] Given a mockup has one or more tags, when I click a tag, then the gallery filters to show all mockups sharing that tag
- [ ] Given I want to remove a tag, when I click the remove icon on a tag, then the tag is deleted from the mockup without a confirmation dialog

## Notes

Tags are free-form strings, max 32 characters each, max 20 tags per mockup. Tag autocomplete should suggest previously used tags within the same workspace. Related to US-076 (search indexes tags).
