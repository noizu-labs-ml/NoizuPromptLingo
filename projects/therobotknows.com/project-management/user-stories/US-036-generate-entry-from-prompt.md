---
id: US-036
title: "Generate Entry from Prompt"
slug: "generate-entry-from-prompt"
personas: [P-001, P-002, P-004, P-005]
epic: "Generation Engine"
priority: "must-have"
complexity: "L"
tags: [generation, ai, prompt, canon, lore, generation-studio]
---

# US-036: Generate Entry from Prompt

## User Story

**As a** hobbyist worldbuilder who wants AI to accelerate her creativity (P-005),
**I want to** write a brief prompt and have the AI generate a full canon entry draft,
**So that** I can rapidly populate my universe with rich lore without writing every word from scratch.

## Acceptance Criteria

- [ ] Given I am in the Generation Studio, when I enter a text prompt (e.g., "A dwarven city built inside a dormant volcano") and select an entry type, then the AI generates a structured draft entry with title, summary, and body.
- [ ] Given the AI generates an entry, when the draft appears, then it is rendered in the same structured format as a manually-created canon entry (with all relevant fields populated where inferable).
- [ ] Given I submit a prompt, when generation begins, then a progress indicator shows the request is in flight and estimated time to completion is displayed.
- [ ] Given generation completes, when I view the draft, then I can edit any field before saving or promoting to canon.
- [ ] Given a generation request fails (API error, timeout), when the failure occurs, then an error message is shown with a retry option and no partial content is saved.

## Notes

Foundational story for the Generation Engine epic. All subsequent generation stories (US-037 through US-050) depend on this. Generation cost tracking (US-048) and history (US-045) should be considered in the data model from the start.
