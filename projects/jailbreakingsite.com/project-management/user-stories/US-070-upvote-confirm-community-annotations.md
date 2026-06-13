---
id: US-070
title: "Upvote/Confirm Community Annotations"
slug: "upvote-confirm-community-annotations"
personas: [P-001, P-006, P-004]
epic: "Community & Disclosure"
priority: "could-have"
complexity: "S"
tags: [community, annotations, upvote, confirmation, signal]
---

# US-070: Upvote/Confirm Community Annotations

## User Story

**As an** independent security consultant (P-006),
**I want to** upvote or confirm annotations on catalog entries that match my own observations,
**So that** the most reliable community signals are surfaced prominently and researchers can validate each other's findings.

## Acceptance Criteria

- [ ] Given I am authenticated and viewing an annotation on a catalog entry, when I click the upvote/confirm button, then my vote is recorded and the annotation's vote count increments
- [ ] Given I have already voted on an annotation, when I view it again, then the vote button shows my active vote state and I can click again to retract my vote
- [ ] Given I am the author of an annotation, when I view it, then the upvote button is disabled — self-voting is not permitted
- [ ] Given an annotation accumulates enough votes to cross a "community confirmed" threshold (configurable, default: 5 votes), when that threshold is crossed, then the annotation is visually promoted to a "Community Confirmed" status within the entry's annotation section
- [ ] Given annotations are sorted by votes, when I view the sorted list, then recently added annotations with zero votes appear in a separate "New" section below confirmed/voted annotations so they remain discoverable

## Notes

The upvote mechanism serves as lightweight peer review — it is not formal editorial review but helps surface quality signals organically. "Community Confirmed" status on an annotation is a trust indicator but should never be conflated with the platform's own editorial verification of catalog entries.
