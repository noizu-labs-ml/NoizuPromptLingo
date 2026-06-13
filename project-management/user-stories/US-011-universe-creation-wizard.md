---
id: US-011
title: "Universe Creation Wizard"
slug: "universe-creation-wizard"
personas: [P-002, P-005]
epic: "Universe Management"
priority: "should-have"
complexity: "L"
tags: [universe, onboarding, wizard, guided]
---

# US-011: Universe Creation Wizard

## User Story

**As a** veteran game master (P-002),
**I want to** step through a guided wizard when creating my first universe,
**So that** I configure genre, tone, and starter templates upfront rather than hunting through settings later.

## Acceptance Criteria

- [ ] Given I click "Create Universe" for the first time, when the wizard launches, then it presents four sequential steps: (1) Name & Description, (2) Genre & Tone, (3) Starter Template selection, (4) Confirm & Create.
- [ ] Given I am on Step 3, when I select a starter template (e.g., "Fantasy Homebrew," "Sci-Fi Setting," "Horror World," "Blank"), then the wizard previews which entry types and example entries will be pre-populated.
- [ ] Given I select "Blank" template, when the universe is created, then no example entries are generated and I land on the Canon Editor with an empty entry list.
- [ ] Given I complete all steps and click "Create," when the universe is created, then I am redirected to the Universe Overview and the onboarding tour (US-007) offer is displayed.

## Notes

Wraps US-009 (create universe) with guided UX. Starter templates pre-populate the canon with example entries to illustrate the data model. Related: US-007, US-015 (genre/tone config).
