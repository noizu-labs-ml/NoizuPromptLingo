---
id: US-044
title: "Regenerate with Different Parameters"
slug: "regenerate-with-different-parameters"
personas: [P-001, P-002, P-004, P-005]
epic: "Generation Engine"
priority: "must-have"
complexity: "S"
tags: [generation, regenerate, parameters, iteration, draft]
---

# US-044: Regenerate with Different Parameters

## User Story

**As a** hobbyist worldbuilder who wants to explore multiple creative directions (P-005),
**I want to** regenerate a draft with tweaked parameters — changing the prompt, generation type, or tone — without losing the original result,
**So that** I can iterate toward the best version without starting over from scratch.

## Acceptance Criteria

- [ ] Given a generated draft is displayed, when I click "Regenerate", then a panel allows me to modify the prompt, generation type, tone, or sources before re-submitting.
- [ ] Given I regenerate with new parameters, when the new draft arrives, then both the original and new draft are shown side-by-side or in a tabbed comparison view.
- [ ] Given I am comparing drafts, when I select one as preferred, then the other is discarded and the selected draft becomes the active result.
- [ ] Given I regenerate, when the new generation is submitted, then a new generation history entry is created (see US-045) and the cost is tracked separately (US-048).
- [ ] Given I regenerate without changing any parameters, when the new result arrives, then it may differ due to AI non-determinism — the system does not warn that parameters are unchanged.

## Notes

Depends on US-036. Side-by-side comparison is a strong UX pattern for AI generation tools. The "keep both" option (adding all versions to history without promoting) is a could-have enhancement.
