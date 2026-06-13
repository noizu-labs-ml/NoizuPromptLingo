---
id: US-023
title: "Duplicate and modify an existing mockup"
slug: "duplicate-and-modify-mockup"
personas: [P-001, P-003, P-006]
epic: "Mockup Management"
priority: "should-have"
complexity: "M"
tags: [mockup-management, duplicate, fork, reuse]
---

# US-023: Duplicate and modify an existing mockup

## User Story

**As a** freelance consultant (P-006),
**I want to** duplicate an existing mockup as a starting point for a new variant,
**So that** I can reuse proven layouts for different clients without overwriting the original.

## Acceptance Criteria

- [ ] Given I click "Duplicate" on a mockup, when the action completes, then a new mockup is created with the same artifact, prompt, and parameters, suffixed with " (Copy)" in its name
- [ ] Given the duplicate is created, when I open it, then it has its own independent `mockup_id` and is not linked to the original's version chain (US-024)
- [ ] Given I duplicate a mockup and then edit the duplicate's name or prompt, when changes are saved, then the original mockup is unaffected
- [ ] Given a duplicated mockup, when I invoke `iterate_mockup` (US-008) on it, then the iteration chain starts fresh from the duplicate, not from the original

## Notes

Duplication copies the artifact bytes and metadata but does not copy version history. This differs from iteration (US-008), which creates a linked child in an existing chain. Project assignment of the duplicate defaults to the same project as the original. Related to US-008, US-019, US-024.
