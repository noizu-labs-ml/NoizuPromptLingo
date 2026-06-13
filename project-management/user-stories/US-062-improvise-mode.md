---
id: US-062
title: "Improvise Mode (Canon-Consistent Generation)"
slug: "improvise-mode"
personas: [P-002]
epic: "Session Companion"
priority: "must-have"
complexity: "L"
tags: [session, generation, ai, improvise, gm, canon-consistent]
---

# US-062: Improvise Mode (Canon-Consistent Generation)

## User Story

**As a** veteran game master (P-002),
**I want to** generate a quick, canon-consistent NPC, location detail, or plot hook on the fly during a session,
**So that** I can improvise confidently when players go off-script without accidentally contradicting my established lore.

## Acceptance Criteria

- [ ] Given I am in the Session Companion, when I activate Improvise Mode and enter a prompt (e.g., "a blacksmith in Thornwall with a secret"), then the system generates a response grounded in existing canon entries for Thornwall and returns it within 5 seconds.
- [ ] Given the generation prompt references a named location, faction, or character, when the AI generates a response, then it retrieves and injects relevant canon entries as context so the output respects established facts (ruler, geography, culture).
- [ ] Given the improvised content is generated, when I review it in the Improvise panel, then I see the canon entries that were used as grounding context, with links to each.
- [ ] Given I am satisfied with the improvised content, when I click "Save to Session Log," then the generated content is appended to the current session log (per US-063) and optionally queued for canon review at session end (per US-068).

## Notes

Depends on US-063 (session log), US-068 (end-of-session canon review). Grounding context retrieval should prefer entries tagged to the active session's universe and scenario. Related: US-061 (quick-reference search).
