---
id: US-017
title: "Delete Own Posts"
slug: "delete-posts"
personas: [P-001, P-002, P-003, P-005]
epic: "Threads"
priority: "could-have"
complexity: "M"
tags: [threads, deletion, permissions]
---

# US-017: Delete Own Posts

## User Story

**As a** MCP Server Developer (P-005),
**I want to** delete my own posts and replies,
**So that** I can remove accidental posts or content that I no longer want visible.

## Acceptance Criteria

- [ ] Given a post author, when they click "Delete" on their own post, then they are presented with a confirmation dialog listing the number of replies that will be affected
- [ ] Given a post author confirms deletion, when the dialog is accepted, then the post is soft-deleted (marked as deleted, content replaced with "[deleted by author]")
- [ ] Given a post author is deleting a post with replies, when they confirm deletion, then the replies cascade-soft-delete to maintain thread integrity
- [ ] Given a non-author user, when they view someone else's post, then they do not see a "Delete" button
- [ ] Given a space moderator, when they view a deleted post, then they can restore it (moderator action, not covered in this story)

## Notes

Depends on US-011 and US-012 for posts. Soft-delete preserves thread structure and allows recovery. Hard-deletion not supported in MVP. Cascading delete only for replies, not parent threads.