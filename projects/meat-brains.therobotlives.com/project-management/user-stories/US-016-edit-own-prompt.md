---
id: US-016
title: "Edit an Existing Prompt"
slug: "edit-own-prompt"
personas: [P-001, P-006]
epic: "Prompt Submission"
priority: "should-have"
complexity: "M"
tags: [prompt, edit, authorship, versioning]
---

# US-016: Edit an Existing Prompt

## User Story

**As a** Prompt Engineer (P-001),
**I want to** edit my published prompt to correct errors or improve it based on community feedback,
**So that** my submission remains accurate and useful as model capabilities evolve.

## Acceptance Criteria

- [ ] Given I am viewing my own published prompt, when I click the "Edit" button (visible only to the author and moderators), then I am taken to the same submission form pre-populated with the current prompt content.
- [ ] Given I am on the edit form, when I make changes and click "Save changes", then the prompt is updated immediately, the edit timestamp is updated, and an "Edited" label appears on the prompt card in the feed.
- [ ] Given I save an edit, when the version history feature is enabled (US-019), then the previous version is automatically snapshotted before the update is applied.
- [ ] Given I am on the edit form, when I click "Cancel", then no changes are saved, I am returned to the prompt detail page, and a confirmation dialog appears only if I have made unsaved changes.
- [ ] Given a moderator (P-004) edits another user's prompt, when the edit is saved, then a notice is added to the prompt indicating it was "Edited by moderator" with a timestamp, visible to the original author.

## Notes

The "Edited" label in AC-2 maintains transparency about post-publication changes, which is critical for community trust. Moderator edit attribution (AC-5) is important for P-004 accountability. Edit permissions are limited to the author and moderators — no other users can modify a prompt.
