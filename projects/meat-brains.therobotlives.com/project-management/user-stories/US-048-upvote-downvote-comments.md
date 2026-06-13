---
id: US-048
title: "Upvote / Downvote Comments"
slug: "upvote-downvote-comments"
personas: [P-001, P-002, P-003, P-005]
epic: "Comments & Discussion"
priority: "should-have"
complexity: "S"
tags: [comments, voting, engagement, quality-control]
---

# US-048: Upvote / Downvote Comments

## User Story

**As a** community member reading a discussion (P-002),
**I want to** upvote or downvote comments just as I can with prompts,
**So that** the most helpful, insightful comments rise to the top of a thread and low-quality or off-topic replies are de-emphasized.

## Acceptance Criteria

- [ ] Given I am logged in and viewing a comment, when I click the upvote button, then the comment's score increments and the button reflects my active state
- [ ] Given comment votes are cast on a thread, when the thread is rendered with "Best" sort selected, then comments are ordered by score descending within each nesting level
- [ ] Given a comment's score drops below −3, when the thread renders, then the comment is visually collapsed with a "score hidden" notice; clicking expands it
- [ ] Given I vote on a comment, when the vote is recorded, then the comment author's comment karma increases or decreases accordingly

## Notes

Comment voting follows the same anti-abuse rules as prompt voting (US-032, US-033). Comment karma should be tracked separately from post karma in the user's karma breakdown. Default comment sort for a thread should be configurable per user (Best, New, or Top).
