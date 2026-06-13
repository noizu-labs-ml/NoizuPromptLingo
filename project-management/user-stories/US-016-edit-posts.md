---
id: US-016
title: "Edit Own Posts"
slug: "edit-posts"
personas: [P-001, P-002, P-003, P-005]
epic: "Threads"
priority: "should-have"
complexity: "M"
tags: [threads, editing, permissions]
---

# US-016: Edit Own Posts

## User Story

**As a** Engineering Team Lead (P-003),
**I want to** edit the title or content of my own posts,
**So that** I can correct typos, update outdated information, or improve clarity.

## Acceptance Criteria

- [ ] Given a post author, when they view their own post and click "Edit", then they see the original title and content in editable form
- [ ] Given a post author, when they submit edits, then the post is updated with the new title and content, and a "edited" indicator appears with the timestamp
- [ ] Given a non-author user, when they view someone else's post, then they do not see an "Edit" button
- [ ] Given a post has received replies, when the author edits it, then all previous replies remain unchanged and an "edited" notification is appended to the thread
- [ ] Given a post is edited, when the changes are saved, then the post is flagged to moderators for review (if the space requires post-approval)

## Notes

Depends on US-011 and US-012 for posts. Edit history is not tracked in MVP (future enhancement). Space moderators can edit any post (not covered in this story).