---
id: US-049
title: "Edit and Delete Own Comments"
slug: "edit-and-delete-own-comments"
personas: [P-001, P-002, P-005, P-006]
epic: "Comments & Discussion"
priority: "should-have"
complexity: "M"
tags: [comments, edit, delete, moderation]
---

# US-049: Edit and Delete Own Comments

## User Story

**As a** community member who posted a comment (P-002),
**I want to** edit or delete my own comments,
**So that** I can correct mistakes, update outdated information, or remove content I no longer wish to share.

## Acceptance Criteria

- [ ] Given I am the author of a comment, when I click "Edit," then an inline editor pre-populated with the current comment body opens and I can save or cancel the edit
- [ ] Given I save an edited comment, when the update is persisted, then the comment displays an "(edited)" label with a timestamp of the last edit
- [ ] Given I click "Delete" on my own comment, when I confirm the deletion prompt, then the comment body is replaced with "[deleted]" and my username is replaced with "[deleted]"; the comment slot remains in the thread to preserve reply context
- [ ] Given a moderator views a deleted comment, when they inspect the thread in the mod view, then the original comment body and author are visible for audit purposes

## Notes

Edit history should be stored server-side (last 5 versions minimum) for moderator review. The edit window should not be time-limited for comment authors, but moderators can lock comments from editing. Soft deletion (replacing content rather than removing the row) is required to maintain thread structural integrity.
