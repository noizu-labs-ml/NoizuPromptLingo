---
id: US-050
title: "@Mention Other Users in Comments"
slug: "mention-users-in-comments"
personas: [P-001, P-002, P-003, P-005, P-006]
epic: "Comments & Discussion"
priority: "should-have"
complexity: "M"
tags: [comments, mentions, notifications, engagement]
---

# US-050: @Mention Other Users in Comments

## User Story

**As a** community member writing a comment (P-001),
**I want to** @mention other users by username in my comment,
**So that** I can bring relevant people into a conversation and they are notified of my reference.

## Acceptance Criteria

- [ ] Given I am typing a comment and type "@" followed by at least 2 characters, when the autocomplete triggers, then a dropdown of matching usernames is displayed, filtered as I continue typing
- [ ] Given I select a username from the autocomplete, when it is inserted, then the mention is rendered as a styled link to that user's profile within the comment
- [ ] Given a comment containing my @mention is posted, when the notification pipeline processes it, then I receive an in-app notification linking to the comment that mentioned me
- [ ] Given a mentioned user has disabled mention notifications in their settings, when a comment mentioning them is posted, then no notification is sent but the @mention link still renders correctly

## Notes

Autocomplete should query the user search API with a debounce of 200ms to avoid excessive requests. Mentions in edited comments should re-trigger notifications only if new mentions are added (not for re-mentioning the same user). Self-mentions should be silently ignored with no notification sent.
