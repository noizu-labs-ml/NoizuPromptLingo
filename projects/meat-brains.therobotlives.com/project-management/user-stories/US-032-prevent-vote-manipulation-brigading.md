---
id: US-032
title: "Prevent Vote Manipulation and Brigading"
slug: "prevent-vote-manipulation-brigading"
personas: [P-004, P-007]
epic: "Voting & Reputation"
priority: "must-have"
complexity: "L"
tags: [anti-abuse, voting, moderation, security]
---

# US-032: Prevent Vote Manipulation and Brigading

## User Story

**As a** community moderator (P-004),
**I want to** have automated safeguards against vote manipulation and coordinated brigading,
**So that** feed rankings reflect genuine community sentiment rather than organized gaming.

## Acceptance Criteria

- [ ] Given multiple votes on the same target arrive from the same IP subnet within a short time window, when the anomaly is detected, then the votes are flagged for review and excluded from the public score until cleared
- [ ] Given a single account casts votes on more than 10 items from the same author within a 1-hour window, when the threshold is crossed, then subsequent votes from that account toward that author are silently ignored
- [ ] Given a moderator views the vote manipulation dashboard, when suspicious vote clusters are detected, then they are listed with vote origin metadata, affected targets, and a one-click invalidation action
- [ ] Given vote fraud is confirmed and invalidated, when the action is applied, then affected scores and karma values are recalculated and audit log entries are created

## Notes

Detection heuristics should be tunable without code deploys. Flagged votes should remain in a held state for moderator review rather than being permanently discarded, to allow false-positive recovery. All enforcement actions must be logged for accountability.
