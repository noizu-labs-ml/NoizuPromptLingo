---
id: US-028
title: "Undo a Vote"
slug: "undo-a-vote"
personas: [P-001, P-002, P-005]
epic: "Voting & Reputation"
priority: "should-have"
complexity: "S"
tags: [voting, undo, prompts]
---

# US-028: Undo a Vote

## User Story

**As a** community member who voted on a prompt (P-002),
**I want to** undo my upvote or downvote,
**So that** I can correct accidental votes or change my mind after re-reading the content.

## Acceptance Criteria

- [ ] Given I have upvoted a prompt, when I click the upvote button again, then my vote is removed and the score returns to its pre-vote value
- [ ] Given I have downvoted a prompt, when I click the downvote button again, then my vote is removed and the score returns to its pre-vote value
- [ ] Given I undo a vote, when the action completes, then the author's karma adjusts to reflect the removed vote
- [ ] Given a vote is undone, when I view the prompt, then neither the upvote nor downvote button appears in an active state

## Notes

Vote undoing is distinct from vote switching — clicking the opposite button after voting switches the vote rather than removing it. Karma adjustments for undo must be applied atomically to prevent race conditions under concurrent requests.
