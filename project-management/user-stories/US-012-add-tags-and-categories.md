---
id: US-012
title: "Add Tags and Categories to a Prompt"
slug: "add-tags-and-categories"
personas: [P-001, P-003]
epic: "Prompt Submission"
priority: "should-have"
complexity: "S"
tags: [prompt, tags, categories, taxonomy, discovery]
---

# US-012: Add Tags and Categories to a Prompt

## User Story

**As a** ML Researcher (P-003),
**I want to** assign tags and a category to my prompt submission,
**So that** it is discoverable by users filtering for specific use cases or model types.

## Acceptance Criteria

- [ ] Given I am on the prompt submission form, when I click the category dropdown, then I see a list of predefined top-level categories (e.g., "Code Generation", "Creative Writing", "Data Analysis", "Reasoning", "Summarization", "Role Play", "Other") and can select exactly one.
- [ ] Given I am on the submission form, when I type in the tags field, then I see autocomplete suggestions from existing tags and can select up to 10 tags; I can also create a new tag by pressing Enter if no match exists.
- [ ] Given I create a new tag, when the tag text is fewer than 3 characters or more than 30 characters, then the tag creation is rejected with an inline validation message.
- [ ] Given I am viewing a published prompt, when I click any tag or category label, then I am taken to a filtered feed showing all prompts with that tag or category.
- [ ] Given I am editing an existing prompt, when I update its tags or category and save, then the changes are reflected immediately in the feed filters without requiring a page reload.

## Notes

The predefined category list prevents taxonomy fragmentation while still allowing flexible free-form tags. Tag creation by regular users allows the folksonomy to grow organically; moderators (P-004) can merge or deprecate tags. Depends on US-011 (prompt creation) and US-016 (edit prompt).
