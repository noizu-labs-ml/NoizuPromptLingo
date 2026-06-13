---
id: US-055
title: "Bookmark / Save Prompts"
slug: "bookmark-save-prompts"
personas: [P-001, P-002, P-005, P-007, P-008]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "M"
tags: [bookmarks, saved, personal-library]
---

# US-055: Bookmark / Save Prompts

## User Story

**As an** enterprise AI lead (P-007),
**I want to** bookmark prompts I find useful,
**So that** I can quickly retrieve them later without relying on browser bookmarks or external notes.

## Acceptance Criteria

- [ ] Given I am authenticated and viewing a prompt, when I click the bookmark icon, then the prompt is added to my saved list and the icon toggles to an active/filled state
- [ ] Given I have bookmarked a prompt, when I click the bookmark icon again, then the prompt is removed from my saved list
- [ ] Given I navigate to "Saved Prompts" in my profile, then I see all bookmarked prompts in reverse-chronological order of when I saved them
- [ ] Given I am not authenticated, when I click the bookmark icon, then I am prompted to log in or create an account

## Notes

Bookmarks are private by default. Consider adding the ability to organize bookmarks into collections (US-056). Bookmark counts can optionally be surfaced as a secondary signal alongside upvotes.
