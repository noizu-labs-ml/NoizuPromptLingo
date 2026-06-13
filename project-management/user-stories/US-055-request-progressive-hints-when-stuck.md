---
id: US-055
title: "Request Progressive Hints When Stuck"
slug: "request-progressive-hints-when-stuck"
personas: [P-008, P-003]
epic: "Academy — Labs"
priority: "should-have"
complexity: "M"
tags: [academy, labs, hints, progressive-disclosure, learning]
---

# US-055: Request Progressive Hints When Stuck

## User Story

**As a** CTF competitor and security student (P-008),
**I want to** request progressively more specific hints when I am stuck on a lab challenge,
**So that** I can get unstuck and continue learning without having the solution handed to me outright.

## Acceptance Criteria

- [ ] Given I am in an active lab session, when I click "Request Hint," then I receive the first (most general) hint tier and my hint usage is logged
- [ ] Given I have already received a hint, when I request another, then I receive the next more specific tier, with a confirmation step warning me I am going deeper
- [ ] Given a lab has N hint tiers (minimum 3), when I exhaust all hints, then the hint button is disabled and replaced with a "View Solution" option that requires explicit confirmation and marks the lab as "completed with solution viewed"
- [ ] Given I use hints, when my score is calculated, then each hint tier used applies a defined point deduction, and the final score reflects hint usage transparently
- [ ] Given I complete a lab without using any hints, when scoring is displayed, then I receive a "No Hints" badge for that completion

## Notes

Hint tiers should follow a nudge → direction → near-answer progression. Hint content is authored per lab at creation time. "Completed with solution viewed" labs should still count toward progress but are excluded from leaderboard rankings.
