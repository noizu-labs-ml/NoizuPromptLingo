---
id: US-027
title: "Downvote a Prompt"
slug: "downvote-a-prompt"
personas: [P-001, P-003, P-004]
epic: "Voting & Reputation"
priority: "must-have"
complexity: "S"
tags: [voting, prompts, quality-control]
---

# US-027: Downvote a Prompt

## User Story

**As an** experienced community member (P-001),
**I want to** downvote a prompt that is low quality, misleading, or unhelpful,
**So that** poor-quality content is deprioritized in feeds and the community maintains high standards.

## Acceptance Criteria

- [ ] Given I am logged in and viewing a prompt, when I click the downvote button, then the vote count decrements by 1 and the button reflects my active vote state
- [ ] Given a new account with fewer than 50 karma points, when I attempt to downvote, then the action is blocked and I am informed of the karma requirement
- [ ] Given I downvote a prompt, when the action completes, then the author's karma score decreases by the configured downvote weight
- [ ] Given a prompt reaches a score threshold of −5 or below, when the feed is rendered, then the prompt is collapsed with a "low score" notice visible to users

## Notes

Downvoting is gated behind a minimum karma threshold to prevent abuse from throwaway accounts. The threshold value is configurable by moderators. Authors are not notified of individual downvotes to reduce retaliation risk.
