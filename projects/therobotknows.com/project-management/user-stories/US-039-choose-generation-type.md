---
id: US-039
title: "Choose Generation Type"
slug: "choose-generation-type"
personas: [P-001, P-002, P-004, P-005]
epic: "Generation Engine"
priority: "must-have"
complexity: "M"
tags: [generation, generation-type, backstory, history, in-universe-document, generation-studio]
---

# US-039: Choose Generation Type

## User Story

**As a** game master who needs different kinds of lore output for different purposes (P-002),
**I want to** select a generation type before submitting my prompt — such as backstory, historical account, or in-universe document,
**So that** the AI produces content in the appropriate format and voice for how I intend to use it at the table.

## Acceptance Criteria

- [ ] Given I am in the Generation Studio, when I prepare to generate, then I see a generation type selector with at least: Backstory, Historical Account, In-Universe Document, and Encyclopedia Entry.
- [ ] Given I select "In-Universe Document", when the AI generates, then the output is written as if authored by a character within the world (e.g., a letter, official decree, or journal entry).
- [ ] Given I select "Backstory", when the AI generates, then the output is written in third-person narrative prose describing a character's or location's history.
- [ ] Given I select "Historical Account", when the AI generates, then the output reads like a world history entry — factual, chronological, and encyclopedic.
- [ ] Given any generation type is selected, when generation completes, then the output includes a label indicating which type was used to produce it.

## Notes

Depends on US-036. Generation type affects the system prompt sent to the AI model. New types can be added without schema changes if they are prompt-template-driven. Related: US-040 (tone/voice matching).
