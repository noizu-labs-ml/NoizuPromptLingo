---
id: US-074
title: "Comment on a Wiki Page"
slug: "comment-on-a-wiki-page"
personas: [P-001]
epic: "Social & Collaboration"
priority: "should-have"
complexity: "S"
tags: [wiki, comments, collaboration]
---

# US-074: Comment on a Wiki Page

## User Story

**As a** Harness Operator (Jordan Vance, P-001),
**I want to** leave a comment on a wiki Page,
**So that** I can ask a question or flag something out of date without editing the Page content itself.

## Acceptance Criteria

- [ ] Given an existing wiki Page, when a comment with text content is submitted, then it appears attached to that Page, visible to other project members, with author and timestamp shown.
- [ ] Given an existing comment on a Page, when a reply comment is submitted against it, then the reply is threaded under the original comment rather than appearing as a new top-level comment.
- [ ] Given a comment its author wrote, when the author edits or deletes it, then the Page reflects the updated or removed comment while other comments on the Page are unaffected.

## Notes

Comment model is expected to be reusable by other entities later (tickets, reviews), but this story scopes strictly to wiki Pages.
