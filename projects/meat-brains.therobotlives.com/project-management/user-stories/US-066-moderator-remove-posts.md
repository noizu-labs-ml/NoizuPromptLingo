---
id: US-066
title: "Moderator Can Remove Posts"
slug: "moderator-remove-posts"
personas: [P-004]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [moderation, remove, admin, content-management]
---

# US-066: Moderator Can Remove Posts

## User Story

**As a** community moderator (P-004),
**I want to** remove prompts or comments that violate community guidelines,
**So that** harmful or spam content is taken down promptly and the community remains trustworthy.

## Acceptance Criteria

- [ ] Given I have moderator privileges, when I click "Remove" on a prompt or comment (from the mod queue or inline), then I am prompted to select a removal reason
- [ ] Given I confirm removal, when the action is processed, then the content is hidden from public view and the author receives a notification stating their content was removed with the reason
- [ ] Given I remove a prompt, when a community member visits its URL, then they see a "this post has been removed" message rather than a 404
- [ ] Given a moderator removes content, when the action is logged, then the audit log records the content ID, moderator ID, timestamp, and reason

## Notes

Removal should be soft-delete by default to support appeals (US-069). Hard deletion should be reserved for severe violations (e.g., illegal content) and require elevated permissions. Author notifications should be templated and professional in tone.
