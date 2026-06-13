---
id: US-047
title: "Threaded / Nested Reply Chains"
slug: "threaded-nested-reply-chains"
personas: [P-001, P-002, P-003, P-005]
epic: "Comments & Discussion"
priority: "must-have"
complexity: "L"
tags: [comments, threading, replies, discussion]
---

# US-047: Threaded / Nested Reply Chains

## User Story

**As a** community member following a discussion (P-001),
**I want to** reply directly to a specific comment and see conversations nested visually,
**So that** I can follow multi-party sub-discussions without losing track of context.

## Acceptance Criteria

- [ ] Given I am viewing a comment, when I click "Reply," then a reply compose box opens inline beneath that comment and my submission is nested under it in the thread
- [ ] Given a comment thread has nested replies, when the page renders, then replies are visually indented to indicate hierarchy, with connecting lines or indentation guides
- [ ] Given a thread exceeds 3 levels of nesting, when additional levels are rendered, then they are displayed at maximum indentation (no further visual nesting) but the reply chain context is preserved
- [ ] Given a parent comment is collapsed, when I collapse it, then all nested replies are hidden; expanding it restores the full subtree

## Notes

Maximum nesting depth of 8 levels is recommended to prevent extreme visual indentation. Threads with more than 50 top-level comments should support "load more" pagination. Comment tree traversal must be efficient — avoid N+1 queries by fetching the full subtree in a single CTE query.
