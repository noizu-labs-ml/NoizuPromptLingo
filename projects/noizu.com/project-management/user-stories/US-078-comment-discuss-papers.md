---
id: US-078
title: "Comment & Discuss Research Papers (Authenticated)"
slug: "comment-discuss-papers"
personas: [P-008, P-001, P-003]
epic: "Research & Community"
priority: "could-have"
complexity: "L"
tags: [research, comments, discussion, community, authenticated]
---

# US-078: Comment & Discuss Research Papers (Authenticated)

## User Story

**As an** AI ethics researcher / academic (P-008),
**I want to** leave comments and engage in threaded discussion on research papers,
**So that** I can contribute to scholarly discourse and receive responses from the author and peers.

## Acceptance Criteria

- [ ] Given an authenticated user on a paper page, when they scroll to the comments section, then a comment composer is visible
- [ ] Given the comment composer, when the user submits a comment with valid text, then the comment appears in the thread with their name, avatar, and timestamp
- [ ] Given an existing comment, when an authenticated user clicks "Reply," then an inline reply composer opens and their reply is nested under the parent
- [ ] Given an unauthenticated visitor, when they view the comments section, then comments are readable but the composer shows a "Sign in to comment" prompt
- [ ] Given a submitted comment, when the site admin (Keith) responds, then the author reply is visually distinguished with an "Author" badge
- [ ] Given a comment containing a URL or paper reference, then it is rendered as a hyperlink

## Notes

Moderation: all comments require admin approval before display, or flag-based post-publish moderation. Consider a simple approval queue in the admin dashboard (US-033 or similar). Spam prevention via honeypot field and rate limiting. Related to US-081 (newsletter) for engaged readers.
