---
id: US-017
title: "Delete Own Prompt"
slug: "delete-own-prompt"
personas: [P-001, P-002]
epic: "Prompt Submission"
priority: "should-have"
complexity: "S"
tags: [prompt, delete, authorship, moderation]
---

# US-017: Delete Own Prompt

## User Story

**As an** AI Hobbyist (P-002),
**I want to** delete a prompt I submitted,
**So that** I can remove content I no longer stand behind or that contains errors I cannot fix through editing.

## Acceptance Criteria

- [ ] Given I am viewing my own published prompt, when I click the "Delete" option in the prompt action menu, then a confirmation modal appears listing the consequences (prompt removed from all feeds, votes are lost, forks reference a deleted parent).
- [ ] Given the deletion confirmation modal is open, when I confirm the deletion, then the prompt is soft-deleted (removed from all public views) and I am redirected to my profile page with a success notification.
- [ ] Given a prompt has been soft-deleted, when a user navigates to the prompt's original URL, then they see a "This prompt has been removed by the author" message instead of a 404.
- [ ] Given I have deleted a prompt, when I view my profile submissions tab, then I can see deleted prompts in a separate "Deleted" section (visible only to me) for a 30-day recovery window.
- [ ] Given I am within the 30-day recovery window, when I click "Restore" on a deleted prompt, then the prompt is restored to its last published state and reappears in the feed.

## Notes

Soft-delete with recovery window (AC-3 to AC-5) prevents accidental permanent deletion. After 30 days, prompts are hard-deleted. If forks exist (US-020), they remain as independent posts but show "Forked from: [deleted prompt]". Moderators can also delete prompts, which skips the recovery window.
