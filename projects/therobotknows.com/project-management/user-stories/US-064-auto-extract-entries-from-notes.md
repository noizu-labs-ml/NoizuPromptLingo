---
id: US-064
title: "Auto-Extract Canon Entries from Session Notes"
slug: "auto-extract-entries-from-notes"
personas: [P-002, P-004]
epic: "Session Companion"
priority: "should-have"
complexity: "L"
tags: [session, extraction, ai, canon, automation, npc]
---

# US-064: Auto-Extract Canon Entries from Session Notes

## User Story

**As a** fiction podcaster (P-004),
**I want to** have the system automatically identify potential new canon entries (characters, locations, events) mentioned in my session notes,
**So that** I don't have to manually re-read my notes to find what needs to be added to my knowledge base after each 50-episode recording session.

## Acceptance Criteria

- [ ] Given a session log contains freeform text, when I trigger "Extract Entries" (manually or at session end), then the AI scans the log and returns a structured list of candidate entries with a suggested type (character, location, event, concept) and extracted name for each.
- [ ] Given the extraction returns candidates, when I review the list, then each candidate shows the source sentence(s) from the session log that prompted the suggestion, and I can approve, edit, or dismiss each one individually.
- [ ] Given I approve a candidate entry, when I confirm, then a draft entry is created in the Canon Editor pre-populated with the extracted name, type, and any attributes the AI inferred from context (e.g., faction affiliation mentioned in text).
- [ ] Given an extracted candidate matches an existing entry by name, when the candidate is displayed, then it is flagged as "possible duplicate of [existing entry]" with a link to the existing entry rather than being auto-approved.

## Notes

Depends on US-063 (session log), US-068 (end-of-session canon review). Extraction should err toward over-suggestion — users dismiss false positives more easily than they catch missed entries. Related: US-053 (duplicate name detection).
