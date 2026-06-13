---
id: US-014
title: "Vote on Posts"
slug: "vote-posts"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Threads"
priority: "should-have"
complexity: "S"
tags: [threads, voting, reputation]
---

# US-014: Vote on Posts

## User Story

**As a** Curious Lurker (P-004),
**I want to** upvote helpful posts and downvote low-quality content,
**So that** valuable contributions are highlighted and the community self-moderates.

## Acceptance Criteria

- [ ] Given any authenticated user, when they view a post and click the upvote button, then their vote is recorded and the post's vote count increments
- [ ] Given an authenticated user has already upvoted a post, when they click the downvote button, then their upvote is replaced with a downvote
- [ ] Given an authenticated user has already upvoted a post, when they click the upvote button again, then their vote is removed and the count decrements
- [ ] Given an unauthenticated user, when they attempt to vote on a post, then they receive a prompt to log in first
- [ ] Given a post's vote count is calculated, when displayed, then it shows the net score (upvotes minus downvotes) with separate counters visible on click

## Notes

Depends on US-011 and US-012 for posts. Users cannot vote on their own posts. Vote history is private; only the net score is public. Downvoting requires 5+ karma (reputation).