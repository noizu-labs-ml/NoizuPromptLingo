---
id: US-076
title: "React to a Wiki Page or Comment"
slug: "react-to-a-wiki-page-or-comment"
personas: [P-001]
epic: "Social & Collaboration"
priority: "could-have"
complexity: "S"
tags: [wiki, reactions, collaboration]
---

# US-076: React to a Wiki Page or Comment

## User Story

**As a** Harness Operator (Jordan Vance, P-001),
**I want to** add a lightweight emoji reaction to a wiki Page or a comment on one,
**So that** I can signal acknowledgment or agreement without writing a full comment.

## Acceptance Criteria

- [ ] Given an existing wiki Page or Page comment, when a reaction (emoji) is added, then it appears with a count and the reacting user is recorded, visible to other project members.
- [ ] Given a Page or comment the user already reacted to with a given emoji, when they trigger that same reaction again, then it toggles off (removes their reaction) rather than double-counting.
- [ ] Given multiple users reacting with different emoji on the same Page, when the Page is viewed, then each distinct emoji shows its own count and none overwrite the others.

## Notes

Same reaction primitive is a natural fit for tickets and reviews later, but this story scopes strictly to wiki Pages and Page comments.
