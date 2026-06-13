---
id: US-038
title: "Source Citations on Generated Entries"
slug: "source-citations-on-generated-entries"
personas: [P-001, P-003, P-004]
epic: "Generation Engine"
priority: "must-have"
complexity: "M"
tags: [generation, citations, transparency, canon, rag, trust]
---

# US-038: Source Citations on Generated Entries

## User Story

**As a** narrative designer who needs to trust AI-generated content (P-003),
**I want to** see which canon entries the AI used as source material when generating new content,
**So that** I can verify the generation is grounded in approved lore and trace any inconsistencies back to their source.

## Acceptance Criteria

- [ ] Given an AI-generated entry draft is displayed, when I view it, then a "Sources" section lists all canon entries used as context during generation.
- [ ] Given a source citation is listed, when I click on it, then I am taken directly to that canon entry (or it opens in a side panel).
- [ ] Given a generated entry is promoted to canon (see US-046), when it is saved, then the source citations are preserved as metadata on the canon entry.
- [ ] Given a generation was performed with no relevant context retrieved, when I view the draft, then the Sources section reads "No existing canon context used" rather than being empty or hidden.
- [ ] Given I view the Sources section, when I hover over a citation, then a tooltip shows the cited entry's title and a one-sentence excerpt of the relevant passage used.

## Notes

Depends on US-036, US-037. Citations are a key trust and accountability feature — they distinguish TheRobotKnows from a generic AI writing tool. Related: US-044 (edit sources before generating).
