---
id: US-050
title: "Style Guide and Voice Configuration"
slug: "style-guide-voice-configuration"
personas: [P-001, P-003, P-004, P-008]
epic: "Generation Engine"
priority: "won't-have-yet"
complexity: "L"
tags: [generation, style-guide, voice, configuration, settings, tone]
---

# US-050: Style Guide and Voice Configuration

## User Story

**As a** narrative designer establishing a consistent narrative voice across a three-writer team (P-003),
**I want to** create and manage a structured style guide for my universe that defines vocabulary, tone, prohibited words, and example passages,
**So that** all AI-generated content — and all collaborator contributions — adhere to the same voice standard.

## Acceptance Criteria

- [ ] Given I am in Universe Settings under the Generation tab, when I open the Style Guide editor, then I can define: a tone descriptor (e.g., "grim, archaic, poetic"), a vocabulary list (preferred and prohibited words/phrases), up to three example passages as voice references, and narrative perspective (first/second/third person).
- [ ] Given a structured style guide is saved, when a generation request is submitted, then the AI is instructed using the full style guide (not just a raw sample) to produce output matching the defined voice.
- [ ] Given the style guide includes prohibited words, when a generated entry is returned, then a post-processing check flags any prohibited terms and highlights them for review.
- [ ] Given collaborators have view access to a universe, when they navigate to the Style Guide, then they can read it (but not edit unless they have editor permissions).
- [ ] Given the style guide is updated, when future generations occur, then the new style guide version is used — and generation history (US-045) records which style guide version was active for each generation.

## Notes

Depends on US-036, US-040, US-045. This is a more structured, team-oriented evolution of the simpler tone/voice matching in US-040. Won't-have-yet because it requires richer settings UI and versioning infrastructure. The style guide versioning requirement (for audit trails) is what elevates the complexity. Related: US-040, US-045.
