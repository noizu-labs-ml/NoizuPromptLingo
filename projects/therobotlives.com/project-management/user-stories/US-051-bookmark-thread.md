---
id: US-051
title: "Bookmark a Thread"
slug: "bookmark-thread"
personas: [P-001, P-004]
epic: "Bookmarking & Collections"
priority: "should-have"
complexity: "S"
tags: [bookmarking, threads, discovery]
---

# US-051: Bookmark a Thread

## User Story

**As a** Prompt Engineer Power User (P-001) or Curious Lurker (P-004),
**I want to** bookmark threads that interest me,
**So that** I can quickly return to valuable discussions without searching or losing track.

## Acceptance Criteria

- [ ] Given a thread exists, when I click the bookmark icon, then the thread is added to my bookmarks
- [ ] Given a thread is already bookmarked, when I click the bookmark icon, then the bookmark is removed (toggle behavior)
- [ ] Given a bookmark is added, when I navigate to my bookmarks, then the bookmarked thread appears in the list with title author, timestamp, and space name
- [ ] Given a bookmarked thread is deleted by its author, when I view my bookmarks, then the bookmark shows [deleted] indicator or gracefully handles the missing content
- [ ] Given I have bookmarked 50+ threads, when I view bookmarks, then the list supports pagination and search filtering

## Notes

Bookmarks are private by default—only the user can see their bookmarks. Must handle edge case where bookmarked content is deleted or made private after bookmarking.