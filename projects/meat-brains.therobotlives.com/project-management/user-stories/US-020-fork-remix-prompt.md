---
id: US-020
title: "Fork and Remix Another User's Prompt"
slug: "fork-remix-prompt"
personas: [P-001, P-002, P-005]
epic: "Prompt Submission"
priority: "should-have"
complexity: "M"
tags: [prompt, fork, remix, attribution, community]
---

# US-020: Fork and Remix Another User's Prompt

## User Story

**As an** Indie Developer (P-005),
**I want to** fork an existing prompt and modify it to suit my use case,
**So that** I can build on community knowledge while maintaining proper attribution to the original author.

## Acceptance Criteria

- [ ] Given I am viewing any published prompt (not my own), when I click the "Fork" button, then the submission form opens pre-populated with the prompt's title (prefixed "Fork of: "), body, tags, and model — ready for me to edit.
- [ ] Given I submit a forked prompt, when it is published, then the prompt detail page shows a "Forked from [original title] by [original author]" attribution link below the title.
- [ ] Given I have forked a prompt, when I view the original prompt's detail page, then a "Forks (N)" tab is visible showing all community forks with their vote scores.
- [ ] Given the original prompt is deleted by its author, when I view my fork, then the attribution reads "Forked from: [deleted prompt]" with no broken link.
- [ ] Given I am the original author, when another user forks my prompt, then I receive an in-app notification (and optionally an email, per my notification preferences) that my prompt was forked.

## Notes

Forking is a core community mechanic that rewards high-quality submissions with derivative attention. Attribution is non-optional — the forked-from reference cannot be removed by the forking user. Authors (P-001, P-006) care about fork counts as a reputation signal.
