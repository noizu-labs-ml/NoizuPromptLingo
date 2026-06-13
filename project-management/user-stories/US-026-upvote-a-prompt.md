---
id: US-026
title: "Upvote a Prompt"
slug: "upvote-a-prompt"
personas: [P-001, P-002, P-005, P-008]
epic: "Voting & Reputation"
priority: "must-have"
complexity: "S"
tags: [voting, prompts, engagement]
---

# US-026: Upvote a Prompt

## User Story

**As an** authenticated community member (P-002),
**I want to** upvote a prompt I found useful or well-crafted,
**So that** high-quality prompts rise in visibility and the author receives recognition.

## Acceptance Criteria

- [ ] Given I am logged in and viewing a prompt, when I click the upvote button, then the vote count increments by 1 and the button reflects my active vote state
- [ ] Given I have already upvoted a prompt, when I view that prompt again, then the upvote button is highlighted to indicate my existing vote
- [ ] Given I am not logged in, when I attempt to upvote, then I am prompted to log in or register before the vote is recorded
- [ ] Given I upvote a prompt, when the action completes, then the author's karma score increases by the configured upvote weight

## Notes

Vote state must persist across sessions. The UI should optimistically update the vote count and revert on API failure. Upvote weight is configurable per reputation tier of the voter.
